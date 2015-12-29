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
		List<WString> errors;
        FileStream fileStream(osx::GetResourceFolder() + L"Table.bin", FileStream::ReadOnly);
		auto resource = GuiResource::LoadPrecompiledBinary(fileStream, errors);
		GetInstanceLoaderManager()->SetResource(L"Resource", resource);
	}
	demo::MainWindow window;
	window.MoveToScreenCenter();
	GetApplication()->Run(&window);
}