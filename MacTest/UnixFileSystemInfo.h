//
//  UnixFileSystemInfo.h
//  GacOSX
//
//  Created by Robert Bu on 12/12/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __UNIX_FILE_SYSTEM_INFO_H__
#define __UNIX_FILE_SYSTEM_INFO_H__

#include "Vlpp.h"
#include "GacUI.h"

#include <sys/stat.h>

extern vl::WString GetUserHome();
extern void SearchDirectoriesAndFiles(const vl::WString& path, vl::collections::List<vl::WString>& directories, vl::collections::List<vl::WString>& files);
extern bool IsFileDirectory(const vl::WString& fullPath);

extern vl::vint64_t GetFileSize(const vl::WString& file);
extern vl::WString GetFileSizeString(vl::vint64_t fileSize);

extern timespec GetFileModificationTime(const vl::WString& file);
extern vl::WString FileModificationTimeToString(timespec spec);

class FileProperties
{
private:
    vl::Ptr<vl::presentation::GuiImageData> smallIcon;
    vl::Ptr<vl::presentation::GuiImageData> bigIcon;
    bool                isDirectory;
    vl::WString         displayName;
    vl::WString         typeName;
    struct timespec     lastWriteTime;
    vl::vint64_t        size;
    
    bool                loaded;
    vl::WString         fullPath;
    
    void                Load();
    
public:
    FileProperties(const vl::WString& _fullPath);
    
    vl::Ptr<vl::presentation::GuiImageData> GetSmallIcon();
    vl::Ptr<vl::presentation::GuiImageData> GetBigIcon();
    
    bool                    IsDirectory();
    vl::WString             GetDisplayName();
    vl::WString             GetTypeName();
    struct timespec         GetLastWriteTime();
    vl::vint64_t            GetSize();
};


#endif 
