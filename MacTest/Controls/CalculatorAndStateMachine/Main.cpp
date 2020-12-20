#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"

#include "Demo.h"

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
        FileStream fileStream(osx::GetResourceFolder() + L"CalculatorAndStateMachine.bin", FileStream::ReadOnly);
        auto resource = GuiResource::LoadPrecompiledBinary(fileStream);
        GuiResourceError::List errors;
        GetResourceManager()->SetResource(resource, errors);
    }
    demo::MainWindow window(new demo::Calculator);
    window.MoveToScreenCenter();
    GetApplication()->Run(&window);
}