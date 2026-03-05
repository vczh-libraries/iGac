//
//  osx_shared.h
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GacOSX__osx_shared__
#define __GacOSX__osx_shared__

#include "GacUI.h"
#include <sys/stat.h>

namespace osx
{
    extern vl::WString GetSysVerString();
    extern void LaunchURL(const vl::WString& url);
    
    extern vl::WString GetFileDisplayName(const vl::WString& file);
    extern vl::WString GetFileDisplayType(const vl::WString& file);
    extern vl::WString GetFileModificationTimeString(const vl::WString& file);
    
    extern bool IsFileDirectory(const vl::WString& file);
    
    extern struct timespec GetFileModificationTime(const vl::WString& file);
    
    extern vl::Ptr<vl::presentation::INativeImage>  GetFileIconImage(const vl::WString& file, vl::presentation::Size size);
    
    extern vl::vint64_t GetFileSize(const vl::WString& file);
    extern vl::WString GetFileModificationTimeString(const vl::WString& file);
    
    extern vl::WString UTF8StringToWString(const char* str, vl::vint len);
    extern void FindDirectoriesAndFiles(const vl::WString& path, vl::collections::List<vl::WString>& directories, vl::collections::List<vl::WString>& files);
    
    extern vl::WString GetResourceFolder();
}


inline int wcsicmp(const wchar_t* s1, const wchar_t* s2)
{
    wchar_t c1 = *s1, c2 = *s2;
    while (c1 != 0 && c2 != 0)
    {
        if (c1 >= 'a' && c1 <= 'z') c1 -= 'a' + 'A';
        if (c2 >= 'a' && c2 <= 'z') c2 -= 'a' + 'A';
        if (c2 < c1) return -1;
        else if (c2 > c1)
            return 1;
        c1 = *(++s1); c2 = *(++s2);
    }
    return 0;
}


#endif
