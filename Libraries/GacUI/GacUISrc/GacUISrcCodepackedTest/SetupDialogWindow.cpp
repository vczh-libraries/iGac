#include "..\..\Public\Source\GacUI.h"

using namespace collections;

namespace SetupDialogWindowHelper
{
	GuiComboBoxListControl* CreateComboBox(const wchar_t** items, int count)
	{
		GuiTextList* listControl=g::NewTextList();
		listControl->SetHorizontalAlwaysVisible(false);
		listControl->SetVerticalAlwaysVisible(true);
		for(int i=0;i<count;i++)
		{
			listControl->GetItems().Add(new list::TextItem(items[i]));
		}

		GuiComboBoxListControl* comboBox=g::NewComboBox(listControl);
		comboBox->SetSelectedIndex(0);
		return comboBox;
	}
}
using namespace SetupDialogWindowHelper;

void SetupDialogWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	{
		const wchar_t* input[]={L"OK", L"OKCancel", L"YesNo", L"YesNoCancel", L"RetryCancel", L"AbortRetryIgnore", L"CancelTryAgainContinue"};
		const wchar_t* defaultButton[]={L"First", L"Second", L"Third"};
		const wchar_t* icons[]={L"None", L"Error", L"Question", L"Warning", L"Information"};
		const wchar_t* modal[]={L"Window", L"Task", L"System"};

		GuiComboBoxListControl* comboInput=CreateComboBox(input, sizeof(input)/sizeof(*input));
		GuiComboBoxListControl* comboDefault=CreateComboBox(defaultButton, sizeof(defaultButton)/sizeof(*defaultButton));
		GuiComboBoxListControl* comboIcons=CreateComboBox(icons, sizeof(icons)/sizeof(*icons));
		GuiComboBoxListControl* comboModal=CreateComboBox(modal, sizeof(modal)/sizeof(*modal));

		comboInput->GetBoundsComposition()->SetBounds(Rect(Point(10, 10), Size(200, 0)));
		comboDefault->GetBoundsComposition()->SetBounds(Rect(Point(10, 40), Size(200, 0)));
		comboIcons->GetBoundsComposition()->SetBounds(Rect(Point(10, 70), Size(200, 0)));
		comboModal->GetBoundsComposition()->SetBounds(Rect(Point(10, 100), Size(200, 0)));

		GuiButton* buttonMessageBox=g::NewButton();
		buttonMessageBox->SetText(L"ShowMessageBox");
		buttonMessageBox->GetBoundsComposition()->SetBounds(Rect(Point(10, 130), Size(0, 0)));

		container->AddChild(comboInput->GetBoundsComposition());
		container->AddChild(comboDefault->GetBoundsComposition());
		container->AddChild(comboIcons->GetBoundsComposition());
		container->AddChild(comboModal->GetBoundsComposition());
		container->AddChild(buttonMessageBox->GetBoundsComposition());

		buttonMessageBox->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			INativeDialogService::MessageBoxButtonsInput buttons=(INativeDialogService::MessageBoxButtonsInput)comboInput->GetSelectedIndex();
			INativeDialogService::MessageBoxDefaultButton defaultButton=(INativeDialogService::MessageBoxDefaultButton)comboDefault->GetSelectedIndex();
			INativeDialogService::MessageBoxIcons icon=(INativeDialogService::MessageBoxIcons)comboIcons->GetSelectedIndex();
			INativeDialogService::MessageBoxModalOptions modal=(INativeDialogService::MessageBoxModalOptions)comboModal->GetSelectedIndex();

			INativeDialogService::MessageBoxButtonsOutput result=GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"This is a message box!", L"The Title", buttons, defaultButton, icon, modal);
			WString selected;
#define SELECT(NAME) case INativeDialogService::Select##NAME: selected=L#NAME; break
			switch(result)
			{
			SELECT(OK);
			SELECT(Cancel);
			SELECT(Yes);
			SELECT(No);
			SELECT(Retry);
			SELECT(Abort);
			SELECT(Ignore);
			SELECT(TryAgain);
			SELECT(Continue);
			}
#undef SELECT
			GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"You selected the \""+selected+L"\" button.", L"Result");
		});
	}
	{
		GuiButton* buttonColorDialog1=g::NewButton();
		buttonColorDialog1->SetText(L"SimpleCustomColor");
		buttonColorDialog1->GetBoundsComposition()->SetBounds(Rect(Point(10, 160), Size(0, 0)));
		container->AddChild(buttonColorDialog1->GetBoundsComposition());

		buttonColorDialog1->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			Color selection;
			if(GetCurrentController()->DialogService()->ShowColorDialog(controlHost->GetNativeWindow(), selection, false, INativeDialogService::CustomColorDisabled, 0))
			{
				WString selected=L"("+itow(selection.r)+L", "+itow(selection.g)+L", "+itow(selection.b)+L")";
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"You selected the \""+selected+L"\" color.", L"Result");
			}
		});

		GuiButton* buttonColorDialog2=g::NewButton();
		buttonColorDialog2->SetText(L"RichCustomColor");
		buttonColorDialog2->GetBoundsComposition()->SetBounds(Rect(Point(10, 190), Size(0, 0)));
		container->AddChild(buttonColorDialog2->GetBoundsComposition());

		buttonColorDialog2->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			Color selection(255, 0, 0);
			Color customColors[]=
			{
				Color(0, 0, 0),
				Color(128, 0, 0),
				Color(0, 128, 0),
				Color(0, 0, 128),
				Color(128, 128, 0),
				Color(0, 128, 128),
				Color(128, 0, 128),
				Color(192, 192, 192),
				Color(128, 128, 128),
				Color(255, 0, 0),
				Color(0, 255, 0),
				Color(0, 0, 255),
				Color(255, 255, 0),
				Color(0, 255, 255),
				Color(255, 0, 255),
				Color(255, 255, 255),
			};
			if(GetCurrentController()->DialogService()->ShowColorDialog(controlHost->GetNativeWindow(), selection, true, INativeDialogService::CustomColorOpened, customColors))
			{
				WString selected=L"("+itow(selection.r)+L", "+itow(selection.g)+L", "+itow(selection.b)+L")";
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"You selected the \""+selected+L"\" color.", L"Result");
			}
		});
	}
	{
		GuiButton* buttonFontDialog1=g::NewButton();
		buttonFontDialog1->SetText(L"SimpleFontDialog");
		buttonFontDialog1->GetBoundsComposition()->SetBounds(Rect(Point(10, 220), Size(0, 0)));
		container->AddChild(buttonFontDialog1->GetBoundsComposition());

		buttonFontDialog1->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			FontProperties font;
			Color color;
			if(GetCurrentController()->DialogService()->ShowFontDialog(controlHost->GetNativeWindow(), font, color, false, false, true))
			{
				WString selected=font.fontFamily+L" "+itow(font.size)+(font.bold?L" bold":L"")+(font.italic?L" italic":L"")+(font.underline?L" underline":L"")+(font.strikeline?L" strikeline":L"");
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"You selected the \""+selected+L"\" font.", L"Result");
			}
		});

		GuiButton* buttonFontDialog2=g::NewButton();
		buttonFontDialog2->SetText(L"RichFontDialog");
		buttonFontDialog2->GetBoundsComposition()->SetBounds(Rect(Point(10, 250), Size(0, 0)));
		container->AddChild(buttonFontDialog2->GetBoundsComposition());

		buttonFontDialog2->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			FontProperties font=GetCurrentController()->ResourceService()->GetDefaultFont();
			Color color(255, 0, 0);
			if(GetCurrentController()->DialogService()->ShowFontDialog(controlHost->GetNativeWindow(), font, color, true, true, true))
			{
				WString selected=font.fontFamily+L" "+itow(font.size)+(font.bold?L" bold":L"")+(font.italic?L" italic":L"")+(font.underline?L" underline":L"")+(font.strikeline?L" strikeline":L"");
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), L"You selected the \""+selected+L"\" font.", L"Result");
			}
		});
	}
	{
		GuiButton* buttonFileDialog1=g::NewButton();
		buttonFileDialog1->SetText(L"OpenFileDialog");
		buttonFileDialog1->GetBoundsComposition()->SetBounds(Rect(Point(10, 280), Size(0, 0)));
		container->AddChild(buttonFileDialog1->GetBoundsComposition());
		
		GuiButton* buttonFileDialog2=g::NewButton();
		buttonFileDialog2->SetText(L"OpenFileDialogPreview");
		buttonFileDialog2->GetBoundsComposition()->SetBounds(Rect(Point(10, 310), Size(0, 0)));
		container->AddChild(buttonFileDialog2->GetBoundsComposition());
		
		GuiButton* buttonFileDialog3=g::NewButton();
		buttonFileDialog3->SetText(L"SaveFileDialog");
		buttonFileDialog3->GetBoundsComposition()->SetBounds(Rect(Point(10, 340), Size(0, 0)));
		container->AddChild(buttonFileDialog3->GetBoundsComposition());
		
		GuiButton* buttonFileDialog4=g::NewButton();
		buttonFileDialog4->SetText(L"SaveFileDialogPreview");
		buttonFileDialog4->GetBoundsComposition()->SetBounds(Rect(Point(10, 370), Size(0, 0)));
		container->AddChild(buttonFileDialog4->GetBoundsComposition());

		buttonFileDialog1->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			List<WString> selectionFileNames;
			vint selectionFilterIndex=0;
			if(GetCurrentController()->DialogService()->ShowFileDialog(
				controlHost->GetNativeWindow(),
				selectionFileNames,
				selectionFilterIndex,
				INativeDialogService::FileDialogOpen,
				L"",
				L"MyFile.txt",
				L"C:\\Windows",
				L".txt",
				L"Text Files(*.txt)|*.txt|All Files(*.*)|*.*",
				(INativeDialogService::FileDialogOptions)
				( INativeDialogService::FileDialogDereferenceLinks
				| INativeDialogService::FileDialogDirectoryMustExist
				| INativeDialogService::FileDialogFileMustExist
				| INativeDialogService::FileDialogPromptOverwriteFile
				| INativeDialogService::FileDialogShowReadOnlyCheckBox
				)
				))
			{
				WString message=L"Filter Index: "+itow(selectionFilterIndex);
				for(int i=0;i<selectionFileNames.Count();i++)
				{
					message+=L"\r\nFile: "+selectionFileNames[i];
				}
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), message, L"Result");
			}
		});

		buttonFileDialog2->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			List<WString> selectionFileNames;
			vint selectionFilterIndex=0;
			if(GetCurrentController()->DialogService()->ShowFileDialog(
				controlHost->GetNativeWindow(),
				selectionFileNames,
				selectionFilterIndex,
				INativeDialogService::FileDialogOpenPreview,
				L"",
				L"MyFile.txt",
				L"C:\\Windows",
				L".txt",
				L"Text Files(*.txt)|*.txt|All Files(*.*)|*.*",
				(INativeDialogService::FileDialogOptions)
				( INativeDialogService::FileDialogDereferenceLinks
				| INativeDialogService::FileDialogDirectoryMustExist
				| INativeDialogService::FileDialogFileMustExist
				| INativeDialogService::FileDialogPromptOverwriteFile
				| INativeDialogService::FileDialogShowNetworkButton
				| INativeDialogService::FileDialogShowReadOnlyCheckBox
				| INativeDialogService::FileDialogAllowMultipleSelection
				)
				))
			{
				WString message=L"Filter Index: "+itow(selectionFilterIndex);
				for(int i=0;i<selectionFileNames.Count();i++)
				{
					message+=L"\r\nFile: "+selectionFileNames[i];
				}
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), message, L"Result");
			}
		});

		buttonFileDialog3->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			List<WString> selectionFileNames;
			vint selectionFilterIndex=0;
			if(GetCurrentController()->DialogService()->ShowFileDialog(
				controlHost->GetNativeWindow(),
				selectionFileNames,
				selectionFilterIndex,
				INativeDialogService::FileDialogSave,
				L"",
				L"MyFile.txt",
				L"C:\\Windows",
				L".txt",
				L"Text Files(*.txt)|*.txt|All Files(*.*)|*.*",
				(INativeDialogService::FileDialogOptions)
				( INativeDialogService::FileDialogDereferenceLinks
				| INativeDialogService::FileDialogDirectoryMustExist
				| INativeDialogService::FileDialogPromptCreateFile
				)
				))
			{
				WString message=L"Filter Index: "+itow(selectionFilterIndex);
				for(int i=0;i<selectionFileNames.Count();i++)
				{
					message+=L"\r\nFile: "+selectionFileNames[i];
				}
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), message, L"Result");
			}
		});

		buttonFileDialog4->Clicked.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			List<WString> selectionFileNames;
			vint selectionFilterIndex=0;
			if(GetCurrentController()->DialogService()->ShowFileDialog(
				controlHost->GetNativeWindow(),
				selectionFileNames,
				selectionFilterIndex,
				INativeDialogService::FileDialogSavePreview,
				L"",
				L"MyFile.txt",
				L"C:\\Windows",
				L".txt",
				L"Text Files(*.txt)|*.txt|All Files(*.*)|*.*",
				(INativeDialogService::FileDialogOptions)
				( INativeDialogService::FileDialogDereferenceLinks
				| INativeDialogService::FileDialogDirectoryMustExist
				| INativeDialogService::FileDialogPromptCreateFile
				| INativeDialogService::FileDialogShowNetworkButton
				)
				))
			{
				WString message=L"Filter Index: "+itow(selectionFilterIndex);
				for(vint i=0;i<selectionFileNames.Count();i++)
				{
					message+=L"\r\nFile: "+selectionFileNames[i];
				}
				GetCurrentController()->DialogService()->ShowMessageBox(controlHost->GetNativeWindow(), message, L"Result");
			}
		});
	}
}