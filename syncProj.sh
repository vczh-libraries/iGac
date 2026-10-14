#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
WORKFLOW_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../Workflow" && pwd)"
GACUI_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../GacUI" && pwd)"
WORKFLOW_BUILD="$WORKFLOW_DIR/.github/Ubuntu/build.sh"
GACUI_BUILD="$GACUI_DIR/.github/Ubuntu/build.sh"
GACBUILD="$SCRIPT_DIR/GacBuild.sh"
REMOTE_RENDERER_SOURCE="$GACUI_DIR/Test/GacUISrc/RemotingTest_Rendering_Win32/GuiMain.cpp"
RVM_GUI_MAIN_SOURCE="$GACUI_DIR/Test/GacUISrc/CppTest_Rvm/GuiMain.cpp"
SHARED_ARGUMENTS_SOURCE="$GACUI_DIR/Test/GacUISrc/SharedArguments.h"
RVM_INITIALIZER_DIR="$GACUI_DIR/Test/GacUISrc/Generated_RemoteViewModelTest"
FCT_PALETTE_DIR="$GACUI_DIR/Test/GacUISrc/Generated_FullControlTest"
TUI_GUI_MAIN_SOURCE="$GACUI_DIR/Test/GacUISrc/CppTest_Tui/Main.cpp"

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

    if [[ "$generated_name" == "TuiControlTest" ]]; then
        perl -0pi -e 's#<Text name="NormalInclude">GacUI.h</Text>#<Text name="NormalInclude">GacUI.h;Skins/TuiSkin/TuiSkin.h</Text>#' "$resource_file"
    elif [[ "$generated_name" == "FullControlTest" ]]; then
        perl -0pi -e 's#<Text name="NormalInclude">GacUI.h</Text>#<Text name="NormalInclude">GacUI.h;Skins/DarkSkin/DarkSkin.h</Text>#' "$resource_file"
    fi

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
    local gacbuild_log="$resource_dir/GacBuild.log"

    echo "Preparing $app_name..." >&2
    require_directory "$source_resources"

    rm -rf "$resource_dir" "$source_dir"
    mkdir -p "$resource_dir" "$source_dir"
    cp -R "$source_resources/." "$resource_dir/"
    if [[ -d "$resource_dir/Source" ]]; then
        cp -R "$resource_dir/Source/." "$source_dir/"
    fi
    rm -rf "$resource_dir/Source"
    require_file "$resource_file"
    configure_resource "$resource_file" "$generated_name"

    if ! "$GACBUILD" -mode:GacGen \
        -FileName "$resource_file" >"$gacbuild_log" 2>&1; then
        cat "$gacbuild_log" >&2
        echo "GacBuild failed for $app_name. See $gacbuild_log and $resource_file.log." >&2
        exit 1
    fi

    require_file "$generated_entry"
    require_file "$generated_resource"
    if [[ "$app_name" == "RemoteViewModelTest" ]]; then
        require_file "$source_dir/RemoteViewModelTestRpc.h"
        require_file "$source_dir/RemoteViewModelTestRpc.cpp"
    fi

    echo "Synchronized $app_name resources and merged x32/x64 C++ sources."
}

require_file "$WORKFLOW_BUILD"
require_file "$GACUI_BUILD"
require_file "$GACBUILD"
require_file "$REMOTE_RENDERER_SOURCE"
require_file "$RVM_GUI_MAIN_SOURCE"
require_file "$SHARED_ARGUMENTS_SOURCE"
require_file "$TUI_GUI_MAIN_SOURCE"
require_file "$RVM_INITIALIZER_DIR/RemoteViewModelTestInitialize.h"
require_file "$RVM_INITIALIZER_DIR/RemoteViewModelTestInitialize.cpp"
require_file "$FCT_PALETTE_DIR/FullControlTestPalette.h"
require_file "$FCT_PALETTE_DIR/FullControlTestPalette.cpp"
require_directory "$SCRIPT_DIR/RemotingTest_Rendering_macOS"
require_directory "$SCRIPT_DIR/MacCppTestRvm"
require_directory "$SCRIPT_DIR/MacTuiControlTest"
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

echo "Building GacUI GacBuild incrementally..."
(
    cd "$GACUI_DIR/Tools/GacBuild"
    "$GACUI_BUILD"
)

sync_application "TuiControlTest" "TuiControlTest"
sync_application "FullControlTest" "FullControlTest"
sync_application "RemoteProtocolTest" "RemoteProtocolTest"
sync_application "RemoteViewModelTest" "RemoteViewModelTest"

cp "$FCT_PALETTE_DIR/FullControlTestPalette.h" "$SCRIPT_DIR/Apps/FullControlTest/Source/"
cp "$FCT_PALETTE_DIR/FullControlTestPalette.cpp" "$SCRIPT_DIR/Apps/FullControlTest/Source/"
cp "$TUI_GUI_MAIN_SOURCE" "$SCRIPT_DIR/MacTuiControlTest/GuiMain.cpp"

cp "$REMOTE_RENDERER_SOURCE" "$SCRIPT_DIR/RemotingTest_Rendering_macOS/GuiMain.cpp"
cp "$RVM_GUI_MAIN_SOURCE" "$SCRIPT_DIR/MacCppTestRvm/GuiMain.cpp"
cp "$SHARED_ARGUMENTS_SOURCE" "$SCRIPT_DIR/SharedArguments.h"
cp "$RVM_INITIALIZER_DIR/RemoteViewModelTestInitialize.h" "$SCRIPT_DIR/Apps/RemoteViewModelTest/Source/"
cp "$RVM_INITIALIZER_DIR/RemoteViewModelTestInitialize.cpp" "$SCRIPT_DIR/Apps/RemoteViewModelTest/Source/"
echo "Synchronized shared renderer and remote view-model entry points."
