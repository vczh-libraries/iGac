//
//  OSXNativeWindow.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSXNATIVEWINDOW_H__
#define __GAC_OSXNATIVEWINDOW_H__

#include "GacUI.h"

#import "TargetConditionals.h"

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC == 1 && TARGET_IPHONE_SIMULATOR == 0

#define GAC_OS_OSX

#endif

#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE == 1 || TARGET_IPHONE_SIMULATOR == 1

#define GAC_OS_IOS

#endif

#ifdef GAC_OS_IOS

@class UIView;

#endif

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            extern INativeController*   CreateOSXNativeController();
            extern void                 SetupOSXApplication();
            extern void                 DestroyOSXNativeController(INativeController* controller);
            
#ifdef GAC_OS_IOS
            extern void                 WindowViewCreated(UIView* view);
#endif
            
        }
        
    }
    
}

#endif