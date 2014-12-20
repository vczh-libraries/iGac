//
//  listview_viewswitching.h
//  GacOSX
//
//  Created by Robert Bu on 12/12/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GacOSX__listview_viewswitching__
#define __GacOSX__listview_viewswitching__

#include "../gac_include.h"
#include "../UnixFileSystemInfo.h"
#include "../osx_shared.h"

extern void FillData(GuiListView* listView);

/***********************************************************************
 ViewSwitchingWindow
 ***********************************************************************/

class ViewSwitchingWindow : public GuiWindow
{
private:
    GuiListView*                    listView;
    GuiComboBoxListControl*         comboView;
    
    void comboView_SelectedIndexChanged(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        switch(comboView->GetSelectedIndex())
        {
            case 0:
                listView->ChangeItemStyle(new list::ListViewBigIconContentProvider);
                break;
            case 1:
                listView->ChangeItemStyle(new list::ListViewSmallIconContentProvider);
                break;
            case 2:
                listView->ChangeItemStyle(new list::ListViewListContentProvider);
                break;
            case 3:
                listView->ChangeItemStyle(new list::ListViewDetailContentProvider);
                break;
            case 4:
                listView->ChangeItemStyle(new list::ListViewTileContentProvider);
                break;
            case 5:
                listView->ChangeItemStyle(new list::ListViewInformationContentProvider);
                break;
        }
    }
public:
    ViewSwitchingWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.ListView.ViewSwitching");
        
        GuiTableComposition* table=new GuiTableComposition;
        table->SetCellPadding(4);
        table->SetAlignmentToParent(Margin(0, 0, 0, 0));
        table->SetRowsAndColumns(2, 1);
        table->SetRowOption(0, GuiCellOption::MinSizeOption());
        table->SetRowOption(1, GuiCellOption::PercentageOption(1.0));
        table->SetColumnOption(0, GuiCellOption::PercentageOption(1.0));
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(0, 0, 1, 1);
            
            GuiTextList* comboSource=g::NewTextList();
            comboSource->GetItems().Add(new list::TextItem(L"Big Icon"));
            comboSource->GetItems().Add(new list::TextItem(L"Small Icon"));
            comboSource->GetItems().Add(new list::TextItem(L"List"));
            comboSource->GetItems().Add(new list::TextItem(L"Detail"));
            comboSource->GetItems().Add(new list::TextItem(L"Tile"));
            comboSource->GetItems().Add(new list::TextItem(L"Information"));
            comboSource->SetHorizontalAlwaysVisible(false);
            
            comboView=g::NewComboBox(comboSource);
            comboView->SetSelectedIndex(0);
            comboView->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, -1, 0));
            comboView->GetBoundsComposition()->SetPreferredMinSize(Size(160, 0));
            comboView->SelectedIndexChanged.AttachMethod(this, &ViewSwitchingWindow::comboView_SelectedIndexChanged);
            cell->AddChild(comboView->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(1, 0, 1, 1);
            
            listView=g::NewListViewBigIcon();
            listView->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            listView->SetHorizontalAlwaysVisible(false);
            listView->SetVerticalAlwaysVisible(false);
            listView->SetMultiSelect(true);
            cell->AddChild(listView->GetBoundsComposition());
        }
        this->GetBoundsComposition()->AddChild(table);
        FillData(listView);
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(640, 480));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
};

/***********************************************************************
 FillData
 ***********************************************************************/

void FillList(GuiListView* listView, const WString& path, List<WString>& files)
{
    // Fill all information about a directory or a file.
    FOREACH(WString, file, files)
    {
        Ptr<list::ListViewItem> item=new list::ListViewItem;
        WString fullPath=path+L"/"+file;
             
        item->SetLargeImage(new GuiImageData(osx::GetFileIconImage(fullPath, Size(48, 48)), 0));
        item->SetSmallImage(new GuiImageData(osx::GetFileIconImage(fullPath, Size(24, 24)), 0));
        
        item->SetText(osx::GetFileDisplayName(fullPath));
        
        item->GetSubItems().Add(osx::GetFileDisplayType(fullPath));
        item->GetSubItems().Add(osx::GetFileModificationTimeString(fullPath));
        item->GetSubItems().Add(GetFileSizeString(GetFileSize(fullPath)));
        
        listView->GetItems().Add(item);
    }
}

void FillData(GuiListView* listView)
{    
    // Enumerate all directories and files in the Windows directory.
    List<WString> directories;
    List<WString> files;
    SearchDirectoriesAndFiles(GetUserHome(), directories, files);
    
    // Set all columns. The first column is the primary column. All others are sub columns.
    listView->GetItems().GetColumns().Add(new list::ListViewColumn(L"Name", 230));
    listView->GetItems().GetColumns().Add(new list::ListViewColumn(L"Type", 120));
    listView->GetItems().GetColumns().Add(new list::ListViewColumn(L"Date", 120));
    listView->GetItems().GetColumns().Add(new list::ListViewColumn(L"Size", 120));
    
    // Set all data columns (important sub solumns). The first sub item is 0. The primary column is not counted in.
    listView->GetItems().GetDataColumns().Add(0);    // Type
    listView->GetItems().GetDataColumns().Add(1);    // Data
    
    // Fill all directories and files into the list view
    FillList(listView, GetUserHome(), directories);
    FillList(listView, GetUserHome(), files);
}

#endif /* defined(__GacOSX__listview_viewswitching__) */
