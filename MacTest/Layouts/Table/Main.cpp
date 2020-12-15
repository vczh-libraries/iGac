#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"

#include "Demo.h"
#include "Skins/DarkSkin/DarkSkin.h"

#define VCZH_DEBUG_NO_REFLECTION

class DefaultSkinPlugin : public Object, public IGuiPlugin
{
public:

    GUI_PLUGIN_NAME(Custom_DefaultSkinPlugin)
    {
        GUI_PLUGIN_DEPEND(GacGen_DarkSkinResourceLoader);
    }

    void Load()override
    {
        RegisterTheme(L"DarkSkin", MakePtr<darkskin::Theme>());
    }

    void Unload()override
    {
    }
};
GUI_REGISTER_PLUGIN(DefaultSkinPlugin)

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
        FileStream fileStream(osx::GetResourceFolder() + L"Table.bin", FileStream::ReadOnly);
		auto resource = GuiResource::LoadPrecompiledBinary(fileStream, errors);
		GetResourceManager()->SetResource(L"Resource", resource);
	}
	demo::MainWindow window;
	window.MoveToScreenCenter();
	GetApplication()->Run(&window);
}