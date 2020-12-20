#include "../../shared/osx_shared.h"
#include "../../shared/gac_include.h"

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
        font.size = 32;
        label->SetFont(font);

        label->SetText(L"Welcome to GacUI Library!");
    }
	window->AddChild(label);
    GetApplication()->Run(window);
}