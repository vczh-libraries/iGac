#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Source directories
SOURCE_DIR="$SCRIPT_DIR/Release/Tutorial/GacUI_ControlTemplate/BlackSkin/UI/FullControlTest/Source"
UIRES_DIR="$SCRIPT_DIR/Release/Tutorial/GacUI_ControlTemplate/UIRes"

# Destination directories
DEST_SOURCE_DIR="$SCRIPT_DIR/MacFullControlTest/UI/FullControlTest/Source"
DEST_UIRES_DIR="$SCRIPT_DIR/MacFullControlTest/UI/FullControlTest/UIRes"

# Create destination directories
mkdir -p "$DEST_SOURCE_DIR"
mkdir -p "$DEST_UIRES_DIR"

# Copy source files (excluding DemoReflection.h and DemoReflection.cpp)
for f in "$SOURCE_DIR"/*; do
    filename=$(basename "$f")
    if [[ "$filename" != "DemoReflection.h" && "$filename" != "DemoReflection.cpp" ]]; then
        cp "$f" "$DEST_SOURCE_DIR/"
        echo "Copied $filename"
    fi
done

# Copy BlackSkin.bin
cp "$UIRES_DIR/BlackSkin.bin" "$DEST_UIRES_DIR/"
echo "Copied BlackSkin.bin"
