#ifndef VCZH_IGAC_FULLCONTROLTESTRAWELEMENT
#define VCZH_IGAC_FULLCONTROLTESTRAWELEMENT

#include "GacUI.h"

namespace demo
{
	// Retain through the window's drawing lifetime; destruction detaches the callback.
	extern vl::Ptr<vl::Object> AttachFullControlTestRawElement(vl::Ptr<vl::presentation::elements::GuiRawElementBase> element);
}

#endif
