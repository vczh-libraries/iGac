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
#include "ServicesImpl/CocoaAsyncService.h"
#include "ServicesImpl/CocoaClipboardService.h"
#include "ServicesImpl/CocoaDialogService.h"
#include "ServicesImpl/CocoaImageService.h"

// _NSGetProgname
#import <crt_externs.h>

#ifdef GAC_OS_OSX

@interface CocoaApplicationDelegate: NSObject<NSApplicationDelegate>


@end

@implementation CocoaApplicationDelegate {

    NSMenu* mainMenu;
}

- (NSString*)findAppName
{
    size_t i;
    NSDictionary* infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // Keys to search for as potential application names
    NSString* GacNameKeys[] = {
        @"CFBundleDisplayName",
        @"CFBundleName",
        @"CFBundleExecutable",
    };
    
    for (i = 0;  i < sizeof(GacNameKeys) / sizeof(GacNameKeys[0]);  i++)
    {
        id name = [infoDictionary objectForKey:GacNameKeys[i]];
        if (name &&
            [name isKindOfClass:[NSString class]] &&
            ![name isEqualToString:@""])
        {
            return name;
        }
    }
    
    char** progname = _NSGetProgname();
    if (progname && *progname)
        return [NSString stringWithUTF8String:*progname];
    
    // Really shouldn't get here
    return @"Gac Application";
}

- (void)createMenu
{
    NSString* appName = [self findAppName];
    
    mainMenu = [[NSMenu alloc] init];
    [NSApp setMainMenu:mainMenu];
    
    NSMenuItem* appMenuItem = [mainMenu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* appMenu = [[NSMenu alloc] init];
    [appMenuItem setSubmenu:appMenu];
    
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"About %@", appName]
                       action:@selector(orderFrontStandardAboutPanel:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    NSMenu* servicesMenu = [[NSMenu alloc] init];
    [NSApp setServicesMenu:servicesMenu];
    [[appMenu addItemWithTitle:@"Services"
                        action:NULL
                 keyEquivalent:@""] setSubmenu:servicesMenu];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"Hide %@", appName]
                       action:@selector(hide:)
                keyEquivalent:@"h"];
    [[appMenu addItemWithTitle:@"Hide Others"
                        action:@selector(hideOtherApplications:)
                 keyEquivalent:@"h"]
     setKeyEquivalentModifierMask:NSAlternateKeyMask | NSCommandKeyMask];
    [appMenu addItemWithTitle:@"Show All"
                       action:@selector(unhideAllApplications:)
                keyEquivalent:@""];
    [appMenu addItem:[NSMenuItem separatorItem]];
    [appMenu addItemWithTitle:[NSString stringWithFormat:@"Quit %@", appName]
                       action:@selector(terminate:)
                keyEquivalent:@"q"];
    
    NSMenuItem* windowMenuItem =
    [mainMenu addItemWithTitle:@"" action:NULL keyEquivalent:@""];
    NSMenu* windowMenu = [[NSMenu alloc] initWithTitle:@"Window"];
    [NSApp setWindowsMenu:windowMenu];
    [windowMenuItem setSubmenu:windowMenu];
    
    [windowMenu addItemWithTitle:@"Minimize"
                          action:@selector(performMiniaturize:)
                   keyEquivalent:@"m"];
    [windowMenu addItemWithTitle:@"Zoom"
                          action:@selector(performZoom:)
                   keyEquivalent:@""];
    [windowMenu addItem:[NSMenuItem separatorItem]];
    [windowMenu addItemWithTitle:@"Bring All to Front"
                          action:@selector(arrangeInFront:)
                   keyEquivalent:@""];
    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
    {
        [windowMenu addItem:[NSMenuItem separatorItem]];
        [[windowMenu addItemWithTitle:@"Enter Full Screen"
                               action:@selector(toggleFullScreen:)
                        keyEquivalent:@"f"]
         setKeyEquivalentModifierMask:NSControlKeyMask | NSCommandKeyMask];
    }
#endif
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self createMenu];
}

@end

#else

namespace vl {
    namespace presentation {
        namespace osx {
            class CocoaController;
        }
    }
}

@interface CocoaApplicationDelegate: UIResponder<UIApplicationDelegate>

@end

@interface RootViewController: UIViewController

@end

@implementation RootViewController

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end

UIWindow* window;
UIViewController* viewController;
NSMutableArray* pendingViews;

#endif


namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            using namespace collections;
            
            void GlobalTimerFunc();
#ifdef GAC_OS_OSX
            void MouseTapFunc(CGEventType type, CGEventRef event);
#endif
            
            class CocoaController : public Object, public virtual INativeController, public virtual INativeWindowService
            {
            protected:
                Dictionary<NSContainer*, CocoaWindow*>		windows;
                INativeWindow*                              mainWindow;
                
                CocoaCallbackService        callbackService;
                CocoaInputService           inputService;
                CocoaResourceService        resourceService;
                CocoaScreenService          screenService;
                CocoaAsyncService           asyncService;
                CocoaClipboardService       clipboardService;
                CocoaImageService           imageService;
                CocoaDialogService          dialogService;
                
                CocoaApplicationDelegate*   appDelegate;
                
            public:
                CocoaController():
                    mainWindow(0),
#ifdef GAC_OS_OSX
                    inputService(&MouseTapFunc, &GlobalTimerFunc)
#else
                    inputService(&GlobalTimerFunc)
#endif
                
                {
#ifdef GAC_OS_OSX
                    
                    [NSApplication sharedApplication];
                    
                    appDelegate = [[CocoaApplicationDelegate alloc] init];
                    [[NSApplication sharedApplication] setDelegate:appDelegate];
                    
                    // dock icon
                    [NSApp setActivationPolicy:NSApplicationActivationPolicyRegular];
                    
                    [NSApp finishLaunching];
                    
#else
                    
                    pendingViews = [[NSMutableArray alloc] init];
#endif
                }
                
                ~CocoaController()
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
                
#ifdef GAC_OS_IOS
                
                void AddView(UIView* view)
                {
                    
                }
      
                void ApplicationDidFinishLaunching()
                {
                    for(UIView* view in pendingViews)
                    {
                        [window.subviews[0] addSubview:view];
                    }
                    mainWindow->Show();
                }
                
#endif
                
                void Run(INativeWindow* window)
                {
                    mainWindow = window;
                    
#ifdef GAC_OS_OSX
                    [NSApp run];
#else
                    UIApplicationMain(0, 0, 0, NSStringFromClass([CocoaApplicationDelegate class]));
#endif
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
                    CocoaWindow* result = 0;
                    Rect minRect(0, 0, 99999, 99999);
                    for(vint i=0; i<windows.Count(); ++i)
                    {
                        CocoaWindow* window = (CocoaWindow*)windows.Values()[i];
                        Rect r = window->GetClientBoundsInScreen();
                        if(r.Contains(location))
                        {
                            if(!result)
                            {
                                result = window;
                                minRect = r;
                                continue;
                            }
                            
#ifdef GAC_OS_OSX
                            if(([window->GetNativeContainer()->window level] > [result->GetNativeContainer()->window level]) || [window->GetNativeContainer()->window level] == NSFloatingWindowLevel)
                            {
                                minRect = r;
                                result = window;
                            }
                            else if([window->GetNativeContainer()->window level] == [result->GetNativeContainer()->window level])
                            {
                                // encapsulates
                                if(r.Width() * r.Height() < minRect.Width() * minRect.Height())
                                {
                                    minRect = r;
                                    result = window;
                                }
                            }
#else
                            
                            
#endif
                        }
                    }
                    return result;
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
                    return &asyncService;
                }
                
                INativeClipboardService* ClipboardService()
                {
                    return &clipboardService;
                }
                
                INativeImageService* ImageService()
                {
                    return &imageService;
                }
                
                INativeScreenService* ScreenService()
                {
                    return &screenService;
                }
                
                INativeInputService* InputService()
                {
                    return &inputService;
                }
                
                INativeDialogService* DialogService()
                {
                    return &dialogService;
                }
                
                INativeWindowService* WindowService()
                {
                    return this;
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
                
                void InvokeGlobalTimer()
                {
                    [window setNeedsDisplay];
                    
                    asyncService.ExecuteAsyncTasks();
                    callbackService.InvokeGlobalTimer();
                }
                
            };
            
            INativeController* CreateOSXNativeController()
            {
                return new CocoaController();
            }
            
            void DestroyOSXNativeController(INativeController* controller)
            {
                delete controller;
            }
    
            void GlobalTimerFunc()
            {
                dynamic_cast<CocoaController*>(GetCurrentController())->InvokeGlobalTimer();
            }
            
            void WindowViewCreated(UIView* view)
            {
                [pendingViews addObject:view];
            }
            
#ifdef GAC_OS_OSX
            void MouseTapFunc(CGEventType type, CGEventRef event)
            {
                INativeCallbackService* cb = dynamic_cast<CocoaController*>(GetCurrentController())->CallbackService();
                dynamic_cast<CocoaCallbackService*>(cb)->InvokeMouseHook(type, event);
            }
#endif
            
        }
        
    }
    
}

#ifdef GAC_OS_IOS


@implementation CocoaApplicationDelegate
{
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    UIWindow* key = [UIApplication sharedApplication].keyWindow;
    
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UIView* rootView = [[UIView alloc] initWithFrame:window.frame];
    viewController = [[RootViewController alloc] init];
    [viewController setView:rootView];
    [window setRootViewController:viewController];
    [window addSubview:rootView];
    
    [window makeKeyAndVisible];
    
    vl::presentation::osx::CocoaController* controller = dynamic_cast<vl::presentation::osx::CocoaController*>(vl::presentation::GetCurrentController());
    
    controller->ApplicationDidFinishLaunching();
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

@end

#endif