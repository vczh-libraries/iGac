#include "GuiCocoaElement.h"
#include <CoreGraphics/CoreGraphics.h>

namespace vl::presentation::elements
{
	vint GuiCocoaElement::GetElementType()
	{
		return GetElementTypeInternal<GuiCocoaElement>();
	}

	GuiCocoaElement* GuiCocoaElement::Create()
	{
		return CreateInternal<GuiCocoaElement>();
	}
}

namespace vl::presentation::elements_coregraphics
{
	void GuiCocoaElementRenderer::InitializeInternal()
	{
	}

	void GuiCocoaElementRenderer::FinalizeInternal()
	{
	}

	void GuiCocoaElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget*, ICoreGraphicsRenderTarget*)
	{
	}

	void GuiCocoaElementRenderer::Render(Rect bounds)
	{
		if (!renderTarget) return;
		auto context = renderTarget->GetCGContext();
		if (!context) return;

		// Quartz graphics state excludes the current path and text matrix.
		auto path = CGContextCopyPath(context);
		auto textMatrix = CGContextGetTextMatrix(context);
		CGContextBeginPath(context);
		renderTarget->PushClipper(bounds, element);
		if (!renderTarget->IsClipperCoverWholeTarget())
		{
			CGContextSaveGState(context);
			GuiCocoaElementEventArgs arguments(element, context, bounds);
			element->Rendering.Execute(arguments);
			CGContextRestoreGState(context);
		}
		renderTarget->PopClipper(element);
		CGContextSetTextMatrix(context, textMatrix);
		CGContextBeginPath(context);
		if (path)
		{
			CGContextAddPath(context, path);
			CGPathRelease(path);
		}
	}

	void GuiCocoaElementRenderer::OnElementStateChanged()
	{
	}
}
