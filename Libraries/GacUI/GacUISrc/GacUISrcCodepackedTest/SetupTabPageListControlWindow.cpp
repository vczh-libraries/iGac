#include "..\..\Public\Source\GacUI.h"

extern void SetupListControlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupListDirectionWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupListviewWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupTreeviewWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupDatagridElementsWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupDatagridExplorerWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);

void SetupTabPageListControlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiTab* tab=g::NewTab();
	tab->GetBoundsComposition()->SetAlignmentToParent(Margin(6, 6, 6, 6));
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Text List");
		SetupListControlWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Layout Direction");
		SetupListDirectionWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"List View");
		SetupListviewWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Tree View");
		SetupTreeviewWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Data Grid (Elements)");
		SetupDatagridElementsWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Data Grid (Explorer)");
		SetupDatagridExplorerWindow(controlHost, page->GetContainerComposition());
	}
	container->AddChild(tab->GetBoundsComposition());
}