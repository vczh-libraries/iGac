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
#import <UIKit/UIKit.h>

#endif

#include "GacUI.h"
#include "CocoaPredef.h"

#define GAC_APPLE_DEFAULT_FONT_FAMILY_NAME @"Helvetica"

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
            NSString*   WStringToNSString(const wchar_t* str, uint32_t len);
            WString     NSStringToWString(NSString* str);
            
#ifdef GAC_OS_OSX

            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, unsigned int bpp));
            
            NSCursor* MakeCursorFromData(unsigned char* data, int hotspot_x, int hotspot_y);
            
            NSFont* CreateFontWithFontFamily(NSString* fontFamily, NSFontTraitMask traits, uint32_t size, uint32_t weight = 5);
            NSFont* CreateFontWithGacFont(const FontProperties& font);
            NSFontTraitMask GetTraitMask(bool bold, bool italic);
            NSFontTraitMask GetTraitMask(const FontProperties& font);
            
            VKEY NSEventKeyCodeToGacKeyCode(unsigned short keycode);
            NativeRect FlipRect(NSWindow* window, NativeRect rect);
            NSScreen* GetWindowScreen(NSWindow* window);
            CGFloat FlipY(NSWindow* window, CGFloat y);
            
#endif



        }
        
    }
    
}


#endif
