# macOS Graphics and Rendering

This document describes the CoreGraphics rendering backend for GacUI on macOS, including resource management, render targets, element renderers, text layout, and font management.

For the overall architecture (entry point, INativeController, services), see [OSProvider.md](OSProvider.md).
For window management (INativeWindow, CocoaWindow, popups), see [OSProvider_Window.md](OSProvider_Window.md).
For hosted mode (single-window rendering, virtual windows), see [OSProvider_HostedMode.md](OSProvider_HostedMode.md).

## Graphics Resource Manager

**File:** `Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.mm`

The CoreGraphics backend uses a `CoreGraphicsResourceManager` (implementing `GuiGraphicsResourceManager`, `INativeControllerListener`, `ICoreGraphicsResourceManager`) to manage render targets and fonts.

### CoreGraphicsView

A subclass of `CocoaBaseView` that manages a `CGLayer` for double-buffered drawing:
- `resize:` creates a `CGBitmapContext` and `CGLayer` at retina scale
- `drawRect:` triggers the global timer (which runs the render loop), then blits the layer to the screen

`drawRect:` calls `GetOSXNativeController()->CallbackService()->Invoker()->InvokeGlobalTimer()` (the **native** controller, not `GetCurrentController()`). This is critical for hosted mode: in hosted mode, `GetCurrentController()` returns `GuiHostedController`, whose callback service only fires timer callbacks to virtual windows without triggering the hosted render loop. But `GuiHostedController::GlobalTimer()` — which contains the actual hosted render loop — is registered as a listener on the **native** controller's callback service. By firing the native controller's `InvokeGlobalTimer()`, `drawRect:` triggers the full rendering pipeline in both modes.

### Render Target

`CoreGraphicsRenderTarget` implements `ICoreGraphicsRenderTarget` (which extends `GuiGraphicsRenderTarget`):
- `StartRenderingOnNativeWindow()` — Gets the `CGContext` from the layer, sets up a flipped and scaled coordinate system for retina displays, fills the black background
- `StopRenderingOnNativeWindow()` — Restores the graphics state, detects if the window moved during rendering (which requires a re-render)
- Clipper push/pop uses `CGContextSaveGState` / `CGContextRestoreGState` with `CGContextClipToRect`

The base class `GuiGraphicsRenderTarget` handles the `StartRendering()`/`StopRendering()` lifecycle and routes to `StartRenderingOnNativeWindow()`/`StopRenderingOnNativeWindow()` appropriately for both standard and hosted modes:
- **Standard mode**: `StartRendering()` calls `StartRenderingOnNativeWindow()` each frame
- **Hosted mode**: `StartHostedRendering()` calls `StartRenderingOnNativeWindow()` once, then `StartRendering()`/`StopRendering()` run multiple times per frame (once per virtual window) without touching the native window again, then `StopHostedRendering()` calls `StopRenderingOnNativeWindow()` once

### Per-Window Lifecycle

`CoreGraphicsCocoaNativeControllerListener` and `CoreGraphicsResourceManager` are installed as listeners on the **native** controller's callback service (not the hosted controller's). This is critical: in hosted mode, `GuiHostedController` fires `NativeWindowCreated` for virtual `GuiHostedWindow` objects that are not real `CocoaWindow`s. Attempting to create `CoreGraphicsRenderTarget` for a virtual window would crash.

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
| `GuiGradientBackgroundElementRenderer` | Gradient fills using `CGGradient`. Supports Rectangle, Ellipse, and RoundRect shapes. |
| `GuiSolidLabelElementRenderer` | Text rendering using CoreText |
| `GuiImageFrameElementRenderer` | Image display |
| `GuiPolygonElementRenderer` | Polygon shapes using `CGMutablePathRef` |
| `GuiCoreGraphicsElementRenderer` | Custom CoreGraphics drawing element |
| `GuiCocoaElementRenderer` | `<Raw/>` drawing through `GuiRawElementBase`, with callback-scoped CoreGraphics access |
| `GuiInnerShadowElementRenderer` | Inner shadow effect using linear gradients (4 sides) and radial gradients (4 corners). Thickness is clamped to `min(width/2, height/2)`. |
| `GuiFocusRectangleElementRenderer` | Focus indicator drawn as a 1px dashed border using macOS `keyboardFocusIndicatorColor`. |

### Raw Cocoa Drawing

`GuiCocoaElement` and its renderer live in `<iGac repo>/Mac/GraphicsElement/CoreGraphics/GuiCocoaElement.h/.cpp`.
The element derives from `GuiRawElementBase` and supplies its own concrete factory.
`CoreGraphicsResourceManager::CreateRawElement()` returns it in standard, hosted and
native remote modes. The portable Core continues using its own raw element and
transmits only the numeric renderer ID, application string ID and string data.

Subscribe to `GuiCocoaElement::Rendering` for the element, bounds and borrowed
`CGContextRef`. The context is valid only during that callback: do not retain or
release it, retain its backing layer, or begin/end another frame. The renderer
queries the current target on every paint, so resizing or replacing a layer does
not leave a cached native context. No target-bound drawing resources or additional
target-change events are needed.

The callback uses the existing logical coordinates, Retina transform, hosted
offsets and parent clip, intersected with the element bounds. The renderer restores
graphics state, the text matrix and current path afterward. Empty clips and absent
targets/contexts do not invoke the callback. The element has no intrinsic minimum
size. Changed Data invalidates drawing; changed Id alone does not, and equal
assignments do nothing.

The FullControlTest clock attachments are test utilities under
`<iGac repo>/MacShared/FullControlTestRawElement*.h/.cpp`, compiled directly into
the local FCT and native remote renderer targets. They draw only
`FullControlTest.Clock` with valid `HH:mm:ss` data; the application timer owns time
updates. Keep the local attachment alive through the window run. The remote
collection attachment subscribes before protocol dispatch, enumerates existing
elements for late attachment, tracks identity across duplicate/empty IDs, and
detaches when an ID changes away or an element is uninstalled. Destroy it before
the renderer. Disconnected and fatal retained pictures keep their attachments
until actual teardown.

`<iGac repo>/MacTest/RawElement.cpp` verifies factory/state behavior in ordinary
and hosted setup, bitmap pixels and callback isolation at two scales, target
replacement, and the native remote collection/repaint lifecycle. Live local,
hosted and remote clock checks are recorded in `<iGac repo>/TestMatrix_NativeRenderer.md`.

### Text Layout

`GuiGraphicsLayoutProviderCoreText.mm` provides `CoreTextLayoutProvider`, which implements `IGuiGraphicsLayoutProvider` using CoreText for rich text layout and rendering.

Inline attachment cells (`GuiElementsTextCell`) must be created with `initWithGraphicsElement:properties:andCallback:` so their inline-object properties and paragraph callback are initialized. Plain `init` and `new` are unavailable.

### Font Management

`ICoreGraphicsResourceManager` provides:
- `CreateCoreTextFont(FontProperties)` — creates and caches a `CTFont` wrapping `CoreTextFontPackage`
- `DestroyCoreTextFont(font)` — returns to cache

The default `FontProperties` comes from
`CocoaResourceService`, which reads AppKit's current `messageFontOfSize:0` at
controller startup and on every application activation. An explicit process
override remains the effective default even though the current AppKit value is
still queried. The reported font size is an AppKit point size in the same
logical coordinate space used by GacUI. Retina backing scale is applied later
by the CoreGraphics render target and must not be folded into the font size.

When the application becomes active and the AppKit default has changed, the
controller raises `EnvironmentChanged`. GacUI updates inherited display fonts,
which invalidates the affected text measurements and lets the normal successive
layout/render passes converge on the new geometry.

### Native text positions and AppKit ranges

GacUI paragraph offsets on macOS count UTF-32 wchar_t scalars, while NSTextStorage ranges count UTF-16 units and NSLayoutManager also has separate glyph indices. CoreTextParagraph stores maps between native and UTF-16 boundaries. Font/style/color and attachment edits convert to storage ranges; glyph clusters and line fragments convert back to native positions for caret movement, selection, hit testing and background painting. Never index paragraphText with an AppKit character or glyph index. Supplementary characters may occupy two UTF-16 units, and ligatures or composed glyphs may span several native characters. Inline-object replacement preserves the original UTF-16 range length while its public range remains in native units.
