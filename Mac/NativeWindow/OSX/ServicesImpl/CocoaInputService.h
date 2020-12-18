//
//  CocoaInputService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_INPUT_SERVICE_H__
#define __GAC_OSX_INPUT_SERVICE_H__

#include "GacUI.h"

#import <Quartz/Quartz.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class EventTapException: public Exception
            {
            public:
                EventTapException(const WString& _message=WString::Empty):
                Exception(_message)
                {
                    
                }
            };
            
            // todo
            
            class CocoaInputService : public Object, public INativeInputService
            {
            public:
                typedef void (*TimerFunc)();
                typedef void (*MouseTapFunc)(CGEventType type, CGEventRef event);
                
            protected:
                collections::Dictionary<WString, VKEY>  keys;
                collections::Array<WString>             keyNames;
                
                CGEventSourceRef                        eventSource;
                bool                                    isTimerEnabled;
                bool                                    isHookingMouse;
                
                MouseTapFunc                            mouseTapFunc;
                TimerFunc                               timerFunc;
                
                CFMachPortRef                           inputTapPort;
                CFRunLoopSourceRef                      inputTapRunLoopSource;
                
                vint8_t                                 globalKeyStates[256];
                
                wchar_t                                 asciiLowerMap[256];
                wchar_t                                 asciiUpperMap[256];
                
            protected:
                void StartGCDTimer();
                // for global key states & mouse hooking
                void HookInput();
                
            public:
                CocoaInputService(MouseTapFunc mouseTap, TimerFunc timer);
                virtual ~CocoaInputService();
                
                // INativeInputService
                
                void    StartHookMouse() override;
                void    StopHookMouse() override;
                bool    IsHookingMouse() override;
                void    StartTimer() override;
                void    StopTimer() override;
                bool    IsTimerEnabled() override;
                
                bool    IsKeyPressing(VKEY code) override;
                bool    IsKeyToggled(VKEY code) override;
                
                WString GetKeyName(VKEY code) override;
                VKEY GetKey(const WString& name) override;
                
                ///
                
                void    InitKeyMapping();
                void    InvokeInputHook(CGEventType type, CGEventRef event);
                bool    ConvertToPrintable(NativeWindowCharInfo& info, NSEvent* event);
            };
            
            CocoaInputService* GetCocoaInputService();
            
        }
        
    }
    
}

#endif
