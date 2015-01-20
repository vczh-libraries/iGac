//
//  ID3Convert.cpp
//  ID3Convert
//
//  Created by Robert Bu on 1/20/15.
//  Copyright (c) 2015 Robert Bu. All rights reserved.
//

#include "ID3Convert.h"
#include "External/taglib/tag.h"
#include "External/taglib/fileref.h"

#include <Foundation/Foundation.h>
#include <Cocoa/Cocoa.h>

namespace id3c
{
    using namespace TagLib;
    
    NSStringEncoding EncodingFromCFEncoding(long cfEncoding, NSStringEncoding backup = NSUTF8StringEncoding)
    {
        NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding ((CFStringEncoding)cfEncoding);
        if(enc == kCFStringEncodingInvalidId)
        {
            enc = backup;
        }
        return enc;
    }
    
    NSData* ConvertStringEncodingToData(const char* str, size_t length, long srcEncoding, long destEncoding)
    {
        NSStringEncoding srcEnc = EncodingFromCFEncoding(srcEncoding, CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000));
        NSStringEncoding destEnc = EncodingFromCFEncoding(destEncoding, CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8));
        
        NSString* encodedStr = [[NSString alloc] initWithBytes: str
                                                        length: length
                                                      encoding: srcEnc];
        
        NSData* strData = [encodedStr dataUsingEncoding:destEnc];
        return strData;
    }
    
    NSString* ConvertStringEncoding(const char* str, size_t length, long srcEncoding, long destEncoding)
    {
        NSStringEncoding destEnc = EncodingFromCFEncoding(srcEncoding);
        
        NSString* dest = [[NSString alloc] initWithData:ConvertStringEncodingToData(str, length, srcEncoding, destEncoding) encoding:destEnc];
        return dest;
    }

    String ConvertField(String fd, long srcEncoding, long dstEncoding)
    {
        if(!fd.isAscii())
        {
            std::string ss = fd.toCString();
            
            NSString* str = ConvertStringEncoding(ss.c_str(), ss.size(), srcEncoding, dstEncoding == -1 ? kCFStringEncodingUTF8 : dstEncoding);
            
            return String([str UTF8String], String::UTF8);
        }
        return fd;
    }
    
    bool ConvertFileID3Encoding(const char* file, long srcEncoding, long dstEncoding)
    {
        FileRef f(file);
        
        if(!f.isNull() && f.tag())
        {
            Tag* tag = f.tag();
            
            tag->setTitle(ConvertField(tag->title(), srcEncoding, dstEncoding));
            tag->setAlbum(ConvertField(tag->album(), srcEncoding, dstEncoding));
            tag->setArtist(ConvertField(tag->artist(), srcEncoding, dstEncoding));
            tag->setGenre(ConvertField(tag->genre(), srcEncoding, dstEncoding));
            tag->setComment(ConvertField(tag->comment(), srcEncoding, dstEncoding));
            
            return f.save();
        }
        
        return false;
    }
    
    
    CFEncodingInfo g_encodings[] =
    {
        { kCFStringEncodingMacJapanese,             "MacJapanese" },
        { kCFStringEncodingMacChineseTrad,          "MacChineseTrad" },
        { kCFStringEncodingMacKorean,               "MacKorean" },
        { kCFStringEncodingMacArabic,               "MacArabic" },
        { kCFStringEncodingMacHebrew,               "MacHebrew" },
        { kCFStringEncodingMacGreek,                "MacGreek" },
        { kCFStringEncodingMacCyrillic,             "MacCyrillic" },
        { kCFStringEncodingMacDevanagari,           "MacDevanagari" },
        { kCFStringEncodingMacGurmukhi,             "MacGurmukhi" },
        { kCFStringEncodingMacGujarati,             "MacGujarati" },
        { kCFStringEncodingMacOriya,                "MacOriya" },
        { kCFStringEncodingMacBengali,              "MacBengali" },
        { kCFStringEncodingMacTamil,                "MacTamil" },
        { kCFStringEncodingMacTelugu,               "MacTelugu" },
        { kCFStringEncodingMacKannada,              "MacKannada" },
        { kCFStringEncodingMacMalayalam,            "MacMalayalam" },
        { kCFStringEncodingMacSinhalese,            "MacSinhalese" },
        { kCFStringEncodingMacBurmese,              "MacBurmese" },
        { kCFStringEncodingMacKhmer,                "MacKhmer" },
        { kCFStringEncodingMacThai,                 "MacThai" },
        { kCFStringEncodingMacLaotian,              "MacLaotian" },
        { kCFStringEncodingMacGeorgian,             "MacGeorgian" },
        { kCFStringEncodingMacArmenian,             "MacArmenian" },
        { kCFStringEncodingMacChineseSimp,          "MacChineseSimp" },
        { kCFStringEncodingMacTibetan,              "MacTibetan" },
        { kCFStringEncodingMacMongolian,            "MacMongolian" },
        { kCFStringEncodingMacEthiopic,             "MacEthiopic" },
        { kCFStringEncodingMacCentralEurRoman,      "MacCentralEurRoman," },
        { kCFStringEncodingMacVietnamese,           "MacVietnamese" },
        { kCFStringEncodingMacExtArabic,            "MacExtArabic" },
        
        { kCFStringEncodingMacSymbol,               "MacSymbol" },
        { kCFStringEncodingMacDingbats,             "MacDingbats" },
        { kCFStringEncodingMacTurkish,              "MacTurkish" },
        { kCFStringEncodingMacCroatian,             "MacCroatian" },
        { kCFStringEncodingMacIcelandic,            "MacIcelandic" },
        { kCFStringEncodingMacRomanian,             "MacRomanian" },
        { kCFStringEncodingMacCeltic,               "MacCeltic" },
        { kCFStringEncodingMacGaelic,               "MacGaelic" },
        
        { kCFStringEncodingMacFarsi,                "MacFarsi" },
        
        { kCFStringEncodingMacUkrainian,            "MacUkrainian" },
        
        { kCFStringEncodingMacInuit,                "MacInuit" },
        { kCFStringEncodingMacVT100,                "MacVT100" },
        
        { kCFStringEncodingMacHFS,                  "MacHFS" },
        { kCFStringEncodingISOLatin1,               "ISOLatin1" },
        { kCFStringEncodingISOLatin2,               "ISOLatin2" },
        { kCFStringEncodingISOLatin3,               "ISOLatin3" },
        { kCFStringEncodingISOLatin4,               "ISOLatin4" },
        { kCFStringEncodingISOLatinCyrillic,        "ISOLatinCyrillic" },
        { kCFStringEncodingISOLatinArabic,          "ISOLatinArabic" },
        { kCFStringEncodingISOLatinGreek,           "ISOLatinGreek" },
        { kCFStringEncodingISOLatinHebrew,          "ISOLatinHebrew" },
        { kCFStringEncodingISOLatin5,               "ISOLatin5" },
        { kCFStringEncodingISOLatin6,               "ISOLatin6" },
        { kCFStringEncodingISOLatinThai,            "ISOLatinThai" },
        { kCFStringEncodingISOLatin7,               "ISOLatin7" },
        { kCFStringEncodingISOLatin8,               "ISOLatin8" },
        { kCFStringEncodingISOLatin9,               "ISOLatin9" },
        { kCFStringEncodingISOLatin10,              "ISOLatin10" },
        
        
        { kCFStringEncodingDOSLatinUS,              "DOSLatinUS" },
        { kCFStringEncodingDOSGreek,                "DOSGreek" },
        { kCFStringEncodingDOSBalticRim,            "DOSBalticRim" },
        { kCFStringEncodingDOSLatin1,               "DOSLatin1" },
        { kCFStringEncodingDOSGreek1,               "DOSGreek1" },
        { kCFStringEncodingDOSLatin2,               "DOSLatin2" },
        { kCFStringEncodingDOSCyrillic,             "DOSCyrillic" },
        { kCFStringEncodingDOSTurkish,              "DOSTurkish" },
        { kCFStringEncodingDOSPortuguese,           "DOSPortuguese" },
        { kCFStringEncodingDOSIcelandic,            "DOSIcelandic" },
        { kCFStringEncodingDOSHebrew,               "DOSHebrew" },
        { kCFStringEncodingDOSCanadianFrench,       "DOSCanadianFrench" },
        { kCFStringEncodingDOSArabic,               "DOSArabic" },
        { kCFStringEncodingDOSNordic,               "DOSNordic" },
        { kCFStringEncodingDOSRussian,              "DOSRussian" },
        { kCFStringEncodingDOSGreek2,               "DOSGreek2" },
        { kCFStringEncodingDOSThai,                 "DOSThai" },
        { kCFStringEncodingDOSJapanese,             "DOSJapanese" },
        { kCFStringEncodingDOSChineseSimplif,       "DOSChineseSimplif" },
        { kCFStringEncodingDOSKorean,               "DOSKorean" },
        { kCFStringEncodingDOSChineseTrad,          "DOSChineseTrad" },
        { kCFStringEncodingWindowsLatin1,           "WindowsLatin1" },
        { kCFStringEncodingWindowsLatin2,           "WindowsLatin2" },
        { kCFStringEncodingWindowsCyrillic,         "WindowsCyrillic" },
        { kCFStringEncodingWindowsGreek,            "WindowsGreek" },
        { kCFStringEncodingWindowsLatin5,           "WindowsLatin5" },
        { kCFStringEncodingWindowsHebrew,           "WindowsHebrew" },
        { kCFStringEncodingWindowsArabic,           "WindowsArabic" },
        { kCFStringEncodingWindowsBalticRim,        "WindowsBalticRim" },
        { kCFStringEncodingWindowsVietnamese,       "WindowsVietnamese" },
        { kCFStringEncodingWindowsKoreanJohab,      "WindowsKoreanJohab," },
        
        
        { kCFStringEncodingASCII,                   "ASCII" },
        { kCFStringEncodingANSEL,                   "ANSEL" },
        { kCFStringEncodingJIS_X0201_76,            "JIS_X0201_76" },
        { kCFStringEncodingJIS_X0208_83,            "JIS_X0208_83" },
        { kCFStringEncodingJIS_X0208_90,            "JIS_X0208_90" },
        { kCFStringEncodingJIS_X0212_90,            "JIS_X0212_90" },
        { kCFStringEncodingJIS_C6226_78,            "JIS_C6226_78" },
        { kCFStringEncodingGB_2312_80,              "GB_2312_80" },
        { kCFStringEncodingGBK_95,                  "GBK_95" },
        { kCFStringEncodingGB_18030_2000,           "GB_18030_2000" },
        { kCFStringEncodingKSC_5601_87,             "KSC_5601_87" },
        { kCFStringEncodingKSC_5601_92_Johab,       "KSC_5601_92_Johab" },
        { kCFStringEncodingCNS_11643_92_P1,         "CNS_11643_92_P1" },
        { kCFStringEncodingCNS_11643_92_P2,         "CNS_11643_92_P2" },
        { kCFStringEncodingCNS_11643_92_P3,         "CNS_11643_92_P3" },
        
        
        { kCFStringEncodingISO_2022_JP,             "ISO_2022_JP" },
        { kCFStringEncodingISO_2022_JP_2,           "ISO_2022_JP_2" },
        { kCFStringEncodingISO_2022_JP_1,           "ISO_2022_JP_1" },
        { kCFStringEncodingISO_2022_JP_3,           "ISO_2022_JP_3" },
        { kCFStringEncodingISO_2022_CN,             "ISO_2022_CN" },
        { kCFStringEncodingISO_2022_CN_EXT,         "ISO_2022_CN_EXT" },
        { kCFStringEncodingISO_2022_KR,             "ISO_2022_KR" },
        
        
        { kCFStringEncodingEUC_JP,                  "EUC_JP" },
        { kCFStringEncodingEUC_CN,                  "EUC_CN" },
        { kCFStringEncodingEUC_TW,                  "EUC_TW" },
        { kCFStringEncodingEUC_KR,                  "EUC_KR" },
        
        { kCFStringEncodingShiftJIS,                "ShiftJIS" },
        { kCFStringEncodingKOI8_R,                  "KOI8_R" },
        { kCFStringEncodingBig5,                    "Big5" },
        { kCFStringEncodingMacRomanLatin1,          "MacRomanLatin1" },
        { kCFStringEncodingHZ_GB_2312,              "HZ_GB_2312" },
        { kCFStringEncodingBig5_HKSCS_1999,         "Big5_HKSCS_1999" },
        { kCFStringEncodingVISCII,                  "VISCII" },
        { kCFStringEncodingKOI8_U,                  "KOI8_U" },
        { kCFStringEncodingBig5_E,                  "Big5_E" },
        
        { kCFStringEncodingUTF16LE,                 "UTF16LE" },
        { kCFStringEncodingUTF16BE,                 "UTF16BE" },
        { kCFStringEncodingUTF16,                   "UTF16" },
        
        { kCFStringEncodingUTF32LE,                 "UTF16LE" },
        { kCFStringEncodingUTF32BE,                 "UTF16BE" },
        { kCFStringEncodingUTF32,                   "UTF16" },
        
        { kCFStringEncodingUTF8,                    "UTF8" },
        
    };

    CFEncodingInfo* GetEncodingList(uint32_t& len)
    {
        len = sizeof(g_encodings) / sizeof(CFEncodingInfo);
        return g_encodings;
    }
    
}