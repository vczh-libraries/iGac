# macOS OS Provider Implementation

This document describes how GacUI's platform abstraction interfaces are implemented on macOS using Cocoa and CoreGraphics. It covers the native controller, services, entry point, and overall architecture.

For window management (INativeWindow, CocoaWindow, popups, child windows), see [OSProvider_Window.md](OSProvider_Window.md).
For graphics rendering (CoreGraphics backend, element renderers, text layout), see [OSProvider_Graphics.md](OSProvider_Graphics.md).
For hosted mode (single-window rendering, virtual windows), see [OSProvider_HostedMode.md](OSProvider_HostedMode.md).

## Overview

GacUI defines a set of platform abstraction interfaces in `Import/GacUI.h`. The macOS port implements these under `Mac/`:

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
| `AutomationService()` | Mode-specific `CocoaAutomationService*` substitution | `Mac/NativeWindow/CocoaAutomationService.cpp` |

The native controller itself returns `nullptr` from `AutomationService()`.
The renderer setup functions do not install test automation. Each test
application constructs and substitutes the concrete service matching its
mode: `CocoaAutomationService` for normal multi-window applications,
`CocoaAutomationServiceHosted` for hosted applications, and
`CocoaAutomationServiceRenderer` for the native remote renderer. The
application starts its MiniHTTP endpoint after substitution, then stops the
endpoint and service before unsubstituting it. This keeps endpoint and service
lifetime in the application that owns the test scenario.

### Window Management

`CocoaController` also implements `INativeWindowService`:

- `CreateNativeWindow(WindowMode)` — creates a `CocoaWindow`, fires the `NativeWindowCreated` callback (which lets the graphics resource manager install its render target), and adds it to the window list.
- `DestroyNativeWindow(window)` — fires the `NativeWindowDestroying` callback and removes the window from the list. If it is the main window, clears `mainWindow` and posts an application-defined event so a blocked `RunOneCycle()` wakes and the run loop exits.
- `Run(window)` — sets the main window, calls `Show()` on it, then repeatedly calls `RunOneCycle()` until the main window is destroyed.
- `GetWindow(NativePoint)` — finds the window at a screen coordinate by iterating all windows and checking bounds.

### Application Delegate

`CocoaApplicationDelegate` (the `NSApplicationDelegate`) creates the default macOS application menu (App menu + Window menu with standard items). It also handles `applicationDidResignActive:` to close all popups when the app loses focus.

When the application becomes active, the delegate asks `CocoaResourceService`
to read AppKit's current default interface font again. If the effective font
changed, the controller invokes `EnvironmentChanged` on the callback service
used by the current application mode. Standard applications use the native
callback service, while hosted applications use the hosted controller's
callback service so `GuiApplication` refreshes every window's inherited display
font.

### Global Timer

`CocoaInputService` runs a GCD timer. On each tick it calls `GlobalTimerFunc()` which:
1. Executes pending async tasks via `SharedAsyncService`
2. Invokes the global timer, which triggers GacUI's render loop for all windows

## Service Implementations

Brief description of each service under `Mac/NativeWindow/OSX/ServicesImpl/`:

| Service | Description |
|---------|-------------|
| **CocoaInputService** | Implements `INativeInputService`. Uses a GCD timer for periodic timer callbacks. Maps macOS key codes to VKEY codes, including Control as `ctrl` and Command as `osSuper`, and registers both modifiers for global shortcuts. Tracks key state via `CGEventSource`. |
| **CocoaScreenService** | `CocoaScreen` wraps `NSScreen`; reports bounds, client bounds, name, primary status, and logical scaling `1.0`. AppKit window/input coordinates are points; Retina backing scale is applied separately by the CoreGraphics drawing path. `CocoaScreenService` enumerates all screens. |
| **CocoaResourceService** | `CocoaCursor` wraps `NSCursor` with all system cursor types. Reads the current default interface font from `NSFont messageFontOfSize:0`, preserves an explicit process override from `SetDefaultFont`, enumerates fonts via `NSFontManager`, and reports `Command` as the canonical Super-key name. |
| **CocoaClipboardService** | Clipboard read/write via `NSPasteboard`. `CocoaClipboardWriter` collects text, document, and image data, then atomically writes all formats on `Submit()`. Text is written as `NSPasteboardTypeString`. Documents are written in three formats: a custom GacUI binary format (`com.gaclib.document`), RTF (`NSPasteboardTypeRTF`), and HTML (`NSPasteboardTypeHTML`). Images are written as TIFF (`NSPasteboardTypeTIFF`). `SetDocument()` auto-fills text and image fallbacks (like Windows). `CocoaClipboardReader` reads from the system pasteboard: text from `NSPasteboardTypeString`, documents from the custom GacUI format, and images from TIFF/PNG types via `ImageService`. Each `ReadClipboard()` call creates a fresh reader that queries the current pasteboard state. |
| **CocoaDialogService** | Message boxes, color picker, font picker, file open/save dialogs using native macOS panels. |
| **CocoaImageService** | `CocoaImage` wraps `NSImage`, `CocoaImageFrame` wraps `CGImageRef`. Creates images from file, memory, or stream. |
| **CocoaAutomationService** | Exposes control-tree automation and routes IO commands to real `CocoaWindow` instances. Hosted and native-renderer variants use the same Cocoa input path with their respective automation tree implementations. |

### Default Font

`CocoaResourceService` queries `NSFont messageFontOfSize:0` at controller
startup and whenever the application becomes active. The font's family, point
size, and bold/italic traits become GacUI `FontProperties`; there is no
hard-coded macOS font size. AppKit point sizes are logical UI units and must not
be multiplied by the screen backing scale.

The resource service publishes the refreshed value only together with
`EnvironmentChanged`, so all inherited display fonts switch consistently.
`SetDefaultFont()` remains a process-level override and prevents system
refreshes from changing the effective default for the lifetime of that resource
service. AppKit's logical system-font family (for example,
`.AppleSystemUIFont`) is added to `EnumerateFonts()` when it is not present in
`NSFontManager`'s public family list.

A remote renderer supplies this freshly queried value when the core requests
`ControllerGetFontConfig`. Starting or replacing
`RemotingTest_Rendering_macOS` therefore refreshes the core's default font. The
current remote protocol has no live default-font update event for an already
connected renderer.

## Terminal entry point

`Mac/TUI/TuiCocoaController.mm` supplies `SetupTuiCocoaRenderer()` over the shared `TuiControllerBase`. The foreground executable initializes AppKit with prohibited activation, so the terminal retains focus and no Cocoa window is created. It owns TUI resource/input adapters and ordinary Cocoa image/clipboard services. The resource adapter exposes only TuiFont, size 1, while retaining style bits. The input adapter runs the 16 ms VlppOS TUI timer; each owner-thread cycle drains AppKit events without blocking and checks pasteboard changes, including while a hosted modal is open. Titles use sanitized UTF-8 OSC output because ordinary Console output is disabled during terminal takeover.

CocoaInputService receives its callback service explicitly and registers its Carbon handler with the service instance as user data. CocoaClipboardService receives callback and image services explicitly; Submit and the TUI pump detect pasteboard change-count transitions through CheckForUpdates. The native Cocoa controller supplies its own services, and the terminal controller supplies its own, so clipboard and global shortcuts do not require GetOSXNativeController in TUI mode. Keyboard input itself comes from the terminal protocol, independently of Carbon global shortcut registration. Command delivery depends on terminal support; SGR mouse has no Command bit.

`Test_TuiControlTest` has no automation endpoint. It uses the imported TuiSkin pair and synchronized showcase resources, with hosted popups and fake TUI dialogs supplied by GacUI. Normal Hide/Close and Stop unwind the shared controller and restore the terminal. See the upstream [TUI provider design](../../GacUI/.github/KnowledgeBase/KB_GacUI_Design_TuiPlatformProvider.md) and [terminal SOP](../../GacUI/.github/Jobs/DebugTuiControlTestSop.md).
