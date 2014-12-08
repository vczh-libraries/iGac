//
//  CoreGraphicsApp.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CoreGraphicsApp.h"

#include "../CocoaNativeController.h"

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::osx;


int SetupOSXCoreGraphicsRenderer()
{
    INativeController* controller = CreateOSXNativeController();
    SetCurrentController(controller);
    
    {
        CoreGraphicsMain();
    }
    
    DestroyOSXNativeController(controller);
    
    return 0;
}