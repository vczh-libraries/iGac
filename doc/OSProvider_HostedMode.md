# macOS Hosted Mode

This document describes the macOS hosted mode implementation — how the entire GacUI application runs inside a single native `NSWindow`, with all sub-windows, dialogs, menus, and popups rendered as graphics within that one window.

For the overall architecture (entry point, INativeController, services), see [OSProvider.md](OSProvider.md).
For window management (INativeWindow, CocoaWindow, popups), see [OSProvider_Window.md](OSProvider_Window.md).
For graphics rendering and elements, see [OSProvider_Graphics.md](OSProvider_Graphics.md).

## Overview

In standard mode, each GacUI window maps to a separate `NSWindow` (via `CocoaWindow`). In hosted mode, only **one** `NSWindow` exists. All other GacUI windows are "virtual" — they are `GuiHostedWindow` instances managed by `GuiHostedController`, which virtualizes `INativeWindowService`, `INativeScreenService`, and other services, and routes input, focus, and rendering to the correct virtual window.

All hosted mode infrastructure — `GuiHostedController`, `GuiHostedGraphicsResourceManager`, `GuiHostedWindow`, `GuiHostedWindowData`, `hosted_window_manager::WindowManager`, `IGuiHostedWindowProxy` and its three implementations (`GuiMainHostedWindowProxy`, `GuiNonMainHostedWindowProxy`, `GuiPlaceholderHostedWindowProxy`) — is platform-independent and lives in `Release/Import/GacUI.cpp` and `GacUI.h`. The macOS port only needs to provide the entry point and ensure the render target supports the hosted rendering lifecycle.

### Why Hosted Mode?

- **Embedding**: GacUI can be embedded inside another application's window (e.g., a game engine editor, a plugin host).
- **Remote rendering**: Hosted mode is a prerequisite for the remote protocol — the remote renderer operates in forced hosted mode since it has no real native windows.
- **Consistency**: All popups, menus, and dialogs stay within the host window boundary.

## Entry Point

**File:** `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm`

`SetupOSXHostedCoreGraphicsRenderer()` is the hosted mode entry point:

1. Calls `StartOSXNativeController()` — instantiates the native `CocoaController`
2. Creates a `GuiHostedController` wrapping the native controller
3. Calls `SetNativeController(hostedController)` — registers the hosted controller as the global controller (so `GetCurrentController()` returns `GuiHostedController`)
4. Calls `SetHostedApplication(hostedController->GetHostedApplication())` — makes `GetHostedApplication()` available to application code
5. Calls `CoreGraphicsMain(nativeController, hostedController)` — passes **both** the native controller and the hosted controller
6. Cleans up: `SetNativeController(nullptr)`, deletes the hosted controller, calls `StopOSXNativeController()`

Compare with the Windows implementation (`SetupWindowsDirect2DRendererInternal` in `GacUI.Windows.cpp`), which follows the identical pattern: create the native controller, optionally wrap it in `GuiHostedController`, pass both to the renderer main function.

The standard mode entry point `SetupOSXCoreGraphicsRenderer()` passes `nullptr` for the hosted controller, so `CoreGraphicsMain` behaves identically to before.

**Header:** `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h` declares both `SetupOSXCoreGraphicsRenderer()` and `SetupOSXHostedCoreGraphicsRenderer()`.

## CoreGraphicsMain — Hosted vs Standard

**File:** `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm`

`CoreGraphicsMain(INativeController* nativeController, GuiHostedController* hostedController)` handles both modes. The key difference is in resource manager wrapping and the initialize/finalize lifecycle.

### Listener Installation

Listeners (`CoreGraphicsCocoaNativeControllerListener` and `CoreGraphicsResourceManager`) are installed on the **native** controller's callback service, not the hosted controller's:

```cpp
nativeController->CallbackService()->InstallListener(g_cocoaListener);
nativeController->CallbackService()->InstallListener(&resourceManager);
```

This is critical: in hosted mode, `GuiHostedController` fires `NativeWindowCreated`/`NativeWindowDestroying` for virtual `GuiHostedWindow` objects. These are not real `CocoaWindow`s — attempting to create `CoreGraphicsRenderTarget` or `CoreGraphicsView` for them would crash. The native controller only fires these callbacks for real native windows.

### Resource Manager Wrapping

When `hostedController` is non-null, the `CoreGraphicsResourceManager` is wrapped in a `GuiHostedGraphicsResourceManager`:

```cpp
if (hostedController)
    hostedResourceManager = new GuiHostedGraphicsResourceManager(hostedController, &resourceManager);
    SetGuiGraphicsResourceManager(hostedResourceManager);
else
    SetGuiGraphicsResourceManager(&resourceManager);
```

`GuiHostedGraphicsResourceManager` delegates most operations to the underlying `CoreGraphicsResourceManager` but overrides `GetRenderTarget()` to always return the **single native window's** render target (instead of looking up per-window render targets). It also makes `RecreateRenderTarget()` and `ResizeRenderTarget()` no-ops for virtual windows.

### Initialize and Finalize

After element renderer registration but before `GuiApplicationMain()`, the hosted controller is initialized:

```cpp
if (hostedController) hostedController->Initialize();
```

`Initialize()` creates the single native `NSWindow` via `nativeController->WindowService()->CreateNativeWindow()` and installs the hosted controller as a listener on it. This native window is the host for all virtual windows.

After `GuiApplicationMain()` returns:

```cpp
if (hostedController) hostedController->Finalize();
```

`Finalize()` destroys the native window and uninstalls the listener.

## Render Target — Hosted Rendering Lifecycle

**File:** `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm`

`CoreGraphicsRenderTarget` extends `GuiGraphicsRenderTarget` (the base class in `GacUI.h`). The base class manages the `hostedRendering` and `rendering` flags and routes calls appropriately:

- **Standard mode**: `StartRendering()` → `StartRenderingOnNativeWindow()` each frame. `StopRendering()` → `StopRenderingOnNativeWindow()` each frame.
- **Hosted mode**: `StartHostedRendering()` → `StartRenderingOnNativeWindow()` once per frame. Then `StartRendering()`/`StopRendering()` run multiple times (once per visible virtual window) **without** calling `StartRenderingOnNativeWindow()`/`StopRenderingOnNativeWindow()`. Finally `StopHostedRendering()` → `StopRenderingOnNativeWindow()` once per frame.

The macOS-specific code implements only `StartRenderingOnNativeWindow()` and `StopRenderingOnNativeWindow()`:

**`StartRenderingOnNativeWindow()`**:
1. Notifies the `CoreGraphicsCocoaNativeWindowListener` that rendering has started (used to detect window moves during rendering)
2. Gets the `CGContext` from the `CGLayer`
3. Calls `SetCurrentRenderTarget(this)` to make it the active render target
4. Saves the `NSGraphicsContext` state and sets up a flipped, retina-scaled coordinate system
5. Fills the black background

**`StopRenderingOnNativeWindow()`**:
1. Notifies the listener that rendering has stopped
2. Checks if the window moved during rendering (returns `ResizeWhileRendering` if so)
3. Restores the `CGContext` graphics state and `NSGraphicsContext`
4. Calls `SetCurrentRenderTarget(0)`

The per-virtual-window clipping (via `PushClipper`/`PopClipper`) uses `CGContextSaveGState`/`CGContextRestoreGState` with `CGContextClipToRect`, which works correctly in both modes since all virtual windows share the same `CGContext`.

### Hosted Rendering Sequence (per frame)

```
StartHostedRendering()           → StartRenderingOnNativeWindow() [once]
  For each visible virtual window (in z-order, back to front):
    PushClipper(window bounds)
    StartRendering()             → skips StartRenderingOnNativeWindow (hostedRendering=true)
      ... element renderers draw to shared CGContext ...
    StopRendering()              → skips StopRenderingOnNativeWindow
    PopClipper()
StopHostedRendering()            → StopRenderingOnNativeWindow() [once]
```

## Hosted Controller Architecture

`GuiHostedController` (in `GacUI.cpp`) is entirely platform-independent. It implements:

| Interface | Purpose |
|-----------|---------|
| `INativeController` | Main controller interface — routes to native or virtual implementations |
| `INativeWindowService` | Creates/destroys `GuiHostedWindow` virtual windows instead of native windows |
| `INativeScreenService` / `INativeScreen` | Reports a single virtual screen matching the native window's client area |
| `INativeAsyncService` | Delegates to the native controller's async service |
| `INativeWindowListener` | Listens on the native window to intercept input, focus, and lifecycle events |
| `INativeControllerListener` | Listens for native window destruction |
| `WindowManager<GuiHostedWindow*>` | Manages z-order, visibility, activation, hit testing for virtual windows |
| `IGuiHostedApplication` | Provides access to the native host window |

### Virtual Window Management

`GuiHostedController::CreateNativeWindow()` creates `GuiHostedWindow` objects (not native windows). Each `GuiHostedWindow` contains a `hosted_window_manager::Window<GuiHostedWindow*>` that tracks bounds, visibility, z-order, parent-child relationships, and activation state.

The `WindowManager` maintains two ordered lists: `ordinaryWindowsInOrder` and `topMostedWindowsInOrder`. Ordinary windows are rendered first (back to front), then top-most windows. This determines both rendering order and hit-test priority.

### Window Proxies

Each `GuiHostedWindow` has an `IGuiHostedWindowProxy` that determines its behavior:

| Proxy | When | Behavior |
|-------|------|----------|
| `PlaceholderHostedWindowProxy` | Before `Run()` is called | No-op for most operations; windows exist but aren't yet tied to the native window |
| `GuiMainHostedWindowProxy` | The main window after `Run()` | Syncs title, icon, bounds, maximized box, etc. to the real native window |
| `GuiNonMainHostedWindowProxy` | All other windows after `Run()` | Operates entirely virtually; enforces custom frame mode and no system border |

When `Run(window)` is called, the main window gets `GuiMainHostedWindowProxy` and all others get `GuiNonMainHostedWindowProxy`. The main hosted window's properties (title, icon, size box, etc.) are forwarded to the real native `NSWindow`. Non-main windows are always custom-frame, borderless, and managed entirely by the hosted controller.

### Input Routing

`GuiHostedController` installs itself as an `INativeWindowListener` on the single native window. All mouse and keyboard events arrive at the native window and are re-routed:

- **Mouse events**: `HitTestInClientSpace()` determines which virtual window the mouse is over. The controller tracks `hoveringWindow`, `capturingWindow`, and `enteringWindow` to deliver `MouseMoving`, `MouseEntered`, `MouseLeaved`, button clicks, and wheel events to the correct virtual window's listeners.
- **Keyboard events**: Delivered to the focused (active) virtual window.
- **Window manager operations**: The controller detects mouse-down on virtual window borders/title bars and performs resize/drag operations by updating the virtual window's bounds directly.

### Focus and Activation

The `WindowManager` tracks which virtual window is `active`. When a virtual window gains activation:
- Its `renderedAsActive` flag is set (and propagated up the parent chain)
- `GotFocus` / `LostFocus` events are fired to the appropriate virtual window listeners
- The native window's caret point is updated to reflect the focused virtual window's caret position

### Screen Virtualization

`GuiHostedController` implements `INativeScreenService` with a single virtual screen whose bounds match the native window's client area. This ensures virtual windows see a screen that corresponds to the host window's dimensions, so operations like `MoveToScreenCenter()` work correctly within the hosted context.

## GetCurrentController() vs GetOSXNativeController() — Hosted Mode Implications

This distinction (documented in [OSProvider.md](OSProvider.md)) is critically important for hosted mode:

- `GetCurrentController()` returns `GuiHostedController` in hosted mode. Its `CallbackService()` fires timer callbacks to virtual window listeners. Its `WindowService()` manages `GuiHostedWindow` objects.
- `GetOSXNativeController()` always returns the underlying `CocoaController`. Its `CallbackService()` fires to the `GuiHostedController` (which registered as a listener), triggering the hosted render loop. Its `WindowService()` manages real `CocoaWindow` objects.

**Rule in `Mac/` code**: Always use `GetOSXNativeController()`. This applies to:
- `CoreGraphicsView::drawRect:` — calls `GetOSXNativeController()->CallbackService()->Invoker()->InvokeGlobalTimer()` to trigger the render loop in both modes
- `CoreGraphicsMain()` — installs listeners on `nativeController->CallbackService()`, not `GetCurrentController()->CallbackService()`
- `CoreGraphicsCocoaNativeControllerListener` — only receives callbacks for real native windows

**Rule in app code (`MacShared/`, `MacTest/`, `MacFullControlTest/`)**: Use `GetCurrentController()` as normal, since application code works with whichever controller is active. Use `GetHostedApplication()` to detect hosted mode or access the native host window.

## Rendering Architecture Comparison

| Aspect | Standard Mode | Hosted Mode |
|--------|---------------|-------------|
| Native windows | One per GacUI window | One for all |
| Render targets | One per window | One shared |
| Resource manager | `CoreGraphicsResourceManager` | `GuiHostedGraphicsResourceManager` wrapping `CoreGraphicsResourceManager` |
| `GetRenderTarget(window)` | Returns window's own render target | Always returns the single native window's render target |
| Window z-order | macOS manages via `NSWindow` levels | `hosted_window_manager::WindowManager` manages two ordered lists |
| Input routing | macOS delivers to correct `NSWindow` | `GuiHostedController` hit-tests and routes to correct `GuiHostedWindow` |
| Clipping | OS window bounds | Render target clipper stack per virtual window |
| Screen info | Real `NSScreen` via `CocoaScreenService` | Virtual screen matching native window client area |

## Test Entry Point

**File:** `MacFullControlTest/Main.mm`

`main()` checks `argv` for `--hosted`:

```cpp
if (hosted)
    SetupOSXHostedCoreGraphicsRenderer();
else
    SetupOSXCoreGraphicsRenderer();
```

**File:** `testFC.sh`

`./testFC.sh --hosted` forwards the flag to the test app.

In `GuiMain()`, the application checks `GetHostedApplication()` to detect hosted mode. In hosted mode, `SetControlThemeName(theme::ThemeName::Window)` is skipped because the main window's theme is managed differently — the hosted controller's `GuiMainHostedWindowProxy` handles the native window appearance.

## Files Involved

| File | Role |
|------|------|
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm` | `SetupOSXHostedCoreGraphicsRenderer()` entry point |
| `Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h` | Declares both entry points |
| `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm` | `CoreGraphicsMain()` with hosted support, `CoreGraphicsRenderTarget` with `StartRenderingOnNativeWindow`/`StopRenderingOnNativeWindow` |
| `MacFullControlTest/Main.mm` | `--hosted` CLI argument parsing |
| `testFC.sh` | Forwards `--hosted` to the test app |
| `Release/Import/GacUI.h` | `GuiHostedController`, `GuiHostedWindow`, `GuiHostedGraphicsResourceManager`, `GuiGraphicsRenderTarget`, `IGuiHostedWindowProxy`, `hosted_window_manager::WindowManager` declarations |
| `Release/Import/GacUI.cpp` | All hosted mode platform-independent implementations |
