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
            
            CocoaInputService::CocoaInputService()
            {
                InitializeKeyMapping();
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
            
            void CocoaInputService::StartTimer()
            {
                
                
            }
            
            void CocoaInputService::StopTimer()
            {
                
                
            }
            
            bool CocoaInputService::IsTimerEnabled()
            {
                 return false;
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