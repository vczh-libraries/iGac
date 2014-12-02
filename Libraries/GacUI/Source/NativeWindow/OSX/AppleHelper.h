//
//  AppleHelper.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_APLLE_HELPER_H__
#define __GAC_OSX_APLLE_HELPER_H__

// for use with bridge files only
// contains objc headers

#include <Foundation/Foundation.h>

#include "TargetConditionals.h"
#include <Availability.h>

#include "../../GuiTypes.h"

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC == 1 && TARGET_IPHONE_SIMULATOR == 0

#define GAC_OS_OSX
#include <Cocoa/Cocoa.h>

#endif

#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE == 1 || TARGET_IPHONE_SIMULATOR == 1

#define GAC_OS_IOS

#endif


#include "OSXPredef.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            NSString* GetApplicationPath();
            NSString* GetDocumentsPath();
            NSString* GetResourcePath();

            NSString* GetOSVersion();
            
            unsigned int GetMainScreenWidth();
            unsigned int GetMainScreenHeight();
            
#ifdef GAC_OS_OSX
            
            void SetupOSXApplication();
            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, int bpp));
            
            NSString* WStringToNSString(const WString& str);
            WString NSStringToWString(NSString* str);
            
            struct NSContainer
            {
                NSWindow* window;
                NSWindowController* controller;
            };
            
            
#endif
            
            
            
        }
        
    }
    
}


#endif
