#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

if [[ "$1" == "--rebuild" ]]; then
    # Clean everything
    git clean -xdf
fi

# Copy required source files for MacFullControlTest
./testFC_Update.sh

# Create build folder and build
mkdir -p build
cd build
cmake ..
make
