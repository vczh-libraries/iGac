//
//  CocoaResourceService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_RESOURCE_SERVICE_H__
#define __GAC_OSX_RESOURCE_SERVICE_H__

#include "../../GuiNativeWindow.h"

namespace vl {
  
    namespace presentation {
        
        namespace osx {
            
            class CocoaResourceService : public Object, public INativeResourceService
            {
            protected:
                FontProperties defaultFont;
                
            public:
                CocoaResourceService();
                virtual ~CocoaResourceService();
                
                INativeCursor*          GetSystemCursor(INativeCursor::SystemCursorType type) override;
                INativeCursor*          GetDefaultSystemCursor() override;
                FontProperties          GetDefaultFont() override;
                void                    SetDefaultFont(const FontProperties& value) override;
            };
            
        }
    }
}


#endif
