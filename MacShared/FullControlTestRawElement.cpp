#include "FullControlTestRawElement.h"
#include "../Mac/GraphicsElement/CoreGraphics/GuiCocoaElement.h"
#include <CoreGraphics/CoreGraphics.h>
#include <cmath>

namespace demo
{
	using namespace vl;
	using namespace vl::presentation;
	using namespace vl::presentation::elements;
	using namespace vl::presentation::compositions;

	class CocoaTouchingAttachment : public Object
	{
	protected:
		vl::Ptr<GuiCocoaElement>				element;
		vl::Ptr<IGuiGraphicsEventHandler>	renderingHandler;

		void Render(GuiGraphicsComposition*, GuiCocoaElementEventArgs& arguments)
		{
			auto data = element->GetData();
			collections::List<double> values;
			vint start = 0;
			for (vint i = 0; i <= data.Length(); i++)
			{
				if (i != data.Length() && data[i] != L',') continue;
				bool success = false;
				auto value = wtof_test(data.Sub(start, i - start), success);
				if (!success || !std::isfinite(value)) return;
				values.Add(value);
				start = i + 1;
			}
			if (values.Count() < 5 || (values.Count() - 5) % 3 != 0 || values[4] < 0 || values[4] != (values.Count() - 5) / 3.0) return;

			auto bounds = arguments.bounds;
			auto context = arguments.context;
			double x[] = { -80,80,80,-80 };
			double y[] = { -50,-50,50,50 };
			CGPoint polygon[4];
			for (vint i = 0; i < 4; i++)
			{
				polygon[i] = CGPointMake(
					bounds.x1 + values[0] + x[i] * values[2] - y[i] * values[3],
					bounds.y1 + values[1] + x[i] * values[3] + y[i] * values[2]);
			}
			CGContextSetRGBFillColor(context, 135.0 / 255, 206.0 / 255, 235.0 / 255, 1);
			CGContextBeginPath(context);
			CGContextAddLines(context, polygon, 4);
			CGContextClosePath(context);
			CGContextFillPath(context);
			CGContextSetRGBStrokeColor(context, 1, 1, 0, 1);
			CGContextSetLineWidth(context, 2);
			for (vint i = 5; i < values.Count(); i += 3)
			{
				auto cx = bounds.x1 + (vint)values[i + 1];
				auto cy = bounds.y1 + (vint)values[i + 2];
				CGContextStrokeEllipseInRect(context, CGRectMake(cx - 16, cy - 16, 32, 32));
			}
		}
	public:
		CocoaTouchingAttachment(vl::Ptr<GuiRawElementBase> rawElement)
			: element(rawElement.Cast<GuiCocoaElement>())
		{
			renderingHandler = element->Rendering.AttachMethod(this, &CocoaTouchingAttachment::Render);
		}

		~CocoaTouchingAttachment()
		{
			element->Rendering.Detach(renderingHandler);
		}
	};

	vl::Ptr<Object> AttachFullControlTestTouchingElement(vl::Ptr<GuiRawElementBase> element)
	{
		return vl::Ptr(new CocoaTouchingAttachment(element));
	}
}
