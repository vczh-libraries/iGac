//
//  CocoaCallbackService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_CALLBACK_SERVICE_H__
#define __GAC_OSX_CALLBACK_SERVICE_H__

#include "GacUI.h"

#import <Quartz/Quartz.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaCallbackService : public Object, public INativeCallbackService
            {
            protected:
                collections::List<INativeControllerListener*>	listeners;
                
            public:
                CocoaCallbackService();
                virtual ~CocoaCallbackService();
                
                // INativeCallbackService
                bool    InstallListener(INativeControllerListener* listener) override;
                bool    UninstallListener(INativeControllerListener* listener) override;
                
                //
                void    InvokeMouseHook(CGEventType type, CGEventRef event);
                void    InvokeGlobalTimer();
                void    InvokeClipboardUpdated();
                void    InvokeNativeWindowCreated(INativeWindow* window);
                void    InvokeNativeWindowDestroyed(INativeWindow* window);
            };
        }
    }
}

#endif /* defined(__GacTest__CocoaCallbackService__) */
