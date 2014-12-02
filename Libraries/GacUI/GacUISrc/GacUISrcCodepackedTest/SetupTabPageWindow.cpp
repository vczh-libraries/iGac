#include "..\..\Public\Source\GacUI.h"

extern void SetupBasicWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupTabPageTextBoxlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupTabPageListControlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupTabPageToolstripWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupDialogWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupRibbonWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);

void SetupTabPageWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiTab* tab=g::NewTab();
	tab->GetBoundsComposition()->SetAlignmentToParent(Margin(6, 6, 6, 6));
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Basic");
		SetupBasicWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Text Layout");
		SetupTabPageTextBoxlWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"List Control");
		SetupTabPageListControlWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Toolstrip");
		SetupTabPageToolstripWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Dialogs");
		SetupDialogWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Ribbon (not completed)");
		SetupRibbonWindow(controlHost, page->GetContainerComposition());
	}
	container->AddChild(tab->GetBoundsComposition());
	tab->MovePage(tab->GetPages().Get(3), 2);
}