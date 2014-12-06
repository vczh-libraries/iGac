//
//  osx_shared.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "osx_shared.h"

#import <Cocoa/Cocoa.h>
#import <AppKit/AppKit.h>

NSString* WStringToNSString(const vl::WString& str)
{
    NSString* nsstr = [[NSString alloc] initWithBytes: (char*)str.Buffer()
                                               length: str.Length() * sizeof(wchar_t)
                                             encoding: CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF32LE)];
    return nsstr;
}

vl::WString NSStringToWString(NSString* str)
{
    NSStringEncoding encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF32LE);
    NSData* data = [str dataUsingEncoding: encode];
    
    return vl::WString((wchar_t*)[data bytes], vl::vint([data length]/sizeof(wchar_t)));
}

vl::WString GetSysVerString()
{
    return NSStringToWString([[NSProcessInfo processInfo] operatingSystemVersionString]);
}

void LaunchURL(const vl::WString& url)
{
    [[NSWorkspace sharedWorkspace] openFile:WStringToNSString(url)
                            withApplication:@"Safari.app"];
}