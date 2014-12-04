//
//  OSXObjcWrapper.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaWindow.h"

#import <Cocoa/Cocoa.h>
#import <Foundation/Foundation.h>

// _NSGetProgname
#import <crt_externs.h>

#include "CocoaHelper.h"

using namespace vl::presentation;

@interface CocoaWindowDelegate : NSObject<NSWindowDelegate>

@property (nonatomic, readonly) INativeWindow::WindowSizeState sizeState;
@property (assign) INativeWindow* nativeWindow;

- (id)initWithNativeWindow:(INativeWindow*)window;

@end

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaWindow::CocoaWindow():
                nativeContainer(0)
            {
                _CreateWindow();
            }
            
            CocoaWindow::~CocoaWindow()
            {
                if(nativeContainer)
                {
                    [nativeContainer->window close];
                    delete nativeContainer;
                }
            }
            
            void CocoaWindow::_CreateWindow()
            {
                NSUInteger windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
                
                NSRect windowRect = NSMakeRect(0, 0, 0, 0);
                
                NSWindow* window = [[NSWindow alloc] initWithContentRect:windowRect
                                                               styleMask:windowStyle
                                                                 backing:NSBackingStoreBuffered
                                                                   defer:NO];
                NSWindowController* controller = [[NSWindowController alloc] initWithWindow:window];
                [window orderFrontRegardless];
                
                [window setAcceptsMouseMovedEvents:YES];
                [window setLevel:NSMainMenuWindowLevel + 1];
                
                // hide on diactivate
                [window setHidesOnDeactivate:YES];
                
                // disable auto restore...
                // which actually sucks for our usage
                [window setRestorable:NO];
                
                nativeContainer = new NSContainer();
                nativeContainer->window = window;
                nativeContainer->controller = controller;
                
                nativeContainer->delegate = [[CocoaWindowDelegate alloc] initWithNativeWindow:this];
                [window setDelegate:nativeContainer->delegate];
            }

            Rect CocoaWindow::GetBounds()
            {
                NSRect nsbounds = [nativeContainer->window frame];
                
                // frame.origin is lower-left
                return Rect(nsbounds.origin.x,
                            nsbounds.origin.y - nsbounds.size.height,
                            nsbounds.size.width + nsbounds.origin.x,
                            nsbounds.origin.y);
            }

            void CocoaWindow::SetBounds(const Rect& bounds) 
            {
                NSRect nsbounds = NSMakeRect(bounds.Left(),
                                             bounds.Bottom(),
                                             bounds.Width(),
                                             bounds.Height());
                [nativeContainer->window setFrame:nsbounds display:YES];
                
                Show();
            }

            Size CocoaWindow::GetClientSize() 
            {
                return GetClientBoundsInScreen().GetSize();
            }

            void CocoaWindow::SetClientSize(Size size) 
            {   [nativeContainer->window setContentSize:NSMakeSize(size.x, size.y)];
                [nativeContainer->window display];
            }

            Rect CocoaWindow::GetClientBoundsInScreen() 
            {
                NSRect nsbounds = [nativeContainer->window frame];
                NSRect contentFrame = [nativeContainer->window contentRectForFrameRect:[nativeContainer->window frame]];
                return Rect(nsbounds.origin.x + contentFrame.origin.x,
                            nsbounds.origin.y - contentFrame.size.height + contentFrame.origin.y,
                            nsbounds.origin.x + contentFrame.size.width + contentFrame.origin.x,
                            nsbounds.origin.y + contentFrame.origin.y);
            }

            WString CocoaWindow::GetTitle() 
            {
                NSString* title = [nativeContainer->window title];
                return NSStringToWString(title);
            }

            void CocoaWindow::SetTitle(WString title) 
            {
                [nativeContainer->window setTitle:WStringToNSString(title)];
            }

            INativeCursor* CocoaWindow::GetWindowCursor() 
            {
                return 0;
            }

            void CocoaWindow::SetWindowCursor(INativeCursor* cursor) 
            {
                // todo
            }

            Point CocoaWindow::GetCaretPoint()
            {
                return caretPoint;
            }
            
            void CocoaWindow::SetCaretPoint(Point point)
            {
                caretPoint = point;
                // todo
            }

            INativeWindow* CocoaWindow::GetParent() 
            {
                return parentWindow;
            }

            void CocoaWindow::SetParent(INativeWindow* parent) 
            {
                parentWindow = dynamic_cast<CocoaWindow*>(parent);
                if(parentWindow)
                {
                    [nativeContainer->window setParentWindow:0];
                }
                else
                {
                    [nativeContainer->window setParentWindow:parentWindow->GetNativeContainer()->window];
                }
            }

            bool CocoaWindow::GetAlwaysPassFocusToParent() 
            {
                return alwaysPassFocusToParent;
            }

            void CocoaWindow::SetAlwaysPassFocusToParent(bool value) 
            {
                alwaysPassFocusToParent = value;
            }

            void CocoaWindow::EnableCustomFrameMode() 
            {
                customFrameMode = true;
            }

            void CocoaWindow::DisableCustomFrameMode() 
            {
                customFrameMode = false;
            }

            bool CocoaWindow::IsCustomFrameModeEnabled() 
            {
                return customFrameMode;
            }

            INativeWindow::WindowSizeState CocoaWindow::GetSizeState()
            {
                CocoaWindowDelegate* delegate = (CocoaWindowDelegate*)[nativeContainer->window delegate];
                return [delegate sizeState];
            }

            void CocoaWindow::Show() 
            {
                // todo
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            void CocoaWindow::ShowDeactivated() 
            {
                // todo
            }

            void CocoaWindow::ShowRestored() 
            {
                // todo
            }

            void CocoaWindow::ShowMaximized() 
            {
                // todo
                [nativeContainer->window toggleFullScreen:nil];
            }

            void CocoaWindow::ShowMinimized() 
            {
                [nativeContainer->window miniaturize:nil];
            }

            void CocoaWindow::Hide() 
            {
                // todo
                // there's no "hide" status in OSX
                // or maybe just make the bounds (0,0,0,0)
                [nativeContainer->window orderOut:nil];
            }

            bool CocoaWindow::IsVisible() 
            {
                return [nativeContainer->window isVisible];
            }

            void CocoaWindow::Enable() 
            {
                // todo
                [nativeContainer->window makeKeyWindow];
                [nativeContainer->window makeFirstResponder:nativeContainer->window];
                enabled = true;
            }

            void CocoaWindow::Disable() 
            {
                // todo
                [nativeContainer->window orderOut:nil];
                [nativeContainer->window makeFirstResponder:nil];
                enabled = false;
            }

            bool CocoaWindow::IsEnabled() 
            {
                return enabled;
            }

            void CocoaWindow::SetFocus() 
            {
                [nativeContainer->window makeKeyWindow];
            }

            bool CocoaWindow::IsFocused() 
            {
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaWindow::SetActivate() 
            {
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            bool CocoaWindow::IsActivated() 
            {
                // todo
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaWindow::ShowInTaskBar() 
            {
                // not configurable at runtime
            }

            void CocoaWindow::HideInTaskBar() 
            {
                // not configurable at runtime
            }

            bool CocoaWindow::IsAppearedInTaskBar() 
            {
                return true;
            }

            void CocoaWindow::EnableActivate() 
            {
                // not configurable
            }

            void CocoaWindow::DisableActivate() 
            {
                // not configurable
            }

            bool CocoaWindow::IsEnabledActivate() 
            {
                return true;
            }
            
            bool CocoaWindow::RequireCapture() 
            {
                return true;
            }

            bool CocoaWindow::ReleaseCapture() 
            {
                return true;
            }

            bool CocoaWindow::IsCapturing() 
            {
                return true;
            }

            bool CocoaWindow::GetMaximizedBox() 
            {
                NSWindowCollectionBehavior behavior = [nativeContainer->window collectionBehavior];
                return behavior & NSWindowCollectionBehaviorFullScreenPrimary;
            }

            void CocoaWindow::SetMaximizedBox(bool visible) 
            {
                NSWindowCollectionBehavior behavior = [nativeContainer->window collectionBehavior];
                if(visible)
                    behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
                else
                    behavior ^= NSWindowCollectionBehaviorFullScreenPrimary;
                [nativeContainer->window setCollectionBehavior:behavior];
            }

            bool CocoaWindow::GetMinimizedBox() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return styleMask & NSMiniaturizableWindowMask;
            }

            void CocoaWindow::SetMinimizedBox(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSMiniaturizableWindowMask;
                else
                    styleMask ^= NSMiniaturizableWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaWindow::GetBorder() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return !(styleMask & NSBorderlessWindowMask);
            }

            void CocoaWindow::SetBorder(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSBorderlessWindowMask;
                else
                    styleMask ^= NSBorderlessWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaWindow::GetSizeBox() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return styleMask & NSResizableWindowMask;
            }

            void CocoaWindow::SetSizeBox(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSResizableWindowMask;
                else
                    styleMask ^= NSResizableWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaWindow::GetIconVisible() 
            {
                // no such thing
                return false;
            }

            void CocoaWindow::SetIconVisible(bool visible) 
            {
                (void)visible;
            }

            bool CocoaWindow::GetTitleBar() 
            {
                return GetBorder();
            }

            void CocoaWindow::SetTitleBar(bool visible) 
            {
                SetBorder(visible);
            }

            bool CocoaWindow::GetTopMost() 
            {
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaWindow::SetTopMost(bool topmost) 
            {
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            void CocoaWindow::SupressAlt()
            {
                
            }

            bool CocoaWindow::InstallListener(INativeWindowListener* listener) 
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

            bool CocoaWindow::UninstallListener(INativeWindowListener* listener) 
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
            
            void CocoaWindow::RedrawContent() 
            {
                [nativeContainer->window display];
            }

            NSContainer* CocoaWindow::GetNativeContainer() const
            {
                return nativeContainer;
            }
            
            void CocoaWindow::SetGraphicsHandler(Interface* handler)
            {
                graphicsHandler = handler;
            }
            
            Interface* CocoaWindow::GetGraphicsHandler() const
            {
                return graphicsHandler;
            }
            
            
            void CocoaWindow::InvokeMoved()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Moved();
                }
            }

            
            NSContainer* GetNSNativeContainer(INativeWindow* window)
            {
                return (dynamic_cast<CocoaWindow*>(window))->GetNativeContainer();
            }
        }
    }
}


@implementation CocoaWindowDelegate

- (id)initWithNativeWindow:(INativeWindow*)window
{
    if(self = [super init])
    {
        _nativeWindow = window;
        _sizeState = vl::presentation::INativeWindow::Restored;
    }
    return self;
}

- (void)windowDidMiniaturize:(NSNotification *)notification
{
    _sizeState = vl::presentation::INativeWindow::Minimized;
}

- (void)windowDidDeminiaturize:(NSNotification *)notification
{
    _sizeState = vl::presentation::INativeWindow::Restored;
}

- (void)windowDidEnterFullScreen:(NSNotification *)notification
{
    _sizeState = vl::presentation::INativeWindow::Maximized;
}

- (void)windowDidExitFullScreen:(NSNotification *)notification
{
    _sizeState = vl::presentation::INativeWindow::Restored;
}

- (void)windowWillClose:(NSNotification *)notification
{
    
}

- (void)windowDidResize:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeMoved();
}

@end
