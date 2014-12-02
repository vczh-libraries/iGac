#include "..\..\Public\Source\GacUI.h"

void SetupListControlWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiTextList* listControl=0;
	{
		listControl=g::NewTextList();
		listControl->GetBoundsComposition()->SetAlignmentToParent(Margin(200, 5, 5, 5));
		listControl->GetBoundsComposition()->SetBounds(Rect(0, 0, 300, 200));
		listControl->SetHorizontalAlwaysVisible(false);
		listControl->SetMultiSelect(true);
		container->AddChild(listControl->GetBoundsComposition());

		for(int i=0;i<30;i++)
		{
			listControl->GetItems().Add(new list::TextItem(L"Text Item "+itow(i+1)));
			listControl->GetItems().Get(i)->SetChecked(i % 2 == 0);
		}
	}
	{
		GuiTextList* typeList=g::NewTextList();
		typeList->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, -1, 5));
		typeList->GetBoundsComposition()->SetBounds(Rect(0, 0, 190, 200));
		typeList->SetHorizontalAlwaysVisible(false);
		container->AddChild(typeList->GetBoundsComposition());

		typeList->GetItems().Add(new list::TextItem(L"Text List"));
		typeList->GetItems().Add(new list::TextItem(L"Check List"));
		typeList->GetItems().Add(new list::TextItem(L"Radio List"));
		typeList->SetSelected(0, true);

		typeList->SelectionChanged.AttachLambda([listControl, typeList](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			if(typeList->GetSelectedItems().Count()>0)
			{
				switch(typeList->GetSelectedItems()[0])
				{
				case 0:
					listControl->ChangeItemStyle(GetCurrentTheme()->CreateTextListItemStyle());
					break;
				case 1:
					listControl->ChangeItemStyle(GetCurrentTheme()->CreateCheckTextListItemStyle());
					break;
				case 2:
					listControl->ChangeItemStyle(GetCurrentTheme()->CreateRadioTextListItemStyle());
					break;
				}
			}
		});
	}
}