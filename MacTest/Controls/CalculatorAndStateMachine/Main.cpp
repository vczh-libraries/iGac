#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"

#include "Demo.h"

#define VCZH_DEBUG_NO_REFLECTION

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
        List<GuiResourceError> errors;
        FileStream fileStream(osx::GetResourceFolder() + L"CalculatorAndStateMachine.bin", FileStream::ReadOnly);
        auto resource = GuiResource::LoadPrecompiledBinary(fileStream, errors);
        GetResourceManager()->SetResource(L"Resource", resource);
    }
    demo::MainWindow window(new demo::Calculator);
    window.MoveToScreenCenter();
    GetApplication()->Run(&window);
}