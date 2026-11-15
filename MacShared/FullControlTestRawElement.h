#ifndef VCZH_IGAC_FULLCONTROLTESTRAWELEMENT
#define VCZH_IGAC_FULLCONTROLTESTRAWELEMENT

#include "GacUI.h"

namespace demo
{
	// Retain through the window's drawing lifetime; destruction detaches the callback.
	// Data: centerX,centerY,axisX,axisY,count followed by count triples of pointId,x,y.
	// The axis rotates/scales a 160 by 100 rectangle. Interpretor remains empty.
	extern vl::Ptr<vl::Object> AttachFullControlTestTouchingElement(vl::Ptr<vl::presentation::elements::GuiRawElementBase> element);
}

#endif
