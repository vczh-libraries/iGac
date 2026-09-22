#include "CocoaAutomationService.h"
#include "OSX/CocoaWindow.h"

namespace vl
{
	namespace presentation
	{
		namespace osx
		{

/***********************************************************************
CocoaAutomationServiceBase
***********************************************************************/

			template<typename TBase>
			WString CocoaAutomationServiceBase<TBase>::RunIOCommandInternal(Nullable<WString> windowId, const WString& ioCommand)
			{
				auto cocoaWindow = dynamic_cast<CocoaWindow*>(this->GetNativeWindow(windowId));
				if (!cocoaWindow)
				{
					return L"!Invalid window.";
				}

				return RunIOCommandOnNativeWindow(&this->ioCommandState, GetOSXNativeController(), cocoaWindow, cocoaWindow->listeners, ioCommand);
			}

			template<typename TBase>
			void CocoaAutomationServiceBase<TBase>::Stop()
			{
				TBase::Stop();
			}

			template<typename TBase>
			INativeAutomationService::IOCommandAvailability CocoaAutomationServiceBase<TBase>::CanRunIOCommands()
			{
				return INativeAutomationService::IOCommandAvailability::Enabled;
			}

/***********************************************************************
CocoaAutomationService
***********************************************************************/

			Nullable<WString> CocoaAutomationService::GetNativeWindowId(INativeWindow* window)
			{
#define ERROR_MESSAGE_PREFIX L"vl::presentation::osx::CocoaAutomationService::GetNativeWindowId(INativeWindow*)#"
				collections::List<CocoaWindow*> windows;
				GetAllCreatedCocoaWindows(windows);
				CHECK_ERROR(windows.Contains(dynamic_cast<CocoaWindow*>(window)), ERROR_MESSAGE_PREFIX L"The specified INativeWindow instance should be native.");
				return u64tow(static_cast<vuint64_t>(reinterpret_cast<uintptr_t>(window)));
#undef ERROR_MESSAGE_PREFIX
			}

			INativeWindow* CocoaAutomationService::GetNativeWindow(Nullable<WString> windowId)
			{
				if (windowId)
				{
					auto id = wtou64(windowId.Value());
					auto address = static_cast<uintptr_t>(id);
					if (static_cast<vuint64_t>(address) != id)
					{
						return nullptr;
					}
					auto expectedWindow = reinterpret_cast<INativeWindow*>(address);
					collections::List<CocoaWindow*> windows;
					GetAllCreatedCocoaWindows(windows);
					for (auto cocoaWindow : windows)
					{
						auto window = static_cast<INativeWindow*>(cocoaWindow);
						if (window == expectedWindow)
						{
							return window;
						}
					}
					return nullptr;
				}
				else
				{
					return GetOSXNativeController()->WindowService()->GetMainWindow();
				}
			}

			CocoaAutomationService::CocoaAutomationService()
			{
			}

			CocoaAutomationService::~CocoaAutomationService()
			{
			}

/***********************************************************************
CocoaAutomationServiceHosted
***********************************************************************/

			CocoaAutomationServiceHosted::CocoaAutomationServiceHosted()
			{
			}

			CocoaAutomationServiceHosted::~CocoaAutomationServiceHosted()
			{
			}

/***********************************************************************
CocoaAutomationServiceRenderer
***********************************************************************/

			CocoaAutomationServiceRenderer::CocoaAutomationServiceRenderer(remote_renderer::GuiRemoteRendererSingle* _renderer)
				: CocoaAutomationServiceBase<AutomationServiceRenderer>(_renderer)
			{
			}

			CocoaAutomationServiceRenderer::~CocoaAutomationServiceRenderer()
			{
			}

			INativeAutomationService::IOCommandAvailability CocoaAutomationServiceRenderer::CanRunIOCommands()
			{
				return AutomationServiceRenderer::CanRunIOCommands();
			}
		}
	}
}
