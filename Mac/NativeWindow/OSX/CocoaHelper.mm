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
                    /* 00 */ VKEY::_A,
                    /* 01 */ VKEY::_S,
                    /* 02 */ VKEY::_D,
                    /* 03 */ VKEY::_F,
                    /* 04 */ VKEY::_H,
                    /* 05 */ VKEY::_G,
                    /* 06 */ VKEY::_Z,
                    /* 07 */ VKEY::_X,
                    /* 08 */ VKEY::_C,
                    /* 09 */ VKEY::_V,
                    /* 0a */ VKEY::_UNKNOWN,
                    /* 0b */ VKEY::_B,
                    /* 0c */ VKEY::_Q,
                    /* 0d */ VKEY::_W,
                    /* 0e */ VKEY::_E,
                    /* 0f */ VKEY::_R,
                    /* 10 */ VKEY::_Y,
                    /* 11 */ VKEY::_T,
                    /* 12 */ VKEY::_1,
                    /* 13 */ VKEY::_2,
                    /* 14 */ VKEY::_3,
                    /* 15 */ VKEY::_4,
                    /* 16 */ VKEY::_6,
                    /* 17 */ VKEY::_5,
                    /* 18 */ VKEY::_OEM_PLUS,
                    /* 19 */ VKEY::_9,
                    /* 1a */ VKEY::_7,
                    /* 1b */ VKEY::_OEM_MINUS,
                    /* 1c */ VKEY::_8,
                    /* 1d */ VKEY::_0,
                    /* 1e */ VKEY::_OEM_4, // }
                    /* 1f */ VKEY::_O,
                    /* 20 */ VKEY::_U,
                    /* 21 */ VKEY::_OEM_6, // {
                    /* 22 */ VKEY::_I,
                    /* 23 */ VKEY::_P,
                    /* 24 */ VKEY::_RETURN,
                    /* 25 */ VKEY::_L,
                    /* 26 */ VKEY::_J,
                    /* 27 */ VKEY::_OEM_7, // '
                    /* 28 */ VKEY::_K,
                    /* 29 */ VKEY::_OEM_1, // ;
                    /* 2a */ VKEY::_OEM_5, // '\'
                    /* 2b */ VKEY::_OEM_COMMA,
                    /* 2c */ VKEY::_OEM_2, // /
                    /* 2d */ VKEY::_N,
                    /* 2e */ VKEY::_M,
                    /* 2f */ VKEY::_OEM_PERIOD,
                    /* 30 */ VKEY::_TAB,
                    /* 31 */ VKEY::_SPACE,
                    /* 32 */ VKEY::_OEM_3, // `
                    /* 33 */ VKEY::_BACK,
                    /* 34 */ VKEY::_UNKNOWN,
                    /* 35 */ VKEY::_ESCAPE,
                    /* 36 */ VKEY::_UNKNOWN,                 // RIGHT_SUPER
                    /* 37 */ VKEY::_UNKNOWN,                 // LEFT_SUPER
                    /* 38 */ VKEY::_LSHIFT,
                    /* 39 */ VKEY::_CAPITAL,
                    /* 3a */ VKEY::_LMENU,        // LATL
                    /* 3b */ VKEY::_LCONTROL,
                    /* 3c */ VKEY::_RSHIFT,
                    /* 3d */ VKEY::_RMENU,        // RALT
                    /* 3e */ VKEY::_RCONTROL,
                    /* 3f */ VKEY::_UNKNOWN,                 // function
                    /* 40 */ VKEY::_F17,
                    /* 41 */ VKEY::_DECIMAL,
                    /* 42 */ VKEY::_UNKNOWN,
                    /* 43 */ VKEY::_MULTIPLY,
                    /* 44 */ VKEY::_UNKNOWN,
                    /* 45 */ VKEY::_ADD,
                    /* 46 */ VKEY::_UNKNOWN,
                    /* 47 */ VKEY::_NUMLOCK,
                    /* 48 */ VKEY::_VOLUME_UP,
                    /* 49 */ VKEY::_VOLUME_DOWN,
                    /* 4a */ VKEY::_VOLUME_MUTE,
                    /* 4b */ VKEY::_DIVIDE,
                    /* 4c */ VKEY::_UNKNOWN,                  // keypad_enter
                    /* 4d */ VKEY::_UNKNOWN,
                    /* 4e */ VKEY::_SUBTRACT,
                    /* 4f */ VKEY::_F18,
                    /* 50 */ VKEY::_F19,
                    /* 51 */ VKEY::_OEM_NEC_EQUAL, // EQUAL
                    /* 52 */ VKEY::_NUMPAD0,
                    /* 53 */ VKEY::_NUMPAD1,
                    /* 54 */ VKEY::_NUMPAD2,
                    /* 55 */ VKEY::_NUMPAD3,
                    /* 56 */ VKEY::_NUMPAD4,
                    /* 57 */ VKEY::_NUMPAD5,
                    /* 58 */ VKEY::_NUMPAD6,
                    /* 59 */ VKEY::_NUMPAD7,
                    /* 5a */ VKEY::_F20,
                    /* 5b */ VKEY::_NUMPAD8,
                    /* 5c */ VKEY::_NUMPAD9,
                    /* 5d */ VKEY::_UNKNOWN,
                    /* 5e */ VKEY::_UNKNOWN,
                    /* 5f */ VKEY::_UNKNOWN,
                    /* 60 */ VKEY::_F5,
                    /* 61 */ VKEY::_F6,
                    /* 62 */ VKEY::_F7,
                    /* 63 */ VKEY::_F3,
                    /* 64 */ VKEY::_F8,
                    /* 65 */ VKEY::_F9,
                    /* 66 */ VKEY::_UNKNOWN,
                    /* 67 */ VKEY::_F11,
                    /* 68 */ VKEY::_UNKNOWN,
                    /* 69 */ VKEY::_F13,
                    /* 6a */ VKEY::_F16,
                    /* 6b */ VKEY::_F14,
                    /* 6c */ VKEY::_UNKNOWN,
                    /* 6d */ VKEY::_F10,
                    /* 6e */ VKEY::_UNKNOWN,
                    /* 6f */ VKEY::_F12,
                    /* 70 */ VKEY::_UNKNOWN,
                    /* 71 */ VKEY::_F15,
                    /* 72 */ VKEY::_INSERT,   // help
                    /* 73 */ VKEY::_HOME,
                    /* 74 */ VKEY::_UNKNOWN,             // page up
                    /* 75 */ VKEY::_DELETE,
                    /* 76 */ VKEY::_F4,
                    /* 77 */ VKEY::_END,
                    /* 78 */ VKEY::_F2,
                    /* 79 */ VKEY::_UNKNOWN,             // page down
                    /* 7a */ VKEY::_F1,
                    /* 7b */ VKEY::_LEFT,
                    /* 7c */ VKEY::_RIGHT,
                    /* 7d */ VKEY::_DOWN,
                    /* 7e */ VKEY::_UP,
                    /* 7f */ VKEY::_UNKNOWN,
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