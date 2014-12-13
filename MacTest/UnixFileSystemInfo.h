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

using namespace vl;
using namespace vl::collections;

extern WString GetUserHome();
extern void SearchDirectoriesAndFiles(const WString& path, List<WString>& directories, List<WString>& files);
extern bool IsFileDirectory(const WString& fullPath);

#if defined(__APPLE__)


#endif


#endif 
