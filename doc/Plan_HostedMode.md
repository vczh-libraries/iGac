# Plan: macOS Hosted Mode — IMPLEMENTED

This document describes the plan for implementing hosted mode on macOS. All steps have been implemented and the project builds successfully. In hosted mode, the entire GacUI application runs inside a **single native NSWindow** — all GacUI sub-windows, dialogs, menus, and popups are rendered as graphics within that one window rather than creating additional native windows.

## Background

### What Is Hosted Mode?

In standard mode, each GacUI window maps to a separate `NSWindow` (via `CocoaWindow`). In hosted mode, only **one** `NSWindow` exists. All other GacUI windows are "virtual" — they are `GuiHostedWindow` instances managed by `GuiHostedController`, which virtualizes `INativeWindowService` and routes input, focus, and rendering to the correct virtual window.

### Why Hosted Mode?

- **Embedding**: GacUI can be embedded inside another application's window (e.g., a game engine editor, a plugin host).
- **Remote rendering**: Hosted mode is a prerequisite for the remote protocol — the remote renderer operates in forced hosted mode.
- **Consistency**: All popups, menus, and dialogs stay within the host window boundary.

### How Windows Does It

The Windows implementation (in `GacUI.Windows.cpp`) provides only the entry points:
- `SetupHostedWindowsDirect2DRenderer()` / `SetupHostedWindowsGDIRenderer()` — these wrap the native controller with `GuiHostedController` and the resource manager with `GuiHostedGraphicsResourceManager`.

Everything else is platform-independent — `GuiHostedController`, `GuiHostedGraphicsResourceManager`, the three `IGuiHostedWindowProxy` implementations, and `GuiHostedWindow` all live in `GacUI.cpp`. They operate through `INativeController` and `INativeWindow` interfaces, meaning they work with any platform backend (including `CocoaWindow`) without modification.

### What's Already Platform-Independent (Reusable)

All of these live in `Release/Import/GacUI.cpp` and `GacUI.h` — they are **not** platform-specific:
- `GuiHostedController` — complete window virtualization, input routing, focus management, hover tracking
- `GuiHostedGraphicsResourceManager` — render target redirection (all virtual windows → one native render target)
- `GuiHostedWindow` — virtual `INativeWindow` implementation
- `GuiHostedWindowData` — virtual window property storage
- `hosted_window_manager::WindowManager` — z-order, visibility, hit testing, activation
- `IGuiHostedApplication` — host window access interface
- `GuiGraphicsRenderTarget` base class — already handles `StartHostedRendering`/`StopHostedRendering` lifecycle (calls `StartRenderingOnNativeWindow` once, then allows multiple `StartRendering`/`StopRendering` cycles)
- `IGuiHostedWindowProxy` and its three implementations (`GuiMainHostedWindowProxy`, `GuiNonMainHostedWindowProxy`, `GuiPlaceholderHostedWindowProxy`) — these operate entirely through the `INativeWindow` interface, so they work with `CocoaWindow` out of the box. The factory functions `CreateMainHostedWindowProxy()`, `CreateNonMainHostedWindowProxy()`, and `CreatePlaceholderHostedWindowProxy()` are called by `GuiHostedController` internally.

## What Needs to Be Done

### Step 1: Fix CoreGraphicsRenderTarget to Use Base Class Rendering Chain

**Prerequisite for all other steps.**

**Problem**: The current `CoreGraphicsRenderTarget` (in `GuiGraphicsCoreGraphics.mm`) overrides `StartRendering()` and `StopRendering()` directly, bypassing the `GuiGraphicsRenderTarget` base class. The base class methods `StartRenderingOnNativeWindow()` and `StopRenderingOnNativeWindow()` are implemented as `CHECK_FAIL` (crash). This means the hosted rendering lifecycle — where `StartHostedRendering()` calls `StartRenderingOnNativeWindow()` once, then `StartRendering()`/`StopRendering()` run multiple times without touching the native window — cannot work.

**Fix**: Refactor `CoreGraphicsRenderTarget` to implement `StartRenderingOnNativeWindow()` and `StopRenderingOnNativeWindow()` with the real CGContext setup/teardown logic, and **remove** the direct overrides of `StartRendering()` and `StopRendering()`. The base class `GuiGraphicsRenderTarget` will then correctly:
- In standard mode: `StartRendering()` → `StartRenderingOnNativeWindow()` → ... → `StopRendering()` → `StopRenderingOnNativeWindow()`
- In hosted mode: `StartHostedRendering()` → `StartRenderingOnNativeWindow()` once, then multiple `StartRendering()`/`StopRendering()` cycles (which skip `StartRenderingOnNativeWindow`/`StopRenderingOnNativeWindow`), then `StopHostedRendering()` → `StopRenderingOnNativeWindow()`

The rendering setup code currently in `StartRendering()` (getting CGContext, saving graphics state, setting up flipped/scaled coordinate system, filling black background) must move to `StartRenderingOnNativeWindow()`. The teardown code in `StopRendering()` must move to `StopRenderingOnNativeWindow()`. The `StartRendering()`/`StopRendering()` overrides should be removed entirely so the base class handles them.

Note: The `SetCurrentRenderTarget(this)` / `SetCurrentRenderTarget(0)` calls and the per-frame black fill should happen in `StartRenderingOnNativeWindow()` / `StopRenderingOnNativeWindow()` since they are once-per-frame operations.

### Step 2: New Entry Point — SetupOSXHostedCoreGraphicsRenderer

Create a new entry point function in `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm`:

```cpp
int SetupOSXHostedCoreGraphicsRenderer()
{
    StartOSXNativeController();
    auto nativeController = GetOSXNativeController();

    auto hostedController = new GuiHostedController(nativeController);
    SetNativeController(hostedController);
    SetHostedApplication(hostedController->GetHostedApplication());

    {
        CoreGraphicsMain(hostedController);
    }

    SetNativeController(nullptr);
    delete hostedController;
    StopOSXNativeController();
    return 0;
}
```

### Step 3: Update CoreGraphicsMain to Accept Optional GuiHostedController

Modify `CoreGraphicsMain()` (in `GuiGraphicsCoreGraphics.mm`) to accept an optional `GuiHostedController*` parameter:

```cpp
void CoreGraphicsMain(GuiHostedController* hostedController = nullptr)
{
    g_cocoaListener = new CoreGraphicsCocoaNativeControllerListener();
    GetCurrentController()->CallbackService()->InstallListener(g_cocoaListener);

    CoreGraphicsResourceManager resourceManager;
    SetCoreGraphicsResourceManager(&resourceManager);
    GetCurrentController()->CallbackService()->InstallListener(&resourceManager);

    // Wrap resource manager for hosted mode
    auto hostedResourceManager = hostedController
        ? new GuiHostedGraphicsResourceManager(hostedController, &resourceManager)
        : nullptr;
    SetGuiGraphicsResourceManager(
        hostedResourceManager ? hostedResourceManager : &resourceManager);

    // Register all element renderers (same as before)
    elements_coregraphics::GuiSolidBorderElementRenderer::Register();
    // ... all other renderers ...
    elements::GuiDocumentElementRenderer::Register();

    // Hosted lifecycle
    if (hostedController) hostedController->Initialize();

    {
        GuiApplicationMain();
    }

    if (hostedController) hostedController->Finalize();

    SetGuiGraphicsResourceManager(nullptr);
    if (hostedResourceManager) delete hostedResourceManager;

    GetCurrentController()->CallbackService()->UninstallListener(g_cocoaListener);
    delete g_cocoaListener;
}
```

### Step 4: Declare the New Entry Point

Add the declaration `int SetupOSXHostedCoreGraphicsRenderer();` to `CoreGraphicsApp.h`.

### Step 5: Add --hosted Command Line Argument to MacFullControlTest

Modify `MacFullControlTest/Main.mm` to check `argv` for `--hosted`:

```cpp
int main(int argc, const char * argv[])
{
    bool hosted = false;
    for (int i = 1; i < argc; i++)
    {
        if (strcmp(argv[i], "--hosted") == 0) hosted = true;
    }

    if (hosted)
        SetupOSXHostedCoreGraphicsRenderer();
    else
        SetupOSXCoreGraphicsRenderer();
    return 0;
}
```

Update `testFC.sh` to forward `--hosted` to the app:

```bash
if [[ "$1" == "--hosted" ]]; then
    "$APP" --hosted
elif [[ "$1" == "--unblock" ]]; then
    "$APP" &
    echo $!
else
    "$APP"
fi
```

### Step 6: Testing

Run `./testFC.sh --hosted` to launch the full control test in hosted mode. Verify:
- The application renders inside a single `NSWindow`.
- Popups, menus, combo boxes, and tooltips all appear correctly within that window.
- Modal dialogs block their owner but not the whole app.
- Resizing the host window correctly resizes the main virtual window and triggers re-layout.
- Keyboard focus routes to the correct virtual window.

## Rendering Architecture Comparison

| Aspect | Standard Mode | Hosted Mode |
|--------|---------------|-------------|
| Native windows | One per GacUI window | One for all |
| Render targets | One per window | One shared |
| Resource manager | `CoreGraphicsResourceManager` | `GuiHostedGraphicsResourceManager` wrapping `CoreGraphicsResourceManager` |
| Window z-order | macOS manages | `hosted_window_manager::WindowManager` manages |
| Input routing | macOS delivers to correct `NSWindow` | `GuiHostedController::HitTestInClientSpace()` routes to correct `GuiHostedWindow` |
| Clipping | OS window bounds | Render target clipper stack per virtual window |
| `GetRenderTarget(window)` | Returns window's own render target | Always returns the single native window's render target |

## Hosted Rendering Lifecycle

```
Per frame (hosted mode):
  StartHostedRendering()           ← calls StartRenderingOnNativeWindow() once
    For each visible GuiHostedWindow (in z-order):
      PushClipper(window bounds)
      StartRendering()             ← skips StartRenderingOnNativeWindow (hostedRendering=true)
        ... element renderers draw to shared CGContext ...
      StopRendering()              ← skips StopRenderingOnNativeWindow
      PopClipper()
  StopHostedRendering()            ← calls StopRenderingOnNativeWindow() once
```

## Implementation Order

1. **Step 1** (render target refactor) — must be done first; it's a prerequisite for hosted rendering.
2. **Steps 2–4** (entry point, CoreGraphicsMain update, header declaration) — can be done together.
3. **Step 5** (CLI argument + testFC.sh) — wire up testing.
4. **Step 6** (testing) — after all code changes.

## Files to Create or Modify

| File | Action |
|------|--------|
| `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm` | Refactor `CoreGraphicsRenderTarget` (Step 1), update `CoreGraphicsMain` (Step 3) |
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm` | Add `SetupOSXHostedCoreGraphicsRenderer()` (Step 2) |
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h` | Declare `SetupOSXHostedCoreGraphicsRenderer()` (Step 4) |
| `MacFullControlTest/Main.mm` | Parse `--hosted` CLI arg, call hosted entry point (Step 5) |
| `testFC.sh` | Forward `--hosted` argument to the app (Step 5) |
| `doc/OSProvider.md` | Add hosted mode section |
| `readme.md` | Update running section, update TODO (remove hosted mode) |
