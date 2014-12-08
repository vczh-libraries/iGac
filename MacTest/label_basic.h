//
//  label_basic.h
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_label_basic_h
#define GacOSX_label_basic_h

#include "osx_shared.h"
#include "gac_include.h"

class HelloWorldWindow : public GuiWindow
{
public:
    HelloWorldWindow()
    :GuiWindow(GetCurrentTheme()->CreateWindowStyle())
    {
        WString title(L"GayUI OSX");
        title += (GetSysVerString());
        
        this->SetText(title);
        this->SetClientSize(vl::presentation::Size(640, 480));
        this->MoveToScreenCenter();
        
        GuiControl* label = g::NewLabel();
        label->SetText(L"Welcome to GacUI Library!");
        {
            FontProperties font;
            font.fontFamily = L"Segoe UI";
            font.size = 40;
            font.antialias = true;
            label->SetFont(font);
        }
        this->AddChild(label);
    }
    
    ~HelloWorldWindow()
    {
    }
};

#endif
