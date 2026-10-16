#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GACUI_DIR="$SCRIPT_DIR/../GacUI"
SOURCE_IMPORT_DIR="$GACUI_DIR/Import"
SOURCE_RELEASE_DIR="$GACUI_DIR/Release"
DEST_DIR="$SCRIPT_DIR/Import"
DEST_TEST_DIR="$SCRIPT_DIR/Import-Test"

if [[ ! -d "$SOURCE_IMPORT_DIR" ]]; then
    echo "GacUI dependency imports not found: $SOURCE_IMPORT_DIR" >&2
    exit 1
fi

if [[ ! -d "$SOURCE_RELEASE_DIR" ]]; then
    echo "GacUI release sources not found: $SOURCE_RELEASE_DIR" >&2
    exit 1
fi

if ! command -v perl >/dev/null 2>&1; then
    echo "Perl is required to normalize imported source line endings." >&2
    exit 1
fi

for dest_dir in "$DEST_DIR" "$DEST_TEST_DIR"; do
    if [[ -e "$dest_dir" ]]; then
        chmod -R u+w "$dest_dir"
    fi
done

rm -rf "$DEST_DIR" "$DEST_TEST_DIR"
mkdir -p "$DEST_DIR/Skins/DarkSkin" "$DEST_DIR/Skins/TuiSkin"
mkdir -p "$DEST_TEST_DIR"

cp -R "$SOURCE_IMPORT_DIR/." "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/GacUI*.h "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/GacUI*.cpp "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/DarkSkin*.h "$DEST_DIR/Skins/DarkSkin/"
cp "$SOURCE_RELEASE_DIR"/DarkSkin*.cpp "$DEST_DIR/Skins/DarkSkin/"
cp "$SOURCE_RELEASE_DIR"/TuiSkin*.h "$DEST_DIR/Skins/TuiSkin/"
cp "$SOURCE_RELEASE_DIR"/TuiSkin*.cpp "$DEST_DIR/Skins/TuiSkin/"
cp "$SOURCE_RELEASE_DIR/Test.RemotingHelpers.h" "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR/Test.RemotingHelpers.cpp" "$DEST_DIR/"

mv "$DEST_DIR/Test.RemotingHelpers.h" "$DEST_TEST_DIR/"
mv "$DEST_DIR/Test.RemotingHelpers.cpp" "$DEST_TEST_DIR/"

chmod -R u+w "$DEST_DIR" "$DEST_TEST_DIR"

# Keep the existing snapshot's line endings independent of CodePack and Git
# checkout conversion. Most files use LF; these older artifacts use CRLF.
find "$DEST_DIR" "$DEST_TEST_DIR" -type f -exec perl -pi -e 's/\r\n/\n/g' {} +
perl -pi -e 's/\r?\n/\r\n/g' \
    "$DEST_DIR"/GacUI.UnitTest*.h \
    "$DEST_DIR"/GacUI.UnitTest*.cpp \
    "$DEST_DIR/Skins/DarkSkin/DarkSkinReflection.h" \
    "$DEST_DIR/Skins/TuiSkin/TuiSkinReflection.h" \
    "$DEST_DIR/VlppOS.Linux.h" \
    "$DEST_DIR/VlppWorkflowRuntime.h" \
    "$DEST_DIR/VlppWorkflowRuntime.cpp"

echo "Imported GacUI dependencies and release sources from $GACUI_DIR to $DEST_DIR and $DEST_TEST_DIR"
