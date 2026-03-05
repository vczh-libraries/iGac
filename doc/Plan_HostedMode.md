# Plan: macOS Hosted Mode

This document describes the plan for implementing hosted mode on macOS. In hosted mode, the entire GacUI application runs inside a **single native NSWindow** — all GacUI sub-windows, dialogs, menus, and popups are rendered as graphics within that one window rather than creating additional native windows.

## Background

### What Is Hosted Mode?

In standard mode, each GacUI window maps to a separate `NSWindow` (via `CocoaWindow`). In hosted mode, only **one** `NSWindow` exists. All other GacUI windows are "virtual" — they are `GuiHostedWindow` instances managed by `GuiHostedController`, which virtualizes `INativeWindowService` and routes input, focus, and rendering to the correct virtual window.

### Why Hosted Mode?

- **Embedding**: GacUI can be embedded inside another application's window (e.g., a game engine editor, a plugin host).
- **Remote rendering**: Hosted mode is a prerequisite for the remote protocol — the remote renderer operates in forced hosted mode.
- **Consistency**: All popups, menus, and dialogs stay within the host window boundary.

### How Windows Does It

The Windows implementation (in `GacUI.Windows.cpp`) provides:
- `SetupHostedWindowsDirect2DRenderer()` / `SetupHostedWindowsGDIRenderer()` — entry points that wrap the native controller with `GuiHostedController`.
- `GuiHostedController` — platform-independent class in `GacUI.cpp` that implements `INativeController` by delegation, virtualizes `INativeWindowService`, manages virtual window hierarchy via `hosted_window_manager::WindowManager<GuiHostedWindow*>`, and routes mouse/keyboard events to the correct virtual window.
- `GuiHostedGraphicsResourceManager` — wraps the native `IGuiGraphicsResourceManager` so all virtual windows share the same render target (the single native window's render target).
- Three `IGuiHostedWindowProxy` implementations — platform-specific proxies that bridge virtual window operations to the real native window (for the main window) or to no-ops (for non-main virtual windows and placeholders).

### What's Already Platform-Independent (Reusable)

All of these live in `Release/Import/GacUI.cpp` and `GacUI.h`:
- `GuiHostedController` — complete window virtualization, input routing, focus management, hover tracking
- `GuiHostedGraphicsResourceManager` — render target redirection (all virtual windows → one native render target)
- `GuiHostedWindow` — virtual `INativeWindow` implementation
- `GuiHostedWindowData` — virtual window property storage
- `hosted_window_manager::WindowManager` — z-order, visibility, hit testing, activation
- `IGuiHostedApplication` — host window access interface
- `GuiGraphicsRenderTarget` base class — already handles `StartHostedRendering`/`StopHostedRendering` lifecycle (calls `StartRenderingOnNativeWindow` once, then allows multiple `StartRendering`/`StopRendering` cycles)

## What Needs to Be Done

### Step 1: Fix CoreGraphicsRenderTarget to Use Base Class Rendering Chain

**Problem**: The current `CoreGraphicsRenderTarget` (in `GuiGraphicsCoreGraphics.mm`) overrides `StartRendering()` and `StopRendering()` directly, bypassing the `GuiGraphicsRenderTarget` base class. The base class methods `StartRenderingOnNativeWindow()` and `StopRenderingOnNativeWindow()` are implemented as `CHECK_FAIL` (crash). This means the hosted rendering lifecycle — where `StartHostedRendering()` calls `StartRenderingOnNativeWindow()` once, then `StartRendering()`/`StopRendering()` run multiple times without touching the native window — cannot work.

**Fix**: Refactor `CoreGraphicsRenderTarget` to implement `StartRenderingOnNativeWindow()` and `StopRenderingOnNativeWindow()` with the real CGContext setup/teardown logic, and **remove** the direct overrides of `StartRendering()` and `StopRendering()`. The base class `GuiGraphicsRenderTarget` will then correctly:
- In standard mode: `StartRendering()` → `StartRenderingOnNativeWindow()` → ... → `StopRendering()` → `StopRenderingOnNativeWindow()`
- In hosted mode: `StartHostedRendering()` → `StartRenderingOnNativeWindow()` once, then multiple `StartRendering()`/`StopRendering()` cycles (which skip `StartRenderingOnNativeWindow`/`StopRenderingOnNativeWindow`), then `StopHostedRendering()` → `StopRenderingOnNativeWindow()`

The rendering setup code currently in `StartRendering()` (getting CGContext, saving graphics state, setting up flipped/scaled coordinate system, filling black background) must move to `StartRenderingOnNativeWindow()`. The teardown code in `StopRendering()` must move to `StopRenderingOnNativeWindow()`. The `StartRendering()`/`StopRendering()` overrides should be removed entirely so the base class handles them.

Note: The `SetCurrentRenderTarget(this)` / `SetCurrentRenderTarget(0)` calls and the per-frame black fill should happen in `StartRenderingOnNativeWindow()` / `StopRenderingOnNativeWindow()` since they are once-per-frame operations.

### Step 2: Implement IGuiHostedWindowProxy for macOS

Three proxy implementations are needed. These are simple — the Windows implementations are straightforward and the macOS versions are nearly identical.

#### PlaceholderHostedWindowProxy
- All methods are no-ops except `Show*()` which calls `CHECK_FAIL` (crash — placeholder windows should never be shown).
- **Identical to the Windows version.** Can be copied directly.

#### MainHostedWindowProxy
- Bridges property updates to the real `CocoaWindow` (the single native `NSWindow`):
  - `UpdateBounds()` → `nativeWindow->SetClientSize(data->wmWindow.bounds.GetSize())`
  - `UpdateTitle()` → `nativeWindow->SetTitle(data->windowTitle)`
  - `UpdateIcon()` → `nativeWindow->SetIcon(data->windowIcon)`
  - `UpdateTopMost()` → `nativeWindow->SetTopMost(data->wmWindow.topMost)`
  - `Show()` → `data->wmWindow.Activate()` + `nativeWindow->Show()`
  - `Close()` → `nativeWindow->Hide(true)`
  - etc.
- `FixBounds()` forces position to `{0,0}` (main window always fills host).
- `CheckAndSyncProperties()` synchronizes all properties to the native window and calls `AssignFrameConfig` on listeners.
- **Nearly identical to the Windows version.** The main difference is that macOS `SetMaximizedBox`/`SetMinimizedBox`/`SetBorder`/`SetSizeBox` map to `CocoaWindow`'s boolean flags + `UpdateStyleMask()`, but this is already abstracted behind `INativeWindow`.

#### NonMainHostedWindowProxy
- Most property updates are no-ops (non-main windows are virtual — no native window to configure).
- `Show()` / `ShowDeactivated()` → `data->wmWindow.SetVisible(true)` + optional `Activate()`
- `Hide()` → `data->wmWindow.SetVisible(false)`
- `Close()` → `Hide()`
- Enforces that non-main windows must either use custom frame mode or have no system border (Border=false, SizeBox=false, TitleBar=false) when visible.
- **Nearly identical to the Windows version.** Can be copied directly.

### Step 3: New Entry Point — SetupOSXHostedCoreGraphicsRenderer

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

### Step 4: Update CoreGraphicsMain to Accept Optional GuiHostedController

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

### Step 5: Declare the New Entry Point

Add the declaration `int SetupOSXHostedCoreGraphicsRenderer();` to an appropriate header (likely `CoreGraphicsApp.h`).

### Step 6: Testing

- **Basic test**: Change `main()` to call `SetupOSXHostedCoreGraphicsRenderer()` instead of `SetupOSXCoreGraphicsRenderer()`. The full control test should render inside a single window.
- **Window tests**: Verify that popups, menus, combo boxes, tooltips all appear correctly within the single window.
- **Modal dialogs**: Verify modal windows block their owner but not the whole app.
- **Resize**: Verify that resizing the host window correctly resizes the main virtual window and triggers re-layout.
- **Focus**: Verify keyboard focus routing to the correct virtual window.

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
2. **Steps 2–5** (proxies, entry point, CoreGraphicsMain update) — can be done together.
3. **Step 6** (testing) — after all code changes.

## Files to Create or Modify

| File | Action |
|------|--------|
| `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm` | Refactor `CoreGraphicsRenderTarget` (Step 1), update `CoreGraphicsMain` (Step 4) |
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm` | Add `SetupOSXHostedCoreGraphicsRenderer()` (Step 3) |
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h` | Declare `SetupOSXHostedCoreGraphicsRenderer()` (Step 5) |
| New file: `Mac/NativeWindow/OSX/HostedWindowProxy.mm` | Three `IGuiHostedWindowProxy` implementations (Step 2) |
| `MacShared/CMakeLists.txt` | Add `HostedWindowProxy.mm` to GacOSX sources |
| `doc/OSProvider.md` | Add hosted mode section |
| `readme.md` | Update doc list, update TODO (remove hosted mode) |
