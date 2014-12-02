//
//  CocoaResourceService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaResourceService.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaResourceService::CocoaResourceService()
            {
                
            }
            
            CocoaResourceService::~CocoaResourceService()
            {
                
            }
            
            INativeCursor* CocoaResourceService::GetSystemCursor(INativeCursor::SystemCursorType type)
            {
                return 0;
            }
            
            INativeCursor* CocoaResourceService::GetDefaultSystemCursor()
            {
                return 0;
            }
            
            FontProperties CocoaResourceService::GetDefaultFont()
            {
                return defaultFont;
            }
            
            void CocoaResourceService::SetDefaultFont(const FontProperties& value)
            {
                defaultFont = value;
            }

        }

    }

}