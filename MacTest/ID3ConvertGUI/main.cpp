//
//  main.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "ID3Window.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    id3c::ID3ConvertWindow* window = new id3c::ID3ConvertWindow();
    GetApplication()->Run(window);
    delete window;
}

