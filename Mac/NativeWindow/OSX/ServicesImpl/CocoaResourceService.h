//
//  CocoaResourceService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_RESOURCE_SERVICE_H__
#define __GAC_OSX_RESOURCE_SERVICE_H__

#include "GacUI.h"

@class NSCursor;

namespace vl {
  
    namespace presentation {
        
        namespace osx {
            
            class CocoaCursor: public INativeCursor
            {
            protected:
                NSCursor*           cursor;
                bool                isSystemCursor;
                SystemCursorType    systemCursorType;
                
            public:
                CocoaCursor(NSCursor* cursor);
                CocoaCursor(SystemCursorType type);
                
                ////
                
                bool                IsSystemCursor() override;
                SystemCursorType    GetSystemCursorType() override;
                
                ///
                void                InitSystemCursors();
                NSCursor*           GetNativeCursor() const;
                void                Set();
            };
            
            class CocoaResourceService : public Object, public INativeResourceService
            {
            protected:
                collections::Array<Ptr<CocoaCursor>>    systemCursors;
                FontProperties                          defaultFont;
                
            public:
                CocoaResourceService();
                virtual ~CocoaResourceService();
                
                /////
                INativeCursor*          GetSystemCursor(INativeCursor::SystemCursorType type) override;
                INativeCursor*          GetDefaultSystemCursor() override;
                FontProperties          GetDefaultFont() override;
                void                    SetDefaultFont(const FontProperties& value) override;
            };
            
        }
    }
}


#endif
