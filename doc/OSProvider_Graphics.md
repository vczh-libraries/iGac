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
| `GuiInnerShadowElementRenderer` | Inner shadow effect using linear gradients (4 sides) and radial gradients (4 corners). Thickness is clamped to `min(width/2, height/2)`. |
| `GuiFocusRectangleElementRenderer` | Focus indicator drawn as a 1px dashed border using macOS `keyboardFocusIndicatorColor`. |

### Text Layout

`GuiGraphicsLayoutProviderCoreText.mm` provides `CoreTextLayoutProvider`, which implements `IGuiGraphicsLayoutProvider` using CoreText for rich text layout and rendering.

### Font Management

`ICoreGraphicsResourceManager` provides:
- `CreateCoreTextFont(FontProperties)` — creates and caches a `CTFont` wrapping `CoreTextFontPackage`
- `DestroyCoreTextFont(font)` — returns to cache
