//
//  AppleHelper.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaHelper.h"

#ifdef GAC_OS_OSX

#import <sys/sysctl.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

#endif

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            NSString* GetApplicationPath()
            {
                return [[[NSBundle mainBundle] bundlePath] stringByAppendingString:@"/"];
            }
            
            NSString* GetDocumentsPath()
            {
                NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString* basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
                return [basePath stringByAppendingString:@"/"];
            }
            
            NSString* GetResourcePath()
            {
                return [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
            }
            
            NSString* GetOSVersion()
            {
                return [[NSProcessInfo processInfo] operatingSystemVersionString];
            }
            
            unsigned int GetMainScreenWidth()
            {
                CGDisplayModeRef cgmode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
                unsigned int result = (unsigned int)CGDisplayModeGetWidth(cgmode);
                CGDisplayModeRelease(cgmode);
                return result;
            }
            
            unsigned int GetMainScreenHeight()
            {
                CGDisplayModeRef cgmode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
                unsigned int result = (unsigned int)CGDisplayModeGetHeight(cgmode);
                CGDisplayModeRelease(cgmode);
                return result;
            }
            
            NSString* WStringToNSString(const WString& str)
            {
                NSString* nsstr = [[NSString alloc] initWithBytes: (char*)str.Buffer()
                                                           length: str.Length() * sizeof(wchar_t)
                                                         encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF32LE)];
                return nsstr;
            }
            
            WString NSStringToWString(NSString* str)
            {
                NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF32LE);
                NSData* data = [str dataUsingEncoding: encode];
                
                return WString((wchar_t*)[data bytes], vint([data length]/sizeof(wchar_t)));
            }
            
            
#ifdef GAC_OS_OSX
            
            
            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, unsigned int bpp))
            {
                CGDisplayModeRef cgmode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
                
                int bpp = 0;
                
                // main resolution
                CFStringRef pixEnc = CGDisplayModeCopyPixelEncoding(cgmode);
                if(CFStringCompare(pixEnc, CFSTR(IO32BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                    bpp = 32;
                else if(CFStringCompare(pixEnc, CFSTR(IO16BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                    bpp = 16;
                else if(CFStringCompare(pixEnc, CFSTR(IO8BitIndexedPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                    bpp = 8;
                
                callback((unsigned int)CGDisplayModeGetWidth(cgmode),
                         (unsigned int)CGDisplayModeGetHeight(cgmode),
                         bpp);
                
                CFRelease(pixEnc);
                CGDisplayModeRelease(cgmode);
                
                // additional
                
                CFArrayRef modes = CGDisplayCopyAllDisplayModes(CGMainDisplayID(), 0);
                CFIndex count = CFArrayGetCount(modes);
                
                for (CFIndex index = 0; index < count; index++) {
                    CGDisplayModeRef cgmode = (CGDisplayModeRef)CFArrayGetValueAtIndex(modes, index);
                    bpp = 0;
                    
                    CFStringRef pixEnc = CGDisplayModeCopyPixelEncoding(cgmode);
                    if(CFStringCompare(pixEnc, CFSTR(IO32BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                        bpp = 32;
                    else if(CFStringCompare(pixEnc, CFSTR(IO16BitDirectPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                        bpp = 16;
                    else if(CFStringCompare(pixEnc, CFSTR(IO8BitIndexedPixels), kCFCompareCaseInsensitive) == kCFCompareEqualTo)
                        bpp = 8;
                    CFRelease(pixEnc);
                    
                    callback((unsigned int)CGDisplayModeGetWidth(cgmode),
                             (unsigned int)CGDisplayModeGetHeight(cgmode),
                             (unsigned int)bpp);
                }
                CFRelease(modes);
            }
            
#endif
            
        

        }
    }

}