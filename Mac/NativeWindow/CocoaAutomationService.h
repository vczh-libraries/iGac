#ifndef VCZH_PRESENTATION_OSX_COCOAAUTOMATIONSERVICE
#define VCZH_PRESENTATION_OSX_COCOAAUTOMATIONSERVICE

#include "OSX/CocoaNativeController.h"

namespace vl
{
	namespace presentation
	{
		class AutomationService;
		class AutomationServiceHosted;

		namespace osx
		{
			template<typename TBase>
			class CocoaAutomationServiceBase : public TBase
			{
			protected:
				WString										RunIOCommandInternal(Nullable<WString> windowId, const WString& ioCommand) override;

			public:
				template<typename ...TArgs>
				CocoaAutomationServiceBase(TArgs&& ...args)
					: TBase(std::forward<TArgs>(args)...)
				{
				}

				void										Stop() override;
				INativeAutomationService::IOCommandAvailability
															CanRunIOCommands() override;
			};

			class CocoaAutomationService : public CocoaAutomationServiceBase<AutomationService>
			{
			protected:
				Nullable<WString>							GetNativeWindowId(INativeWindow* window) override;
				INativeWindow*								GetNativeWindow(Nullable<WString> windowId) override;

			public:
				CocoaAutomationService();
				~CocoaAutomationService();
			};

			class CocoaAutomationServiceHosted : public CocoaAutomationServiceBase<AutomationServiceHosted>
			{
			public:
				CocoaAutomationServiceHosted();
				~CocoaAutomationServiceHosted();
			};

			class CocoaAutomationServiceRenderer : public CocoaAutomationServiceBase<AutomationServiceRenderer>
			{
			public:
				CocoaAutomationServiceRenderer(remote_renderer::GuiRemoteRendererSingle* _renderer);
				~CocoaAutomationServiceRenderer();

				INativeAutomationService::IOCommandAvailability
															CanRunIOCommands() override;
			};
		}
	}
}

#endif
