# macOS Hosted Mode — Implemented Design

Hosted mode is implemented. The maintained behavior and lifecycle reference is
[OSProvider_HostedMode.md](OSProvider_HostedMode.md); this page records the
integration decisions rather than an outstanding implementation plan.

## Shared Framework and Native Integration

GacUI owns `GuiHostedController`, `GuiHostedGraphicsResourceManager`,
`GuiHostedWindow`, the hosted window proxies, and window ordering/input routing.
The Cocoa backend supplies the native controller, one real `NSWindow`, and the
CoreGraphics render target. Virtual GacUI windows share that target with their
own bounds, offsets and clipping. Native dialog services remain separate;
hosted mode alone does not replace them with GacUI dialogs.

The entry points in `<iGac repo>/Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.mm`
delegate to `SetupOSXCoreGraphicsRendererInternal(hosted, raw)`:

| Entry point | `hosted` | `raw` | Application entry |
| --- | --- | --- | --- |
| `SetupOSXCoreGraphicsRenderer()` | `false` | `false` | `GuiApplicationMain()` |
| `SetupOSXHostedCoreGraphicsRenderer()` | `true` | `false` | `GuiApplicationMain()` |
| `SetupRawOSXCoreGraphicsRenderer()` | `false` | `true` | `GuiRawMain()` |

`CoreGraphicsMain(nativeController, hostedController, raw)` registers native
element renderers in every setup. When a hosted controller is present, it wraps
the native resource manager and calls the controller's `Initialize()` and
`Finalize()` around the application. Native window listeners are always
installed on `nativeController->CallbackService()`; installing them through
`GetCurrentController()` would incorrectly expose virtual hosted windows to
Cocoa code.

The remote Core uses hosted virtual windows. The native remote renderer uses
the raw entry point and owns a real Cocoa window; it does not use a hosted
controller. The `raw` entry-point flag is independent of the XML `<Raw/>`
graphics element.

## Rendering Lifecycle

`CoreGraphicsRenderTarget` implements `StartRenderingOnNativeWindow()` and
`StopRenderingOnNativeWindow()`. The shared base orchestrates standard and
hosted rendering: hosted mode starts the native frame once, renders each
visible virtual window, and stops the native frame once. The backend obtains
the current layer context, applies the Retina transform, and restores graphics
state at the end. The native controller's timer drives both setups.

`<Raw/>` is the recommended owner-drawing element in every graphical setup.
`CoreGraphicsResourceManager::CreateRawElement()` supplies `GuiCocoaElement`,
which exposes a callback-scoped `CGContextRef` and bounds through `Rendering`.
The callback uses the current hosted offsets and clipping, and the renderer
restores graphics state, text matrix and current path afterward. Shared `Id`
and `Data` state supports remote rendering with renderer-owned drawing; TUI
does not support this element. See
[Raw Cocoa Drawing](OSProvider_Graphics.md#raw-cocoa-drawing).

## Verification

Run `<iGac repo>/import.sh`, `<iGac repo>/syncProj.sh` and `<iGac repo>/build.sh`
in order on macOS. Exercise local Full Control Test in standard and `--hosted`
modes, including menus, popups, modal windows, palettes and Misc / Raw Clock.
Run the native remote renderer separately with Core, including replacement
and takeover. Use the commands and automation guidance in
[the repository readme](../readme.md), and retain actual runtime results in
`<iGac repo>/TestMatrix_NativeRenderer.md`.
