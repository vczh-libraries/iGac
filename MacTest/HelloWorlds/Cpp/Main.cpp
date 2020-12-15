#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"
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
        label->SetFont(font);
        label->SetText(L"Welcome to GacUI Library!");
    }
	window->AddChild(label);
    GetApplication()->Run(window);
}