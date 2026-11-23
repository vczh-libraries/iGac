#include "FullControlTestRawClockInterpretor.h"
#include "../Mac/GraphicsElement/CoreGraphics/GuiCocoaElement.h"
#include <CoreGraphics/CoreGraphics.h>

namespace demo
{
	using namespace vl;
	using namespace vl::presentation;
	using namespace vl::presentation::elements;
	using namespace vl::presentation::compositions;

	class RawClockCocoaInterpretor : public RawClockInterpretorBase
	{
	protected:
		vl::Ptr<IGuiGraphicsEventHandler>		renderingHandler;
		CGContextRef						context = nullptr;

		void SelectStroke(Stroke stroke) override
		{
			auto color = GetStrokeColor(stroke);
			CGContextSetRGBStrokeColor(context, color.r / 255.0, color.g / 255.0, color.b / 255.0, 1);
			CGContextSetLineWidth(context, GetStrokeWidth(stroke));
		}

		void DrawLine(double x1, double y1, double x2, double y2) override
		{
			CGContextMoveToPoint(context, x1, y1);
			CGContextAddLineToPoint(context, x2, y2);
			CGContextStrokePath(context);
		}

		void DrawEllipse(double cx, double cy, double radius) override
		{
			CGContextStrokeEllipseInRect(context, CGRectMake(cx - radius, cy - radius, radius * 2, radius * 2));
		}

		void Render(GuiGraphicsComposition*, GuiCocoaElementEventArgs& arguments)
		{
			context = arguments.context;
			DrawClock(arguments.bounds);
			context = nullptr;
		}

	public:
		void Initialize(IGuiGraphicsElement* value) override
		{
			auto cocoa = dynamic_cast<GuiCocoaElement*>(value);
			element = cocoa;
			renderingHandler = cocoa->Rendering.AttachMethod(this, &RawClockCocoaInterpretor::Render);
		}

		void Finalize() override
		{
			static_cast<GuiCocoaElement*>(element)->Rendering.Detach(renderingHandler);
			renderingHandler = nullptr;
		}
	};

	class RawClockCocoaInterpretorFactory : public Object, public IGuiGraphicsRawInterpretorFactory
	{
	public:
		IGuiGraphicsRawInterpretor* Create() override
		{
			return new RawClockCocoaInterpretor;
		}
	};

	class FullControlTestClockInterpretorPlugin : public Object, public IGuiPlugin
	{
	public:
		GUI_PLUGIN_NAME(FullControlTest_ClockInterpretor)
		{
		}

		void Load(bool controllerUnrelatedPlugins, bool controllerRelatedPlugins) override
		{
			if (controllerRelatedPlugins)
			{
				GetGuiGraphicsResourceManager()->RegisterRawInterpretorFactory(L"FullControlTest::Clock", vl::Ptr(new RawClockCocoaInterpretorFactory));
			}
		}

		void Unload(bool controllerUnrelatedPlugins, bool controllerRelatedPlugins) override
		{
		}
	};
	GUI_REGISTER_PLUGIN(FullControlTestClockInterpretorPlugin)
}
