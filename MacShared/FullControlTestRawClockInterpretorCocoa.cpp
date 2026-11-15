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

		void DrawLine(vint color, double x1, double y1, double x2, double y2) override
		{
			Color colors[] = { Color(255,255,255), Color(0,255,255), Color(0,255,0), Color(255,255,0) };
			CGContextSetRGBStrokeColor(context, colors[color].r / 255.0, colors[color].g / 255.0, colors[color].b / 255.0, 1);
			CGContextMoveToPoint(context, x1, y1);
			CGContextAddLineToPoint(context, x2, y2);
			CGContextStrokePath(context);
		}

		void DrawEllipse(double cx, double cy, double radius) override
		{
			CGContextSetRGBStrokeColor(context, 1, 1, 1, 1);
			CGContextStrokeEllipseInRect(context, CGRectMake(cx - radius, cy - radius, radius * 2, radius * 2));
		}

		void Render(GuiGraphicsComposition*, GuiCocoaElementEventArgs& arguments)
		{
			context = arguments.context;
			CGContextSetLineWidth(context, 2);
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
