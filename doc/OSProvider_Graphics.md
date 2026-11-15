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

`<Raw/>` is the standard, recommended GacUI owner-drawing element for local and
remote graphical applications. Set `Id`, `Interpretor` and `Data` in XML or C++,
give the owning composition useful bounds or a minimum size, and select a named
interpretor or attach native drawing manually. TUI rejects raw-element creation.

`GuiCocoaElement` and its renderer live in `<iGac repo>/Mac/GraphicsElement/CoreGraphics/GuiCocoaElement.h/.cpp`.
The element derives from `GuiRawElementBase` and supplies its own concrete factory.
`CoreGraphicsResourceManager::CreateRawElement()` returns it in standard, hosted and
native remote modes. Core transports `ElementDesc_Raw` with numeric renderer `id`,
application string `rawId`, `interpretor` and `data` as separate fields; no native
context or rendered pixels cross the protocol. Keep Core and renderer snapshots
synchronized when this schema changes.

`GuiCocoaElementRenderer` inherits `GuiRawElementRendererBase`. Register an
`IGuiGraphicsRawInterpretorFactory` with the active graphics resource manager after
backend setup and before constructing consumers or processing remote messages.
Hosted registration and lookup forward to the native registry. Each renderer owns
a fresh interpretor. `Initialize` borrows the element and attaches handlers;
`Finalize` detaches those handlers. An owning element pointer would create a cycle.
`GuiCocoaElement` finalizes its renderer while `Rendering` still exists; later base
finalization does not finalize the same interpretor twice.

Selection uses `Interpretor` independently of `Id`. Empty and unknown names remove
only the renderer-owned handlers, preserving independent manual drawing. Unknown
names remain stored; registering them later does not retry installation. Data-only,
ID-only and identical assignments do not reinstall an unchanged name.
`SetInterpretorAndData` assigns both fields before initialization. Changed name or
data invalidates drawing; an ID-only change does not request repaint. All strings
start empty, and empty or duplicate IDs are valid.

Subscribe to `GuiCocoaElement::Rendering` for the element, logical bounds and borrowed
`CGContextRef`. The context is valid only during that callback: do not retain or
release it, retain its backing layer, or begin/end another frame. The renderer
queries the target on every paint; interpretor lifetime is independent of target,
layer and context replacement. No target-bound resources or extra target events
are needed for these CoreGraphics primitives.

The provider already applies Retina scale, hosted offsets and the parent clip,
intersected with element bounds. Do not scale or flip again. The renderer restores
graphics state, text matrix and current path afterward. Empty clips and absent
targets/contexts do not invoke callbacks. The element has no intrinsic minimum size.

`GuiRawElementBase` has no property-change events. Remote dirty state is batched
into frames: ID-only changes wait for another required frame; name/data changes
schedule one. `RawElementInstalled` fires with empty strings before target assignment.
Descriptors assign all three strings before one `RawElementChanged`; identical
updates emit nothing. `RawElementUninstalled` fires while the element remains in
`GetRawElements()`, allowing manual handlers to detach before target removal.
Track element identity, enumerate existing elements when subscribing late, and do
not treat resize, hidden DOM nodes or retained disconnected pictures as removal.

The application Clock module is outside the platform provider. `<iGac repo>/syncProj.sh`
copies both portable `FullControlTestRawClockInterpretor.h/.cpp` files from GacUI into
`<iGac repo>/MacShared/`, adapting the framework include. The separate local
`FullControlTestRawClockInterpretorCocoa.cpp` implements the CoreGraphics primitives
and a controller-related `IGuiPlugin`. It registers exactly `FullControlTest::Clock`
through the active manager before `GuiMain`, including raw remote startup. Both
implementations compile directly once into FCT, the renderer and `Test_RawElement`;
they cannot be discarded as unreferenced static-library objects. Clock preserves
`Id="FullControlTest.Clock"` but selects by `Interpretor`; the portable base draws
received `HH:mm:ss` data with upstream geometry/colors and no native timer.

`<iGac repo>/MacShared/FullControlTestRawElement.h/.cpp` implements the manual
Touching painter with empty `Interpretor`. FCT retains the attachment for
`MainWindow::GetTouchingElement()` until before window destruction. Its payload is
`centerX,centerY,axisX,axisY,count`, followed by `count` triples of `pointId,x,y`.
The complex axis rotates/scales a filled SkyBlue 160 by 100 rectangle, with yellow
radius-16 contact rings. The remote adapter in `FullControlTestRawElementRemote.h/.cpp`
reconciles `Id="FullControlTest.Touching"`, attaches existing elements on late
subscription, and detaches on ID changes, replacement, uninstall and adapter
teardown. It does not attach Clock and must be destroyed before the renderer.

`<iGac repo>/MacTest/RawElement.cpp` checks selection/lifetime in native and hosted
setup, manual handler survival, fixed-data Clock pixels, Touching transforms/contact
rings, clipping/offsets at 1x and 2x, and remote interpretor-only repaint without
input or timer delivery. Application observations and display limitations belong
in `<iGac repo>/TestMatrix_NativeRenderer.md`.

### Text Layout

Ellipsized solid labels contribute zero minimum width while retaining their
measured height, matching the Windows label renderers. Their full text is drawn
with tail truncation inside the assigned rectangle. This lets hosted captions
and responsive rows fit narrow windows; toggling ellipsis off restores natural
width. `Test_Paragraph` checks this through composition layout.

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

An inline image can be reapplied at its existing range when other images share
the paragraph. Duplicate-image checks compare against each other range, so a
selection or formatting update can refresh every image. Resetting an inline
image requires its exact range, removes its attachment and lookup entries, and
restores the original text. The image can then be inserted at another range.
`Test_Paragraph` covers this lifecycle with a supplementary character before the
images.
