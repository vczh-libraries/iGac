#include "osx_shared.h"
#include "gac_include.h"
#include "UI/FullControlTest/Source/Demo.h"
#include "../Mac/NativeWindow/OSX/CoreGraphics/CoreGraphicsApp.h"

#include <cstring>

using namespace vl;
using namespace vl::stream;
using namespace vl::presentation;

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
        auto resourceFolder = osx::GetResourceFolder();
        FileStream fileStream(resourceFolder + L"BlackSkin.bin", FileStream::ReadOnly);
        GetResourceManager()->LoadResourceOrPending(fileStream);
    }
    {
        demo::MainWindow window;
        if (!GetHostedApplication())
        {
            // TODO: In hosted mode this doesn't work, maybe needs to call the underlying INativeWindow
            window.SetControlThemeName(theme::ThemeName::Window);
        }
        window.ForceCalculateSizeImmediately();
        window.MoveToScreenCenter();
        GetApplication()->Run(&window);
    }
}
