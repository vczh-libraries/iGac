# macOS OS Provider Implementation

This document describes how GacUI's platform abstraction interfaces are implemented on macOS using Cocoa and CoreGraphics. It covers the native controller, services, entry point, and overall architecture.

For window management (INativeWindow, CocoaWindow, popups, child windows), see [OSProvider_Window.md](OSProvider_Window.md).
For graphics rendering (CoreGraphics backend, element renderers, text layout), see [OSProvider_Graphics.md](OSProvider_Graphics.md).
For hosted mode (single-window rendering, virtual windows), see [OSProvider_HostedMode.md](OSProvider_HostedMode.md).

## Overview

GacUI defines a set of platform abstraction interfaces in `Release/Import/GacUI.h`. The macOS port implements these under `Mac/`:

- `Mac/NativeWindow/OSX/` — Cocoa windowing system (controller, window, input, view)
- `Mac/NativeWindow/OSX/ServicesImpl/` — Platform services (screen, clipboard, dialog, image, input, resource)
- `Mac/NativeWindow/OSX/CoreGraphics/` — App entry point for CoreGraphics backend
- `Mac/GraphicsElement/CoreGraphics/` — CoreGraphics rendering engine (renderers, layout, resource manager)

Shared test utilities live in `MacShared/`.

## Entry Point

### Standard Mode — `SetupOSXCoreGraphicsRenderer()`

The standard mode entry point is `SetupOSXCoreGraphicsRenderer()` (in `CoreGraphicsApp.mm`), called from `main()`. It:

1. Calls `StartOSXNativeController()` — instantiates the Cocoa controller
2. Calls `SetNativeController(GetOSXNativeController())` — registers it as the global controller
3. Calls `CoreGraphicsMain()` — sets up the graphics resource manager, registers element renderers, and runs `GuiApplicationMain()`
4. Calls `StopOSXNativeController()` — cleans up

### Hosted Mode — `SetupOSXHostedCoreGraphicsRenderer()`

The hosted mode entry point is `SetupOSXHostedCoreGraphicsRenderer()` (in `CoreGraphicsApp.mm`). In hosted mode, the entire GacUI application runs inside a single native `NSWindow` — all sub-windows, dialogs, menus, and popups are rendered as graphics within that one window. It:

1. Calls `StartOSXNativeController()` — instantiates the Cocoa controller
2. Creates a `GuiHostedController` wrapping the native controller — virtualizes window management
3. Calls `SetNativeController(hostedController)` — registers the hosted controller as the global controller
4. Calls `SetHostedApplication(hostedController->GetHostedApplication())` — makes the hosted application interface available
5. Calls `CoreGraphicsMain(hostedController)` — sets up the resource manager (wrapped in `GuiHostedGraphicsResourceManager`), registers element renderers, calls `hostedController->Initialize()`/`Finalize()`, and runs `GuiApplicationMain()`
6. Cleans up the hosted controller and calls `StopOSXNativeController()`

`GuiHostedController`, `GuiHostedGraphicsResourceManager`, and all supporting types are platform-independent and live in `GacUI.cpp`/`GacUI.h`.

## GetCurrentController() vs GetOSXNativeController()

In hosted mode, `SetNativeController()` registers the `GuiHostedController` as the global controller. This means `GetCurrentController()` returns `GuiHostedController`, **not** the native `CocoaController`. The hosted controller has its own `CallbackService`, `WindowService`, etc. that manage virtual windows. Calling these from OS provider code (which operates on real Cocoa objects) produces incorrect results:

- **`CallbackService()`** — The hosted controller's callback service fires to virtual window listeners only. The native callback service fires to the hosted controller itself (which runs the hosted render loop) and to native window listeners. Calling the wrong one skips the hosted render loop entirely.
- **`WindowService()`** — The hosted controller's window service manages virtual `GuiHostedWindow` objects, not native `CocoaWindow`s.

**Rule:** All code under `Mac/` must use `GetOSXNativeController()` (declared in `CocoaNativeController.h`) to access the native controller. Test/app code (`MacShared/`, `MacTest/`, `MacFullControlTest/`) should use `GetCurrentController()` as normal, since application code is designed to work with whichever controller is active.

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

## Service Implementations

Brief description of each service under `Mac/NativeWindow/OSX/ServicesImpl/`:

| Service | Description |
|---------|-------------|
| **CocoaInputService** | Implements `INativeInputService`. Uses a GCD timer for periodic timer callbacks. Maps macOS key codes to VKEY codes. Tracks key state via `CGEventSource`. |
| **CocoaScreenService** | `CocoaScreen` wraps `NSScreen`; reports bounds, client bounds, name, primary status, DPI scaling. `CocoaScreenService` enumerates all screens. |
| **CocoaResourceService** | `CocoaCursor` wraps `NSCursor` with all system cursor types. Provides default font ("Helvetica"), font enumeration via `NSFontManager`. |
| **CocoaClipboardService** | Clipboard read/write via `NSPasteboard`. `CocoaClipboardWriter` collects text, document, and image data, then atomically writes all formats on `Submit()`. Text is written as `NSPasteboardTypeString`. Documents are written in three formats: a custom GacUI binary format (`com.gaclib.document`), RTF (`NSPasteboardTypeRTF`), and HTML (`NSPasteboardTypeHTML`). Images are written as TIFF (`NSPasteboardTypeTIFF`). `SetDocument()` auto-fills text and image fallbacks (like Windows). `CocoaClipboardReader` reads from the system pasteboard: text from `NSPasteboardTypeString`, documents from the custom GacUI format, and images from TIFF/PNG types via `ImageService`. Each `ReadClipboard()` call creates a fresh reader that queries the current pasteboard state. |
| **CocoaDialogService** | Message boxes, color picker, font picker, file open/save dialogs using native macOS panels. |
| **CocoaImageService** | `CocoaImage` wraps `NSImage`, `CocoaImageFrame` wraps `CGImageRef`. Creates images from file, memory, or stream. |
