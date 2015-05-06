//
//  UnixFileSystemInfo.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/12/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "UnixFileSystemInfo.h"
#include <pwd.h>
#include <dirent.h>
#include <unistd.h>
#include <sys/fcntl.h>
#include <sys/stat.h>
#include <math.h>
#include <time.h>

#if defined(__APPLE__)

#include "osx_shared.h"

#endif


vl::WString GetUserHome()
{
    struct passwd* pw = getpwuid(getuid());
    
    return atow(vl::AString(pw->pw_dir, (vl::vint)strlen(pw->pw_dir)));
}

void SearchDirectoriesAndFiles(const vl::WString& path, vl::collections::List<vl::WString>& directories, vl::collections::List<vl::WString>& files)
{
#if defined(__APPLE__)
    
    osx::FindDirectoriesAndFiles(path, directories, files);
    
#else
    DIR* dir = opendir(wtoa(path).Buffer());
    if(dir)
    {
        for(;;)
        {
            struct dirent* entry = readdir(dir);
            if(entry)
            {
                if(strcmp(entry->d_name, ".") != 0 &&
                   strcmp(entry->d_name, "..") != 0 &&
                   entry->d_name[0] != '.')
                {
                    if(entry->d_type == DT_REG)
                        files.Add(atow(vl::AString(entry->d_name, (vl::vint)entry->d_namlen)));
                    else if(entry->d_type == DT_DIR)
                        directories.Add(atow(vl::AString(entry->d_name, (vl::vint)entry->d_namlen)));
                }
            }
            else
                break;
        }
        closedir(dir);
    }
#endif
}

bool IsFileDirectory(const vl::WString& fullPath)
{
    struct stat sb;
    
    if (stat(wtoa(fullPath).Buffer(), &sb) == 0 && S_ISDIR(sb.st_mode))
    {
        return true;
    }
    return false;
}

timespec GetFileModificationTime(const vl::WString& file)
{
    struct stat sb;
    
    if (stat(wtoa(file).Buffer(), &sb) == 0)
    {
#if defined(__APPLE__)
        return sb.st_mtimespec;
#else
        timespec ts;
        ts.tv_sec = sb.st_mtime;
        ts.tv_nsec = sb.st_mtimensec;
        
        return ts;
#endif
    }
    return timespec();
}

vl::WString FileModificationTimeToString(timespec spec)
{
    struct tm t;
    
    tzset();
    if(localtime_r(&(spec.tv_sec), &t) == NULL)
        return L"Unknown";
    
    char buf[256];
    size_t len = strftime(buf, 256, "%F %T", &t);
    
    if(len == 0)
        return L"Unknown";

    buf[len] = '\0';
    return atow(vl::AString(buf, (vl::vint)len));
}

vl::vint64_t GetFileSize(const vl::WString& file)
{
    struct stat attr;
    if(stat(wtoa(file).Buffer(), &attr) == 0)
        return (vl::vint64_t)attr.st_size;
    return 0;
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

void FileProperties::Load()
{
    if(!loaded)
    {
#if defined(__APPLE__)
        
        smallIcon       =   new vl::presentation::GuiImageData(osx::GetFileIconImage(fullPath, vl::presentation::Size(24, 24)), 0);
        bigIcon         =   new vl::presentation::GuiImageData(osx::GetFileIconImage(fullPath, vl::presentation::Size(48, 48)), 0);
        
        lastWriteTime   =   osx::GetFileModificationTime(fullPath);
        size            =   osx::GetFileSize(fullPath);
        
        isDirectory     =   osx::IsFileDirectory(fullPath);
        displayName     =   osx::GetFileDisplayName(fullPath);
        typeName        =   osx::GetFileDisplayType(fullPath);
        
#else
        
        loaded          =   true;
        isDirectory     =   IsFileDirectory(fullPath);
        
        lastWriteTime   =   GetFileModificationTime(fullPath);
        size            =   GetFileSize(fullPath);
  
        
#endif
    }
}

FileProperties::FileProperties(const vl::WString& _fullPath)
:loaded(false)
,isDirectory(false)
,fullPath(_fullPath)
{
}

vl::Ptr<vl::presentation::GuiImageData> FileProperties::GetSmallIcon()
{
    Load();
    return smallIcon;
}

vl::Ptr<vl::presentation::GuiImageData> FileProperties::GetBigIcon()
{
    Load();
    return bigIcon;
}

bool FileProperties::IsDirectory()
{
    Load();
    return isDirectory;
}

vl::WString FileProperties::GetDisplayName()
{
    Load();
    return displayName;
}

vl::WString FileProperties::GetTypeName()
{
    Load();
    return typeName;
}

struct timespec FileProperties::GetLastWriteTime()
{
    Load();
    return lastWriteTime;
}

vl::vint64_t FileProperties::GetSize()
{
    Load();
    return size;
}