#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"
#include "UI/Source/Demo.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();

    return 0;
}

using namespace vl::collections;
using namespace vl::stream;

void GuiMain()
{
    {
        FileStream fileStream(osx::GetResourceFolder() + L"DataGrid.bin", FileStream::ReadOnly);
        auto resource = GuiResource::LoadPrecompiledBinary(fileStream);
        GuiResourceError::List errors;
        GetResourceManager()->SetResource(resource, errors);
    }
    demo::MainWindow window;
    window.MoveToScreenCenter();
    GetApplication()->Run(&window);
}