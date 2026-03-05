# macOS OS Provider Implementation

This document describes how GacUI's platform abstraction interfaces are implemented on macOS using Cocoa and CoreGraphics. It covers the native controller, native window, services, and graphics resource manager.

## Overview

GacUI defines a set of platform abstraction interfaces in `Release/Import/GacUI.h`. The macOS port implements these under `Mac/`:

- `Mac/NativeWindow/OSX/` — Cocoa windowing system (controller, window, input, view)
- `Mac/NativeWindow/OSX/ServicesImpl/` — Platform services (screen, clipboard, dialog, image, input, resource)
- `Mac/NativeWindow/OSX/CoreGraphics/` — App entry point for CoreGraphics backend
- `Mac/GraphicsElement/CoreGraphics/` — CoreGraphics rendering engine (renderers, layout, resource manager)

Shared test utilities live in `MacShared/`.

## Entry Point

The app entry point is `SetupOSXCoreGraphicsRenderer()` (in `CoreGraphicsApp.mm`), called from `main()`. It:

1. Calls `StartOSXNativeController()` — instantiates the Cocoa controller
2. Calls `SetNativeController(GetOSXNativeController())` — registers it as the global controller
3. Calls `CoreGraphicsMain()` — sets up the graphics resource manager, registers element renderers, and runs `GuiApplicationMain()`
4. Calls `StopOSXNativeController()` — cleans up

## INativeController — CocoaController

**File:** `Mac/NativeWindow/OSX/CocoaNativeController.mm`

`CocoaController` implements both `INativeController` and `INativeWindowService`. It owns all platform services and the list of native windows.

### Initialization

The constructor:
- Initializes `[NSApplication sharedApplication]`
- Sets the activation policy to `NSApplicationActivationPolicyRegular`
- Calls `[NSApp finishLaunching]`
- Creates all service instances

### Services

Each service is returned by the corresponding `INativeController` method:

| Service | Class | File |
|---------|-------|------|
| `CallbackService()` | `SharedCallbackService` | (GacUI built-in) |
| `AsyncService()` | `SharedAsyncService` | (GacUI built-in) |
| `InputService()` | `CocoaInputService` | `ServicesImpl/CocoaInputService.mm` |
| `ScreenService()` | `CocoaScreenService` | `ServicesImpl/CocoaScreenService.mm` |
| `ResourceService()` | `CocoaResourceService` | `ServicesImpl/CocoaResourceService.mm` |
| `ClipboardService()` | `CocoaClipboardService` | `ServicesImpl/CocoaClipboardService.mm` |
| `ImageService()` | `CocoaImageService` | `ServicesImpl/CocoaImageService.mm` |
| `DialogService()` | `CocoaDialogService` | `ServicesImpl/CocoaDialogService.mm` |

### Window Management

`CocoaController` also implements `INativeWindowService`:

- `CreateNativeWindow(WindowMode)` — creates a `CocoaWindow`, fires the `NativeWindowCreated` callback (which lets the graphics resource manager install its render target), and adds it to the window list.
- `DestroyNativeWindow(window)` — fires the `NativeWindowDestroying` callback, removes from the list. If the destroyed window is the main window, calls `[NSApp stop:nil]` to exit the run loop.
- `Run(window)` — sets the main window, calls `Show()` on it, then enters `[NSApp run]`.
- `GetWindow(NativePoint)` — finds the window at a screen coordinate by iterating all windows and checking bounds.

### Application Delegate

`CocoaApplicationDelegate` (the `NSApplicationDelegate`) creates the default macOS application menu (App menu + Window menu with standard items). It also handles `applicationDidResignActive:` to close all popups when the app loses focus.

### Global Timer

`CocoaInputService` runs a GCD timer. On each tick it calls `GlobalTimerFunc()` which:
1. Executes pending async tasks via `SharedAsyncService`
2. Invokes the global timer, which triggers GacUI's render loop for all windows

## INativeWindow — CocoaWindow

**File:** `Mac/NativeWindow/OSX/CocoaWindow.mm`

`CocoaWindow` implements `INativeWindow`. Each instance wraps an `NSWindow` (specifically the `CocoaNSWindow` subclass), an `NSWindowController`, and a `CocoaWindowDelegate`.

### Window Creation

`CreateWindow()` allocates a `CocoaNSWindow` with:
- Style: `Titled | Closable | Miniaturizable | Resizable`
- Backing: `NSBackingStoreBuffered`, deferred: `YES`
- Initial frame: `(0, 0, 0, 0)` — the window starts hidden and zero-sized

The window is **not shown at creation time**. It only becomes visible when GacUI explicitly calls `Show()` or `ShowDeactivated()`. This is important: GacUI creates multiple native windows during initialization (for popups, tooltips, menus) and controls their visibility via its own lifecycle.

### Show / ShowDeactivated / Hide

**`Show()`** — For the main window (no parent): `[nsWindow makeKeyAndOrderFront:nil]` + `[nsWindow makeMainWindow]`. For child windows (has parent): `[nsWindow orderFront:nil]` + `[nsWindow makeFirstResponder:nsWindow.contentView]`. On first call, fires `InvokeOpened()`.

**`ShowDeactivated()`** — Used for popups. Calls `[nsWindow orderFront:nil]` + `makeFirstResponder` without making the window key or main. Wrapped in `suppressClosePopups = true/false` to prevent re-entrant popup closing (see below). On first call, fires `InvokeOpened()`.

**`Hide(bool closeWindow)`** — If `closeWindow` is true or this is the main window, calls `[nsWindow close]` (which triggers the close sequence and app exit for the main window). Otherwise calls `[nsWindow setIsVisible:false]` and fires `InvokeClosed()`.

### IsVisible

```objc
return [nsWindow isVisible];
```

This is critical for GacUI's render loop. The render loop (`GuiGraphicsHost::Render`) **only runs when `nativeWindow->IsVisible() == true`**. Inside the render loop, `UpdateClientSizeAfterRendering()` computes the correct layout size and resizes the window.

A window that starts at 0×0 (like menu popups) relies on the render loop to compute its content size. If `IsVisible()` returned `false` for 0×0 windows, the render loop would never run, and the window would stay at 0×0 forever — a deadlock. This is why `IsVisible()` must not add extra checks like `frame.size.width > 0`.

### SetBounds / SetClientSize

**`SetBounds()`** — Notifies listeners via `Moving()`, flips coordinates for macOS (Cocoa uses bottom-left origin), calls `[nsWindow setFrame:display:YES]`. Does **not** call `Show()`.

On Windows, `SetBounds` maps to `MoveWindow` / `SetWindowPos`, which repositions and resizes without affecting visibility or activation. The macOS implementation must match this behavior — `SetBounds` should never make a window visible or steal focus. GacUI calls `Show()` / `ShowDeactivated()` explicitly when it wants a window displayed.

**`SetClientSize()`** — Computes the new bounds preserving the top-left position, then calls `SetBounds()`.

### SetParent / Child Windows

`SetParent(parent)` manages the macOS child window relationship:
- Removes from old parent: `[oldParent removeChildWindow:nsWindow]`, removes from `childWindows` list
- Adds to new parent: `[newParent addChildWindow:nsWindow ordered:NSWindowAbove]`, adds to `childWindows` list
- The `addChildWindow:` call is wrapped in `suppressClosePopups = true/false` because it synchronously triggers `windowDidBecomeKey:` → `InvokeGotFocus()` → `ClosePopups()`, which would immediately close the popup being opened.

Popup windows (menus, tooltips, combo dropdowns) are child windows of their logical owner.

### SetTopMost / GetTopMost

On Windows, "TopMost" means `WS_EX_TOPMOST` — a z-order flag that keeps a window above all non-topmost windows. The macOS equivalent is the **window level**:

```objc
void SetTopMost(bool topmost) {
    [nsWindow setLevel: topmost ? NSPopUpMenuWindowLevel : NSNormalWindowLevel];
}
bool GetTopMost() {
    return [nsWindow level] > NSNormalWindowLevel;
}
```

GacUI calls `SetTopMost(controlWindow->GetTopMost())` when opening popups to ensure they appear above their owner.

### Custom Frame Mode

When custom frame mode is enabled, the window uses `NSWindowStyleMaskBorderless` so GacUI can draw its own window chrome. `UpdateStyleMask()` computes the style mask based on `customFrameMode`, `hasBorder`, `hasSizeBox`, and `hasMinimizedBox`.

In custom frame mode, `CocoaWindow` handles hit-testing manually in `HandleEventInternal()` to detect resize edges and title bar drag areas, matching the behavior of `INativeWindowListener::HitTest()`.

Note: `NSWindowStyleMaskBorderless` has value 0. This means XOR-based toggling does not work — the style mask must be rebuilt from the boolean flags each time.

### Popup Auto-Close

Popups must close when the user clicks outside or the app loses focus. This is managed by three mechanisms:

**1. Mouse-down in `HandleEventInternal()`** — When any mouse button is pressed, `ClosePopups(this)` is called before the event is dispatched.

**2. `InvokeGotFocus()`** — When a window gains focus, `ClosePopups(this)` is called (unless `suppressClosePopups` is true).

**3. `applicationDidResignActive:`** — When the app loses focus entirely, `ClosePopupsOnActivation(nullptr, nullptr)` closes all popups.

**`ClosePopups(activatedWindow)`** builds an exception list (the activated window and all its parents up the chain) and calls `ClosePopupsOnActivation()`, which iterates all Normal-mode windows and for each calls `ClosePopupsOf()`.

**`ClosePopupsOf(owner, exceptions)`** is a static recursive method: for each child of `owner`, if the child is non-Normal mode, visible, and not in the exceptions list, it calls `Hide(false)`. Then it recurses into that child's children.

**`suppressClosePopups`** — A file-static boolean flag that prevents re-entrant popup closing. It is set to `true` during:
- `SetParent()` when calling `addChildWindow:` (which synchronously triggers focus callbacks)
- `ShowDeactivated()` when calling `orderFront:` (which can trigger focus callbacks)

Without this guard, opening a popup would immediately trigger its own closing.

### CocoaNSWindow

`CocoaNSWindow` is an `NSWindow` subclass that overrides:

- `canBecomeKeyWindow` — Returns `YES` unless the window has a parent AND uses `NSWindowStyleMaskBorderless` (value 0, so `styleMask & Borderless` is always 0 for borderless windows). This prevents popup windows from stealing keyboard focus.
- `canBecomeMainWindow` — Returns `YES` only if there is no parent window.

### CocoaWindowDelegate

An `NSWindowDelegate` that bridges Cocoa window events to GacUI:

- `windowShouldClose:` → `InvokeClosing()`
- `windowWillClose:` → `InvokeClosed()`; if main window, posts a dummy event to unblock `[NSApp run]` and calls `[NSApp stop:nil]`
- `windowDidResize:` → `InvokeMoved()`
- `windowDidBecomeKey:` → `InvokeGotFocus()`
- `windowDidResignKey:` → `InvokeLostFocus()`
- Tracks `sizeState` (Restored/Minimized/Maximized)

### EnableActivate / DisableActivate

These are currently no-ops on macOS. On Windows, `DisableActivate` sets `WS_EX_NOACTIVATE` to prevent a window from gaining activation when clicked. GacUI calls `SetEnabledActivate(false)` on popup windows, but the macOS implementation relies on `ShowDeactivated()` and `canBecomeKeyWindow` to achieve similar behavior.

## CocoaBaseView

**File:** `Mac/NativeWindow/OSX/CocoaBaseView.mm`

`CocoaBaseView` is an `NSView` subclass that serves as the content view for every `CocoaNSWindow`. It:

- Forwards all mouse and keyboard events to `CocoaWindow::HandleEventInternal()`
- Implements `NSTextInputClient` for IME composition support
- Uses `NSTrackingArea` for mouse enter/exit tracking
- Handles drag-and-drop via `NSDraggingDestination`
- Manages cursor rects

## Graphics Resource Manager

**File:** `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm`

The CoreGraphics backend uses a `CoreGraphicsResourceManager` (implementing `GuiGraphicsResourceManager`, `INativeControllerListener`, `ICoreGraphicsResourceManager`) to manage render targets and fonts.

### CoreGraphicsView

A subclass of `CocoaBaseView` that manages a `CGLayer` for double-buffered drawing:
- `resize:` creates a `CGBitmapContext` and `CGLayer` at retina scale
- `drawRect:` triggers the global timer (which runs the render loop), then blits the layer to the screen

### Render Target

`CoreGraphicsRenderTarget` implements `ICoreGraphicsRenderTarget`:
- `StartRendering()` — Gets the `CGContext` from the layer, sets up a flipped and scaled coordinate system for retina displays
- `StopRendering()` — Restores the graphics state, detects if the window moved during rendering (which requires a re-render)
- Clipper push/pop uses `CGContextSaveGState` / `CGContextRestoreGState` with `CGContextClipToRect`

### Per-Window Lifecycle

`CoreGraphicsCocoaNativeControllerListener` listens for `NativeWindowCreated` and `NativeWindowDestroying` callbacks. On creation, it installs a `CoreGraphicsCocoaNativeWindowListener` on the window, which:
- Creates the `CoreGraphicsView` and sets it as the window's content view
- Manages layer rebuild on window resize
- Provides the render target for the graphics resource manager

### Element Renderers

`CoreGraphicsMain()` registers these element renderers:

| Renderer | Description |
|----------|-------------|
| `GuiSolidBorderElementRenderer` | Solid color border rectangles |
| `Gui3DBorderElementRenderer` | 3D-style beveled borders |
| `Gui3DSplitterElementRenderer` | 3D-style splitter lines |
| `GuiSolidBackgroundElementRenderer` | Solid color filled rectangles |
| `GuiGradientBackgroundElementRenderer` | Gradient fills using `CGGradient` |
| `GuiSolidLabelElementRenderer` | Text rendering using CoreText |
| `GuiImageFrameElementRenderer` | Image display |
| `GuiPolygonElementRenderer` | Polygon shapes using `CGMutablePathRef` |
| `GuiCoreGraphicsElementRenderer` | Custom CoreGraphics drawing element |
| `GuiInnerShadowElementRenderer` | Inner shadow effect |
| `GuiFocusRectangleElementRenderer` | Focus indicator rectangles |

### Text Layout

`GuiGraphicsLayoutProviderCoreText.mm` provides `CoreTextLayoutProvider`, which implements `IGuiGraphicsLayoutProvider` using CoreText for rich text layout and rendering.

### Font Management

`ICoreGraphicsResourceManager` provides:
- `CreateCoreTextFont(FontProperties)` — creates and caches a `CTFont` wrapping `CoreTextFontPackage`
- `DestroyCoreTextFont(font)` — returns to cache

## Service Implementations

Brief description of each service under `Mac/NativeWindow/OSX/ServicesImpl/`:

| Service | Description |
|---------|-------------|
| **CocoaInputService** | Implements `INativeInputService`. Uses a GCD timer for periodic timer callbacks. Maps macOS key codes to VKEY codes. Tracks key state via `CGEventSource`. |
| **CocoaScreenService** | `CocoaScreen` wraps `NSScreen`; reports bounds, client bounds, name, primary status, DPI scaling. `CocoaScreenService` enumerates all screens. |
| **CocoaResourceService** | `CocoaCursor` wraps `NSCursor` with all system cursor types. Provides default font ("Helvetica"), system font enumeration. |
| **CocoaClipboardService** | Clipboard read/write via `NSPasteboard`. Supports text, document, and image content types. |
| **CocoaDialogService** | Message boxes, color picker, font picker, file open/save dialogs using native macOS panels. |
| **CocoaImageService** | `CocoaImage` wraps `NSImage`, `CocoaImageFrame` wraps `CGImageRef`. Creates images from file, memory, or stream. |

## Key Differences from Windows

| Aspect | Windows | macOS |
|--------|---------|-------|
| Coordinate system | Top-left origin | Bottom-left origin (Cocoa). All coordinates are flipped via `FlipY()` / `FlipRect()` in `CocoaHelper`. |
| Show without activation | `ShowWindow(SW_SHOWNOACTIVATE)` | `[nsWindow orderFront:nil]` — does not make key or main. |
| TopMost | `WS_EX_TOPMOST` via `SetWindowPos` | `[nsWindow setLevel:NSPopUpMenuWindowLevel]` |
| Disable activation | `WS_EX_NOACTIVATE` | No-op. Handled by `canBecomeKeyWindow` returning NO for child borderless windows. |
| Hide | `PostMessage(WM_CLOSE)` always | Main window: `[nsWindow close]`. Others: `[nsWindow setIsVisible:false]`. |
| SetBounds | `MoveWindow` / `SetWindowPos` — no visibility side effects | `[nsWindow setFrame:display:YES]` — no visibility side effects. |
| Custom frame | Style flags via `SetWindowLongPtr` | `NSWindowStyleMaskBorderless` + manual hit testing in `HandleEventInternal`. Note: `NSWindowStyleMaskBorderless = 0`, so XOR-based toggling does not work. |
| Window creation | Window starts hidden until `ShowWindow` | Window starts hidden (not ordered). Only becomes visible on `Show()` / `ShowDeactivated()`. |
| Popup close trigger | `WM_ACTIVATEAPP` + mouse messages | `windowDidBecomeKey:` → `InvokeGotFocus()`, mouse-down in `HandleEventInternal`, `applicationDidResignActive:` |
| Render loop gate | `IsWindowVisible(handle)` — true for 0×0 windows | `[nsWindow isVisible]` — true for 0×0 windows (they are ordered on screen). The render loop must be able to run for 0×0 popup windows to compute their content size. |
