//
//  main.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include <iostream>

#include "../Source/GacUI.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}


void GuiMain()
{
    GuiWindow* window = g::NewWindow();
    
    window->SetText(L"GayUI OSX Version 10.10 (Build 14A388a) _ CoreGraphics");
    window->SetClientSize(vl::presentation::Size(640, 480));
    window->MoveToScreenCenter();
    
    GuiControl* label = g::NewLabel();
    label->SetText(L"Welcome to GacUI Library!");
    {
        FontProperties font;
        font.fontFamily = L"Segoe UI";
        font.size = 40;
        font.antialias = true;
        label->SetFont(font);
    }
    window->AddChild(label);
    
    
    GetApplication()->Run(window);
    delete window;
}