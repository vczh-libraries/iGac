#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GACUI_DIR="$SCRIPT_DIR/../GacUI"
SOURCE_IMPORT_DIR="$GACUI_DIR/Import"
SOURCE_RELEASE_DIR="$GACUI_DIR/Release"
DEST_DIR="$SCRIPT_DIR/Import"

if [[ ! -d "$SOURCE_IMPORT_DIR" ]]; then
    echo "GacUI dependency imports not found: $SOURCE_IMPORT_DIR" >&2
    exit 1
fi

if [[ ! -d "$SOURCE_RELEASE_DIR" ]]; then
    echo "GacUI release sources not found: $SOURCE_RELEASE_DIR" >&2
    exit 1
fi

if [[ -e "$DEST_DIR" ]]; then
    chmod -R u+w "$DEST_DIR"
fi

rm -rf "$DEST_DIR"
mkdir -p "$DEST_DIR/Skins/DarkSkin"

cp -R "$SOURCE_IMPORT_DIR/." "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/GacUI*.h "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/GacUI*.cpp "$DEST_DIR/"
cp "$SOURCE_RELEASE_DIR"/DarkSkin*.h "$DEST_DIR/Skins/DarkSkin/"
cp "$SOURCE_RELEASE_DIR"/DarkSkin*.cpp "$DEST_DIR/Skins/DarkSkin/"

chmod -R a-w "$DEST_DIR"

echo "Imported GacUI dependencies and release sources from $GACUI_DIR to $DEST_DIR"
