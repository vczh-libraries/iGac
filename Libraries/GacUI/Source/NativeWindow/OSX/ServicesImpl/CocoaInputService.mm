//
//  CocoaInputService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaInputService.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaInputService::CocoaInputService(TimerFunc timer):
                timerFunc(timer)
            {
                InitializeKeyMapping();
                
                eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
                // default is 0.25s
                CGEventSourceSetLocalEventsSuppressionInterval(eventSource, 0.0);
            }
            
            CocoaInputService::~CocoaInputService()
            {
                
            }
            
            void CocoaInputService::InitializeKeyMapping()
            {
                // todo
                // just build the map...
                // need some copy-pasta here
            }
            
            void CocoaInputService::StartHookMouse()
            {
                
                
            }
            
            void CocoaInputService::StopHookMouse()
            {
                
                
            }
            
            bool CocoaInputService::IsHookingMouse()
            {
                return false;
            }
            
            void CocoaInputService::StartGCDTimer()
            {
                double delayInMilliseconds = 16;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInMilliseconds * NSEC_PER_MSEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    if(IsTimerEnabled())
                    {
                        timerFunc();
                        StartGCDTimer();
                    }
                });
            }
            
            void CocoaInputService::StartTimer()
            {
                StartGCDTimer();
                isTimerEnabled = true;
            }
            
            void CocoaInputService::StopTimer()
            {
                isTimerEnabled = false;
            }
            
            bool CocoaInputService::IsTimerEnabled()
            {
                 return isTimerEnabled;
            }
            
            bool CocoaInputService::IsKeyPressing(vint code)
            {
                 return false;
            }
            
            bool CocoaInputService::IsKeyToggled(vint code)
            {
                return false;
            }
            
            WString CocoaInputService::GetKeyName(vint code)
            {
                return L"";
            }
            
            vint CocoaInputService::GetKey(const WString& name)
            {
                return 0;
            }
            
        }
        
    }
    
}