//
//  ID3Convert.h
//  ID3Convert
//
//  Created by Robert Bu on 1/20/15.
//  Copyright (c) 2015 Robert Bu. All rights reserved.
//

#ifndef __K_ID3CONVERT_H__
#define __K_ID3CONVERT_H__

#include <stdint.h>

namespace id3c
{
    /*
     Default src encoding = GBK_18030_2000
     Default dst encoding = UTF8
     */
    extern bool ConvertFileID3Encoding(const char* file, long srcEncoding, long dstEncoding = -1);
    
    
    struct CFEncodingInfo
    {
        long v;
        const char* name;
    };
    
    extern CFEncodingInfo* GetEncodingList(uint32_t& len);
}


#endif
