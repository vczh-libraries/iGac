#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME=""
HOSTED=0
UNBLOCK=0
PORT=""

usage() {
    cat >&2 <<'EOF'
Usage:
  ./test.sh --app:simple [--unblock]
  ./test.sh --app:fct [--hosted] [--unblock]
  ./test.sh --app:rvmt [--unblock]
  ./test.sh --app:renderer [--port:<1-65535>] [--unblock]
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
        --app:rvmt)
            APP_NAME="rvmt"
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
        --port:*)
            PORT="${argument#--port:}"
            if [[ ! "$PORT" =~ ^[0-9]+$ || "${#PORT}" -gt 5 ]] || ((10#$PORT < 1 || 10#$PORT > 65535)); then
                echo "Invalid port: $PORT" >&2
                usage
                exit 1
            fi
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
    rvmt)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/MacCppTestRvm/bin/Test_CppTest_Rvm.app/Contents/MacOS/Test_CppTest_Rvm"
        ;;
    renderer)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/RemotingTest_Rendering_macOS/bin/RemotingTest_Rendering_macOS.app/Contents/MacOS/RemotingTest_Rendering_macOS"
        ;;
    *)
        usage
        exit 1
        ;;
esac

if [[ -n "$PORT" && "$APP_NAME" != "renderer" ]]; then
    echo "--port is only supported by --app:renderer." >&2
    exit 1
fi

if [[ ! -x "$APP" ]]; then
    echo "Test application not found. Run ./build.sh first: $APP" >&2
    exit 1
fi

if [[ "$UNBLOCK" -eq 1 ]]; then
    if [[ "$HOSTED" -eq 1 ]]; then
        "$APP" --hosted &
    elif [[ "$APP_NAME" == "renderer" ]]; then
        RENDERER_ARGUMENTS=(/MiniHttp)
        if [[ -n "$PORT" ]]; then
            RENDERER_ARGUMENTS+=("/port:$PORT")
        fi
        "$APP" "${RENDERER_ARGUMENTS[@]}" &
    elif [[ "$APP_NAME" == "rvmt" ]]; then
        "$APP" /MiniHttp &
    else
        "$APP" &
    fi
    echo $!
else
    if [[ "$HOSTED" -eq 1 ]]; then
        exec "$APP" --hosted
    elif [[ "$APP_NAME" == "renderer" ]]; then
        RENDERER_ARGUMENTS=(/MiniHttp)
        if [[ -n "$PORT" ]]; then
            RENDERER_ARGUMENTS+=("/port:$PORT")
        fi
        exec "$APP" "${RENDERER_ARGUMENTS[@]}"
    elif [[ "$APP_NAME" == "rvmt" ]]; then
        exec "$APP" /MiniHttp
    else
        exec "$APP"
    fi
fi
