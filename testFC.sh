#!/bin/bash

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

APP="$SCRIPT_DIR/build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest"

if [[ "$1" == "--hosted" ]]; then
    "$APP" --hosted
elif [[ "$1" == "--unblock" ]]; then
    "$APP" &
    echo $!
else
    "$APP"
fi
