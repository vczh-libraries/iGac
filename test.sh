#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME=""
HOSTED=0
UNBLOCK=0

usage() {
    cat >&2 <<'EOF'
Usage:
  ./test.sh --app:simple [--unblock]
  ./test.sh --app:fct [--hosted] [--unblock]
  ./test.sh --app:renderer [--unblock]
EOF
}

for argument in "$@"; do
    case "$argument" in
        --app:simple)
            APP_NAME="simple"
            ;;
        --app:fct)
            APP_NAME="fct"
            ;;
        --app:renderer)
            APP_NAME="renderer"
            ;;
        --hosted)
            HOSTED=1
            ;;
        --unblock)
            UNBLOCK=1
            ;;
        *)
            echo "Unknown argument: $argument" >&2
            usage
            exit 1
            ;;
    esac
done

case "$APP_NAME" in
    simple)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/MacTest/bin/Test_HellWorld_Cpp.app/Contents/MacOS/Test_HellWorld_Cpp"
        ;;
    fct)
        APP="$SCRIPT_DIR/build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest"
        ;;
    renderer)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/RemotingTest_Renderer_macOS/bin/RemotingTest_Renderer_macOS.app/Contents/MacOS/RemotingTest_Renderer_macOS"
        ;;
    *)
        usage
        exit 1
        ;;
esac

if [[ ! -x "$APP" ]]; then
    echo "Test application not found. Run ./build.sh first: $APP" >&2
    exit 1
fi

if [[ "$UNBLOCK" -eq 1 ]]; then
    if [[ "$HOSTED" -eq 1 ]]; then
        "$APP" --hosted &
    elif [[ "$APP_NAME" == "renderer" ]]; then
        "$APP" /MiniHttp &
    else
        "$APP" &
    fi
    echo $!
else
    if [[ "$HOSTED" -eq 1 ]]; then
        exec "$APP" --hosted
    elif [[ "$APP_NAME" == "renderer" ]]; then
        exec "$APP" /MiniHttp
    else
        exec "$APP"
    fi
fi
