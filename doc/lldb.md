# LLDB MCP Server — Debugging via Model Context Protocol

This document describes how to set up and use the **LLDB MCP server** ([dbgmcp](https://github.com/ramenhost/dbgmcp)) for debugging GacUI macOS apps from within VS Code Copilot or other MCP-compatible AI agents.

## Overview

The MCP server wraps LLDB's command-line interface, exposing 5 tools over the [Model Context Protocol](https://spec.modelcontextprotocol.io/) (JSON-RPC over stdio):

| Tool | Description |
|------|-------------|
| `lldb_start` | Start a new LLDB debugging session |
| `lldb_load` | Load a program into an existing session |
| `lldb_command` | Execute any LLDB command |
| `lldb_wait` | Wait for the debuggee to stop (breakpoint, signal, etc.) |
| `lldb_terminate` | Terminate the LLDB session |

## Installation

The binary must be built from source (no pre-built macOS binary is provided).

### Prerequisites

- **Rust** toolchain: `brew install rust`

### Build

```bash
git clone https://github.com/ramenhost/dbgmcp.git /tmp/dbgmcp
cd /tmp/dbgmcp
cargo build --release
cp target/release/lldb-mcp ~/.local/bin/lldb-mcp
```

The installed binary is at `~/.local/bin/lldb-mcp`.

### VS Code MCP Configuration

The file `.vscode/mcp.json` in this repo configures the MCP server for VS Code:

```json
{
  "inputs": [],
  "servers": {
    "lldb": {
      "type": "stdio",
      "command": "/Users/vczh/.local/bin/lldb-mcp",
      "args": []
    }
  }
}
```

After creating/editing this file, reload VS Code (`Cmd+Shift+P` → "Reload Window"). The MCP server should appear in the Copilot tools panel. You may need to enable `chat.mcp.enabled` in VS Code settings.

## Usage — Typical Debugging Session

### Basic Workflow (via MCP tools)

```
1. lldb_start                    → session_id = "lldb-0"
2. lldb_load(session_id, program) → loads the executable
3. lldb_command("breakpoint set --name FunctionName")
4. lldb_command("run")           → launches the app
5. lldb_wait(timeout=30)         → waits for breakpoint hit
6. lldb_command("bt")            → print backtrace
7. lldb_command("frame variable") → inspect variables
8. lldb_command("continue")      → resume
9. lldb_terminate(session_id)    → end session
```

### Paths for Test Binaries

```
# MacFullControlTest (standard mode):
build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest

# MacTest (Hello World):
build/MacTest/bin/Test_HellWorld_Cpp.app/Contents/MacOS/Test_HellWorld_Cpp
```

## Graceful App Termination

GacUI Cocoa apps run `[NSApp run]` which enters an infinite event loop. The app exits only when the main window is closed (which calls `[NSApp stop:nil]` in the `windowWillClose:` delegate).

### Method 1: `[NSApp terminate:nil]` (Recommended for LLDB)

From LLDB, interrupt the process and call:

```
(lldb) expression -l objc -- (void)[NSApp terminate:nil]
```

This causes the process to exit immediately with status 0. It bypasses GacUI's window close callbacks but provides a clean OS-level exit.

**Verified**: Process exits with `status = 0 (0x00000000)`. LLDB may show warning messages ("execution stopped with unexpected state") because the process exits during expression evaluation — these are harmless.

### Method 2: Close the Main Window

```
(lldb) expression -l objc -- (void)[(id)[NSApp mainWindow] close]
```

This triggers the normal shutdown path: `windowWillClose:` → `InvokeClosed()` → `[NSApp stop:nil]`. After evaluating, you must `continue` for the close event to propagate.

### Method 3: External Signal

From another terminal:

```bash
kill -TERM <pid>    # Sends SIGTERM (not handled by the app — falls through to default termination)
kill -KILL <pid>    # Force kill (last resort)
```

### How It Works (Windows vs macOS)

| Aspect | Windows | macOS |
|--------|---------|-------|
| Run loop | `GetMessage` loop | `[NSApp run]` |
| Stop mechanism | `PostQuitMessage(0)` | `[NSApp stop:nil]` + dummy event |
| Close trigger | `PostMessage(WM_CLOSE)` | `[nsWindow close]` |
| External termination | `SendMessage(WM_CLOSE)` | `[NSApp terminate:nil]` or `kill -TERM` |

## MCP Limitations

### Cannot Interrupt a Running Process

The MCP's `lldb_command` writes text to LLDB's stdin. When the debuggee is freely running (no breakpoint hit), LLDB is in **synchronous mode** and only accepts **Ctrl-C** (`\x03` byte) to interrupt — it does **not** process text commands like `process interrupt`.

The MCP cannot send raw control characters, so it cannot interrupt a running process.

**Workarounds**:

1. **Use breakpoints**: Set a breakpoint before `run`. When the breakpoint hits, evaluate expressions, inspect state, then `continue`.

2. **External interrupt**: From another terminal, send `kill -STOP <pid>` to pause the process. LLDB will regain control and you can use `lldb_command` to inspect/close.

3. **Use `lldb_terminate`**: This sends `quit` to LLDB. Since dbgmcp spawns LLDB with `kill_on_drop(true)`, the debuggee is killed when LLDB exits. This is a **force kill**, not graceful.

### Prompt Echo Detection Bug

The MCP's `execute_command` waits for the `(lldb)` prompt to detect command completion. However, LLDB echoes commands as `(lldb) run`, `(lldb) continue`, etc. The MCP sometimes matches these echoes as prompts, causing `execute_command` to return before the command has actually completed. This can desynchronize the session.

### `lldb_wait` Pattern Matching

`lldb_wait` reads output until it sees "stop reason" (text match) or times out. If the stop output was already consumed by a previous `lldb_command` call, `lldb_wait` will time out even though the process is stopped.

## Recommended Debugging Workflow

Given the MCP limitations, the most reliable workflow is:

```
1. lldb_start
2. lldb_load(program)
3. lldb_command("breakpoint set --name SomeFunction")
4. lldb_command("run")
5. lldb_wait(timeout=30)          — wait for breakpoint
6. [inspect: bt, frame variable, expression, etc.]
7. lldb_command("continue")       — or set more breakpoints
8. lldb_terminate                  — kills the session + debuggee
```

For **graceful termination** at a breakpoint:

```
6. lldb_command("expression -l objc -- (void)[NSApp terminate:nil]")
   — process exits immediately with status 0
7. lldb_terminate
```

## Technical Details

- **Project**: [dbgmcp](https://github.com/ramenhost/dbgmcp) by ramenhost (MIT license)
- **Language**: Rust, using `rmcp` MCP SDK v0.1.5
- **Protocol**: JSON-RPC over stdio, MCP protocol version 2024-11-05
- **LLDB flags**: `--no-use-colors --source-quietly`, prompt set to `(lldb)`
- **Binary**: `~/.local/bin/lldb-mcp` (arm64, ~2 MB)
