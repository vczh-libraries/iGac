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
#include "../CocoaHelper.h"

#ifdef GAC_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaScreen : public Object, public INativeScreen
            {
                friend class CocoaScreenService;
                
            protected:
#ifdef GAC_OS_OSX
                NSScreen*    screen;
#else
                UIScreen*    screen;
#endif
            public:
#ifdef GAC_OS_OSX
                CocoaScreen(NSScreen* screen);
#else
                CocoaScreen(UIScreen* screen);
#endif
                Rect        GetBounds() override;
                Rect        GetClientBounds() override;
                WString     GetName() override;
                bool        IsPrimary() override;
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