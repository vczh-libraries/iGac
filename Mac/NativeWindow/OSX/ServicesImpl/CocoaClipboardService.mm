//
//  CocoaClipboardService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaClipboardService.h"
#include "CocoaImageService.h"
#include "../CocoaHelper.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {

            // Custom pasteboard type for GacUI document format
            static NSString* const GacDocumentPasteboardType = @"com.gaclib.document";

/***********************************************************************
CocoaClipboardWriter
***********************************************************************/

            CocoaClipboardWriter::CocoaClipboardWriter(CocoaClipboardService* _service)
                : service(_service)
            {
            }

            void CocoaClipboardWriter::SetText(const WString& value)
            {
                textData = value;
            }

            void CocoaClipboardWriter::SetDocument(Ptr<DocumentModel> value)
            {
                if (!textData)
                {
                    textData = value->GetTextForReading(WString::Unmanaged(L"\r\n\r\n"));
                }

                if (!imageData)
                {
                    imageData = GetImageFromSingleImageDocument(value);
                }

                documentData = value;
                ModifyDocumentForClipboard(documentData);
            }

            void CocoaClipboardWriter::SetImage(Ptr<INativeImage> value)
            {
                imageData = value;
            }

            bool CocoaClipboardWriter::Submit()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];

                // Collect all types we will write
                NSMutableArray* types = [NSMutableArray array];
                if (textData)
                {
                    [types addObject:NSPasteboardTypeString];
                }
                if (documentData)
                {
                    [types addObject:GacDocumentPasteboardType];
                    [types addObject:NSPasteboardTypeRTF];
                    [types addObject:NSPasteboardTypeHTML];
                }
                if (imageData && imageData->GetFrameCount() > 0)
                {
                    [types addObject:NSPasteboardTypePNG];
                }

                if ([types count] == 0) return false;

                // Clear and declare all types atomically
                [pasteboard clearContents];
                [pasteboard declareTypes:types owner:nil];

                // Write text
                if (textData)
                {
                    NSString* nsText = WStringToNSString(textData.Value());
                    if (![pasteboard setString:nsText forType:NSPasteboardTypeString]) return false;
                }

                // Write document in multiple formats
                if (documentData)
                {
                    // GacUI custom document format (binary)
                    {
                        stream::MemoryStream memoryStream;
                        SaveDocumentToClipboardStream(documentData, memoryStream);
                        memoryStream.SeekFromBegin(0);
                        NSData* data = [NSData dataWithBytes:memoryStream.GetInternalBuffer()
                                                      length:(NSUInteger)memoryStream.Size()];
                        if (![pasteboard setData:data forType:GacDocumentPasteboardType]) return false;
                    }
                    // RTF format
                    {
                        stream::MemoryStream memoryStream;
                        SaveDocumentToRtfStream(documentData, memoryStream);
                        memoryStream.SeekFromBegin(0);
                        NSData* data = [NSData dataWithBytes:memoryStream.GetInternalBuffer()
                                                      length:(NSUInteger)memoryStream.Size()];
                        if (![pasteboard setData:data forType:NSPasteboardTypeRTF]) return false;
                    }
                    // HTML format
                    {
                        AString header, content, footer;
                        SaveDocumentToHtmlUtf8(documentData, header, content, footer);
                        AString html;
                        html = header + content + footer;
                        NSData* data = [NSData dataWithBytes:html.Buffer()
                                                      length:(NSUInteger)html.Length()];
                        if (![pasteboard setData:data forType:NSPasteboardTypeHTML]) return false;
                    }
                }

                if (imageData && imageData->GetFrameCount() > 0)
                {
                    stream::MemoryStream png;
                    imageData->SaveToStream(png, INativeImage::Png);
                    if (png.Size() == 0) return false;
                    NSData* data = [NSData dataWithBytes:png.GetInternalBuffer() length:(NSUInteger)png.Size()];
                    if (![pasteboard setData:data forType:NSPasteboardTypePNG]) return false;
                }

                service->CheckForUpdates();
                return true;
            }

/***********************************************************************
CocoaClipboardReader
***********************************************************************/

            CocoaClipboardReader::CocoaClipboardReader(CocoaClipboardService* _service)
                : service(_service)
            {
            }

            bool CocoaClipboardReader::ContainsText()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                return [[pasteboard types] containsObject:NSPasteboardTypeString];
            }

            WString CocoaClipboardReader::GetText()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                NSString* text = [pasteboard stringForType:NSPasteboardTypeString];
                if (text)
                {
                    return NSStringToWString(text);
                }
                return WString::Empty;
            }

            bool CocoaClipboardReader::ContainsDocument()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                return [[pasteboard types] containsObject:GacDocumentPasteboardType];
            }

            Ptr<DocumentModel> CocoaClipboardReader::GetDocument()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                NSData* data = [pasteboard dataForType:GacDocumentPasteboardType];
                if (data)
                {
                    stream::MemoryWrapperStream memoryStream((void*)[data bytes], (vint)[data length]);
                    return LoadDocumentFromClipboardStream(memoryStream);
                }
                return nullptr;
            }

            bool CocoaClipboardReader::ContainsImage()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];
                NSArray* types = [pasteboard types];
                return [types containsObject:NSPasteboardTypeTIFF]
                    || [types containsObject:NSPasteboardTypePNG];
            }

            Ptr<INativeImage> CocoaClipboardReader::GetImage()
            {
                NSPasteboard* pasteboard = [NSPasteboard generalPasteboard];

                // Try to read image data — NSImage can handle TIFF, PNG, and other formats
                NSData* data = [pasteboard dataForType:NSPasteboardTypeTIFF];
                if (!data)
                {
                    data = [pasteboard dataForType:NSPasteboardTypePNG];
                }
                if (data)
                {
                    auto images = service->imageService ? service->imageService : GetCurrentController()->ImageService();
                    return images->CreateImageFromMemory(
                        (void*)[data bytes],
                        (vint)[data length]
                    );
                }
                return nullptr;
            }

/***********************************************************************
CocoaClipboardService
***********************************************************************/

            CocoaClipboardService::CocoaClipboardService(INativeCallbackService* callbacks, INativeImageService* images)
                : callbackService(callbacks)
                , imageService(images)
                , changeCount([[NSPasteboard generalPasteboard] changeCount])
            {
            }

            bool CocoaClipboardService::PumpClipboardEvents()
            {
                @autoreleasepool
                {
                    auto current = [[NSPasteboard generalPasteboard] changeCount];
                    if (current == changeCount) return false;
                    changeCount = current;
                    return true;
                }
            }

            void CocoaClipboardService::CheckForUpdates()
            {
                if (callbackService && PumpClipboardEvents()) callbackService->Invoker()->InvokeClipboardUpdated();
            }

            Ptr<INativeClipboardReader> CocoaClipboardService::ReadClipboard()
            {
                return Ptr(new CocoaClipboardReader(this));
            }

            Ptr<INativeClipboardWriter> CocoaClipboardService::WriteClipboard()
            {
                return Ptr(new CocoaClipboardWriter(this));
            }
        }
    }
}