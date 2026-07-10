#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SOURCE_DIR="$SCRIPT_DIR/../Release/Import"
DEST_DIR="$SCRIPT_DIR/Import"

if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "GacUI Import source not found: $SOURCE_DIR" >&2
    exit 1
fi

if [[ -e "$DEST_DIR" ]]; then
    chmod -R u+w "$DEST_DIR"
fi

rm -rf "$DEST_DIR"
cp -R "$SOURCE_DIR" "$DEST_DIR"
chmod -R a-w "$DEST_DIR"

echo "Imported $SOURCE_DIR to $DEST_DIR"
