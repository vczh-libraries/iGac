#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

cd "$SCRIPT_DIR"

# Clean everything
git clean -xdf

# Create build folder and build
mkdir -p build
cd build
cmake ..
make
