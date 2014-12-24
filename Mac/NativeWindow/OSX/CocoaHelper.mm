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
                NSString* nsstr = [[NSString alloc] initWithBytes: (wchar_t*)str.Buffer()
                                                           length: str.Length() * sizeof(wchar_t)
                                                         encoding: NSUTF32LittleEndianStringEncoding];
                return nsstr;
            }
            
            NSString* WStringToNSString(const wchar_t* str, uint32_t len)
            {
                NSString* nsstr = [[NSString alloc] initWithBytes: str
                                                           length: len * sizeof(wchar_t)
                                                         encoding: NSUTF32LittleEndianStringEncoding];
                return nsstr;
            }
            
            WString NSStringToWString(NSString* str)
            {
                NSData* data = [str dataUsingEncoding: NSUTF32LittleEndianStringEncoding];
                
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
            
            vint NSEventKeyCodeToGacKeyCode(unsigned short keycode)
            {
                static const vint table[128] =
                {
                    /* 00 */ VKEY_A,
                    /* 01 */ VKEY_S,
                    /* 02 */ VKEY_D,
                    /* 03 */ VKEY_F,
                    /* 04 */ VKEY_H,
                    /* 05 */ VKEY_G,
                    /* 06 */ VKEY_Z,
                    /* 07 */ VKEY_X,
                    /* 08 */ VKEY_C,
                    /* 09 */ VKEY_V,
                    /* 0a */ 0,
                    /* 0b */ VKEY_B,
                    /* 0c */ VKEY_Q,
                    /* 0d */ VKEY_W,
                    /* 0e */ VKEY_E,
                    /* 0f */ VKEY_R,
                    /* 10 */ VKEY_Y,
                    /* 11 */ VKEY_T,
                    /* 12 */ VKEY_1,
                    /* 13 */ VKEY_2,
                    /* 14 */ VKEY_3,
                    /* 15 */ VKEY_4,
                    /* 16 */ VKEY_6,
                    /* 17 */ VKEY_5,
                    /* 18 */ VKEY_OEM_PLUS,
                    /* 19 */ VKEY_9,
                    /* 1a */ VKEY_7,
                    /* 1b */ VKEY_OEM_MINUS,
                    /* 1c */ VKEY_8,
                    /* 1d */ VKEY_0,
                    /* 1e */ VKEY_OEM_4, // }
                    /* 1f */ VKEY_O,
                    /* 20 */ VKEY_U,
                    /* 21 */ VKEY_OEM_6, // {
                    /* 22 */ VKEY_I,
                    /* 23 */ VKEY_P,
                    /* 24 */ VKEY_RETURN,
                    /* 25 */ VKEY_L,
                    /* 26 */ VKEY_J,
                    /* 27 */ VKEY_OEM_7, // '
                    /* 28 */ VKEY_K,
                    /* 29 */ VKEY_OEM_1, // ;
                    /* 2a */ VKEY_OEM_5, // '\'
                    /* 2b */ VKEY_OEM_COMMA,
                    /* 2c */ VKEY_OEM_2, // /
                    /* 2d */ VKEY_N,
                    /* 2e */ VKEY_M,
                    /* 2f */ VKEY_OEM_PERIOD,
                    /* 30 */ VKEY_TAB,
                    /* 31 */ VKEY_SPACE,
                    /* 32 */ VKEY_OEM_3, // `
                    /* 33 */ VKEY_BACK,
                    /* 34 */ 0,
                    /* 35 */ VKEY_ESCAPE,
                    /* 36 */ 0,                 // RIGHT_SUPER
                    /* 37 */ 0,                 // LEFT_SUPER
                    /* 38 */ VKEY_LSHIFT,
                    /* 39 */ VKEY_CAPITAL,
                    /* 3a */ VKEY_LMENU,        // LATL
                    /* 3b */ VKEY_LCONTROL,
                    /* 3c */ VKEY_RSHIFT,
                    /* 3d */ VKEY_RMENU,        // RALT
                    /* 3e */ VKEY_RCONTROL,
                    /* 3f */ 0,                 // function
                    /* 40 */ VKEY_F17,
                    /* 41 */ VKEY_DECIMAL,
                    /* 42 */ 0,
                    /* 43 */ VKEY_MULTIPLY,
                    /* 44 */ 0,
                    /* 45 */ VKEY_ADD,
                    /* 46 */ 0,
                    /* 47 */ VKEY_NUMLOCK,
                    /* 48 */ VKEY_VOLUME_UP,
                    /* 49 */ VKEY_VOLUME_DOWN,
                    /* 4a */ VKEY_VOLUME_MUTE,
                    /* 4b */ VKEY_DIVIDE,
                    /* 4c */ 0,                  // keypad_enter
                    /* 4d */ 0,
                    /* 4e */ VKEY_SUBTRACT,
                    /* 4f */ VKEY_F18,
                    /* 50 */ VKEY_F19,
                    /* 51 */ VKEY_OEM_NEC_EQUAL, // EQUAL
                    /* 52 */ VKEY_NUMPAD0,
                    /* 53 */ VKEY_NUMPAD1,
                    /* 54 */ VKEY_NUMPAD2,
                    /* 55 */ VKEY_NUMPAD3,
                    /* 56 */ VKEY_NUMPAD4,
                    /* 57 */ VKEY_NUMPAD5,
                    /* 58 */ VKEY_NUMPAD6,
                    /* 59 */ VKEY_NUMPAD7,
                    /* 5a */ VKEY_F20,
                    /* 5b */ VKEY_NUMPAD8,
                    /* 5c */ VKEY_NUMPAD9,
                    /* 5d */ 0,
                    /* 5e */ 0,
                    /* 5f */ 0,
                    /* 60 */ VKEY_F5,
                    /* 61 */ VKEY_F6,
                    /* 62 */ VKEY_F7,
                    /* 63 */ VKEY_F3,
                    /* 64 */ VKEY_F8,
                    /* 65 */ VKEY_F9,
                    /* 66 */ 0,
                    /* 67 */ VKEY_F11,
                    /* 68 */ 0,
                    /* 69 */ VKEY_F13,
                    /* 6a */ VKEY_F16,
                    /* 6b */ VKEY_F14,
                    /* 6c */ 0,
                    /* 6d */ VKEY_F10,
                    /* 6e */ 0,
                    /* 6f */ VKEY_F12,
                    /* 70 */ 0,
                    /* 71 */ VKEY_F15,
                    /* 72 */ VKEY_INSERT,   // help
                    /* 73 */ VKEY_HOME,
                    /* 74 */ 0,             // page up
                    /* 75 */ VKEY_DELETE,
                    /* 76 */ VKEY_F4,
                    /* 77 */ VKEY_END,
                    /* 78 */ VKEY_F2,
                    /* 79 */ 0,             // page down
                    /* 7a */ VKEY_F1,
                    /* 7b */ VKEY_LEFT,
                    /* 7c */ VKEY_RIGHT,
                    /* 7d */ VKEY_DOWN,
                    /* 7e */ VKEY_UP,
                    /* 7f */ 0,
                };
                
                return table[keycode];
            }
            
            NSCursor* MakeCursorFromData(unsigned char* data, int hotspot_x, int hotspot_y)
            {
                NSCursor *c = NULL;
                NSBitmapImageRep* bmp = [[NSBitmapImageRep alloc]
                                         initWithBitmapDataPlanes:0
                                         pixelsWide:16
                                         pixelsHigh:16
                                         bitsPerSample:8
                                         samplesPerPixel:2
                                         hasAlpha:YES
                                         isPlanar:NO
                                         colorSpaceName:NSCalibratedWhiteColorSpace
                                         bytesPerRow:(16*2)
                                         bitsPerPixel:16];
                
                if (bmp)
                {
                    unsigned char* p = [bmp bitmapData];
                    if (p)
                    {
                        int i;
                        for (i = 0; i < 16*16; ++i)
                        {
                            // tried 4 bits per sample and memcpy, didn't work
                            p[2*i] = (data[i]&0xF0) | data[i]>>4;
                            p[2*i+1] = (data[i]<<4) | (data[i]&0xf);
                        }
                        
                        NSImage *img = [[NSImage alloc] init];
                        if (img)
                        {
                            [img addRepresentation:bmp];
                            NSPoint hs = { (CGFloat)hotspot_x, (CGFloat)hotspot_y };
                            c = [[NSCursor alloc] initWithImage:img hotSpot:hs];
                        }
                    }
                }
                return c;
            }
            
            
            Rect FlipRect(NSWindow* window, Rect rect)
            {
                return Rect(rect.x1,
                            [[window screen] frame].size.height - (rect.Top() + rect.Height()),
                            rect.x2,
                            [[window screen] frame].size.height - (rect.Bottom() - rect.Height()));
            }
            
            
            NSScreen* GetWindowScreen(NSWindow* window)
            {
                NSScreen* s = [window screen];
                while(!s && [window parentWindow])
                {
                    s = [[window parentWindow] screen];
                    window = [window parentWindow];
                }
                if(!s)
                    s = [NSScreen mainScreen];
                
                return s;
            }
            
            
            CGFloat FlipY(NSWindow* window, CGFloat y)
            {
                NSScreen* s = GetWindowScreen(window);
                return s.frame.size.height - y;
            }

#endif
            
        

        }
    }

}