//
//  OSXNativeWindow.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaNativeController.h"

#include "CocoaWindow.h"
#include "CocoaHelper.h"

#include "ServicesImpl/CocoaInputService.h"
#include "ServicesImpl/CocoaCallbackService.h"
#include "ServicesImpl/CocoaScreenService.h"
#include "ServicesImpl/CocoaResourceService.h"

#include <Cocoa/Cocoa.h>


@interface CocoaApplicationDelegate: NSObject<NSApplicationDelegate>



@end


namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            using namespace collections;
            
            class OSXController : public Object, public virtual INativeController, public virtual INativeWindowService
            {
            protected:
                Dictionary<NSContainer*, CocoaWindow*>		windows;
                INativeWindow*                                      mainWindow;
                
                CocoaCallbackService    callbackService;
                CocoaInputService       inputService;
                CocoaResourceService    resourceService;
                CocoaScreenService      screenService;
                
            public:
                OSXController():
                    mainWindow(0)
                {
                
                }
                
                ~OSXController()
               {
                    inputService.StopTimer();
                    inputService.StopHookMouse();
                }
                
                
                INativeWindow* CreateNativeWindow()
                {
                    CocoaWindow* window = new CocoaWindow();
                    callbackService.InvokeNativeWindowCreated(window);
                    windows.Add(window->GetNativeContainer(), window);
                    return window;
                }
                
                void DestroyNativeWindow(INativeWindow* window)
                {
                    CocoaWindow* cocoaWindow = dynamic_cast<CocoaWindow*>(window);
                    if(window != 0 && windows.Keys().Contains(cocoaWindow->GetNativeContainer()))
                    {
                        callbackService.InvokeNativeWindowDestroyed(window);
                        windows.Remove(cocoaWindow->GetNativeContainer());
                        delete cocoaWindow;
                    }
                }
                
                INativeWindow* GetMainWindow()
                {
                    return mainWindow;
                }
                
                void Run(INativeWindow* window)
                {
                    mainWindow = window;
                    mainWindow->Show();
                    
                    [NSApp run];
//                    // todo
//                    for (;;)
//                    {
//                        NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask
//                                                            untilDate:[NSDate distantPast]
//                                                               inMode:NSDefaultRunLoopMode
//                                                              dequeue:YES];
//                        if (event != nil)
//                        {
//                            [NSApp sendEvent:event];
//                        }
//                        else
//                        {
//                            sleep(1);
//                        }
//                    }
                }
                
                INativeWindow* GetWindow(Point location)
                {
                    // todo
                    return 0;
                }
                
                //=======================================================================
                
                INativeCallbackService* CallbackService()
                {
                    return &callbackService;
                }
                
                INativeResourceService* ResourceService()
                {
                    return &resourceService;
                }
                
                INativeAsyncService* AsyncService()
                {
                    return 0;
                }
                
                INativeClipboardService* ClipboardService()
                {
                    return 0;
                }
                
                INativeImageService* ImageService()
                {
                    return 0;
                }
                
                INativeScreenService* ScreenService()
                {
                    return &screenService;
                }
                
                INativeWindowService* WindowService()
                {
                    return this;
                }
                
                INativeInputService* InputService()
                {
                    return &inputService;
                }
                
                INativeDialogService* DialogService()
                {
                    return 0;
                }
                
                WString GetOSVersion()
                {
                    return NSStringToWString(vl::presentation::osx::GetOSVersion());
                }
                
                WString GetExecutablePath()
                {
                    return NSStringToWString(GetApplicationPath());
                }
                
                //=======================================================================
                
            };
            
            INativeController* CreateOSXNativeController()
            {
                return new OSXController();
            }
            
            void DestroyOSXNativeController(INativeController* controller)
            {
                delete controller;
            }
        }
        
    }
    
}