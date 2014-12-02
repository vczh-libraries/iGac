//
//  OSXNativeWindow.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "OSXNativeController.h"

#include "OSXNativeWindow.h"
#include "AppleHelper.h"

#include "ServicesImpl/CocoaInputService.h"
#include "ServicesImpl/CocoaCallbackService.h"
#include "ServicesImpl/CocoaScreenService.h"
#include "ServicesImpl/CocoaResourceService.h"

#include <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            using namespace collections;
            
            class OSXController : public Object, public virtual INativeController, public virtual INativeWindowService
            {
            protected:
                Dictionary<NSContainer*, CocoaNativeWindow*>		windows;
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
                    CocoaNativeWindow* window = new CocoaNativeWindow();
                    callbackService.InvokeNativeWindowCreated(window);
                    windows.Add(window->GetNativeContainer(), window);
                    return window;
                }
                
                void DestroyNativeWindow(INativeWindow* window)
                {
                    CocoaNativeWindow* cocoaWindow = dynamic_cast<CocoaNativeWindow*>(window);
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
                    
                    // todo
                    while(true)
                    {
                        for (;;)
                        {
                            NSEvent* event = [NSApp nextEventMatchingMask:NSAnyEventMask
                                                                untilDate:[NSDate distantPast]
                                                                   inMode:NSDefaultRunLoopMode
                                                                  dequeue:YES];
                            if (event == nil)
                                break;
                            
                            [NSApp sendEvent:event];
                            
                            sleep(1);
                        }
                    }
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