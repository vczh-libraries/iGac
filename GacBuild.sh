#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GACUI_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../GacUI" && pwd)"
WORKFLOW_DIR="$(CDPATH= cd -- "$SCRIPT_DIR/../Workflow" && pwd)"
GACBUILD="$GACUI_DIR/Tools/GacBuild/Bin/GacBuild"
GACGEN="$GACUI_DIR/Tools/GacGen/Bin/GacGen"
CPPMERGE="$WORKFLOW_DIR/Tools/CppMerge/Bin/CppMerge"

# Usage: GacBuild.sh [-mode:GacBuild|-mode:GacGen] -FileName <xml> [options]
# Default to the driver-XML interface shared with the released GacBuild.sh.
MODE=GacBuild
if [[ "${1:-}" == -mode:* ]]; then
    MODE="${1#-mode:}"
    shift
fi

for executable in "$GACBUILD" "$GACGEN" "$CPPMERGE"; do
    if [[ ! -f "$executable" || ! -x "$executable" ]]; then
        echo "Required executable not found or not executable: $executable. Run syncProj.sh to build the tools." >&2
        exit 1
    fi
done

for architecture in 32 64; do
    metadata="$GACUI_DIR/Test/Resources/Metadata/Reflection${architecture}.bin"
    if [[ ! -f "$metadata" ]]; then
        echo "Required reflection metadata not found: $metadata" >&2
        exit 1
    fi
done

# Full metadata includes generated dialog types absent from GacGen's usual
# core-only metadata. Do not resolve this symlink: its invocation path selects
# the adjacent Metadata.txt. Keep the caller's working directory unchanged.
TOOL_DIR="$(mktemp -d "$SCRIPT_DIR/.GacBuild.XXXXXX")"
trap 'rm -rf -- "$TOOL_DIR"' EXIT
ln -s "$GACGEN" "$TOOL_DIR/GacGen"
printf '%s\n%s\n%s\n' \
    "../../GacUI/Test/Resources/Metadata" \
    "Reflection32.bin" \
    "Reflection64.bin" \
    > "$TOOL_DIR/Metadata.txt"

# Do not exec: the EXIT trap removes the temporary metadata entry point.
"$GACBUILD" "-mode:$MODE" \
    "-pathGacGen:$TOOL_DIR/GacGen" \
    "-pathCppMerge:$CPPMERGE" \
    "$@"
