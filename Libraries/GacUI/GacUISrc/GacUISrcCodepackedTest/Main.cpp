#if _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif

#pragma comment(linker,"\"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

#include "..\..\Public\Source\GacUI.h"
#include <Windows.h>

#define GUI_GRAPHICS_RENDERER_DIRECT2D

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int CmdShow)
{
#ifdef GUI_GRAPHICS_RENDERER_GDI
	int result=SetupWindowsGDIRenderer();
#endif
#ifdef GUI_GRAPHICS_RENDERER_DIRECT2D
	int result=SetupWindowsDirect2DRenderer();
#endif

#if _DEBUG
	_CrtDumpMemoryLeaks();
#endif
	return result;
}
extern void SetupTabPageWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);

/***********************************************************************
MainWindow
***********************************************************************/

class MainWindow : public GuiWindow
{
public:
	MainWindow()
		:GuiWindow(GetCurrentTheme()->CreateWindowStyle())
	{
#ifdef GUI_GRAPHICS_RENDERER_GDI
		SetText(L"Vczh GUI Demo (GDI): "+GetCurrentController()->GetOSVersion());
#endif
#ifdef GUI_GRAPHICS_RENDERER_DIRECT2D
		SetText(L"Vczh GUI Demo (Direct2D): "+GetCurrentController()->GetOSVersion());
#endif
		SetClientSize(Size(800, 660));
		MoveToScreenCenter();
		SetupTabPageWindow(this, this->GetContainerComposition());
	}
};

/***********************************************************************
GuiMain
***********************************************************************/

void GuiMain()
{
	MainWindow window;
	GetApplication()->Run(&window);
}