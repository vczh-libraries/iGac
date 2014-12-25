//
//  treeview_file_explorer.h
//  GacOSX
//
//  Created by Robert Bu on 12/14/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_treeview_file_explorer_h
#define GacOSX_treeview_file_explorer_h

#include "../gac_include.h"

class FileExplorerWindow : public GuiWindow
{
private:
    GuiTreeView*                    treeView;
    
    void OnNodeExpanded(GuiGraphicsComposition* sender, GuiNodeEventArgs& arguments)
    {
        tree::MemoryNodeProvider* parent=treeView->Nodes()->GetMemoryNode(arguments.node);
        if(parent->Children().Count()==1)
        {
            tree::MemoryNodeProvider* child=parent->Children()[0].Obj();
            Ptr<tree::TreeViewItem> childItem=child->GetData().Cast<tree::TreeViewItem>();
            if(childItem->text==L"Loading...")
            {
                GetApplication()->InvokeAsync([=]()
                                              {
                                                  // get back the full path from the item
                                                  Ptr<tree::TreeViewItem> item=parent->GetData().Cast<tree::TreeViewItem>();
                                                  WString path=vl::reflection::description::UnboxValue<WString>(item->tag);
                                                  if(path[path.Length()-1]!=L'/')
                                                  {
                                                      path+=L"/";
                                                  }
                                                  
                                                  // add sub folders and sub files
                                                  List<WString> directories, files;
                                                  SearchDirectoriesAndFiles(path, directories, files);
                                                  
                                                  GetApplication()->InvokeInMainThreadAndWait([=, &directories, &files]()
                                                                                              {
                                                                                                  FOREACH(WString, file, directories)
                                                                                                  {
                                                                                                      FileExplorerWindow::AddFolder(parent, path+file);
                                                                                                  }
                                                                                                  FOREACH(WString, file, files)
                                                                                                  {
                                                                                                      FileExplorerWindow::AddFile(parent, path+file);
                                                                                                  }
                                                                                                  // remove the  "Loading..." node
                                                                                                  parent->Children().RemoveAt(0);
                                                                                              });
                                              });
            }
        }
    }
    
    static vint AddFile(tree::MemoryNodeProvider* parent, const WString& path)
    {
        Ptr<tree::TreeViewItem> item=new tree::TreeViewItem;
        // set the item text using the display name of the file
        item->text=osx::GetFileDisplayName(path);
        // set the image using the file icon
        item->image=new GuiImageData(osx::GetFileIconImage(path, Size(16, 16)), 0);
        // tag the full path to the item
        item->tag = vl::reflection::description::BoxValue<WString>(path);
        
        vint index=parent->Children().Add(new tree::MemoryNodeProvider(item));
        return index;
    }
    
    static void AddFolder(tree::MemoryNodeProvider* parent, const WString& path)
    {
        vint index=AddFile(parent, path);
        
        // Add the "loading" item under a folder
        Ptr<tree::TreeViewItem> loading=new tree::TreeViewItem;
        loading->text=L"Loading...";
        parent->Children()[index]->Children().Add(new tree::MemoryNodeProvider(loading));
    }
    
    void InitializeFileSystem()
    {
        AddFolder(treeView->Nodes().Obj(), L"/");

    }
public:
    FileExplorerWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"Controls.TreeView.FileExplorerWindow");
        
        // create tree view control to display the local file system
        treeView=g::NewTreeView();
        treeView->SetHorizontalAlwaysVisible(false);
        treeView->SetVerticalAlwaysVisible(false);
        treeView->GetBoundsComposition()->SetAlignmentToParent(Margin(4, 4, 4, 4));
        // listen to the NodeExpanded event to load the folder content when a folder node is opened
        treeView->NodeExpanded.AttachMethod(this, &FileExplorerWindow::OnNodeExpanded);
        this->AddChild(treeView);
        
        InitializeFileSystem();
        
        // set the preferred minimum client size
        this->GetBoundsComposition()->SetPreferredMinSize(Size(640, 480));
        // call this to calculate the size immediately if any indirect content in the table changes
        // so that the window can calcaulte its correct size before calling the MoveToScreenCenter()
        this->ForceCalculateSizeImmediately();
        // move to the screen center
        this->MoveToScreenCenter();
    }
    
    ~FileExplorerWindow()
    {
    }
};


#endif
