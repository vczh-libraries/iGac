//
//  CoreGraphicsApp.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CoreGraphicsApp.h"

#include "../../CocoaAutomationService.h"
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

    Ptr<INativeAutomationService> automationService;
    if (hosted)
    {
        automationService = Ptr(new CocoaAutomationServiceHosted);
    }
    else
    {
        automationService = Ptr(new CocoaAutomationService);
    }
    GetNativeServiceSubstitution()->Substitute(automationService.Obj(), false);

    CoreGraphicsMain(nativeController, hostedController, raw);

    GetNativeServiceSubstitution()->Unsubstitute(automationService.Obj());
    automationService = nullptr;

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
