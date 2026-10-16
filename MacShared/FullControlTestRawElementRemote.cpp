#include "FullControlTestRawElementRemote.h"
#include "FullControlTestRawElement.h"

namespace demo
{
	using namespace vl;
	using namespace vl::collections;
	using namespace vl::presentation::elements;
	using namespace vl::presentation::remote_renderer;

	class CocoaClockCollectionAttachment : public Object
	{
	protected:
		GuiRemoteRendererSingle&					renderer;
		Dictionary<GuiRawElementBase*, Ptr<Object>>	attachments;
		Ptr<EventHandler>						installed, changed, uninstalled;

		void Update(const GuiRemoteRawElementEventArgs& arguments)
		{
			auto element = arguments.element;
			if (element->GetId() == L"FullControlTest.Clock")
			{
				if (!attachments.Keys().Contains(element.Obj()))
				{
					attachments.Add(element.Obj(), AttachFullControlTestRawElement(element));
				}
			}
			else
			{
				attachments.Remove(element.Obj());
			}
		}
	public:
		CocoaClockCollectionAttachment(GuiRemoteRendererSingle& _renderer) : renderer(_renderer)
		{
			installed = renderer.RawElementInstalled.Add(this, &CocoaClockCollectionAttachment::Update);
			changed = renderer.RawElementChanged.Add(this, &CocoaClockCollectionAttachment::Update);
			uninstalled = renderer.RawElementUninstalled.Add([this](const GuiRemoteRawElementEventArgs& arguments)
			{
				attachments.Remove(arguments.element.Obj());
			});
			for (auto element : renderer.GetRawElements()) Update({ element });
		}

		~CocoaClockCollectionAttachment()
		{
			renderer.RawElementInstalled.Remove(installed);
			renderer.RawElementChanged.Remove(changed);
			renderer.RawElementUninstalled.Remove(uninstalled);
		}
	};

	Ptr<Object> AttachFullControlTestRawElements(GuiRemoteRendererSingle& renderer)
	{
		return Ptr(new CocoaClockCollectionAttachment(renderer));
	}
}
