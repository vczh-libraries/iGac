//
//  CocoaIntrospection.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/26/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaIntrospection.h"

#include <objc/objc-runtime.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            void ChangeImplementation(Class baseClass, SEL originalSel, Class proxyClass, SEL replacementSel, SEL backupSel)
            {
                if (!replacementSel)
                    replacementSel = originalSel;
                
                Method originalMethod = class_getInstanceMethod(baseClass, originalSel);
                Method replacementMethod = class_getInstanceMethod(proxyClass, replacementSel);
                
                IMP originalImp = method_setImplementation(originalMethod,
                                                           method_getImplementation(replacementMethod));

                if (backupSel)
                {
                    Method backupMethod = class_getInstanceMethod(proxyClass, backupSel);
                    class_addMethod(baseClass,
                                    backupSel,
                                    originalImp,
                                    method_getTypeEncoding(backupMethod));
                }
            }
            
            void ChangeBackImplementation(Class baseClass, SEL originalSel, SEL backupSel)
            {
                Method originalMethod = class_getInstanceMethod(baseClass, originalSel);
                
                Method backupMethod = class_getInstanceMethod(baseClass, backupSel);
                
                method_setImplementation(originalMethod,
                                         method_getImplementation(backupMethod));
            }
            
        }
        
    }
    
}