//
//  main.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include <iostream>

#include "GacUI.h"

#include "label_basic.h"
#include "label_hyperlink.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

template<typename T>
void RunWindow()
{
    GuiWindow* window = new T();
    GetApplication()->Run(window);
    delete window;
}

void GuiMain()
{
    RunWindow<HyperlinkWindow>();
}

