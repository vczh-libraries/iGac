//
//  CoreGraphicsApp.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_CORE_GRAPHICS_APP_H__
#define __GAC_OSX_CORE_GRAPHICS_APP_H__

namespace vl { namespace presentation { class GuiHostedController; } }

extern void CoreGraphicsMain(vl::presentation::GuiHostedController* hostedController = nullptr);

int SetupOSXCoreGraphicsRenderer();
int SetupOSXHostedCoreGraphicsRenderer();

#endif 