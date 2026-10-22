#include "../MacShared/gac_include.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"
#include <chrono>
#include <cstdio>
#include <cstdlib>
#include <thread>

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::controls;

class ModalTimerListener : public Object, public INativeControllerListener
{
public:
	GuiWindow* owner = nullptr;
	bool inModal = false;
	bool queuedTaskRan = false;
	vint ticks = 0;

	void GlobalTimer() override
	{
		if (!inModal || ++ticks != 2) return;
		GetApplication()->InvokeInMainThread(owner, [this]()
		{
			for (auto window : GetApplication()->GetWindows())
			{
				if (window != owner && window->GetVisible())
				{
					queuedTaskRan = true;
					window->Close();
					break;
				}
			}
		});
	}
};

TEST_FILE
{
	TEST_CASE(L"Hosted modal opened by queued input keeps timers and queued tasks running")
	{
		std::jthread watchdog([](std::stop_token stop)
		{
			for (vint i = 0; i < 200 && !stop.stop_requested(); i++)
			{
				std::this_thread::sleep_for(std::chrono::milliseconds(50));
			}
			if (!stop.stop_requested())
			{
				std::fputs("Hosted modal event pump timed out.\n", stderr);
				std::_Exit(1);
			}
		});

		GuiWindow owner(theme::ThemeName::Window);
		owner.SetText(L"Hosted modal event pump regression");
		owner.SetClientSize(Size(480, 320));
		ModalTimerListener listener;
		listener.owner = &owner;
		auto callbacks = GetCurrentController()->CallbackService();
		callbacks->InstallListener(&listener);
		vint completed = 0;
		GetApplication()->InvokeInMainThread(&owner, [&]()
		{
			for (vint i = 0; i < 2; i++)
			{
				listener.ticks = 0;
				listener.queuedTaskRan = false;
				listener.inModal = true;
				GetCurrentController()->DialogService()->ShowMessageBox(
					owner.GetNativeWindow(), L"Close from a queued task after two timer ticks.",
					L"Hosted modal", INativeDialogService::DisplayOK,
					INativeDialogService::DefaultFirst, INativeDialogService::IconNone,
					INativeDialogService::ModalWindow);
				listener.inModal = false;
				if (listener.ticks >= 2 && listener.queuedTaskRan) completed++;
			}
			owner.Close();
		});
		GetApplication()->Run(&owner);
		callbacks->UninstallListener(&listener);
		TEST_ASSERT(completed == 2);
	});
}

int testArgc = 0;
char** testArgv = nullptr;
int testResult = 0;

void GuiMain()
{
	testResult = unittest::UnitTest::RunAndDisposeTests(testArgc, testArgv);
}

int main(int argc, char* argv[])
{
	testArgc = argc;
	testArgv = argv;
	auto result = SetupOSXHostedCoreGraphicsRenderer();
	return result == 0 ? testResult : result;
}
