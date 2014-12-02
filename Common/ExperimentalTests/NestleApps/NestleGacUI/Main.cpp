#if _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>
#endif

#pragma comment(linker,"\"/manifestdependency:type='win32' name='Microsoft.Windows.Common-Controls' version='6.0.0.0' processorArchitecture='*' publicKeyToken='6595b64144ccf1df' language='*'\"")

#include "MainWindow.h"

using namespace vl;
using namespace vl::nestle;

/***********************************************************************
WinMain
***********************************************************************/

#define GUI_GRAPHICS_RENDERER_DIRECT2D

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int CmdShow)
{
	int result=SetupWindowsDirect2DRenderer();

#if _DEBUG
	_CrtDumpMemoryLeaks();
#endif
	return result;
}

/***********************************************************************
GuiMain
***********************************************************************/

void GuiMain()
{
	{
		FontProperties font=GetCurrentController()->ResourceService()->GetDefaultFont();
		font.size=16;
		GetCurrentController()->ResourceService()->SetDefaultFont(font);
	}
	MainWindow window;
	GetApplication()->Run(&window);
}