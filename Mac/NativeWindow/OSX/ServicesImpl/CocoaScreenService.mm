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

#ifdef GAC_OS_OSX
            CocoaScreen::CocoaScreen(NSScreen* _screen):
                screen(_screen)
            {
                
            }
#else
            CocoaScreen::CocoaScreen(UIScreen* _screen):
            screen(_screen)
            {
                
            }
#endif
            
            Rect CocoaScreen::GetBounds()
            {
#ifdef GAC_OS_OSX
                NSRect r = [screen frame];
#else
                CGRect r = [screen bounds];
#endif
                return Rect(r.origin.x,
                            r.origin.y,
                            r.origin.x + r.size.width,
                            r.origin.y + r.size.height);
            }
            
            Rect CocoaScreen::GetClientBounds()
            {
                return GetBounds();
            }
            
            WString CocoaScreen::GetName()
            {
                return L"?";
            }
            
            bool CocoaScreen::IsPrimary()
            {
#ifdef GAC_OS_OSX
                return screen == [NSScreen mainScreen];
#else
                return true;
#endif
            }
            
            CocoaScreenService::CocoaScreenService()
            {
                RefreshScreenInformation();
            }

            void CocoaScreenService::RefreshScreenInformation()
            {
                screens.Clear();
                
#ifdef GAC_OS_OSX
                NSArray* nsscreens = [NSScreen screens];
                [nsscreens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                {
                    screens.Add((new CocoaScreen((NSScreen*)obj)));
                }];
#else
                screens.Add(new CocoaScreen([UIScreen mainScreen]));
#endif
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
#ifdef GAC_OS_OSX
                CocoaWindow* wnd = dynamic_cast<CocoaWindow*>(window);
                if(wnd)
                {
                    NSContainer* container = wnd->GetNativeContainer();
                    
                    for(vint i=0;i<screens.Count();i++)
                    {
                        if(screens[i]->screen == [container->window screen])
                        {
                            return screens[i].Obj();
                        }
                    }
                }
#else
                return screens[0].Obj();
#endif
                return 0;
            }
            
        }

    }

}