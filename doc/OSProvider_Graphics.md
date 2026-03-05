# macOS Graphics and Rendering

This document describes the CoreGraphics rendering backend for GacUI on macOS, including resource management, render targets, element renderers, text layout, and font management.

For the overall architecture (entry point, INativeController, services), see [OSProvider.md](OSProvider.md).
For window management (INativeWindow, CocoaWindow, popups), see [OSProvider_Window.md](OSProvider_Window.md).

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
