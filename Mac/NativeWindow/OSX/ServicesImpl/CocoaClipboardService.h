//
//  CocoaClipboardService.h
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_CLIPBOARD_SERVICE_H__
#define __GAC_OSX_COCOA_CLIPBOARD_SERVICE_H__

#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {

            class CocoaClipboardService;

            class CocoaClipboardReader : public INativeClipboardReader
            {
                friend class CocoaClipboardService;
            public:
                CocoaClipboardReader(CocoaClipboardService* _service);
                bool ContainsText() override;
                WString GetText() override;
                bool ContainsDocument() override;
                Ptr<DocumentModel> GetDocument() override;
                bool ContainsImage() override;
                Ptr<INativeImage> GetImage() override;

            };

            class CocoaClipboardWriter : public INativeClipboardWriter
            {
                friend class CocoaClipboardService;
            public:
                CocoaClipboardWriter(CocoaClipboardService* _service);
                void SetText(const WString &value) override;
                void SetDocument(Ptr<DocumentModel> value) override;
                void SetImage(Ptr<INativeImage> value) override;
                bool Submit() override;
            };

            class CocoaClipboardService: public Object, public INativeClipboardService
            {
                friend class OSXClipboardReader;
                friend class OSXClipboardWriter;
            protected:
                CocoaClipboardReader*			reader = nullptr;
            public:
                Ptr<INativeClipboardReader>		ReadClipboard()override;
                Ptr<INativeClipboardWriter>		WriteClipboard()override;
            };


        }
    }
}


#endif
