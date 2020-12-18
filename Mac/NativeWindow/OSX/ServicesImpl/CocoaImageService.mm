//
//  CocoaImageService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaImageService.h"
#include "../CocoaHelper.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaImageFrame::CocoaImageFrame(INativeImage* _image, CGImageRef _frame):
            image(_image),
            cgImage(_frame)
            {
                
            }
            
            CocoaImageFrame::~CocoaImageFrame()
            {
                for(vint i=0 ; i<caches.Count() ; i++)
                {
                    caches.Values().Get(i)->OnDetach(this);
                }
                if(cgImage)
                    CGImageRelease(cgImage);
            }
            
            INativeImage* CocoaImageFrame::GetImage()
            {
                return image;
            }
            
            Size CocoaImageFrame::GetSize()
            {
                Size size = cgImage ? Size(CGImageGetWidth(cgImage), CGImageGetHeight(cgImage))  : Size(0, 0);
                return size;
            }
            
            bool CocoaImageFrame::SetCache(void* key, Ptr<INativeImageFrameCache> cache)
            {
                vint index = caches.Keys().IndexOf(key);
                if(index != -1)
                {
                    return false;
                }
                caches.Add(key, cache);
                cache->OnAttach(this);
                return true;
            }
            
            Ptr<INativeImageFrameCache> CocoaImageFrame::GetCache(void* key)
            {
                vint index = caches.Keys().IndexOf(key);
                return (index == -1) ? nullptr : caches.Values().Get(index);
            }
            
            Ptr<INativeImageFrameCache> CocoaImageFrame::RemoveCache(void* key)
            {
                vint index = caches.Keys().IndexOf(key);
                if(index == -1)
                    return nullptr;
                
                Ptr<INativeImageFrameCache> cache = caches.Values().Get(index);
                cache->OnDetach(this);
                caches.Remove(key);
                return cache;
            }
            
            CGImageRef CocoaImageFrame::GetCGImage()
            {
                return cgImage;
            }
            
            CocoaImage::CocoaImage(INativeImageService* _service, NSImage* _image):
            imageService(_service),
            nsImage(_image)
            {
                imageRep = [[nsImage representations] objectAtIndex:0];
                
                vint count = 1;
                if([imageRep isKindOfClass:[NSBitmapImageRep class]])
                {
                    vint count = (vint)[[(NSBitmapImageRep*)imageRep valueForProperty:NSImageFrameCount] intValue];
                    if(count == 0)
                        count = 1;
                }
                
                frames.Resize(count);
            }
            
            INativeImageService* CocoaImage::GetImageService()
            {
                return imageService;
            }
            
            INativeImage::FormatType CocoaImage::GetFormat()
            {
                if([imageRep isKindOfClass:[NSBitmapImageRep class]])
                {
                    vint count = (vint)[[(NSBitmapImageRep*)imageRep valueForProperty:NSImageFrameCount] intValue];
                    if(count > 0)
                        return INativeImage::Gif;
                }
                return INativeImage::Bmp;
            }
            
            vint CocoaImage::GetFrameCount()
            {
                return frames.Count();
            }
            
            INativeImageFrame* CocoaImage::GetFrame(vint index)
            {
                if(index >= 0 && index < frames.Count())
                {
                    Ptr<CocoaImageFrame>& frame = frames[index];
                    if(!frame)
                    {
                        if([imageRep isKindOfClass:[NSBitmapImageRep class]])
                        {
                            NSBitmapImageRep* bitmapRep = (NSBitmapImageRep*)imageRep;
                            
                            [bitmapRep setProperty:NSImageCurrentFrame withValue:@(index)];
                            
                            CGDataProviderRef frameProvider = CGDataProviderCreateWithData(NULL,
                                                                                           [bitmapRep bitmapData],
                                                                                           [bitmapRep bytesPerRow] * [bitmapRep pixelsHigh],
                                                                                           NULL
                                                                                           );
                            
                            CGImageRef cgFrame = CGImageCreate ([bitmapRep pixelsWide],
                                                                [bitmapRep pixelsHigh],
                                                                8,
                                                                [bitmapRep bitsPerPixel],
                                                                [bitmapRep bytesPerRow],
                                                                CGColorSpaceCreateDeviceRGB(),
                                                                kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedLast,
                                                                frameProvider,
                                                                NULL,
                                                                NO,
                                                                kCGRenderingIntentDefault);
                            
                            CGDataProviderRelease(frameProvider);
                            frame = new CocoaImageFrame(this, cgFrame);
                        }
                        else
                        {
                            frame = new CocoaImageFrame(this, [imageRep CGImageForProposedRect:nil context:nil hints:nil]);
                        }
                        
                    }
                    return frame.Obj();
                }
                else
                    return 0;
            }

            void CocoaImage::SaveToStream(stream::IStream& stream, FormatType formatType)
            {
            }

            ////
            Ptr<INativeImage> CocoaImageService::CreateImageFromFile(const WString& path)
            {
                NSImage* image = [[NSImage alloc] initWithContentsOfFile:WStringToNSString(path)];
                if(image)
                {
                    return new CocoaImage(this, image);
                }
                return nullptr;
            }
            
            Ptr<INativeImage> CocoaImageService::CreateImageFromMemory(void* buffer, vint length)
            {
                NSData* data = [NSData dataWithBytes:buffer length:(NSUInteger)length];
                NSImage* image = [[NSImage alloc] initWithData:data];
                if(image)
                {
                    return new CocoaImage(this, image);
                }
                return nullptr;
            }
            
            Ptr<INativeImage> CocoaImageService::CreateImageFromStream(stream::IStream& stream)
            {
                stream::MemoryStream memoryStream;
                char buffer[65536];
                while(true)
                {
                    vint length = stream.Read(buffer, sizeof(buffer));
                    memoryStream.Write(buffer, length);
                    if(length != sizeof(buffer))
                    {
                        break;
                    }
                }
                return CreateImageFromMemory(memoryStream.GetInternalBuffer(), (vint)memoryStream.Size());
            }
            
            Ptr<INativeImage> CocoaImageService::GetIconForFile(const WString& path, Size iconSize)
            {
                NSImage* image = [[NSWorkspace sharedWorkspace] iconForFile:WStringToNSString(path)];
                if(image)
                {
                    if(iconSize != Size(0, 0))
                    {
                        NSSize newSize = NSMakeSize((CGFloat)iconSize.x, (CGFloat)iconSize.y);
                        
                        NSImage* smallIcon = [[NSImage alloc] initWithSize: newSize];
                        [smallIcon lockFocus];
                        [image setSize: newSize];
                        [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
                        [image drawAtPoint:NSZeroPoint fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.f];
                        [smallIcon unlockFocus];
                        
                        return new CocoaImage(this, smallIcon);
                    }
                    return new CocoaImage(this, image);
                }
                return nullptr;
            }
        }
    }
}