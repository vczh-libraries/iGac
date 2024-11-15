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
                
                return WString::CopyFrom((wchar_t*)[data bytes], vint([data length]/sizeof(wchar_t)));
            }
            
            
#ifdef GAC_OS_OSX
            
            
            void EnumDesktopModes(void (*callback)(unsigned int w, unsigned int h, unsigned int bpp))
            {
                CGDisplayModeRef cgmode = CGDisplayCopyDisplayMode(kCGDirectMainDisplay);
                
                int bpp = 0;
                
                // main resolution
                // todo , CGDisplayModeCopyPixelEncoding deprecated in 10.11
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
            
            VKEY NSEventKeyCodeToGacKeyCode(unsigned short keycode)
            {
                static const VKEY table[128] =
                {
                    /* 00 */ VKEY::KEY_A,
                    /* 01 */ VKEY::KEY_S,
                    /* 02 */ VKEY::KEY_D,
                    /* 03 */ VKEY::KEY_F,
                    /* 04 */ VKEY::KEY_H,
                    /* 05 */ VKEY::KEY_G,
                    /* 06 */ VKEY::KEY_Z,
                    /* 07 */ VKEY::KEY_X,
                    /* 08 */ VKEY::KEY_C,
                    /* 09 */ VKEY::KEY_V,
                    /* 0a */ VKEY::KEY_UNKNOWN,
                    /* 0b */ VKEY::KEY_B,
                    /* 0c */ VKEY::KEY_Q,
                    /* 0d */ VKEY::KEY_W,
                    /* 0e */ VKEY::KEY_E,
                    /* 0f */ VKEY::KEY_R,
                    /* 10 */ VKEY::KEY_Y,
                    /* 11 */ VKEY::KEY_T,
                    /* 12 */ VKEY::KEY_1,
                    /* 13 */ VKEY::KEY_2,
                    /* 14 */ VKEY::KEY_3,
                    /* 15 */ VKEY::KEY_4,
                    /* 16 */ VKEY::KEY_6,
                    /* 17 */ VKEY::KEY_5,
                    /* 18 */ VKEY::KEY_OEM_PLUS,
                    /* 19 */ VKEY::KEY_9,
                    /* 1a */ VKEY::KEY_7,
                    /* 1b */ VKEY::KEY_OEM_MINUS,
                    /* 1c */ VKEY::KEY_8,
                    /* 1d */ VKEY::KEY_0,
                    /* 1e */ VKEY::KEY_OEM_4, // }
                    /* 1f */ VKEY::KEY_O,
                    /* 20 */ VKEY::KEY_U,
                    /* 21 */ VKEY::KEY_OEM_6, // {
                    /* 22 */ VKEY::KEY_I,
                    /* 23 */ VKEY::KEY_P,
                    /* 24 */ VKEY::KEY_RETURN,
                    /* 25 */ VKEY::KEY_L,
                    /* 26 */ VKEY::KEY_J,
                    /* 27 */ VKEY::KEY_OEM_7, // '
                    /* 28 */ VKEY::KEY_K,
                    /* 29 */ VKEY::KEY_OEM_1, // ;
                    /* 2a */ VKEY::KEY_OEM_5, // '\'
                    /* 2b */ VKEY::KEY_OEM_COMMA,
                    /* 2c */ VKEY::KEY_OEM_2, // /
                    /* 2d */ VKEY::KEY_N,
                    /* 2e */ VKEY::KEY_M,
                    /* 2f */ VKEY::KEY_OEM_PERIOD,
                    /* 30 */ VKEY::KEY_TAB,
                    /* 31 */ VKEY::KEY_SPACE,
                    /* 32 */ VKEY::KEY_OEM_3, // `
                    /* 33 */ VKEY::KEY_BACK,
                    /* 34 */ VKEY::KEY_UNKNOWN,
                    /* 35 */ VKEY::KEY_ESCAPE,
                    /* 36 */ VKEY::KEY_UNKNOWN,                 // RIGHT_SUPER
                    /* 37 */ VKEY::KEY_UNKNOWN,                 // LEFT_SUPER
                    /* 38 */ VKEY::KEY_LSHIFT,
                    /* 39 */ VKEY::KEY_CAPITAL,
                    /* 3a */ VKEY::KEY_LMENU,        // LATL
                    /* 3b */ VKEY::KEY_LCONTROL,
                    /* 3c */ VKEY::KEY_RSHIFT,
                    /* 3d */ VKEY::KEY_RMENU,        // RALT
                    /* 3e */ VKEY::KEY_RCONTROL,
                    /* 3f */ VKEY::KEY_UNKNOWN,                 // function
                    /* 40 */ VKEY::KEY_F17,
                    /* 41 */ VKEY::KEY_DECIMAL,
                    /* 42 */ VKEY::KEY_UNKNOWN,
                    /* 43 */ VKEY::KEY_MULTIPLY,
                    /* 44 */ VKEY::KEY_UNKNOWN,
                    /* 45 */ VKEY::KEY_ADD,
                    /* 46 */ VKEY::KEY_UNKNOWN,
                    /* 47 */ VKEY::KEY_NUMLOCK,
                    /* 48 */ VKEY::KEY_VOLUME_UP,
                    /* 49 */ VKEY::KEY_VOLUME_DOWN,
                    /* 4a */ VKEY::KEY_VOLUME_MUTE,
                    /* 4b */ VKEY::KEY_DIVIDE,
                    /* 4c */ VKEY::KEY_UNKNOWN,                  // keypad_enter
                    /* 4d */ VKEY::KEY_UNKNOWN,
                    /* 4e */ VKEY::KEY_SUBTRACT,
                    /* 4f */ VKEY::KEY_F18,
                    /* 50 */ VKEY::KEY_F19,
                    /* 51 */ VKEY::KEY_OEM_NEC_EQUAL, // EQUAL
                    /* 52 */ VKEY::KEY_NUMPAD0,
                    /* 53 */ VKEY::KEY_NUMPAD1,
                    /* 54 */ VKEY::KEY_NUMPAD2,
                    /* 55 */ VKEY::KEY_NUMPAD3,
                    /* 56 */ VKEY::KEY_NUMPAD4,
                    /* 57 */ VKEY::KEY_NUMPAD5,
                    /* 58 */ VKEY::KEY_NUMPAD6,
                    /* 59 */ VKEY::KEY_NUMPAD7,
                    /* 5a */ VKEY::KEY_F20,
                    /* 5b */ VKEY::KEY_NUMPAD8,
                    /* 5c */ VKEY::KEY_NUMPAD9,
                    /* 5d */ VKEY::KEY_UNKNOWN,
                    /* 5e */ VKEY::KEY_UNKNOWN,
                    /* 5f */ VKEY::KEY_UNKNOWN,
                    /* 60 */ VKEY::KEY_F5,
                    /* 61 */ VKEY::KEY_F6,
                    /* 62 */ VKEY::KEY_F7,
                    /* 63 */ VKEY::KEY_F3,
                    /* 64 */ VKEY::KEY_F8,
                    /* 65 */ VKEY::KEY_F9,
                    /* 66 */ VKEY::KEY_UNKNOWN,
                    /* 67 */ VKEY::KEY_F11,
                    /* 68 */ VKEY::KEY_UNKNOWN,
                    /* 69 */ VKEY::KEY_F13,
                    /* 6a */ VKEY::KEY_F16,
                    /* 6b */ VKEY::KEY_F14,
                    /* 6c */ VKEY::KEY_UNKNOWN,
                    /* 6d */ VKEY::KEY_F10,
                    /* 6e */ VKEY::KEY_UNKNOWN,
                    /* 6f */ VKEY::KEY_F12,
                    /* 70 */ VKEY::KEY_UNKNOWN,
                    /* 71 */ VKEY::KEY_F15,
                    /* 72 */ VKEY::KEY_INSERT,   // help
                    /* 73 */ VKEY::KEY_HOME,
                    /* 74 */ VKEY::KEY_UNKNOWN,             // page up
                    /* 75 */ VKEY::KEY_DELETE,
                    /* 76 */ VKEY::KEY_F4,
                    /* 77 */ VKEY::KEY_END,
                    /* 78 */ VKEY::KEY_F2,
                    /* 79 */ VKEY::KEY_UNKNOWN,             // page down
                    /* 7a */ VKEY::KEY_F1,
                    /* 7b */ VKEY::KEY_LEFT,
                    /* 7c */ VKEY::KEY_RIGHT,
                    /* 7d */ VKEY::KEY_DOWN,
                    /* 7e */ VKEY::KEY_UP,
                    /* 7f */ VKEY::KEY_UNKNOWN,
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


            NativeRect FlipRect(NSWindow* window, NativeRect rect)
            {
                return NativeRect(rect.x1.value,
                            [[window screen] frame].size.height - rect.Bottom().value,
                            rect.x2.value,
                            [[window screen] frame].size.height - rect.Top().value);
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
            
            NSFontTraitMask GetTraitMask(bool bold, bool italic)
            {
                NSFontTraitMask traitMask = 0;
                if(bold)
                    traitMask |= NSBoldFontMask;
                if(italic)
                    traitMask |= NSItalicFontMask;
                
                return traitMask;
            }
            
            NSFontTraitMask GetTraitMask(const FontProperties& font)
            {
                return GetTraitMask(font.bold, font.italic);
            }
            
            NSFont* CreateFontWithFontFamily(NSString* fontFamily, NSFontTraitMask traits, uint32_t size, uint32_t weight)
            {
                NSFontManager* fontManager = [NSFontManager sharedFontManager];
                NSFont* font = [fontManager fontWithFamily:fontFamily
                                                    traits:traits
                                                    weight:5
                                                    size:size];
                
                // this is just a pretty naive fall back here
                // but its safe to assume that this is availabe in every OS X
                if(!font)
                {
                    font = [fontManager fontWithFamily:GAC_APPLE_DEFAULT_FONT_FAMILY_NAME
                                                traits:traits
                                                weight:5
                                                  size:size];
                }
                
                return font;
            }
            
            NSFont* CreateFontWithGacFont(const FontProperties& fontProperties)
            {
                return CreateFontWithFontFamily(WStringToNSString(fontProperties.fontFamily),
                                                GetTraitMask(fontProperties),
                                                (uint32_t)fontProperties.size);
            }

#endif
            
        

        }
    }

}