//
//  CocoaResourceService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaResourceService.h"
#include "../CocoaPredef.h"
#include "../CocoaHelper.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            // hack hack hack
            // note this guy may not work in a sandboxed app?
            
            NSCursor* LoadSystemCursor(INativeCursor::SystemCursorType cursorId)
            {
               // NSCursor* cursor;
                NSString* cursorName;
                switch(cursorId)
                {
                    case INativeCursor::SmallWaiting:
                    case INativeCursor::LargeWaiting:
                        cursorName = @"busybutclickable";
                        break;
                        
                    case INativeCursor::Cross:
                        cursorName = @"cross";
                        break;
                        
                    case INativeCursor::Hand:
                        cursorName = @"openhand";
                        break;
                        
                    case INativeCursor::Help:
                        cursorName = @"help";
                        break;
                        
                    case INativeCursor::IBeam:
                        cursorName = @"ibeamvertical";
                        break;
                        
                    case INativeCursor::SizeAll:
                        cursorName = @"move";
                        break;
                        
                    case INativeCursor::SizeNESW:
                        cursorName = @"resizenortheastsouthwest";
                        break;
                        
                    case INativeCursor::SizeNWSE:
                        cursorName = @"resizenorthwestsoutheast";
                        break;
                        
                    case INativeCursor::SizeWE:
                        cursorName = @"resizeleftright";
                        break;
                        
                    case INativeCursor::SizeNS:
                        cursorName = @"resizeupdown";
                        break;
                        
                    default:
                        cursorName = 0;
                }
                if(cursorName)
                {
                    // TODO, copy these to proj
                    NSString *cursorPath = [@"/System/Library/Frameworks/ApplicationServices.framework/Versions/A/Frameworks/HIServices.framework/Versions/A/Resources/cursors" stringByAppendingPathComponent:cursorName];
                    
                    NSImage* image = [[NSImage alloc] initByReferencingFile:[cursorPath stringByAppendingPathComponent:@"cursor.pdf"]];
                    
                    NSDictionary* info = [NSDictionary dictionaryWithContentsOfFile:[cursorPath stringByAppendingPathComponent:@"info.plist"]];
                    
                    NSCursor* cursor = [[NSCursor alloc] initWithImage:image
                                                               hotSpot:NSMakePoint([[info valueForKey:@"hotx"] doubleValue],
                                                                                   [[info valueForKey:@"hoty"] doubleValue])];
                    
                    return cursor;
                }
                
                return 0;
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
                    case INativeCursor::Help:
                    case INativeCursor::SizeAll:
                    case INativeCursor::SizeNESW:
                    case INativeCursor::SizeNWSE:
                        cursor = LoadSystemCursor(systemCursorType);
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
                        
                        break;
                        
                    case INativeCursor::IBeam:
                        cursor = [NSCursor IBeamCursor];
                        break;
                        
                        
                    case INativeCursor::SizeWE:
                        cursor = [NSCursor resizeLeftRightCursor];
                        break;
                        
                    case INativeCursor::SizeNS:
                        cursor = [NSCursor resizeUpDownCursor];
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