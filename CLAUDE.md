# CLAUDE.md — Instructions for AI Coding Agents

## Before You Start

**You MUST read these files before doing any work:**

1. **[readme.md](readme.md)** — Project structure, build commands, script descriptions.
2. **[doc/OSProvider.md](doc/OSProvider.md)** — Controller, services, entry point, overall architecture.
3. **[doc/OSProvider_Window.md](doc/OSProvider_Window.md)** — INativeWindow (CocoaWindow): window lifecycle, popup management, coordinate systems, differences from Windows.
4. **[doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md)** — CoreGraphics rendering: render targets, element renderers, text layout, font management.

Read them thoroughly. Most macOS porting bugs come from behavioral differences between Win32 and Cocoa that are documented there.

**Debugging reference:**

6. **[doc/lldb.md](doc/lldb.md)** — LLDB MCP server setup, debugging workflow, graceful app termination, and known MCP limitations.

**Critical reference — GacUI Knowledge Base:**

5. **[Release/.github/KnowledgeBase/Index.md](Release/.github/KnowledgeBase/Index.md)** — The master index for all GacUI framework knowledge: preferred data types, API guidance for every library (Vlpp, VlppOS, VlppRegex, VlppReflection, GacUI, Workflow), and design explanations covering platform initialization, window management, element rendering, layout, focus, and more. **You MUST consult the relevant Knowledge Base articles before implementing or modifying any feature that touches GacUI framework interfaces.** Key design docs include:
   - `KB_GacUI_Design_PlatformInitialization.md` — Entry points, hosted/raw/standard modes, renderer setup, service registration.
   - `KB_GacUI_Design_MainWindowModalWindow.md` — Modal windows, hosted mode considerations, event loop architecture.
   - `KB_GacUI_Design_ImplementingIGuiGraphicsElement.md` — Element lifecycle, renderer registration, render target abstraction.
   - `KB_GacUI_Design_LayoutAndGuiGraphicsComposition.md` — Layout system, composition hierarchy, invalidation chain.

## Key Facts

- This is the **macOS port** of GacUI. The GacUI framework source code lives in `Release/Import/` and must NOT be modified — it is a git submodule.
- All macOS-specific code is under `Mac/`. Shared test utilities are in `MacShared/`.
- Build with `./build.sh` (incremental) or `./build.sh --rebuild` (clean).
- Test with `./testFC.sh` (full control test), `./testFC.sh --hosted` (hosted mode), or `./test.sh` (hello world).
- The code compiles with `VCZH_DEBUG_NO_REFLECTION`.

## When You Make Changes

**You MUST update the documentation if your changes affect anything documented:**

- If you modify window behavior (Show, Hide, SetBounds, SetParent, popups, focus, etc.) → update [doc/OSProvider_Window.md](doc/OSProvider_Window.md).
- If you modify rendering, element renderers, text layout, or font management → update [doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md).
- If you modify the controller, services, or entry point → update [doc/OSProvider.md](doc/OSProvider.md).
- If you add/remove/rename files, directories, scripts, or CMake targets → update [readme.md](readme.md).
- If you add new documentation files → add them to the Documentation section in [readme.md](readme.md).
- If you change build steps or script behavior → update [readme.md](readme.md).

Documentation must stay in sync with the code. If you fix a bug or implement a feature, check whether the relevant doc section needs updating.

## Architecture Notes

- `Release/Import/GacUI.h` defines the platform abstraction interfaces (`INativeController`, `INativeWindow`, `INativeWindowListener`, etc.). Read the interface comments to understand the contract before implementing.
- `Release/Import/GacUI.Windows.cpp` is the Windows implementation. When the macOS behavior is unclear, check how Windows does it — the macOS port should match Windows semantics.
- The render loop only runs when `INativeWindow::IsVisible()` returns true. Never add extra conditions to `IsVisible()` that would prevent 0×0 windows from being "visible" — popup windows start at 0×0 and rely on the render loop to compute their size.
- `SetBounds()` must not call `Show()`. On Windows, `MoveWindow`/`SetWindowPos` repositions without showing. GacUI calls `Show()`/`ShowDeactivated()` explicitly.
- macOS Cocoa uses bottom-left origin coordinates. All coordinate conversions go through `FlipY()`/`FlipRect()` in `CocoaHelper`.
- `NSWindowStyleMaskBorderless = 0`. Bitwise XOR/AND operations on style masks do not work as expected with this value. Use explicit flag-based reconstruction (see `UpdateStyleMask()`).

## Testing Rules

- After launching a test app (via `./testFC.sh`, `./test.sh`, or directly), you **MUST** ensure the process is killed or properly exited when done. Never leave test processes running.
- When LLDB or a test app is no longer needed, just kill the processes directly — do not rely on `lldb_terminate` or graceful shutdown, as those may hang or be unavailable.
- Use `--unblock` to launch in background and get the PID for later cleanup.
- Use the following to find and kill test/debugger processes:

```bash
# Find all running test processes
pgrep -fl 'Test_FullControlTest|Test_HellWorld|lldb'

# Kill all test and debugger processes
pkill -f 'Test_FullControlTest|Test_HellWorld|lldb'
```

## Files You Should Never Modify

- Anything under `Release/` — this is a git submodule containing the upstream GacUI release.
- `build/` — generated build artifacts.
