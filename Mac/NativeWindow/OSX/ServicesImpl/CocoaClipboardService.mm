//
//  CocoaClipboardService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaClipboardService.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {

            ////
            CocoaClipboardWriter::CocoaClipboardWriter(CocoaClipboardService *_service) {}

            void CocoaClipboardWriter::SetText(const WString &value) {

            }

            void CocoaClipboardWriter::SetDocument(Ptr<DocumentModel> value) {

            }

            void CocoaClipboardWriter::SetImage(Ptr<INativeImage> value) {

            }

            bool CocoaClipboardWriter::Submit() {
                return false;
            }

            ////
            CocoaClipboardReader::CocoaClipboardReader(CocoaClipboardService *_service) {}

            bool CocoaClipboardReader::ContainsText() {
                return false;
            }

            WString CocoaClipboardReader::GetText() {
                return vl::WString();
            }

            bool CocoaClipboardReader::ContainsDocument() {
                return false;
            }

            Ptr<DocumentModel> CocoaClipboardReader::GetDocument() {
                return Ptr<DocumentModel>();
            }

            bool CocoaClipboardReader::ContainsImage() {
                return false;
            }

            Ptr<INativeImage> CocoaClipboardReader::GetImage() {
                return Ptr<INativeImage>();
            }

            ////
            Ptr<INativeClipboardReader>		CocoaClipboardService::ReadClipboard()
            {
                if (!reader)
                {
                    reader = new CocoaClipboardReader(this);
                }
                return reader;
            }

            Ptr<INativeClipboardWriter>		CocoaClipboardService::WriteClipboard()
            {
                return new CocoaClipboardWriter(this);
            }
        }
    }
}