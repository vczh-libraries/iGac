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
#include "../CocoaHelper.h"

#ifdef GAC_OS_OSX
#import <Quartz/Quartz.h>
#endif

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
#ifdef GAC_OS_OSX
                void    InvokeMouseHook(CGEventType type, CGEventRef event);
#endif
                void    InvokeGlobalTimer();
                void    InvokeClipboardUpdated();
                void    InvokeNativeWindowCreated(INativeWindow* window);
                void    InvokeNativeWindowDestroyed(INativeWindow* window);
            };
        }
    }
}

#endif /* defined(__GacTest__CocoaCallbackService__) */
