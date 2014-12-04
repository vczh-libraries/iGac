//
//  CocoaInputService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_INPUT_SERVICE_H__
#define __GAC_OSX_INPUT_SERVICE_H__

#include "../../GuiNativeWindow.h"

#import <Quartz/Quartz.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            // todo
            
            class CocoaInputService : public Object, public INativeInputService
            {
            public:
                typedef void (*TimerFunc)();
                
            protected:
                collections::Dictionary<WString, vint>  keys;
                collections::Array<WString>             keyNames;
                
                CGEventSourceRef                        eventSource;
                bool                                    isTimerEnabled;
                TimerFunc                               timerFunc;
                
            protected:
                void StartGCDTimer();
                
            public:
                CocoaInputService(TimerFunc timer);
                virtual ~CocoaInputService();
                
                void InitializeKeyMapping();
                
                // INativeInputService
                
                void    StartHookMouse() override;
                void    StopHookMouse() override;
                bool    IsHookingMouse() override;
                void    StartTimer() override;
                void    StopTimer() override;
                bool    IsTimerEnabled() override;
                
                bool    IsKeyPressing(vint code) override;
                bool    IsKeyToggled(vint code) override;
                
                WString GetKeyName(vint code) override;
                vint    GetKey(const WString& name) override;
            };
            
        }
        
    }
    
}

#endif
