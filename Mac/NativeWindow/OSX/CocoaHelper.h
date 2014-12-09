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

#import <Foundation/Foundation.h>
#import "TargetConditionals.h"
#import <Availability.h>

#if defined(TARGET_OS_MAC) && TARGET_OS_MAC == 1 && TARGET_IPHONE_SIMULATOR == 0

#define GAC_OS_OSX
#import <Cocoa/Cocoa.h>

#endif

#if defined(TARGET_OS_IPHONE) && TARGET_OS_IPHONE == 1 || TARGET_IPHONE_SIMULATOR == 1

#define GAC_OS_IOS

#endif

#include "GacUI.h"
#include "CocoaPredef.h"

@class CocoaWindowDelegate;

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            NSString* GetApplicationPath();
            NSString* GetDocumentsPath();
            NSString* GetResourcePath();

            NSString* GetOSVersion();
            
            unsigned int GetMainScreenWidth();
            unsigned int GetMainScreenHeight();
            
            NSString*   WStringToNSString(const WString& str);
            WString     NSStringToWString(NSString* str);
            
#ifdef GAC_OS_OSX
            
            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, unsigned int bpp));
            
            NSCursor* MakeCursorFromData(unsigned char* data, int hotspot_x, int hotspot_y);
            
            struct NSContainer
            {
                NSWindow* window;
                NSWindowController* controller;
                CocoaWindowDelegate* delegate;
            };
            
            vint NSEventKeyCodeToGacKeyCode(unsigned short keycode);
            Rect FlipRect(NSWindow* window, Rect rect);
            NSScreen* GetWindowScreen(NSWindow* window);
            CGFloat FlipY(NSWindow* window, CGFloat y);
            
#endif
            
            
            
        }
        
    }
    
}


#endif
