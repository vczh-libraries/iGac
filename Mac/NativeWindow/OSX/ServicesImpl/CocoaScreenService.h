//
//  CocoaScreenService.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_SCREEN_SERVICE_H__
#define __GAC_OSX_SCREEN_SERVICE_H__

#include "GacUI.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaScreen : public Object, public INativeScreen
            {
                friend class CocoaScreenService;
                
            protected:
                NSScreen*    screen;
                
            public:
                double GetScalingX() override;

                double GetScalingY() override;

                CocoaScreen(NSScreen* screen);

                NativeRect      GetBounds() override;
                NativeRect      GetClientBounds() override;
                WString         GetName() override;
                bool            IsPrimary() override;
            };
            
            class CocoaScreenService : public Object, public INativeScreenService
            {
                typedef void (*HandleRetriver)(INativeWindow*);
                
            protected:
                collections::List<Ptr<CocoaScreen>>			screens;
                HandleRetriver                              handleRetriver;
                
            public:
                CocoaScreenService();
                
                void                    RefreshScreenInformation();
                vint                    GetScreenCount() override;
                INativeScreen*          GetScreen(vint index) override;
                INativeScreen*          GetScreen(INativeWindow* window) override;
            };
        }
    }
}


#endif