#include "..\..\Public\Source\GacUI.h"

void SetupMainPanel(GuiControlHost* controlHost, GuiGraphicsComposition* container, GuiCellComposition* cell)
{
	{
		GuiControl* groupBox=g::NewGroupBox();
		cell->AddChild(groupBox->GetBoundsComposition());
		groupBox->GetBoundsComposition()->SetBounds(Rect(Point(0, 0), Size(200, 200)));
		groupBox->SetText(L"GroupBox1");

		GuiButton* buttonBig=g::NewButton();
		groupBox->GetContainerComposition()->AddChild(buttonBig->GetBoundsComposition());
		buttonBig->GetBoundsComposition()->SetAlignmentToParent(Margin(10, 10, 10, 10));
		buttonBig->SetText(L"I am a big button!");
		{
			GuiButton* buttonEnabling=g::NewButton();
			cell->AddChild(buttonEnabling->GetBoundsComposition());
			buttonEnabling->GetBoundsComposition()->SetBounds(Rect(Point(0, 210), Size(200, 25)));
			buttonEnabling->SetText(L"Disable GroupBox1");

			buttonEnabling->Clicked.AttachLambda([groupBox, buttonEnabling](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				if(groupBox->GetEnabled())
				{
					buttonEnabling->SetText(L"Enable GroupBox1");
				}
				else
				{
					buttonEnabling->SetText(L"Disable GroupBox1");
				}
				groupBox->SetEnabled(!groupBox->GetEnabled());
			});
		}
		{
			GuiButton* buttonEnabling=g::NewButton();
			cell->AddChild(buttonEnabling->GetBoundsComposition());
			buttonEnabling->GetBoundsComposition()->SetBounds(Rect(Point(0, 245), Size(200, 25)));
			buttonEnabling->SetText(L"Disable big button");

			buttonEnabling->Clicked.AttachLambda([buttonBig, buttonEnabling](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				if(buttonBig->GetEnabled())
				{
					buttonEnabling->SetText(L"Enable big button");
				}
				else
				{
					buttonEnabling->SetText(L"Disable big button");
				}
				buttonBig->SetEnabled(!buttonBig->GetEnabled());
			});
		}
		{
			GuiMultilineTextBox* textBox=g::NewMultilineTextBox();
			cell->AddChild(textBox->GetBoundsComposition());
			textBox->GetBoundsComposition()->SetBounds(Rect(Point(0, 280), Size(200, 180)));

			const wchar_t* text=
				L"#include <iostream>"											L"\r\n"
				L"using namespace std;"											L"\r\n"
				L""																L"\r\n"
				L"int main()"													L"\r\n"
				L"{"															L"\r\n"
				L"    cout<<\"Hello, world! This is Vczh GUI Demo.\"<<endl;"	L"\r\n"
				L"}"															L"\r\n"
				;
			textBox->SetText(text);

			GuiButton* buttonEnabling=g::NewButton();
			cell->AddChild(buttonEnabling->GetBoundsComposition());
			buttonEnabling->GetBoundsComposition()->SetBounds(Rect(Point(0, 470), Size(200, 25)));
			buttonEnabling->SetText(L"Disable TextBox");

			buttonEnabling->Clicked.AttachLambda([textBox, buttonEnabling](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				if(textBox->GetEnabled())
				{
					buttonEnabling->SetText(L"Enable TextBox");
				}
				else
				{
					buttonEnabling->SetText(L"Disable TextBox");
				}
				textBox->SetEnabled(!textBox->GetEnabled());
			});
		}
	}
	{
		GuiControl* groupBox=g::NewGroupBox();
		cell->AddChild(groupBox->GetBoundsComposition());
		groupBox->GetBoundsComposition()->SetBounds(Rect(Point(210, 0), Size(200, 200)));
		groupBox->SetText(L"GroupBox2");
		{
			GuiSelectableButton* checkBox=g::NewCheckBox();
			groupBox->GetContainerComposition()->AddChild(checkBox->GetBoundsComposition());
			checkBox->GetBoundsComposition()->SetAlignmentToParent(Margin(10, 5, 10, -1));
			checkBox->SetText(L"CheckBox 1");
		}
		{
			GuiSelectableButton* checkBox=g::NewCheckBox();
			groupBox->GetContainerComposition()->AddChild(checkBox->GetBoundsComposition());
			checkBox->GetBoundsComposition()->SetAlignmentToParent(Margin(10, 40, 10, -1));
			checkBox->SetText(L"CheckBox 2");
		}
		{
			GuiSelectableButton::MutexGroupController* controller=new GuiSelectableButton::MutexGroupController;
			controlHost->AddComponent(controller);

			for(int i=0;i<3;i++)
			{
				GuiSelectableButton* radioButton=g::NewRadioButton();
				groupBox->GetContainerComposition()->AddChild(radioButton->GetBoundsComposition());
				radioButton->GetBoundsComposition()->SetBounds(Rect(Point(10, 75+i*35), Size(200, 25)));
				radioButton->SetText(L"RadioButton "+itow(i+1));
				radioButton->SetGroupController(controller);
			}
		}
		{
			GuiButton* buttonEnabling=g::NewButton();
			cell->AddChild(buttonEnabling->GetBoundsComposition());
			buttonEnabling->GetBoundsComposition()->SetBounds(Rect(Point(210, 210), Size(200, 25)));
			buttonEnabling->SetText(L"Disable GroupBox2");

			buttonEnabling->Clicked.AttachLambda([groupBox, buttonEnabling](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				if(groupBox->GetEnabled())
				{
					buttonEnabling->SetText(L"Enable GroupBox2");
				}
				else
				{
					buttonEnabling->SetText(L"Disable GroupBox2");
				}
				groupBox->SetEnabled(!groupBox->GetEnabled());
			});
		}
		{
			GuiSinglelineTextBox* textBox=g::NewTextBox();
			cell->AddChild(textBox->GetBoundsComposition());
			textBox->GetBoundsComposition()->SetBounds(Rect(Point(210, 245), Size(200, 27)));
			textBox->SetText(L"Singleline TextBox");
		}
		{
			GuiSinglelineTextBox* textBox=g::NewTextBox();
			textBox->SetPasswordChar(L'*');
			cell->AddChild(textBox->GetBoundsComposition());
			textBox->GetBoundsComposition()->SetBounds(Rect(Point(210, 280), Size(200, 27)));
			textBox->SetText(L"Password TextBox");
		}
	}
	{
		GuiScrollContainer* scrollView=g::NewScrollContainer();
		cell->AddChild(scrollView->GetBoundsComposition());
		scrollView->GetBoundsComposition()->SetBounds(Rect(Point(420, 0), Size(200, 200)));
		{
			GuiButton* buttonAdd=g::NewButton();
			cell->AddChild(buttonAdd->GetBoundsComposition());
			buttonAdd->GetBoundsComposition()->SetBounds(Rect(Point(420, 210), Size(200, 25)));
			buttonAdd->SetText(L"Add Button");

			buttonAdd->Clicked.AttachLambda([scrollView](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				int count=0;
				for(int i=0;i<scrollView->GetChildrenCount();i++)
				{
					if(dynamic_cast<GuiButton*>(scrollView->GetChild(i)))
					{
						count++;
					}
				}
				GuiButton* child=g::NewButton();
				child->GetBoundsComposition()->SetBounds(Rect(Point(0, count*40), Size(200, 30)));
				child->SetText(L"Button "+itow(count+1));
				scrollView->GetContainerComposition()->AddChild(child->GetBoundsComposition());
			});
		}
		{
			GuiButton* buttonClear=g::NewButton();
			cell->AddChild(buttonClear->GetBoundsComposition());
			buttonClear->GetBoundsComposition()->SetBounds(Rect(Point(420, 245), Size(200, 25)));
			buttonClear->SetText(L"Clear Buttons");

			buttonClear->Clicked.AttachLambda([scrollView](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				for(vint i=scrollView->GetChildrenCount()-1;i>=0;i--)
				{
					GuiControl* child=scrollView->GetChild(i);
					if(dynamic_cast<GuiButton*>(child))
					{
						scrollView->GetContainerComposition()->RemoveChild(child->GetBoundsComposition());
						delete child;
					}
				}
			});
		}
		{
			GuiButton* buttonHorizontal=g::NewButton();
			cell->AddChild(buttonHorizontal->GetBoundsComposition());
			buttonHorizontal->GetBoundsComposition()->SetBounds(Rect(Point(420, 280), Size(200, 25)));
			buttonHorizontal->SetText(L"Horizontal Scroll Bar");

			buttonHorizontal->Clicked.AttachLambda([scrollView](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				scrollView->SetHorizontalAlwaysVisible(!scrollView->GetHorizontalAlwaysVisible());
			});
		}
		{
			GuiButton* buttonVertical=g::NewButton();
			cell->AddChild(buttonVertical->GetBoundsComposition());
			buttonVertical->GetBoundsComposition()->SetBounds(Rect(Point(420, 315), Size(200, 25)));
			buttonVertical->SetText(L"Vertical Scroll Bar");

			buttonVertical->Clicked.AttachLambda([scrollView](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
			{
				scrollView->SetVerticalAlwaysVisible(!scrollView->GetVerticalAlwaysVisible());
			});
		}
		{
			GuiTextList* listControl=0;
			{
				listControl=g::NewTextList();
				listControl->GetBoundsComposition()->SetAlignmentToParent(Margin(200, 5, 5, 5));
				listControl->SetHorizontalAlwaysVisible(false);

				for(int i=0;i<30;i++)
				{
					listControl->GetItems().Add(new list::TextItem(L"Text Item "+itow(i+1)));
					listControl->GetItems().Get(i)->SetChecked(i % 2 == 0);
				}
			}
			GuiComboBoxListControl* comboBox=g::NewComboBox(listControl);
			comboBox->GetBoundsComposition()->SetBounds(Rect(Point(420, 350), Size(200, 25)));
			comboBox->SetSelectedIndex(0);
			cell->AddChild(comboBox->GetBoundsComposition());
		}
		{
			GuiListView* listControl=0;
			{
				listControl=g::NewListViewBigIcon();
				listControl->GetBoundsComposition()->SetAlignmentToParent(Margin(200, 5, 5, 5));
				listControl->SetHorizontalAlwaysVisible(false);
				listControl->SetVerticalAlwaysVisible(false);
		
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
			GuiComboBoxListControl* comboBox=g::NewComboBox(listControl);
			comboBox->GetBoundsComposition()->SetBounds(Rect(Point(420, 385), Size(200, 25)));
			comboBox->SetSelectedIndex(0);
			cell->AddChild(comboBox->GetBoundsComposition());
		}
		{
			GuiTreeView* treeControl=0;
			{
				treeControl=g::NewTreeView();
				treeControl->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, 5, 5));
				treeControl->SetHorizontalAlwaysVisible(false);
				treeControl->SetVerticalAlwaysVisible(false);
		
				INativeImageService* imageService=GetCurrentController()->ImageService();
				Ptr<INativeImage> image=imageService->CreateImageFromFile(L"Resources\\SmallDoc.png");
				Ptr<GuiImageData> imageData=new GuiImageData(image, 0);

				treeControl->Nodes()->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Microsoft")));
				{
					Ptr<tree::MemoryNodeProvider> node=treeControl->Nodes()->Children()[0];
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Visual C++")));
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Visual C#")));
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Visual Basic.NET")));
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Visual F#")));
				}
				treeControl->Nodes()->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"IBM")));
				{
					Ptr<tree::MemoryNodeProvider> node=treeControl->Nodes()->Children()[1];
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Eclipse")));
				}
				treeControl->Nodes()->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Borland")));
				{
					Ptr<tree::MemoryNodeProvider> node=treeControl->Nodes()->Children()[2];
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"Delphi")));
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"C++ Builder")));
					node->Children().Add(new tree::MemoryNodeProvider(new tree::TreeViewItem(imageData, L"JBuilder")));
				}
			}
			GuiComboBoxListControl* comboBox=g::NewComboBox(treeControl);
			comboBox->GetBoundsComposition()->SetBounds(Rect(Point(420, 420), Size(200, 25)));
			cell->AddChild(comboBox->GetBoundsComposition());
		}
		{
			GuiDateComboBox* comboBox=g::NewDateComboBox();
			comboBox->GetBoundsComposition()->SetBounds(Rect(Point(420, 455), Size(200, 25)));
			cell->AddChild(comboBox->GetBoundsComposition());
		}
	}
}