#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
APP_NAME=""
HOSTED=0
UNBLOCK=0
INJECTION_ARGUMENTS=()
CORE_ARGUMENTS=()
CORE_MODE=""
PORT=""
CORE_HOST="localhost"
CORE_HOST_SPECIFIED=0

usage() {
    cat >&2 <<'EOF'
Usage:
  ./test.sh --app:simple [--unblock]
  ./test.sh --app:fct [--hosted] [--unblock]
  ./test.sh --app:rvmt [--unblock]
  ./test.sh --app:tui
  ./test.sh --app:core [/FCT|/RPT|/RVMT] [/Cli:<command>] [--remoteDT] [--remoteLocale] [--remoteFS] [--fakeClipboard] [--denyClipboard] [--unblock]
  ./test.sh --app:renderer [--corehost:<host>] [--port:<1-65535>] [--remoteDT] [--remoteLocale] [--remoteFS] [--denyClipboard] [--unblock]
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
        --app:tui)
            APP_NAME="tui"
            ;;
        --app:rvmt)
            APP_NAME="rvmt"
            ;;
        --app:core)
            APP_NAME="core"
            ;;
        /FCT|/RPT|/RVMT)
            if [[ -n "$CORE_MODE" ]]; then echo "Choose one Core application." >&2; exit 1; fi
            CORE_MODE="$argument"
            ;;
        /Cli:*)
            CORE_ARGUMENTS+=("$argument")
            ;;
        --fakeClipboard)
            CORE_ARGUMENTS+=(/fakeClipboard)
            ;;
        --app:renderer)
            APP_NAME="renderer"
            ;;
        --hosted)
            HOSTED=1
            ;;
        --remoteDT|--remoteLocale|--remoteFS|--denyClipboard)
            INJECTION_ARGUMENTS+=("/${argument#--}")
            ;;
        --unblock)
            UNBLOCK=1
            ;;
        --corehost:*)
            if [[ "$CORE_HOST_SPECIFIED" -eq 1 || -z "${argument#--corehost:}" ]]; then
                echo "--corehost requires one nonempty destination host." >&2
                exit 1
            fi
            CORE_HOST="${argument#--corehost:}"
            CORE_HOST_SPECIFIED=1
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
    tui)
        if [[ "$HOSTED" -eq 1 || "$UNBLOCK" -eq 1 ]]; then
            echo "--app:tui requires foreground terminal input; --hosted and --unblock are not supported." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/MacTuiControlTest/bin/Test_TuiControlTest"
        ;;
    rvmt)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/MacCppTestRvm/bin/Test_CppTest_Rvm.app/Contents/MacOS/Test_CppTest_Rvm"
        ;;
    core)
        if [[ "$HOSTED" -eq 1 ]]; then
            echo "--hosted is only supported by --app:fct." >&2
            exit 1
        fi
        APP="$SCRIPT_DIR/build/RemotingTest_Core/bin/RemotingTest_Core"
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

if [[ "$APP_NAME" != "core" && ( -n "$CORE_MODE" || ${#CORE_ARGUMENTS[@]} -gt 0 ) ]]; then
    echo "Core application, /Cli and --fakeClipboard options require --app:core." >&2
    exit 1
fi

if [[ "${#INJECTION_ARGUMENTS[@]}" -gt 0 && "$APP_NAME" != "renderer" && "$APP_NAME" != "core" ]]; then
    echo "Remote injection options require --app:core or --app:renderer." >&2
    exit 1
fi

if [[ "$CORE_HOST_SPECIFIED" -eq 1 && "$APP_NAME" != "renderer" ]]; then
    echo "--corehost is only supported by --app:renderer." >&2
    exit 1
fi

if [[ -n "$PORT" && "$APP_NAME" != "renderer" ]]; then
    echo "--port is only supported by --app:renderer." >&2
    exit 1
fi

if [[ ! -x "$APP" ]]; then
    echo "Test application not found. Run ./build.sh first: $APP" >&2
    exit 1
fi

arguments=()
case "$APP_NAME" in
    core)
        arguments=(/MiniHttp "${CORE_MODE:-/FCT}")
        if (( ${#CORE_ARGUMENTS[@]} )); then arguments+=("${CORE_ARGUMENTS[@]}"); fi
        ;;
    renderer)
        arguments=(/MiniHttp "/corehost:$CORE_HOST")
        if [[ -n "$PORT" ]]; then arguments+=("/port:$PORT"); fi
        ;;
    rvmt) arguments=(/MiniHttp) ;;
    fct) if [[ "$HOSTED" -eq 1 ]]; then arguments=(--hosted); fi ;;
esac
if (( ${#INJECTION_ARGUMENTS[@]} )); then arguments+=("${INJECTION_ARGUMENTS[@]}"); fi

# The conditional expansion also supports empty arrays in macOS Bash 3.2 with nounset.
if [[ "$UNBLOCK" -eq 1 ]]; then
    "$APP" ${arguments[@]+"${arguments[@]}"} &
    echo $!
else
    exec "$APP" ${arguments[@]+"${arguments[@]}"}
fi
