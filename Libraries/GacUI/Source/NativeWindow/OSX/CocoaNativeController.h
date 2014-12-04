//
//  OSXNativeWindow.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSXNATIVEWINDOW_H__
#define __GAC_OSXNATIVEWINDOW_H__

#include "../GuiNativeWindow.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            extern INativeController*   CreateOSXNativeController();
            extern void                 SetupOSXApplication();
            extern void                 DestroyOSXNativeController(INativeController* controller);
            
        }
        
    }
    
}

#endif