#include "gac_include.h"
#include "FullControlTest.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"

#include <cstring>
#include <VlppOS.h>

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::remoting;

int main(int argc, const char * argv[])
{
    bool hosted = false;
    for (int i = 1; i < argc; i++)
    {
        if (strcmp(argv[i], "--hosted") == 0) hosted = true;
    }

    if (hosted)
        SetupOSXHostedCoreGraphicsRenderer();
    else
        SetupOSXCoreGraphicsRenderer();
    return 0;
}

void GuiMain()
{
    {
        demo::MainWindow window;
        window.ForceCalculateSizeImmediately();
        window.MoveToScreenCenter();
        auto socketServer = inter_process::async_tcp_socket::CreateDefaultAsyncSocketServer(8888);
        StartMiniHttpAutomationService(socketServer, WString::Unmanaged(L"Test_FullControlTest"));
        try
        {
            GetApplication()->Run(&window);
        }
        catch (...)
        {
            StopMiniHttpAutomationService();
            throw;
        }
        StopMiniHttpAutomationService();
    }
}
