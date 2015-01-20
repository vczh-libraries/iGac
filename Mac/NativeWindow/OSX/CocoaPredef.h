//
//  OSXPredef.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_PREDEF_H__
#define __GAC_OSX_PREDEF_H__

namespace vl {
    
    
    namespace presentation {
        
        namespace osx {
            
            class NotImplementedException: public Exception
            {
            public:
                NotImplementedException(const WString& message):
                Exception(message)
                {
                    
                }
            };
            
            class NotSupportedException: public Exception
            {
            public:
                NotSupportedException(const WString& message):
                Exception(message)
                {
                    
                }
            };
            
            struct IDraggingListener: public Interface
            {
                virtual void PerformFileDrag(const vl::collections::List<WString>& files) = 0;
            };
            
    
        }
        
    }
    
}


#endif
