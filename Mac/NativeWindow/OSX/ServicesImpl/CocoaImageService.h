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
#include "../CocoaHelper.h"

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
#ifdef GAC_OS_OSX
                NSImage*                                    nsImage;
                NSImageRep*                                 imageRep;
#else
                UIImage*                                    nsImage;
#endif
                collections::Array<Ptr<CocoaImageFrame>>    frames;
                
            public:
#ifdef GAC_OS_OSX

                CocoaImage(INativeImageService* service, NSImage* image);
#else
                CocoaImage(INativeImageService* service, UIImage* image);

#endif
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
                
                ////
#ifdef GAC_OS_OSX

                Ptr<INativeImage>           GetIconForFile(const WString& path, Size iconSize = Size(0, 0));
#endif
                
            };

            
        }
    }
}

#endif