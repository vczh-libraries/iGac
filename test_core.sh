#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GACUI_ROOT="$(cd "$SCRIPT_DIR/../GacUI" && pwd)"
CORE_PROJECT="$GACUI_ROOT/Test/Linux/RemotingTest_Core"
HOST_PROJECT="$GACUI_ROOT/Test/Linux/RemotingTest_RvmHost"
CORE_EXE="$CORE_PROJECT/Bin/RemotingTest_Core"
HOST_EXE="$HOST_PROJECT/Bin/RemotingTest_RvmHost"
LOCAL_RVM="$SCRIPT_DIR/build/MacCppTestRvm/bin/Test_CppTest_Rvm.app/Contents/MacOS/Test_CppTest_Rvm"

APP_NAME=""
PROTOCOL=""
CLI=0
UNBLOCK=0

usage() {
    cat >&2 <<'EOF'
Usage:
  ./test_core.sh --app:cpptest_rvm --protocol:minihttp [--unblock]
  ./test_core.sh --app:fct --protocol:minihttp [--unblock]
  ./test_core.sh --app:rpt --protocol:minihttp [--unblock]
  ./test_core.sh --app:rvmt --protocol:minihttp [--cli] [--unblock]
EOF
}

for argument in "$@"; do
    case "$argument" in
        --app:cpptest_rvm)
            APP_NAME="cpptest_rvm"
            ;;
        --app:fct)
            APP_NAME="fct"
            ;;
        --app:rpt)
            APP_NAME="rpt"
            ;;
        --app:rvmt)
            APP_NAME="rvmt"
            ;;
        --protocol:minihttp)
            PROTOCOL="minihttp"
            ;;
        --cli)
            CLI=1
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

if [[ -z "$APP_NAME" || -z "$PROTOCOL" ]]; then
    usage
    exit 1
fi
if [[ "$CLI" -eq 1 && "$APP_NAME" != "rvmt" ]]; then
    echo "--cli is only supported by --app:rvmt on portable platforms." >&2
    exit 1
fi

build_gacui_project() {
    (
        cd "$1"
        ../../../.github/Ubuntu/build.sh
    )
}

if [[ "$APP_NAME" == "cpptest_rvm" ]]; then
    if [[ ! -x "$LOCAL_RVM" ]]; then
        echo "Test application not found. Run ./build.sh first: $LOCAL_RVM" >&2
        exit 1
    fi
    PRIMARY="$LOCAL_RVM"
    PRIMARY_ARGUMENTS=(/MiniHttp)
    NEEDS_MANUAL_HOST=1
else
    if [[ "$CLI" -eq 1 ]]; then
        build_gacui_project "$HOST_PROJECT"
    fi
    build_gacui_project "$CORE_PROJECT"
    if [[ ! -x "$CORE_EXE" ]]; then
        echo "GacUI Core build did not produce: $CORE_EXE" >&2
        exit 1
    fi

    PRIMARY="$CORE_EXE"
    case "$APP_NAME" in
        fct) PRIMARY_ARGUMENTS=(/MiniHttp /FCT) ;;
        rpt) PRIMARY_ARGUMENTS=(/MiniHttp /RPT) ;;
        rvmt) PRIMARY_ARGUMENTS=(/MiniHttp /RVMT) ;;
    esac

    if [[ "$CLI" -eq 1 ]]; then
        if [[ ! -x "$HOST_EXE" ]]; then
            echo "GacUI RVM host build did not produce: $HOST_EXE" >&2
            exit 1
        fi
        HOST_EXE="$(cd "$(dirname "$HOST_EXE")" && pwd)/$(basename "$HOST_EXE")"
        PRIMARY_ARGUMENTS+=("/Cli:$HOST_EXE")
        NEEDS_MANUAL_HOST=0
    elif [[ "$APP_NAME" == "rvmt" ]]; then
        NEEDS_MANUAL_HOST=1
    else
        NEEDS_MANUAL_HOST=0
    fi
fi

if [[ "$NEEDS_MANUAL_HOST" -eq 0 ]]; then
    if [[ "$UNBLOCK" -eq 1 ]]; then
        "$PRIMARY" "${PRIMARY_ARGUMENTS[@]}" &
        echo $!
    else
        exec "$PRIMARY" "${PRIMARY_ARGUMENTS[@]}"
    fi
    exit 0
fi

"$PRIMARY" "${PRIMARY_ARGUMENTS[@]}" &
PRIMARY_PID=$!
HOST_PID=""

cleanup_manual_run() {
    if [[ -n "$HOST_PID" ]]; then
        kill "$HOST_PID" 2>/dev/null || true
        wait "$HOST_PID" 2>/dev/null || true
    fi
    if [[ -n "$PRIMARY_PID" ]]; then
        kill "$PRIMARY_PID" 2>/dev/null || true
        wait "$PRIMARY_PID" 2>/dev/null || true
    fi
}

trap cleanup_manual_run EXIT
trap 'exit 130' INT TERM
sleep 1
build_gacui_project "$HOST_PROJECT"
if [[ ! -x "$HOST_EXE" ]]; then
    echo "GacUI RVM host build did not produce: $HOST_EXE" >&2
    exit 1
fi
"$HOST_EXE" /MiniHttp &
HOST_PID=$!

if [[ "$UNBLOCK" -eq 1 ]]; then
    trap - EXIT INT TERM
    echo "$PRIMARY_PID"
    echo "$HOST_PID"
else
    if wait "$PRIMARY_PID"; then
        PRIMARY_RESULT=0
    else
        PRIMARY_RESULT=$?
    fi
    PRIMARY_PID=""
    kill "$HOST_PID" 2>/dev/null || true
    wait "$HOST_PID" 2>/dev/null || true
    HOST_PID=""
    trap - EXIT INT TERM
    exit "$PRIMARY_RESULT"
fi
