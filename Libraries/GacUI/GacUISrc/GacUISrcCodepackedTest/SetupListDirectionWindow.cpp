#include "..\..\Public\Source\GacUI.h"

void SetupListDirectionWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	GuiListView* listControl=0;
	{
		listControl=g::NewListViewBigIcon();
		listControl->GetBoundsComposition()->SetAlignmentToParent(Margin(200, 5, 5, 5));
		listControl->GetBoundsComposition()->SetBounds(Rect(0, 0, 300, 200));
		listControl->SetHorizontalAlwaysVisible(false);
		listControl->SetVerticalAlwaysVisible(false);
		container->AddChild(listControl->GetBoundsComposition());
		
		INativeImageService* imageService=GetCurrentController()->ImageService();
		Ptr<INativeImage> largeImage=imageService->CreateImageFromFile(L"Resources\\BigDoc.png");
		Ptr<GuiImageData> largeImageData=new GuiImageData(largeImage, 0);
		Ptr<INativeImage> smallImage=imageService->CreateImageFromFile(L"Resources\\SmallDoc.png");
		Ptr<GuiImageData> smallImageData=new GuiImageData(smallImage, 0);

		for(int i=0;i<100;i++)
		{
			Ptr<list::ListViewItem> item=new list::ListViewItem;
			item->SetText(L"List View Item " + itow(i + 1));
			item->SetLargeImage(largeImageData);
			listControl->GetItems().Add(item);
		}
	}
	{
		GuiTextList* typeList=g::NewTextList();
		typeList->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, -1, 160));
		typeList->GetBoundsComposition()->SetBounds(Rect(0, 0, 190, 200));
		typeList->SetHorizontalAlwaysVisible(false);
		container->AddChild(typeList->GetBoundsComposition());

		typeList->GetItems().Add(new list::TextItem(L"Right Down"));
		typeList->GetItems().Add(new list::TextItem(L"Left Down"));
		typeList->GetItems().Add(new list::TextItem(L"Right Up"));
		typeList->GetItems().Add(new list::TextItem(L"Left Up"));
		typeList->GetItems().Add(new list::TextItem(L"Down Right"));
		typeList->GetItems().Add(new list::TextItem(L"Down Left"));
		typeList->GetItems().Add(new list::TextItem(L"Up Right"));
		typeList->GetItems().Add(new list::TextItem(L"Up Left"));
		typeList->SetSelected(0, true);

		typeList->SelectionChanged.AttachLambda([listControl, typeList](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			if(typeList->GetSelectedItems().Count()>0)
			{
				switch(typeList->GetSelectedItems()[0])
				{
				case 0:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::RightDown));
					break;
				case 1:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::LeftDown));
					break;
				case 2:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::RightUp));
					break;
				case 3:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::LeftUp));
					break;
				case 4:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::DownRight));
					break;
				case 5:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::DownLeft));
					break;
				case 6:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::UpRight));
					break;
				case 7:
					listControl->SetCoordinateTransformer(new list::AxisAlignedItemCoordinateTransformer(list::AxisAlignedItemCoordinateTransformer::UpLeft));
					break;
				}
			}
		});
	}
	{
		GuiTextList* typeList=g::NewTextList();
		typeList->GetBoundsComposition()->SetAlignmentToParent(Margin(5, -1, -1, 5));
		typeList->GetBoundsComposition()->SetBounds(Rect(0, 0, 190, 145));
		typeList->SetHorizontalAlwaysVisible(false);
		container->AddChild(typeList->GetBoundsComposition());

		typeList->GetItems().Add(new list::TextItem(L"Block"));
		typeList->GetItems().Add(new list::TextItem(L"Item"));
		typeList->SetSelected(0, true);

		typeList->SelectionChanged.AttachLambda([listControl, typeList](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			if(typeList->GetSelectedItems().Count()>0)
			{
				switch(typeList->GetSelectedItems()[0])
				{
				case 0:
					listControl->SetArranger(new list::FixedSizeMultiColumnItemArranger);
					break;
				case 1:
					listControl->SetArranger(new list::FixedHeightItemArranger);
					break;
				}
			}
		});
	}
}