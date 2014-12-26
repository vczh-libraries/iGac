//
//  CocoaIntrospection.h
//  GacOSX
//
//  Created by Robert Bu on 12/26/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_INTROSPECTION__
#define __GAC_OSX_COCOA_INTROSPECTION__

#include <objc/objc-class.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            void ChangeImplementation(Class baseClass, SEL originalSel, Class proxyClass, SEL replacementSel, SEL backupSel = 0);
            
            void ChangeBackImplementation(Class baseClass, SEL originalSel, SEL backupSel);
            
        }
        
    }
    
}


#endif
