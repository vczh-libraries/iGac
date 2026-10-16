#ifndef VCZH_IGAC_FULLCONTROLTESTRAWELEMENTREMOTE
#define VCZH_IGAC_FULLCONTROLTESTRAWELEMENTREMOTE

#include "GacUI.h"

namespace demo
{
	// Destroy this attachment before the renderer. Disconnection retains the last picture.
	extern vl::Ptr<vl::Object> AttachFullControlTestRawElements(vl::presentation::remote_renderer::GuiRemoteRendererSingle& renderer);
}

#endif
