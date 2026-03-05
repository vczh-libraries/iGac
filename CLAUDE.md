# CLAUDE.md — Instructions for AI Coding Agents

## Before You Start

**You MUST read these files before doing any work:**

1. **[readme.md](readme.md)** — Project structure, build commands, script descriptions.
2. **[doc/OSProvider.md](doc/OSProvider.md)** — Controller, services, entry point, overall architecture.
3. **[doc/OSProvider_Window.md](doc/OSProvider_Window.md)** — INativeWindow (CocoaWindow): window lifecycle, popup management, coordinate systems, differences from Windows.
4. **[doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md)** — CoreGraphics rendering: render targets, element renderers, text layout, font management.

Read them thoroughly. Most macOS porting bugs come from behavioral differences between Win32 and Cocoa that are documented there.

## Key Facts

- This is the **macOS port** of GacUI. The GacUI framework source code lives in `Release/Import/` and must NOT be modified — it is a git submodule.
- All macOS-specific code is under `Mac/`. Shared test utilities are in `MacShared/`.
- Build with `./build.sh` (incremental) or `./build.sh --rebuild` (clean).
- Test with `./testFC.sh` (full control test) or `./test.sh` (hello world).
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

## Files You Should Never Modify

- Anything under `Release/` — this is a git submodule containing the upstream GacUI release.
- `build/` — generated build artifacts.
