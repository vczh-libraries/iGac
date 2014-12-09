//
//  CocoaImageService.h
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_IMAGE_SERVICE_H__
#define __GAC_OSX_COCOA_IMAGE_SERVICE_H__


#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaImageFrame: public Object, public INativeImageFrame
            {
            public:
                INativeImage*				GetImage()  override;
                Size						GetSize()  override;
                
                bool						SetCache(void* key, Ptr<INativeImageFrameCache> cache)  override;
                Ptr<INativeImageFrameCache>	GetCache(void* key) override;
                Ptr<INativeImageFrameCache>	RemoveCache(void* key)  override;
            };
            
            class CocoaImage: public Object, public INativeImage
            {
            public:
                INativeImageService*		GetImageService() override;
                FormatType					GetFormat()  override;
                vint						GetFrameCount()  override;
                INativeImageFrame*			GetFrame(vint index)  override;
            };
            
            class CocoaImageService: public Object, public INativeImageService
            {
            public:
                Ptr<INativeImage>			CreateImageFromFile(const WString& path) override;
                
                Ptr<INativeImage>			CreateImageFromMemory(void* buffer, vint length)  override;
                
                Ptr<INativeImage>			CreateImageFromStream(stream::IStream& stream)  override;
            };

            
        }
    }
}

#endif