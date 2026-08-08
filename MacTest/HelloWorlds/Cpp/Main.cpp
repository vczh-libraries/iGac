#include "osx_shared.h"
#include "gac_include.h"
#include "../../../Mac/NativeWindow/CocoaAutomationService.h"

#include <VlppOS.h>

using namespace vl::presentation::remoting;

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
	auto window = new GuiWindow(theme::ThemeName::Window);
	window->SetText(L"Hello, world!");
	window->SetClientSize(Size(480, 320));
	window->GetBoundsComposition()->SetPreferredMinSize(Size(480, 320));
	window->MoveToScreenCenter();

	auto label = new GuiLabel(theme::ThemeName::Label);
	{
		FontProperties font;
		font.fontFamily = L"Lucida Calligraphy";
		font.antialias = true;
		font.size = 32;
		label->SetFont(font);

		label->SetText(L"Welcome to GacUI Library!");
	}
	window->AddChild(label);

	vl::presentation::osx::CocoaAutomationService automationService;
	GetNativeServiceSubstitution()->Substitute(&automationService, false);
	auto socketServer = inter_process::async_tcp_socket::CreateDefaultAsyncSocketServer(8888);
	StartMiniHttpAutomationService(socketServer, WString::Unmanaged(L"Test_HellWorld_Cpp"));
	GetApplication()->Run(window);
	StopMiniHttpAutomationService();
	automationService.Stop();
	GetNativeServiceSubstitution()->Unsubstitute(&automationService);
}
