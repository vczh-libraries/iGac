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


extern vl::WString GetSysVerString();
extern void LaunchURL(const vl::WString& url);

extern vl::WString GetFileDisplayName(const vl::WString& file);
extern vl::WString GetFileDisplayType(const vl::WString& file);

extern vl::vint64_t GetFileSize(const vl::WString& file);
extern vl::WString GetFileSizeString(vl::vint64_t fileSize);
extern vl::WString GetFileModificationTimeString(const vl::WString& file);

extern vl::Ptr<vl::presentation::INativeImage>  GetFileIconImage(const vl::WString& file, vl::presentation::Size size);


#endif
