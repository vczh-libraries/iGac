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


WString GetUserHome()
{
    struct passwd* pw = getpwuid(getuid());
    
    return atow(AString(pw->pw_dir, (vint)strlen(pw->pw_dir)));
}

void SearchDirectoriesAndFiles(const WString& path, List<WString>& directories, List<WString>& files)
{
    DIR* dir = opendir(wtoa(path).Buffer());
    if(dir)
    {
        for(;;)
        {
            struct dirent* entry = readdir(dir);
            if(entry)
            {
                if(strcmp(entry->d_name, ".") != 0 &&
                   strcmp(entry->d_name, "..") != 0)
                {
                    if(entry->d_type == DT_REG)
                        files.Add(atow(AString(entry->d_name, (vint)entry->d_namlen)));
                    else if(entry->d_type == DT_DIR)
                        directories.Add(atow(AString(entry->d_name, (vint)entry->d_namlen)));
                }
            }
            else
                break;
        }
    }
    closedir(dir);
}

bool IsFileDirectory(const WString& fullPath)
{
    struct stat sb;
    
    if (stat(wtoa(fullPath).Buffer(), &sb) == 0 && S_ISDIR(sb.st_mode))
    {
        return true;
    }
    return false;
}