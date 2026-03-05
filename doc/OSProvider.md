# macOS OS Provider Implementation

This document describes how GacUI's platform abstraction interfaces are implemented on macOS using Cocoa and CoreGraphics. It covers the native controller, services, entry point, and overall architecture.

For window management (INativeWindow, CocoaWindow, popups, child windows), see [OSProvider_Window.md](OSProvider_Window.md).
For graphics rendering (CoreGraphics backend, element renderers, text layout), see [OSProvider_Graphics.md](OSProvider_Graphics.md).

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
