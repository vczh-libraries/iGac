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

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            // todo
            
            class CocoaInputService : public Object, public INativeInputService
            {
            protected:
                collections::Dictionary<WString, vint> keys;
                collections::Array<WString> keyNames;
                
            public:
                CocoaInputService();
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
