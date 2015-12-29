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

namespace osx {

    NSString* WStringToNSString(const vl::WString& str)
    {
        NSString* nsstr = [[NSString alloc] initWithBytes: (char*)str.Buffer()
                                                   length: str.Length() * sizeof(wchar_t)
                                                 encoding: NSUTF32LittleEndianStringEncoding];
        return nsstr;
    }

    vl::WString NSStringToWString(NSString* str)
    {
        NSData* data = [str dataUsingEncoding: NSUTF32LittleEndianStringEncoding];
        
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

    vl::WString UTF8StringToWString(const char* str, vl::vint len)
    {
        NSString* nsstr = [[NSString alloc] initWithUTF8String:str];
        return NSStringToWString(nsstr);
    }

    vl::WString GetFileDisplayType(const vl::WString& file)
    {
        CFStringRef kind = nil;
        NSString* path = WStringToNSString(file);
        NSURL *url = [NSURL fileURLWithPath:[path stringByExpandingTildeInPath]];
        LSCopyKindStringForURL((__bridge CFURLRef)url, (CFStringRef *)&kind);
        return kind ? NSStringToWString((__bridge NSString*)kind) : L"???";
    }

    void FindDirectoriesAndFiles(const vl::WString& path, vl::collections::List<vl::WString>& directories, vl::collections::List<vl::WString>& files)
    {
        NSString* file;
        NSString* nsPath = WStringToNSString(path);
        NSDirectoryEnumerator* enumerator = [[NSFileManager defaultManager] enumeratorAtPath:nsPath];
        
        while (file = [enumerator nextObject])
        {
            // check if it's a directory
            BOOL isDirectory = NO;
            [[NSFileManager defaultManager] fileExistsAtPath: [NSString stringWithFormat:@"%@/%@", nsPath, file]
                                                 isDirectory: &isDirectory];
            if (!isDirectory)
            {
                if([file characterAtIndex:0] != '.')
                    files.Add(NSStringToWString(file));
            }
            else
            {
                if([file characterAtIndex:0] != '.')
                    directories.Add(NSStringToWString(file));

                [enumerator skipDescendants];
            }
        }
    }
    
    bool IsFileDirectory(const vl::WString& file)
    {
        BOOL result;
        [[NSFileManager defaultManager] fileExistsAtPath: WStringToNSString(file)
                                             isDirectory: &result];
        
        return result;
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

    vl::Ptr<vl::presentation::INativeImage> GetFileIconImage(const vl::WString& file, vl::presentation::Size size)
    {
        using namespace vl::presentation::osx;
        CocoaImageService* service = (CocoaImageService*)vl::presentation::GetCurrentController()->ImageService();
        return service->GetIconForFile(file, size);
    }
    
    struct timespec GetFileModificationTime(const vl::WString& file)
    {
        struct timespec result;
        NSDictionary* attributes = [[NSFileManager defaultManager] attributesOfItemAtPath: WStringToNSString(file) error:nil];

        result.tv_sec = [[attributes fileModificationDate] timeIntervalSince1970];
        result.tv_nsec = 0;
        return result;
    }
    
    vl::WString GetResourceFolder()
    {
        vl::WString exePath = vl::presentation::GetFolderPath(vl::presentation::controls::GetApplication()->GetExecutablePath());
        return exePath + L"/Contents/Resources/";
    }

}