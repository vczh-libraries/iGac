#include "osx_shared.h"
#include "gac_include.h"
#include "UI/FullControlTest/Source/Demo.h"

using namespace vl;
using namespace vl::stream;
using namespace vl::presentation;

int main(int argc, const char * argv[])
{
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
        window.ForceCalculateSizeImmediately();
        window.MoveToScreenCenter();
        GetApplication()->Run(&window);
    }
}
