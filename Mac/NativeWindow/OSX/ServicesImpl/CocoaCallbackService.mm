//
//  CocoaCallbackService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaCallbackService.h"


namespace vl {
    
    namespace presentation {
      
        namespace osx {
            
            CocoaCallbackService::CocoaCallbackService()
            {
                
            }
            
            CocoaCallbackService::~CocoaCallbackService()
            {
                
            }
            
            bool CocoaCallbackService::InstallListener(INativeControllerListener* listener)
            {
                if(listeners.Contains(listener))
                {
                    return false;
                }
                else
                {
                    listeners.Add(listener);
                    return true;
                }
            }
            
            bool CocoaCallbackService::UninstallListener(INativeControllerListener* listener)
            {
                if(listeners.Contains(listener))
                {
                    listeners.Remove(listener);
                    return true;
                }
                else
                {
                    return false;
                }
            }
            
            void CocoaCallbackService::InvokeMouseHook(CGEventType type, CGEventRef event)
            {
                CGPoint cgLoc = CGEventGetLocation(event);
                NativePoint location(cgLoc.x, cgLoc.y);
                switch(type)
                {
                    case kCGEventMouseMoved:
                    {
                        for(vint i=0;i<listeners.Count();i++)
                        {
                            listeners[i]->MouseMoving(location);
                        }
                        break;
                    }
                    case kCGEventLeftMouseDown:
                    {
                        for(vint i=0;i<listeners.Count();i++)
                        {
                            listeners[i]->LeftButtonDown(location);
                        }
                        break;
                    }
                    case kCGEventLeftMouseUp:
                    {
                        for(vint i=0;i<listeners.Count();i++)
                        {
                            listeners[i]->LeftButtonUp(location);
                        }
                        break;
                    }
                    case kCGEventRightMouseDown:
                    {
                        for(vint i=0;i<listeners.Count();i++)
                        {
                            listeners[i]->RightButtonDown(location);
                        }
                        break;
                    }
                    case kCGEventRightMouseUp:
                    {
                        for(vint i=0;i<listeners.Count();i++)
                        {
                            listeners[i]->RightButtonUp(location);
                        }
                        break;
                    }
                    default: break;
                }
            }
    
            void CocoaCallbackService::InvokeGlobalTimer()
            {
                for(vint i=0;i<listeners.Count();i++)
                {
                    listeners[i]->GlobalTimer();
                }
            }
            
            void CocoaCallbackService::InvokeClipboardUpdated()
            {
                for(vint i=0;i<listeners.Count();i++)
                {
                    listeners[i]->ClipboardUpdated();
                }
            }
            
            void CocoaCallbackService::InvokeNativeWindowCreated(INativeWindow* window)
            {
                for(vint i=0;i<listeners.Count();i++)
                {
                    listeners[i]->NativeWindowCreated(window);
                }
            }
            
            void CocoaCallbackService::InvokeNativeWindowDestroyed(INativeWindow* window)
            {
                for(vint i=0;i<listeners.Count();i++)
                {
                    listeners[i]->NativeWindowDestroying(window);
                }
            }
        }
    }
}