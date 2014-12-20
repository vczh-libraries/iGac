//
//  listbox_virtual_mode.h
//  GacOSX
//
//  Created by Robert Bu on 12/12/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_listbox_virtual_mode_h
#define GacOSX_listbox_virtual_mode_h

#include "../gac_include.h"

class ListBoxVirtualModeDataSource : public list::ItemProviderBase, private list::TextItemStyleProvider::ITextItemView
{
protected:
    vint             count;
    
public:
    ListBoxVirtualModeDataSource()
    :count(100000)
    {
    }
    
    void SetCount(vint newCount)
    {
        if(0<=newCount)
        {
            vint oldCount=count;
            count=newCount;
            
            // this->InvokeOnItemModified(affected-items-start, affected-items-count, new-items-count);
            // this function notifies the list control to update it's content and scroll bars
            if(oldCount<newCount)
            {
                // insert
                this->InvokeOnItemModified(oldCount, 0, newCount-oldCount);
            }
            else if(oldCount>newCount)
            {
                // delete
                this->InvokeOnItemModified(newCount, oldCount-newCount, 0);
            }
        }
    }
    
    // GuiListControl::IItemProvider
    
    vint Count()
    {
        return count;
    }
    
    IDescriptable* RequestView(const WString& identifier)
    {
        if(identifier==list::TextItemStyleProvider::ITextItemView::Identifier)
        {
            return this;
        }
        else if(identifier==GuiListControl::IItemPrimaryTextView::Identifier)
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
    
    // list::TextItemStyleProvider::ITextItemView
    
    WString GetText(vint itemIndex)
    {
        return L"Item "+itow(itemIndex+1);
    }
    
    bool GetChecked(vint itemIndex)
    {
        // DataSource don't support check state
        return false;
    }
    
    void SetCheckedSilently(vint itemIndex, bool value)
    {
        // DataSource don't support check state
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
};

/***********************************************************************
 VirtualModeWindow
 ***********************************************************************/

class ListBoxVirtualModeWindow : public GuiWindow
{
private:
    GuiVirtualTextList*                 listBox;
    GuiButton*                          buttonIncrease;
    GuiButton*                          buttonDecrease;
    ListBoxVirtualModeDataSource*       dataSource;
    
    void buttonIncrease_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        dataSource->SetCount(dataSource->Count()+100000);
    }
    
    void buttonDecrease_Clicked(GuiGraphicsComposition* sender, GuiEventArgs& arguments)
    {
        dataSource->SetCount(dataSource->Count()-100000);
    }
public:
    ListBoxVirtualModeWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.ListBox.VirtualMode");
        
        GuiTableComposition* table=new GuiTableComposition;
        table->SetRowsAndColumns(3, 2);
        table->SetCellPadding(3);
        table->SetAlignmentToParent(Margin(0, 0, 0, 0));
        
        table->SetRowOption(0, GuiCellOption::MinSizeOption());
        table->SetRowOption(1, GuiCellOption::MinSizeOption());
        table->SetRowOption(2, GuiCellOption::PercentageOption(1.0));
        
        table->SetColumnOption(0, GuiCellOption::PercentageOption(1.0));
        table->SetColumnOption(1, GuiCellOption::MinSizeOption());
        
        this->GetContainerComposition()->AddChild(table);
        
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(0, 0, 3, 1);
            
            dataSource=new ListBoxVirtualModeDataSource;
            listBox=new GuiVirtualTextList(GetCurrentTheme()->CreateTextListStyle(), GetCurrentTheme()->CreateTextListItemStyle(), dataSource);
            listBox->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            listBox->SetHorizontalAlwaysVisible(false);
            cell->AddChild(listBox->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(0, 1, 1, 1);
            
            buttonIncrease=g::NewButton();
            buttonIncrease->SetText(L"Increase 100000 Items");
            buttonIncrease->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            buttonIncrease->Clicked.AttachMethod(this, &ListBoxVirtualModeWindow::buttonIncrease_Clicked);
            cell->AddChild(buttonIncrease->GetBoundsComposition());
        }
        {
            GuiCellComposition* cell=new GuiCellComposition;
            table->AddChild(cell);
            cell->SetSite(1, 1, 1, 1);
            
            buttonDecrease=g::NewButton();
            buttonDecrease->SetText(L"Decrease 100000 Items");
            buttonDecrease->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
            buttonDecrease->Clicked.AttachMethod(this, &ListBoxVirtualModeWindow::buttonDecrease_Clicked);
            cell->AddChild(buttonDecrease->GetBoundsComposition());
        }
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(480, 480));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
};

#endif
