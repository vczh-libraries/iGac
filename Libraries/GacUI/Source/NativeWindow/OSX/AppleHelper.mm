//
//  AppleHelper.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "AppleHelper.h"

#ifdef GAC_OS_OSX

#import <sys/sysctl.h>
#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>

// _NSGetProgname
#import <crt_externs.h>


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
            
            
            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, int bpp))
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
                             bpp);
                }
                CFRelease(modes);
            }
            
            
            static NSString* FindAppName()
            {
                size_t i;
                NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
                
                // Keys to search for as potential application names
                NSString* GacNameKeys[] = {
                    @"CFBundleDisplayName",
                    @"CFBundleName",
                    @"CFBundleExecutable",
                };
                
                for (i = 0;  i < sizeof(GacNameKeys) / sizeof(GacNameKeys[0]);  i++)
                {
                    id name = [infoDictionary objectForKey:GacNameKeys[i]];
                    if (name &&
                        [name isKindOfClass:[NSString class]] &&
                        ![name isEqualToString:@""])
                    {
                        return name;
                    }
                }
                
                char** progname = _NSGetProgname();
                if (progname && *progname)
                    return [NSString stringWithUTF8String:*progname];
                
                // Really shouldn't get here
                return @"Gac Application";
            }
            
            void CreateMenuBar(void) {
                NSString* appName = FindAppName();
                
                NSMenu* bar = [[NSMenu alloc] init];
                [NSApp setMainMenu:bar];
                
                NSMenuItem* appMenuItem = [bar addItemWithTitle:@"" action:NULL keyEquivalent:@""];
                NSMenu* appMenu = [[NSMenu alloc] init];
                [appMenuItem setSubmenu:appMenu];
                
                [appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", appName]
                                   action:@selector(orderFrontStandardAboutPanel:)
                            keyEquivalent:@""];
                [appMenu addItem:[NSMenuItem separatorItem]];
                NSMenu* servicesMenu = [[NSMenu alloc] init];
                [NSApp setServicesMenu:servicesMenu];
                [[appMenu addItemWithTitle:@"Services"
                                    action:NULL
                             keyEquivalent:@""] setSubmenu:servicesMenu];
                [appMenu addItem:[NSMenuItem separatorItem]];
                [appMenu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", appName]
                                   action:@selector(hide:)
                            keyEquivalent:@"h"];
                [[appMenu addItemWithTitle:@"Hide Others"
                                    action:@selector(hideOtherApplications:)
                             keyEquivalent:@"h"]
                 setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
                [appMenu addItemWithTitle:@"Show All"
                                   action:@selector(unhideAllApplications:)
                            keyEquivalent:@""];
                [appMenu addItem:[NSMenuItem separatorItem]];
                [appMenu addItemWithTitle:[NSString stringWithFormat:@"Quit %@", appName]
                                   action:@selector(terminate:)
                            keyEquivalent:@"q"];
                
                NSMenuItem* windowMenuItem =
                [bar addItemWithTitle:@"" action:NULL keyEquivalent:@""];
                NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
                [NSApp setWindowsMenu:windowMenu];
                [windowMenuItem setSubmenu:windowMenu];
                
                [windowMenu addItemWithTitle:@"Minimize"
                                      action:@selector(performMiniaturize:)
                               keyEquivalent:@"m"];
                [windowMenu addItemWithTitle:@"Zoom"
                                      action:@selector(performZoom:)
                               keyEquivalent:@""];
                [windowMenu addItem:[NSMenuItem separatorItem]];
                [windowMenu addItemWithTitle:@"Bring All to Front"
                                      action:@selector(arrangeInFront:)
                               keyEquivalent:@""];
                
                
                // Prior to Snow Leopard, we need to use this oddly-named semi-private API
                // to get the application menu working properly.
                SEL setAppleMenuSelector = NSSelectorFromString(@"setAppleMenu:");
                [NSApp performSelector:setAppleMenuSelector withObject:appMenu];
            }
        
            void SetupOSXApplication()
            {
                [NSApplication sharedApplication];
                [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
               // CreateMenuBar();
            }
#endif
            
        

        }
    }

}