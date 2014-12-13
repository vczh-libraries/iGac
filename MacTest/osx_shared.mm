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
#import <CoreServices/CoreServices.h>

#include "../Mac/NativeWindow/OSX/ServicesImpl/CocoaImageService.h"

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
    NSURL* nsurl = [NSURL URLWithString:WStringToNSString(url)];
    [[NSWorkspace sharedWorkspace] openURL:nsurl];
}

vl::WString GetFileDisplayName(const vl::WString& file)
{
    return NSStringToWString([[NSFileManager defaultManager] displayNameAtPath:WStringToNSString(file)]);
}

vl::WString GetFileDisplayType(const vl::WString& file)
{
    CFStringRef kind = nil;
    NSString* path = WStringToNSString(file);
    NSURL *url = [NSURL fileURLWithPath:[path stringByExpandingTildeInPath]];
    LSCopyKindStringForURL((__bridge CFURLRef)url, (CFStringRef *)&kind);
    return kind ? NSStringToWString((__bridge NSString*)kind) : L"";
}

vl::vint64_t GetFileSize(const vl::WString& file)
{
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: WStringToNSString(file) error:nil];
    return (vl::vint64_t)[attributes fileSize];
}

vl::WString GetFileModificationTimeString(const vl::WString& file)
{
    NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: WStringToNSString(file) error:nil];
    NSString* dateString = [NSDateFormatter localizedStringFromDate:[attributes fileModificationDate]
                                                          dateStyle:NSDateFormatterShortStyle
                                                          timeStyle:NSDateFormatterShortStyle];
    return NSStringToWString(dateString);
}

vl::WString GetFileSizeString(vl::vint64_t fileSize)
{
    vl::WString unit;
    double size=0;
    if(fileSize >= 1024*1024*1024)
    {
        unit=L" GB";
        size=ceil((double)fileSize/(1024*1024))/1024;
    }
    else if(fileSize>=1024*1024)
    {
        unit=L" MB";
        size=ceil((double)fileSize/(1024*1024));
    }
    else if(fileSize>=1024)
    {
        unit=L" KB";
        size=ceil((double)fileSize/1024);
    }
    else
    {
        unit=L" Bytes";
        size=(double)fileSize;
    }
    
    vl::WString sizeString = vl::ftow(size);
    const wchar_t* reading = sizeString.Buffer();
    const wchar_t* point = wcschr(sizeString.Buffer(), L'.');
    if(point)
    {
        const wchar_t* max = reading + sizeString.Length();
        point += 4;
        if(point > max) point = max;
        sizeString = sizeString.Left(point - reading);
    }
    
    return sizeString + unit;
}

vl::Ptr<vl::presentation::INativeImage> GetFileIconImage(const vl::WString& file, vl::presentation::Size size)
{
    using namespace vl::presentation::osx;
    CocoaImageService* service = (CocoaImageService*)vl::presentation::GetCurrentController()->ImageService();
    return service->GetIconForFile(file, size);
}