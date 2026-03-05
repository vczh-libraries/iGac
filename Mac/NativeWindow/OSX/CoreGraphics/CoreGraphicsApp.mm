//
//  CoreGraphicsApp.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CoreGraphicsApp.h"

#include "../CocoaNativeController.h"

#import <GacUI.h>

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::osx;


int SetupOSXCoreGraphicsRenderer()
{
    StartOSXNativeController();
    auto nativeController = GetOSXNativeController();
    SetNativeController(nativeController);
    
    {
        CoreGraphicsMain(nativeController);
    }
    
    StopOSXNativeController();
    return 0;
}

int SetupOSXHostedCoreGraphicsRenderer()
{
    StartOSXNativeController();
    auto nativeController = GetOSXNativeController();

    auto hostedController = new GuiHostedController(nativeController);
    SetNativeController(hostedController);
    SetHostedApplication(hostedController->GetHostedApplication());

    {
        CoreGraphicsMain(nativeController, hostedController);
    }

    SetNativeController(nullptr);
    delete hostedController;
    StopOSXNativeController();
    return 0;
}