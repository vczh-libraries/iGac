#include "..\..\Public\Source\GacUI.h"

extern void SetupTextBoxWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupSolidLabelElementLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupDocumentElementLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container, const WString& filename);
extern void SetupDocumentViewerLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);
extern void SetupDocumentLabelLayoutWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container);

void SetupTabPageTextBoxlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiTab* tab=g::NewTab();
	tab->GetBoundsComposition()->SetAlignmentToParent(Margin(6, 6, 6, 6));
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Colorized TextBox");
		SetupTextBoxWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Solid Label Layout");
		SetupSolidLabelElementLayoutWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"document.xml");
		SetupDocumentElementLayoutWindow(controlHost, page->GetContainerComposition(), L"Resources\\document.xml");
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"document2.xml");
		SetupDocumentElementLayoutWindow(controlHost, page->GetContainerComposition(), L"Resources\\document2.xml");
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Document Viewer");
		SetupDocumentViewerLayoutWindow(controlHost, page->GetContainerComposition());
	}
	{
		GuiTabPage* page=tab->CreatePage();
		page->SetText(L"Document Label");
		SetupDocumentLabelLayoutWindow(controlHost, page->GetContainerComposition());
	}
	container->AddChild(tab->GetBoundsComposition());
}