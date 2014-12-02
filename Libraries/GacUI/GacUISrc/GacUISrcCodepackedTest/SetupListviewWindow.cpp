#include "..\..\Public\Source\GacUI.h"

void SetupListviewWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiListView* listControl=0;
	{
		listControl=g::NewListViewBigIcon();
		listControl->GetBoundsComposition()->SetAlignmentToParent(Margin(200, 5, 5, 5));
		listControl->GetBoundsComposition()->SetBounds(Rect(0, 0, 300, 200));
		listControl->SetHorizontalAlwaysVisible(false);
		listControl->SetVerticalAlwaysVisible(false);
		listControl->SetMultiSelect(true);
		container->AddChild(listControl->GetBoundsComposition());
		
		INativeImageService* imageService=GetCurrentController()->ImageService();
		Ptr<INativeImage> largeImage=imageService->CreateImageFromFile(L"Resources\\BigDoc.png");
		Ptr<GuiImageData> largeImageData=new GuiImageData(largeImage, 0);
		Ptr<INativeImage> smallImage=imageService->CreateImageFromFile(L"Resources\\SmallDoc.png");
		Ptr<GuiImageData> smallImageData=new GuiImageData(smallImage, 0);

		for(int i=0;i<100;i++)
		{
			Ptr<list::ListViewItem> item=new list::ListViewItem;
			if(i<10)
			{
				item->SetText(L"This is a very long List View Item " + itow(i + 1));
			}
			else
			{
				item->SetText(L"List View Item " + itow(i + 1));
			}
			item->SetLargeImage(largeImageData);
			item->SetSmallImage(smallImageData);
			item->GetSubItems().Add(L"Description of " + item->GetText());
			item->GetSubItems().Add(itow(i + 1));
			item->GetSubItems().Add(i < 10 ? L"Long" : L"Short");
			listControl->GetItems().Add(item);
		}
		listControl->GetItems().GetColumns().Add(new list::ListViewColumn(L"Name"));
		listControl->GetItems().GetColumns().Add(new list::ListViewColumn(L"Description"));
		listControl->GetItems().GetColumns().Add(new list::ListViewColumn(L"Index"));
		listControl->GetItems().GetColumns().Add(new list::ListViewColumn(L"Type"));
	}
	{
		GuiTextList* typeList=g::NewTextList();
		typeList->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, -1, 5));
		typeList->GetBoundsComposition()->SetBounds(Rect(0, 0, 190, 200));
		typeList->SetHorizontalAlwaysVisible(false);
		container->AddChild(typeList->GetBoundsComposition());

		typeList->GetItems().Add(new list::TextItem(L"Big Icon"));
		typeList->GetItems().Add(new list::TextItem(L"Small Icon"));
		typeList->GetItems().Add(new list::TextItem(L"List"));
		typeList->GetItems().Add(new list::TextItem(L"Detail"));
		typeList->GetItems().Add(new list::TextItem(L"Tile"));
		typeList->GetItems().Add(new list::TextItem(L"Information"));
		typeList->SetSelected(0, true);

		typeList->SelectionChanged.AttachLambda([listControl, typeList](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			if(typeList->GetSelectedItems().Count()>0)
			{
				listControl->GetItems().GetDataColumns().Clear();
				switch(typeList->GetSelectedItems()[0])
				{
				case 0:
					listControl->ChangeItemStyle(new list::ListViewBigIconContentProvider);
					break;
				case 1:
					listControl->ChangeItemStyle(new list::ListViewSmallIconContentProvider);
					break;
				case 2:
					listControl->ChangeItemStyle(new list::ListViewListContentProvider);
					break;
				case 3:
					listControl->ChangeItemStyle(new list::ListViewDetailContentProvider);
					break;
				case 4:
					listControl->GetItems().GetDataColumns().Add(0);
					listControl->GetItems().GetDataColumns().Add(2);
					listControl->ChangeItemStyle(new list::ListViewTileContentProvider);
					break;
				case 5:
					listControl->GetItems().GetDataColumns().Add(1);
					listControl->GetItems().GetDataColumns().Add(2);
					listControl->ChangeItemStyle(new list::ListViewInformationContentProvider);
					break;
				}
			}
		});
	}
}