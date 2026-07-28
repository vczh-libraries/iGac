#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
WORKFLOW_DIR="$SCRIPT_DIR/../Workflow"
GACUI_DIR="$SCRIPT_DIR/../GacUI"
WORKFLOW_BUILD="$WORKFLOW_DIR/.github/Ubuntu/build.sh"
GACUI_BUILD="$GACUI_DIR/.github/Ubuntu/build.sh"
GACGEN="$GACUI_DIR/Tools/GacGen/Bin/GacGen"
METADATA_DIR="$GACUI_DIR/Test/Resources/Metadata"
MINI_HTTP_AUTOMATION_SOURCE="$GACUI_DIR/Test/GacUISrc/RemotingTest_Core/Shared.cpp"
REMOTE_RENDERER_SOURCE="$GACUI_DIR/Test/GacUISrc/RemotingTest_Rendering_Win32/GuiMain.cpp"
TOOL_DIR=""

cleanup() {
    if [[ -n "$TOOL_DIR" && "$TOOL_DIR" == "$SCRIPT_DIR"/.syncProj.* ]]; then
        rm -rf "$TOOL_DIR"
    fi
}
trap cleanup EXIT

require_file() {
    if [[ ! -f "$1" ]]; then
        echo "Required file not found: $1" >&2
        exit 1
    fi
}

require_directory() {
    if [[ ! -d "$1" ]]; then
        echo "Required directory not found: $1" >&2
        exit 1
    fi
}

configure_resource() {
    local resource_file="$1"
    local generated_name="$2"

    perl -0pi -e '
        s#<Text name="SourceFolder">Source</Text>#<Text name="SourceFolder">../Source</Text>#;
        s#\s*<Text name="Resource">[^<]*</Text>##;
        s#<Text name="Name">[^<]*</Text>#<Text name="Name">'"$generated_name"'</Text>\n      <Text name="CppResource">'"$generated_name"'Resource.cpp</Text>#;
    ' "$resource_file"

    if ! grep -q '<Text name="SourceFolder">../Source</Text>' "$resource_file"; then
        echo "Failed to configure generated source folder in $resource_file" >&2
        exit 1
    fi

    if ! grep -q "<Text name=\"CppResource\">${generated_name}Resource.cpp</Text>" "$resource_file"; then
        echo "Failed to configure embedded resource source in $resource_file" >&2
        exit 1
    fi
}

sync_application() {
    local app_name="$1"
    local generated_name="$2"
    local source_resources="$GACUI_DIR/Test/Resources/App/$app_name"
    local app_dir="$SCRIPT_DIR/Apps/$app_name"
    local resource_dir="$app_dir/Resources"
    local source_dir="$app_dir/Source"
    local resource_file="$resource_dir/Resource.xml"
    local generated_entry="$source_dir/${generated_name}.h"
    local generated_resource="$source_dir/${generated_name}Resource.cpp"
    local gacgen_log="$TOOL_DIR/${app_name}.log"
    local error_file="$resource_file.log/x64/Errors.txt"

    echo "Preparing $app_name..." >&2
    require_directory "$source_resources"

    rm -rf "$resource_dir" "$source_dir"
    mkdir -p "$resource_dir" "$source_dir"
    cp -R "$source_resources/." "$resource_dir/"
    require_file "$resource_file"
    configure_resource "$resource_file" "$generated_name"

    if ! "$TOOL_DIR/GacGen" /C64 "$resource_file" >"$gacgen_log" 2>&1; then
        cat "$gacgen_log" >&2
        echo "GacGen failed for $app_name." >&2
        exit 1
    fi

    if [[ -f "$error_file" ]]; then
        cat "$error_file" >&2
        echo "GacGen reported resource errors for $app_name." >&2
        exit 1
    fi

    require_file "$generated_entry"
    require_file "$generated_resource"
    rm -rf "$resource_file.log"

    echo "Synchronized $app_name resources and generated x64 C++ sources."
}

require_file "$WORKFLOW_BUILD"
require_file "$GACUI_BUILD"
require_file "$METADATA_DIR/Reflection32.bin"
require_file "$METADATA_DIR/Reflection64.bin"
require_file "$MINI_HTTP_AUTOMATION_SOURCE"
require_file "$REMOTE_RENDERER_SOURCE"
if ! command -v perl >/dev/null 2>&1; then
    echo "Perl is required to configure copied GacGen resource files." >&2
    exit 1
fi

echo "Building Workflow CppMerge incrementally..."
(
    cd "$WORKFLOW_DIR/Tools/CppMerge"
    "$WORKFLOW_BUILD"
)

echo "Building GacUI GacGen incrementally..."
(
    cd "$GACUI_DIR/Tools/GacGen"
    "$GACUI_BUILD"
)
require_file "$GACGEN"

cp "$MINI_HTTP_AUTOMATION_SOURCE" "$SCRIPT_DIR/MacShared/MiniHttpAutomationService.cpp"
cp "$REMOTE_RENDERER_SOURCE" "$SCRIPT_DIR/RemotingTest_Renderer_macOS/GuiMain.cpp"
echo "Synchronized MiniHTTP automation and macOS native remote renderer sources."

# GacGen normally uses the core-only metadata beside its executable. Full
# Control Test also references types from GacUI's generated dialog support, so
# run it through a temporary entry point configured to use the full metadata.
TOOL_DIR="$(mktemp -d "$SCRIPT_DIR/.syncProj.XXXXXX")"
ln -s "$GACGEN" "$TOOL_DIR/GacGen"
printf '%s\n%s\n%s\n' \
    "../../GacUI/Test/Resources/Metadata" \
    "Reflection32.bin" \
    "Reflection64.bin" \
    > "$TOOL_DIR/Metadata.txt"

sync_application "FullControlTest" "FullControlTest"
sync_application "RemoteProtocolTest" "RemoteProtocolTest"
