# Debugging macOS Test Apps with LLDB

Use Xcode's command-line LLDB directly. No MCP server is required.

Run LLDB from the repository root in a PTY-backed terminal. Keep the PTY session open, send commands one round at a time, and wait for LLDB output before sending the next command. When debugging, launch the application executable directly instead of invoking `test.sh`.

## Verify LLDB and Build

```bash
xcrun --find lldb
lldb --version
./build.sh
```

## Application Paths

```text
build/MacTest/bin/Test_HellWorld_Cpp.app/Contents/MacOS/Test_HellWorld_Cpp
build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest
```

## Launching

Hello World:

```bash
lldb -- ./build/MacTest/bin/Test_HellWorld_Cpp.app/Contents/MacOS/Test_HellWorld_Cpp
```

Full Control Test:

```bash
lldb -- ./build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest
```

Full Control Test in hosted mode:

```bash
lldb -- ./build/MacFullControlTest/bin/Test_FullControlTest.app/Contents/MacOS/Test_FullControlTest --hosted
```

The `--` separates LLDB options from the executable and its arguments.

## Startup Validation

At the LLDB prompt, stop on both C++ and Objective-C exceptions before running the target:

```text
breakpoint set -E c++
breakpoint set -E objc
run
```

Exception breakpoints can initially be pending and resolve as runtime libraries load. They stop at every throw, including exceptions that application code intentionally catches. Inspect the backtrace before deciding whether a stop is a failure.

The Full Control Test has a generated binding fallback that attempts to unbox an empty data-grid cell and catches the resulting C++ exception to select a default enum value. After confirming that backtrace, disable only the C++ exception breakpoint and continue:

```text
breakpoint disable <c++-breakpoint-number>
continue
```

A successful startup means the application reaches its event loop and remains running without an unhandled exception or crash. Keep the Objective-C exception breakpoint enabled.

If LLDB stops unexpectedly, inspect the stop before continuing:

```text
process status
thread backtrace all
frame variable
```

## Interrupting and Killing the Application

While the target is running, LLDB's synchronous console does not process ordinary text commands. Send raw Ctrl-C (`\u0003` in a tool-driven PTY) and wait for the LLDB prompt. A normal manual interruption typically reports `stop reason = signal SIGSTOP`.

Then kill the debuggee and exit LLDB:

```text
process kill
quit
```

Do not depend on Cocoa expression calls such as `[NSApp terminate:nil]`. They can re-enter application code or hang. Always ensure both the target and debugger have exited.

From another terminal, find and force-clean stale test/debugger processes when necessary:

```bash
pgrep -fl 'Test_FullControlTest|Test_HellWorld|lldb'
pkill -f 'Test_FullControlTest|Test_HellWorld|lldb'
```

## Useful Commands

```text
breakpoint set --name FunctionName
breakpoint set --file CocoaWindow.mm --line 123
breakpoint list
breakpoint delete <number>
continue
next
step
finish
thread backtrace
thread backtrace all
frame select <number>
frame variable
expression -- <expression>
process status
```

## Application Event Loop and Normal Shutdown

`CocoaController::Run()` shows the main window and runs `while (RunOneCycle())`. Each cycle waits for one Cocoa event, dispatches it, updates windows, and executes pending asynchronous work.

For an ordinary user close, `CocoaWindowDelegate::windowShouldClose:` calls `CocoaWindow::Hide(true)`. Hiding the main window schedules `DestroyNativeWindow()`, which clears the controller's `mainWindow` pointer and posts an application-defined event to wake a blocked cycle. `RunOneCycle()` then returns `false` and the loop exits.

Debugger validation deliberately uses `process kill` after inspecting startup because it is deterministic and does not exercise or depend on the application's close path.
