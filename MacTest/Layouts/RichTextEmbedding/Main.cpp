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

class ViewModel : public Object, public virtual demo::IViewModel
{
public:
	void OpenUrl(WString url)override
	{
        osx::LaunchURL(url.Buffer());
	}
};

void GuiMain()
{
	{
		List<WString> errors;
        FileStream fileStream(osx::GetResourceFolder() + L"RichTextEmbedding.bin", FileStream::ReadOnly);
		auto resource = GuiResource::LoadPrecompiledBinary(fileStream, errors);
		GetInstanceLoaderManager()->SetResource(L"Resource", resource);
	}
	demo::MainWindow window(new ViewModel);
	window.MoveToScreenCenter();
	GetApplication()->Run(&window);
}