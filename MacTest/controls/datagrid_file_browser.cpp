//
//  datagrid_file_browser.h
//  GacOSX
//
//  Created by Robert Bu on 12/16/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_datagrid_file_browser_h
#define GacOSX_datagrid_file_browser_h

#include "../shared/gac_include.h"
#include "../shared/UnixFileSystemInfo.h"
#include "../shared/osx_shared.h"

class FileNameColumnProvider : public list::StrongTypedColumnProvider<Ptr<FileProperties>, WString>
{
public:
    FileNameColumnProvider(list::StrongTypedDataProvider<Ptr<FileProperties>>* _dataProvider)
    :StrongTypedColumnProvider(_dataProvider)
    {
    }
    
    void GetCellData(const Ptr<FileProperties>& rowData, WString& cellData)
    {
        // This column will be sorted igoring case, so this function always return a uppder-cased string.
        cellData=INVLOC.ToUpper(rowData->GetDisplayName());
    }
    
    WString GetCellText(vint row)
    {
        // Get the real string.
        Ptr<FileProperties> rowData;
        dataProvider->GetRowData(row, rowData);
        return rowData->GetDisplayName();
    }
};

/***********************************************************************
 FileDateColumnProvider
 ***********************************************************************/

class FileDateColumnProvider : public list::StrongTypedColumnProvider<Ptr<FileProperties>, vint64_t>
{
public:
    FileDateColumnProvider(list::StrongTypedDataProvider<Ptr<FileProperties>>* _dataProvider)
    :StrongTypedColumnProvider(_dataProvider)
    {
    }
    
    void GetCellData(const Ptr<FileProperties>& rowData, vint64_t& cellData)
    {
        struct timespec t = rowData->GetLastWriteTime();
      
        cellData = t.tv_sec;
    }
    
    WString GetCellText(vint row)
    {
        Ptr<FileProperties> rowData;
        dataProvider->GetRowData(row, rowData);
        // Display the FILETIME using custom format.
        return FileModificationTimeToString(rowData->GetLastWriteTime());
    }
};

/***********************************************************************
 FileSizeColumnProvider
 ***********************************************************************/

class FileSizeColumnProvider : public list::StrongTypedColumnProvider<Ptr<FileProperties>, vint64_t>
{
public:
    FileSizeColumnProvider(list::StrongTypedDataProvider<Ptr<FileProperties>>* _dataProvider)
    :StrongTypedColumnProvider(_dataProvider)
    {
    }
    
    void GetCellData(const Ptr<FileProperties>& rowData, vint64_t& cellData)
    {
        // In order to put folders before files when sorting by file size, we define the size of a folder is -1.
        if(rowData->IsDirectory())
        {
            cellData=-1;
        }
        else
        {
            cellData=(vint64_t)rowData->GetSize();
        }
    }
    
    WString GetCellText(vint row)
    {
        Ptr<FileProperties> rowData;
        dataProvider->GetRowData(row, rowData);
        if(rowData->IsDirectory())
        {
            // Don't display sizes for folders
            return L"";
        }
        else
        {
            // Display sizes with custom format for files.
            return GetFileSizeString(rowData->GetSize());
        }
    }
};

/***********************************************************************
 FileTypeColumnProvider
 ***********************************************************************/

class FileTypeColumnProvider : public list::StrongTypedColumnProvider<Ptr<FileProperties>, WString>
{
protected:
    class FileTypeFilter : public FilterBase
    {
    protected:
        GuiMenu*                            popup;
        GuiTextList*                        textList;
        bool                                preventEvent;
        
        bool FilterData(const Ptr<FileProperties>& rowData, const WString& cellData)
        {
            if(textList->GetItems().Count()==0)
            {
                return true;
            }
            else
            {
                return From(textList->GetItems())
                .Skip(1)
                .Where([](Ptr<list::TextItem> item){return item->GetChecked();})
                .Any([=](Ptr<list::TextItem> item){return item->GetText()==cellData;});
            }
        }
        
        void textList_ItemChecked(GuiGraphicsComposition* sender, GuiItemEventArgs& arguments)
        {
            if(!preventEvent)
            {
                if(arguments.itemIndex==0)
                {
                    preventEvent=true;
                    bool checked=textList->GetItems()[0]->GetChecked();
                    for(vint i=1;i<textList->GetItems().Count();i++)
                    {
                        textList->GetItems().Get(i)->SetChecked(checked);
                    }
                    preventEvent=false;
                }
                // If the user checks or unchecks items in the list control,
                // the filter will notify the data grid control that the filter is changed.
                // Then the data grid control will start a new filtering action.
                InvokeOnFilterChanged();
            }
        }
        
        void popup_Opened(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
        {
            // The first item of the list control inside the column header popup is always "(Select All)".
            // If there is not item, then we should initialize the list control.
            // This function will be called everytime when the user open the column header popup.
            // So when this function is called, the data in the data grid control is ready.
            if(textList->GetItems().Count()==0)
            {
                // Add the first item.
                textList->GetItems().Add(new list::TextItem(L"(Select All)", true));
                
                // Find all distinct file types in the data grid control.
                LazyList<WString> columns=Range((vint)0, (vint)dataProvider->GetRowCount())
                .Select([this](vint i)->WString
                        {
                            Ptr<FileProperties> rowData;
                            WString cellData;
                            dataProvider->GetRowData(i, rowData);
                            ownerColumn->GetCellData(rowData, cellData);
                            return cellData;
                        })
                .Distinct()
                .OrderBy([](const WString& a, const WString& b){return WString::Compare(a, b);});
                
                // Add selected file types to the list control.
                FOREACH(WString, item, columns)
                {
                    textList->GetItems().Add(new list::TextItem(item, true));
                }
            }
        }
    public:
        FileTypeFilter(FileTypeColumnProvider* columnProvider)
        :FilterBase(columnProvider)
        ,popup(0)
        ,preventEvent(false)
        {
            textList=g::NewCheckTextList();
            textList->SetHorizontalAlwaysVisible(false);
            textList->SetVerticalAlwaysVisible(false);
            textList->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            textList->GetBoundsComposition()->SetPreferredMinSize(Size(160, 200));
            textList->ItemChecked.AttachMethod(this, &FileTypeFilter::textList_ItemChecked);
            
            popup=g::NewMenu(0);
            popup->GetContainerComposition()->AddChild(textList->GetBoundsComposition());
            popup->WindowOpened.AttachMethod(this, &FileTypeFilter::popup_Opened);
        }
        
        ~FileTypeFilter()
        {
            delete popup;
        }
        
        GuiMenu* GetPopup()
        {
            return popup;
        }
    };
protected:
    Ptr<FileTypeFilter>                       filter;
    
public:
    FileTypeColumnProvider(list::StrongTypedDataProvider<Ptr<FileProperties>>* _dataProvider)
    :StrongTypedColumnProvider(_dataProvider)
    {
        filter=new FileTypeFilter(this);
        // Bind a filter for this column.
        SetInherentFilter(filter);
        // Display the popup in the column header to control the filter.
        SetPopup(filter->GetPopup());
    }
    
    void GetCellData(const Ptr<FileProperties>& rowData, WString& cellData)
    {
        cellData=rowData->GetTypeName();
    }
};

/***********************************************************************
 DataProvider
 ***********************************************************************/

class DataGridFileExplorerWindowDataProvider : public list::StrongTypedDataProvider<Ptr<FileProperties>>
{
protected:
    List<Ptr<FileProperties>>               fileProperties;
public:
    DataGridFileExplorerWindowDataProvider()
    {
        AddSortableStrongTypedColumn<WString>(L"Name", new FileNameColumnProvider(this))
        ->SetSize(240);
        
        AddSortableStrongTypedColumn<vint64_t>(L"Data modified", new FileDateColumnProvider(this))
        ->SetSize(120);
        
        AddSortableStrongTypedColumn<WString>(L"Type", new FileTypeColumnProvider(this))
        ->SetSize(160);
        
        AddSortableStrongTypedColumn<vint64_t>(L"Size", new FileSizeColumnProvider(this))
        ->SetSize(100);
        
        List<WString> directories, files;
        WString path=GetUserHome();
        SearchDirectoriesAndFiles(path, directories, files);
        FOREACH(WString, fileName, directories)
        {
            fileProperties.Add(new FileProperties(path+L"/"+fileName));
        }
        FOREACH(WString, fileName, files)
        {
            fileProperties.Add(new FileProperties(path+L"/"+fileName));
        }
    }
    
    void GetRowData(vint row, Ptr<FileProperties>& rowData)
    {
        rowData=fileProperties[row];
    }
    
    vint GetRowCount()
    {
        return fileProperties.Count();
    }
    
    Ptr<GuiImageData> GetRowLargeImage(vint row)
    {
        return fileProperties[row]->GetBigIcon();
    }
    
    Ptr<GuiImageData> GetRowSmallImage(vint row)
    {
        return fileProperties[row]->GetSmallIcon();
    }
};

/***********************************************************************
 FileExplorerWindow
 ***********************************************************************/

class DataGridFileExplorerWindow : public GuiWindow
{
private:
    GuiVirtualDataGrid*                 dataGrid;
    
public:
    DataGridFileExplorerWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.DataGrid.FileExplorer");
        
        dataGrid=new GuiVirtualDataGrid(GetCurrentTheme()->CreateListViewStyle(), new DataGridFileExplorerWindowDataProvider);
        dataGrid->GetBoundsComposition()->SetAlignmentToParent(Margin(5, 5, 5, 5));
        dataGrid->SetHorizontalAlwaysVisible(false);
        dataGrid->SetVerticalAlwaysVisible(false);
        AddChild(dataGrid);
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(640, 480));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
};


int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<DataGridFileExplorerWindow>();
}

#endif
