//
//  ID3Window.cpp
//  GacOSX
//
//  Created by Robert Bu on 1/20/15.
//  Copyright (c) 2015 Robert Bu. All rights reserved.
//

#include "ID3Window.h"
#include "../../Mac/NativeWindow/OSX/CocoaWindow.h"

namespace id3c
{
    
    ID3ConvertWindow::ID3ConvertWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        this->SetText(L"ID3 Convert");
        this->SetClientSize(vl::presentation::Size(640, 480));
        this->MoveToScreenCenter();
        
    }

    ID3ConvertWindow::~ID3ConvertWindow()
    {
        
    }
    
    void ID3ConvertWindow::PerformFileDrag(const List<WString>& files)
    {
        
    }

}