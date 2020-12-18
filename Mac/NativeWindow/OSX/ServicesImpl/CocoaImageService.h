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

#include <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaImageFrame: public Object, public INativeImageFrame
            {
            protected:
                INativeImage*                                                   image;
                CGImageRef                                                      cgImage;
                collections::Dictionary<void*, Ptr<INativeImageFrameCache>>     caches;
                
            public:
                CocoaImageFrame(INativeImage* image, CGImageRef frame);
                ~CocoaImageFrame();
                
                INativeImage*				GetImage()  override;
                Size						GetSize()  override;
                
                bool						SetCache(void* key, Ptr<INativeImageFrameCache> cache)  override;
                Ptr<INativeImageFrameCache>	GetCache(void* key) override;
                Ptr<INativeImageFrameCache>	RemoveCache(void* key)  override;
                
                /////
                
                CGImageRef                  GetCGImage();
            };
            
            class CocoaImage: public Object, public INativeImage
            {
            protected:
                INativeImageService*                        imageService;
                NSImage*                                    nsImage;
                NSImageRep*                                 imageRep;
                collections::Array<Ptr<CocoaImageFrame>>    frames;
                
            public:
                CocoaImage(INativeImageService* service, NSImage* image);
                
                INativeImageService*		GetImageService() override;
                FormatType					GetFormat()  override;
                vint						GetFrameCount()  override;
                INativeImageFrame*			GetFrame(vint index)  override;
                void                        SaveToStream(stream::IStream& stream, FormatType formatType = FormatType::Unknown) override;
            };
            
            class CocoaImageService: public Object, public INativeImageService
            {
            public:
                Ptr<INativeImage>			CreateImageFromFile(const WString& path) override;
                
                Ptr<INativeImage>			CreateImageFromMemory(void* buffer, vint length)  override;
                
                Ptr<INativeImage>			CreateImageFromStream(stream::IStream& stream)  override;
                
                ////
                Ptr<INativeImage>           GetIconForFile(const WString& path, Size iconSize = Size(0, 0));
            };

            
        }
    }
}

#endif