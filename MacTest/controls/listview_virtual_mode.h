//
//  listview_virtual_mode.h
//  GacOSX
//
//  Created by Robert Bu on 12/14/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_listview_virtual_mode_h
#define GacOSX_listview_virtual_mode_h

#include "../gac_include.h"

class ListViewDataSource : public list::ItemProviderBase, public list::ListViewItemStyleProvider::IListViewItemView, public list::ListViewColumnItemArranger::IColumnItemView
{
    typedef List<list::ListViewColumnItemArranger::IColumnItemViewCallback*>      ColumnItemViewCallbackList;
private:
    List<Ptr<FileProperties>>       fileProperties;
    ColumnItemViewCallbackList      columnItemViewCallbacks;
    vint                            columnSizes[4];
public:
    ListViewDataSource()
    {
        for(int i=0;i<4;i++)
        {
            columnSizes[i]=i==0?230:120;
        }
    }
    
    void SetDirectory(const WString& directory)
    {
        int oldCount=fileProperties.Count();
        fileProperties.Clear();
        
        // Enumerate all directories and files in the Windows directory.
        List<WString> directories;
        List<WString> files;
        SearchDirectoriesAndFiles(directory, directories, files);
        FOREACH(WString, file, From(directories).Concat(files))
        {
            fileProperties.Add(new FileProperties(directory+L"/"+file));
        }
        
        InvokeOnItemModified(0, oldCount, fileProperties.Count());
    }
    
    // GuiListControl::IItemProvider
    
    vint Count()
    {
        return fileProperties.Count();
    }
    
    IDescriptable* RequestView(const WString& identifier)
    {
        if(identifier==list::ListViewItemStyleProvider::IListViewItemView::Identifier)
        {
            return this;
        }
        else if(identifier==list::ListViewColumnItemArranger::IColumnItemView::Identifier)
        {
            return this;
        }
        else
        {
            return 0;
        }
    }
    
    void ReleaseView(IDescriptable* view)
    {
    }
    
    // GuiListControl::IItemPrimaryTextView
    
    WString GetPrimaryTextViewText(vint itemIndex)
    {
        return GetText(itemIndex);
    }
    
    bool ContainsPrimaryText(vint itemIndex)
    {
        return true;
    }
    
    // list::ListViewItemStyleProvider::IListViewItemView
    
    Ptr<GuiImageData> GetSmallImage(vint itemIndex)
    {
        if(0<=itemIndex && itemIndex<fileProperties.Count())
        {
            return fileProperties[itemIndex]->GetSmallIcon();
        }
        return 0;
    }
    
    Ptr<GuiImageData> GetLargeImage(vint itemIndex)
    {
        if(0<=itemIndex && itemIndex<fileProperties.Count())
        {
            return fileProperties[itemIndex]->GetBigIcon();
        }
        return 0;
    }
    
    WString GetText(vint itemIndex)
    {
        if(0<=itemIndex && itemIndex<fileProperties.Count())
        {
            return fileProperties[itemIndex]->GetDisplayName();
        }
        return L"";
    }
    
    WString GetSubItem(vint itemIndex, vint index)
    {
        if(0<=itemIndex && itemIndex<fileProperties.Count() && 0<=index && index<3)
        {
            switch(index)
            {
                case 0:
                    return fileProperties[itemIndex]->GetTypeName();
                case 1:
                    return FileModificationTimeToString(fileProperties[itemIndex]->GetLastWriteTime());
                case 2:
                    return GetFileSizeString(fileProperties[itemIndex]->GetSize());
            }
        }
        return L"";
    }
    
    vint GetDataColumnCount()
    {
        return 2;
    }
    
    vint GetDataColumn(vint index)
    {
        return index;
    }
    
    // list::ListViewColumnItemArranger::IColumnItemView
    
    bool AttachCallback(list::ListViewColumnItemArranger::IColumnItemViewCallback* value)
    {
        if(columnItemViewCallbacks.Contains(value))
        {
            return false;
        }
        else
        {
            columnItemViewCallbacks.Add(value);
            return true;
        }
    }
    
    bool DetachCallback(list::ListViewColumnItemArranger::IColumnItemViewCallback* value)
    {
        vint index=columnItemViewCallbacks.IndexOf(value);
        if(index==-1)
        {
            return false;
        }
        else
        {
            columnItemViewCallbacks.Remove(value);
            return true;
        }
    }
    
    vint GetColumnCount()
    {
        return 4;
    }
    
    WString GetColumnText(vint index)
    {
        switch(index)
        {
            case 0:
                return L"Name";
            case 1:
                return L"Type";
            case 2:
                return L"Date";
            case 3:
                return L"Size";
            default:
                return L"";
        }
    }
    
    vint GetColumnSize(vint index)
    {
        if(0<=index && index<4)
        {
            return columnSizes[index];
        }
        else
        {
            return -1;
        }
    }
    
    void SetColumnSize(vint index, vint value)
    {
        if(0<=index && index<4)
        {
            columnSizes[index]=value;
            for(int i=0;i<columnItemViewCallbacks.Count();i++)
            {
                columnItemViewCallbacks[i]->OnColumnChanged();
            }
        }
    }
    
    GuiMenu* GetDropdownPopup(vint index)
    {
        return 0;
    }
    
    GuiListViewColumnHeader::ColumnSortingState GetSortingState(vint index)
    {
        return GuiListViewColumnHeader::NotSorted;
    }
};

/***********************************************************************
 VirtualModeWindow
 ***********************************************************************/

class ListViewVirtualModeWindow : public GuiWindow
{
private:
    ListViewDataSource*             dataSource;
    GuiVirtualListView*             listView;
    GuiComboBoxListControl*         comboView;
    GuiSinglelineTextBox*           textDirectory;
    GuiButton*                      buttonRefresh;
    
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
    
    void buttonRefresh_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        WString directory=textDirectory->GetText();
        if(directory.Length()>0 && directory[directory.Length()-1]==L'\\')
        {
            directory=directory.Left(directory.Length()-1);
        }
        dataSource->SetDirectory(directory);
    }
public:
    ListViewVirtualModeWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.ListView.VirtualMode");
        
        GuiTableComposition* table=new GuiTableComposition;
        table->SetCellPadding(4);
        table->SetAlignmentToParent(Margin(0, 0, 0, 0));
        table->SetRowsAndColumns(2, 3);
        table->SetRowOption(0, GuiCellOption::MinSizeOption());
        table->SetRowOption(1, GuiCellOption::PercentageOption(1.0));
        table->SetColumnOption(0, GuiCellOption::MinSizeOption());
        table->SetColumnOption(1, GuiCellOption::PercentageOption(1.0));
        table->SetColumnOption(2, GuiCellOption::MinSizeOption());
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
            comboView->SelectedIndexChanged.AttachMethod(this, &ListViewVirtualModeWindow::comboView_SelectedIndexChanged);
            cell->AddChild(comboView->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(0, 1, 1, 1);
            
            textDirectory=g::NewTextBox();
            textDirectory->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            cell->AddChild(textDirectory->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(0, 2, 1, 1);
            
            buttonRefresh=g::NewButton();
            buttonRefresh->SetText(L"<- Load this directory");
            buttonRefresh->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            buttonRefresh->Clicked.AttachMethod(this, &ListViewVirtualModeWindow::buttonRefresh_Clicked);
            cell->AddChild(buttonRefresh->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(1, 0, 1, 3);
            
            dataSource=new ListViewDataSource;
            
            listView=new GuiVirtualListView(GetCurrentTheme()->CreateListViewStyle(), dataSource);
            listView->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            listView->SetHorizontalAlwaysVisible(false);
            listView->SetVerticalAlwaysVisible(false);
            listView->SetMultiSelect(true);
            cell->AddChild(listView->GetBoundsComposition());
        }
        this->GetBoundsComposition()->AddChild(table);
        
        textDirectory->SetText(GetUserHome());
        dataSource->SetDirectory(textDirectory->GetText());
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(640, 480));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
};


#endif
