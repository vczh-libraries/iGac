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
                
                TimerFunc                               timerFunc;
                
                CFMachPortRef                           inputTapPort;
                CFRunLoopSourceRef                      inputTapRunLoopSource;
                
                vint8_t                                 globalKeyStates[256];
                
                wchar_t                                 asciiLowerMap[256];
                wchar_t                                 asciiUpperMap[256];
                
            protected:
                void StartGCDTimer();
                
            public:
                CocoaInputService(TimerFunc timer);
                virtual ~CocoaInputService();
                void    RestartTimer();

                // INativeInputService
                
                void    StartTimer() override;
                void    StopTimer() override;
                bool    IsTimerEnabled() override;
                
                bool    IsKeyPressing(VKEY code) override;
                bool    IsKeyToggled(VKEY code) override;
                
                WString GetKeyName(VKEY code) override;
                VKEY    GetKey(const WString& name) override;

				vint    RegisterGlobalShortcutKey(bool ctrl, bool shift, bool alt, VKEY key)override;
				bool    UnregisterGlobalShortcutKey(vint id)override;
                
                ///
                
                void    InitKeyMapping();
                bool    ConvertToPrintable(NativeWindowCharInfo& info, NSEvent* event);
            };
            
            CocoaInputService* GetCocoaInputService();
            
        }
        
    }
    
}

#endif
