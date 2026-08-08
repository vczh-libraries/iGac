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

int SetupOSXCoreGraphicsRendererInternal(bool hosted, bool raw)
{
    StartOSXNativeController();
    auto nativeController = GetOSXNativeController();

    GuiHostedController* hostedController = nullptr;
    if (hosted)
    {
        hostedController = new GuiHostedController(nativeController);
        SetNativeController(hostedController);
        SetHostedApplication(hostedController->GetHostedApplication());
    }
    else
    {
        SetNativeController(nativeController);
    }
    SetOSXApplicationEnvironmentCallbackService(
        (hostedController ? static_cast<INativeController*>(hostedController) : nativeController)->CallbackService()
        );

    CoreGraphicsMain(nativeController, hostedController, raw);

    SetOSXApplicationEnvironmentCallbackService(nullptr);
    SetNativeController(nullptr);
    if (hostedController)
    {
        SetHostedApplication(nullptr);
        delete hostedController;
    }
    StopOSXNativeController();
    return 0;
}

int SetupOSXCoreGraphicsRenderer()
{
    return SetupOSXCoreGraphicsRendererInternal(false, false);
}

int SetupOSXHostedCoreGraphicsRenderer()
{
    return SetupOSXCoreGraphicsRendererInternal(true, false);
}

int SetupRawOSXCoreGraphicsRenderer()
{
    return SetupOSXCoreGraphicsRendererInternal(false, true);
}
