//
//  CocoaClipboardService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaClipboardService.h"
#include "../CocoaHelper.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            bool CocoaClipboardService::SetText(const WString& value)
            {
                NSArray* types = [NSArray arrayWithObjects:NSStringPboardType, nil];
                
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                [pasteboard declareTypes:types owner:nil];
                return [pasteboard setString:WStringToNSString(value)
                                     forType:NSStringPboardType];
            }
            
            WString CocoaClipboardService::GetText()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                
                if (![[pasteboard types] containsObject:NSStringPboardType])
                {
                    return L"";
                }
                
                NSString* str = [pasteboard stringForType:NSStringPboardType];
                if (!str)
                {
                    return L"";
                }
                
                return NSStringToWString(str);
            }
            
            bool CocoaClipboardService::ContainsText()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                return [[pasteboard types] containsObject:NSStringPboardType];
            }

        }
    }
}