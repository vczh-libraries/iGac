#include "HelloWorld.h"
#include <Windows.h>

using namespace vl::collections;
using namespace demos;

int CALLBACK WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int CmdShow)
{
	return SetupWindowsDirect2DRenderer();
}

void GuiMain()
{
	List<WString> errors;
	auto resource = GuiResource::LoadFromXml(L"XmlWindowResource.precompiled.xml", errors);
	GetInstanceLoaderManager()->SetResource(L"HelloWorld", resource);

	MainWindow window;
	window.ForceCalculateSizeImmediately();
	window.MoveToScreenCenter();
	GetApplication()->Run(&window);
}