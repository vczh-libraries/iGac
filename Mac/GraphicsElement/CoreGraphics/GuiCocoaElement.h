#ifndef VCZH_IGAC_GUICOCOAELEMENT
#define VCZH_IGAC_GUICOCOAELEMENT

#include "GuiGraphicsCoreGraphics.h"

namespace vl::presentation::elements
{
	class GuiCocoaElement;

	struct GuiCocoaElementEventArgs : compositions::GuiEventArgs
	{
		GuiCocoaElement*			element;
		// Borrowed for this callback only. Do not retain or release the context.
		CGContextRef			context;
		Rect					bounds;

		GuiCocoaElementEventArgs(GuiCocoaElement* _element, CGContextRef _context, Rect _bounds)
			: element(_element), context(_context), bounds(_bounds)
		{
		}
	};

	class GuiCocoaElement : public GuiRawElementBase
	{
		friend class GuiElementBase<GuiRawElementBase>;
		static constexpr const wchar_t* ElementTypeName = L"CocoaElement";
	protected:
		GuiCocoaElement() = default;
	public:
		static vint				GetElementType();
		static GuiCocoaElement*	Create();

		// Bounds and context retain the current logical coordinates, clip and backing scale.
		compositions::GuiGraphicsEvent<GuiCocoaElementEventArgs>	Rendering;
	};
}

namespace vl::presentation::elements_coregraphics
{
	class GuiCocoaElementRenderer : public GuiElementRendererBase<GuiCocoaElement, GuiCocoaElementRenderer, ICoreGraphicsRenderTarget>
	{
		friend class GuiElementRendererBase<GuiCocoaElement, GuiCocoaElementRenderer, ICoreGraphicsRenderTarget>;
	protected:
		void			InitializeInternal();
		void			FinalizeInternal();
		void			RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldTarget, ICoreGraphicsRenderTarget* newTarget);
	public:
		void			Render(Rect bounds) override;
		void			OnElementStateChanged() override;
	};
}

#endif
