//
//  CocoaResourceService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaResourceService.h"
#include "CocoaPredef.h"
#include "CocoaHelper.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            // from WDC C++ Library w some modification
            
            NSCursor* MakeSWELLSystemCursor(int cursorId)
            {
                // bytemaps are (white<<4)|(alpha)
                const unsigned char B = 0xF;
                const unsigned char W = 0xFF;
                const unsigned char G = 0xF8;
                
                static NSCursor* carr[3] = { 0, 0, 0 };
                
                NSCursor* pc = 0;
                if (cursorId == INativeCursor::SizeAll) pc = carr[0];
                else if (cursorId == INativeCursor::SizeNWSE) pc = carr[1];
                else if (cursorId == INativeCursor::SizeNESW) pc = carr[2];
                else return 0;
                
                if (!pc)
                {
                    if (cursorId == INativeCursor::SizeAll)
                    {
                        static unsigned char p[16*16] =
                        {
                            0, 0, 0, 0, 0, 0, G, W, W, G, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, G, W, B, B, W, G, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, W, B, B, B, B, W, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, G, B, B, B, B, B, B, G, 0, 0, 0, 0,
                            0, 0, 0, G, 0, 0, W, B, B, W, 0, 0, G, 0, 0, 0,
                            0, G, W, B, 0, 0, W, B, B, W, 0, 0, B, W, G, 0,
                            G, W, B, B, W, W, W, B, B, W, W, W, B, B, W, G,
                            W, B, B, B, B, B, B, B, B, B, B, B, B, B, B, W,
                            W, B, B, B, B, B, B, B, B, B, B, B, B, B, B, W,
                            G, W, B, B, W, W, W, B, B, W, W, W, B, B, W, G,
                            0, G, W, B, 0, 0, W, B, B, W, 0, 0, B, W, G, 0,
                            0, 0, 0, G, 0, 0, W, B, B, W, 0, 0, G, 0, 0, 0,
                            0, 0, 0, 0, G, B, B, B, B, B, B, G, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, W, B, B, B, B, W, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, G, W, B, B, W, G, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, G, W, W, G, 0, 0, 0, 0, 0, 0,
                        };
                        pc = carr[0] = MakeCursorFromData(p, 8, 8);
                    }
                    else if (cursorId == INativeCursor::SizeNWSE ||
                             cursorId == INativeCursor::SizeNESW)
                    {
                        static unsigned char p[16*16] =
                        {
                            W, W, W, W, W, W, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            W, G, G, G, W, G, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            W, G, B, W, G, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            W, G, W, B, W, G, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            W, W, G, W, B, W, G, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                            W, G, 0, G, W, B, W, G, 0, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, G, W, B, W, G, 0, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, G, W, B, W, G, 0, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, G, W, B, W, G, 0, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, G, W, B, W, G, 0, 0, 0, 0,
                            0, 0, 0, 0, 0, 0, 0, 0, G, W, B, W, G, 0, G, W,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, G, W, B, W, G, W, W,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, G, W, B, W, G, W,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, G, W, B, G, W,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, G, W, G, G, G, W,
                            0, 0, 0, 0, 0, 0, 0, 0, 0, 0, W, W, W, W, W, W,
                        };
                        if (cursorId == INativeCursor::SizeNESW)
                        {
                            int x, y;
                            for (y = 0; y < 16; ++y)
                            {
                                for (x = 0; x < 8; ++x)
                                {
                                    unsigned char tmp = p[16*y+x];
                                    p[16*y+x] = p[16*y+16-x-1];
                                    p[16*y+16-x-1] = tmp;
                                }
                            }
                            
                            pc = carr[2] = MakeCursorFromData(p, 8, 8);
                        }
                        else
                        {
                            pc = carr[1] = MakeCursorFromData(p, 8, 8);
                        }
                        
                        if (cursorId == INativeCursor::SizeNESW) // swap back!
                        {
                            int x, y;
                            for (y = 0; y < 16; ++y)
                            {
                                for (x = 0; x < 8; ++x)
                                {
                                    unsigned char tmp = p[16*y+x];
                                    p[16*y+x] = p[16*y+16-x-1];
                                    p[16*y+16-x-1] = tmp;
                                }
                            }
                        }
                    }
                }
                
                
                return pc;
            }
            
            
            CocoaCursor::CocoaCursor(NSCursor* _cursor):
                cursor(_cursor),
                isSystemCursor(false),
                systemCursorType(INativeCursor::Arrow)
            {
                
            }
            
            CocoaCursor::CocoaCursor(SystemCursorType _type):
                cursor(0),
                isSystemCursor(true),
                systemCursorType(_type)
            {
                InitSystemCursors();
            }
            
            void CocoaCursor::InitSystemCursors()
            {
                // seems NSCursor won't get properly initialized until applicationDidFinishLaunching happened
                switch (systemCursorType)
                {
                    case INativeCursor::SmallWaiting:
                    case INativeCursor::LargeWaiting:
                        cursor = [NSCursor arrowCursor];
                        //                        throw NotSupportedException(L"Waiting cursor not supported by OSX (its managed by the system). This behavior maybe changed later as we could load a cursor from a image.");
                        break;
                        
                    case INativeCursor::Arrow:
                        cursor = [NSCursor arrowCursor];
                        break;
                        
                    case INativeCursor::Cross:
                        cursor = [NSCursor crosshairCursor];
                        break;
                        
                    case INativeCursor::Hand:
                        cursor = [NSCursor openHandCursor];
                        break;
                        
                    case INativeCursor::Help:
                        break;
                        
                    case INativeCursor::IBeam:
                        cursor = [NSCursor IBeamCursor];
                        break;
                        
                    case INativeCursor::SizeAll:
                        cursor = MakeSWELLSystemCursor(INativeCursor::SizeAll);
                        break;
                        
                    case INativeCursor::SizeNESW:
                        cursor = MakeSWELLSystemCursor(INativeCursor::SizeNESW);
                        break;
                        
                    case INativeCursor::SizeNWSE:
                        cursor = MakeSWELLSystemCursor(INativeCursor::SizeNWSE);
                        break;
                        
                    case INativeCursor::SizeWE:
                        cursor = [NSCursor resizeLeftRightCursor];
                        break;
                        
                    case INativeCursor::SizeNS:
                        cursor = [NSCursor resizeUpCursor];
                        break;
                        
                }
            }
            
            bool CocoaCursor::IsSystemCursor()
            {
                return isSystemCursor;
            }
            
            NSCursor* CocoaCursor::GetNativeCursor() const
            {
                return cursor;
            }
            
            void CocoaCursor::Set()
            {
                if(!cursor && IsSystemCursor())
                    InitSystemCursors();
                
                if(cursor)
                {
                    [cursor set];
                }
            }
            
            INativeCursor::SystemCursorType CocoaCursor::GetSystemCursorType()
            {
                return systemCursorType;
            }
            
            CocoaResourceService::CocoaResourceService()
            {
                {
                    systemCursors.Resize(INativeCursor::SystemCursorCount);
                    for(vint i=0;i<systemCursors.Count();i++)
                    {
                        systemCursors[i]=new CocoaCursor((INativeCursor::SystemCursorType)i);
                    }
                }
                {
                    NSFont* userFont = [NSFont userFontOfSize:10];
                    NSFontDescriptor* descriptor = [userFont fontDescriptor];
                    
                    defaultFont.fontFamily = NSStringToWString([descriptor.fontAttributes valueForKey:NSFontFamilyAttribute]);
                    // osx default is 12
                    defaultFont.size = 12;
                    
                    NSFontTraitMask traits = [[descriptor.fontAttributes valueForKey:NSFontTraitsAttribute] unsignedIntegerValue];
                    
                    defaultFont.italic = traits & NSItalicFontMask;
                    defaultFont.bold = traits & NSBoldFontMask;
                    
                    // underline is handled by text attribute
                    // not a font attribute
                    defaultFont.underline = false;
                    defaultFont.strikeline = false;
                    
                    // system default
                    defaultFont.antialias = true;
                    defaultFont.verticalAntialias = true;
                }
            }
            
            CocoaResourceService::~CocoaResourceService()
            {
                
            }
            
            INativeCursor* CocoaResourceService::GetSystemCursor(INativeCursor::SystemCursorType type)
            {
                vint index = (vint)type;
                if(index < systemCursors.Count())
                {
                    return systemCursors[index].Obj();
                }
                return 0;;
            }
            
            INativeCursor* CocoaResourceService::GetDefaultSystemCursor()
            {
                return GetSystemCursor(INativeCursor::Arrow);
            }
            
            FontProperties CocoaResourceService::GetDefaultFont()
            {
                return defaultFont;
            }
            
            void CocoaResourceService::SetDefaultFont(const FontProperties& value)
            {
                defaultFont = value;
            }

        }

    }

}