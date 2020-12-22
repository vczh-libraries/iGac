//
//  CocoaScreenService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaScreenService.h"

#include "../CocoaHelper.h"
#include "../CocoaWindow.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {

            CocoaScreen::CocoaScreen(NSScreen* _screen):
                screen(_screen)
            {
                
            }
            
            NativeRect CocoaScreen::GetBounds()
            {
                NSRect r = [screen frame];
                return NativeRect(r.origin.x,
                            r.origin.y,
                            r.origin.x + r.size.width,
                            r.origin.y + r.size.height);
            }

            NativeRect CocoaScreen::GetClientBounds()
            {
                return GetBounds();
            }
            
            WString CocoaScreen::GetName()
            {
                return L"?";
            }
            
            bool CocoaScreen::IsPrimary()
            {
                return screen == [NSScreen mainScreen];
            }

            double CocoaScreen::GetScalingX()
            {
                return 2.0;
            }

            double CocoaScreen::GetScalingY()
            {
                return 2.0;
            }

            CocoaScreenService::CocoaScreenService()
            {
                RefreshScreenInformation();
            }

            void CocoaScreenService::RefreshScreenInformation()
            {
                screens.Clear();
                
                NSArray* nsscreens = [NSScreen screens];
                [nsscreens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                {
                    screens.Add((new CocoaScreen((NSScreen*)obj)));
                }];
            }
            
            vint CocoaScreenService::GetScreenCount()
            {
                return screens.Count();
            }
            
            INativeScreen* CocoaScreenService::GetScreen(vint index)
            {
                return screens[index].Obj();
            }
            
            INativeScreen* CocoaScreenService::GetScreen(INativeWindow* window)
            {
                CocoaWindow* wnd = dynamic_cast<CocoaWindow*>(window);
                if(wnd)
                {
                    NSScreen* windowScreen = [wnd->GetNativeWindow() screen];
                    
                    for(vint i=0;i<screens.Count();i++)
                    {
                        if(screens[i]->screen == windowScreen)
                        {
                            return screens[i].Obj();
                        }
                    }
                }
                return 0;
            }
            
        }

    }

}