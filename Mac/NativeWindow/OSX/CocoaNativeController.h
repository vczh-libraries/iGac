//
//  OSXNativeWindow.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSXNATIVEWINDOW_H__
#define __GAC_OSXNATIVEWINDOW_H__

#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            extern void                 SetupOSXApplication();
            extern INativeController*   GetOSXNativeController();
            extern void                 StartOSXNativeController();
            extern void                 StopOSXNativeController();
            
        }
        
    }
    
}

#endif