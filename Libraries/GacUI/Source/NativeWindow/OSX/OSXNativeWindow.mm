//
//  OSXObjcWrapper.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "OSXNativeWindow.h"

#include <Cocoa/Cocoa.h>
#include <Foundation/Foundation.h>

// _NSGetProgname
#include <crt_externs.h>

#include "AppleHelper.h"

@interface OSXWindowDelegate : NSObject<NSWindowDelegate>

@property (nonatomic, readonly) vl::presentation::INativeWindow::WindowSizeState sizeState;

@end

@implementation OSXWindowDelegate

- (id)init
{
    if(self = [super init])
    {
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

@end

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaNativeWindow::CocoaNativeWindow():
                nativeContainer(0)
            {
                _CreateWindow();
            }
            
            CocoaNativeWindow::~CocoaNativeWindow()
            {
                if(nativeContainer)
                {
                    [nativeContainer->window close];
                    delete nativeContainer;
                }
            }
            
            void CocoaNativeWindow::_CreateWindow()
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
                
                nativeContainer = new NSContainer();
                nativeContainer->window = window;
                nativeContainer->controller = controller;
                
                OSXWindowDelegate* delegate = [[OSXWindowDelegate alloc] init];
                [window setDelegate:delegate];
            }

            Rect CocoaNativeWindow::GetBounds()
            {
                NSRect nsbounds = [nativeContainer->window frame];
                
                // frame.origin is lower-left
                return Rect(nsbounds.origin.x,
                            nsbounds.origin.y - nsbounds.size.height,
                            nsbounds.size.width + nsbounds.origin.x,
                            nsbounds.origin.y);
                
            }

            void CocoaNativeWindow::SetBounds(const Rect& bounds) 
            {
                NSRect nsbounds = NSMakeRect(bounds.Left(),
                                             bounds.Bottom(),
                                             bounds.Width(),
                                             bounds.Height());
                [nativeContainer->window setFrame:nsbounds display:YES];
            }

            Size CocoaNativeWindow::GetClientSize() 
            {
                return GetClientBoundsInScreen().GetSize();
            }

            void CocoaNativeWindow::SetClientSize(Size size) 
            {
                NSRect nsbounds = [nativeContainer->window frame];
                nsbounds.size.width = size.x;
                nsbounds.size.height = size.y;
                
                [nativeContainer->window setFrame:nsbounds display:YES];
            }

            Rect CocoaNativeWindow::GetClientBoundsInScreen() 
            {
                NSRect clientBounds = [[nativeContainer->window contentView] bounds];
                NSRect nsbounds = [nativeContainer->window frame];
                
                return Rect(nsbounds.origin.x + clientBounds.origin.x,
                            nsbounds.origin.y - clientBounds.size.height + clientBounds.origin.y,
                            nsbounds.origin.x + clientBounds.size.width + clientBounds.origin.x,
                            nsbounds.origin.y + clientBounds.origin.y);
            }

            WString CocoaNativeWindow::GetTitle() 
            {
                NSString* title = [nativeContainer->window title];
                return NSStringToWString(title);
            }

            void CocoaNativeWindow::SetTitle(WString title) 
            {
                [nativeContainer->window setTitle:WStringToNSString(title)];
            }

            INativeCursor* CocoaNativeWindow::GetWindowCursor() 
            {
                return 0;
            }

            void CocoaNativeWindow::SetWindowCursor(INativeCursor* cursor) 
            {
                // todo
            }

            Point CocoaNativeWindow::GetCaretPoint()
            {
                return caretPoint;
            }
            
            void CocoaNativeWindow::SetCaretPoint(Point point)
            {
                caretPoint = point;
                // todo
            }

            INativeWindow* CocoaNativeWindow::GetParent() 
            {
                return parentWindow;
            }

            void CocoaNativeWindow::SetParent(INativeWindow* parent) 
            {
                parentWindow = dynamic_cast<CocoaNativeWindow*>(parent);
                if(parentWindow)
                {
                    [nativeContainer->window setParentWindow:0];
                }
                else
                {
                    [nativeContainer->window setParentWindow:parentWindow->GetNativeContainer()->window];
                }
            }

            bool CocoaNativeWindow::GetAlwaysPassFocusToParent() 
            {
                return alwaysPassFocusToParent;
            }

            void CocoaNativeWindow::SetAlwaysPassFocusToParent(bool value) 
            {
                alwaysPassFocusToParent = value;
            }

            void CocoaNativeWindow::EnableCustomFrameMode() 
            {
                customFrameMode = true;
            }

            void CocoaNativeWindow::DisableCustomFrameMode() 
            {
                customFrameMode = false;
            }

            bool CocoaNativeWindow::IsCustomFrameModeEnabled() 
            {
                return customFrameMode;
            }

            INativeWindow::WindowSizeState CocoaNativeWindow::GetSizeState()
            {
                OSXWindowDelegate* delegate = (OSXWindowDelegate*)[nativeContainer->window delegate];
                return [delegate sizeState];
            }

            void CocoaNativeWindow::Show() 
            {
                // todo
                [nativeContainer->controller showWindow:nil];
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            void CocoaNativeWindow::ShowDeactivated() 
            {
                // todo
            }

            void CocoaNativeWindow::ShowRestored() 
            {
                // todo
            }

            void CocoaNativeWindow::ShowMaximized() 
            {
                // todo
                [nativeContainer->window toggleFullScreen:nil];
            }

            void CocoaNativeWindow::ShowMinimized() 
            {
                [nativeContainer->window miniaturize:nil];
            }

            void CocoaNativeWindow::Hide() 
            {
                // todo
                // there's no "hide" status in OSX
                // or maybe just make the bounds (0,0,0,0)
            }

            bool CocoaNativeWindow::IsVisible() 
            {
                return [nativeContainer->window isVisible];
            }

            void CocoaNativeWindow::Enable() 
            {
                // todo
                [nativeContainer->window makeKeyWindow];
                [nativeContainer->window makeFirstResponder:nativeContainer->window];
                enabled = true;
            }

            void CocoaNativeWindow::Disable() 
            {
                // todo
                [nativeContainer->window orderOut:nil];
                [nativeContainer->window makeFirstResponder:nil];
                enabled = false;
            }

            bool CocoaNativeWindow::IsEnabled() 
            {
                return enabled;
            }

            void CocoaNativeWindow::SetFocus() 
            {
                [nativeContainer->window makeKeyWindow];
            }

            bool CocoaNativeWindow::IsFocused() 
            {
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaNativeWindow::SetActivate() 
            {
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            bool CocoaNativeWindow::IsActivated() 
            {
                // todo
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaNativeWindow::ShowInTaskBar() 
            {
                // not configurable in runtime
            }

            void CocoaNativeWindow::HideInTaskBar() 
            {
                // not configurable in runtime
            }

            bool CocoaNativeWindow::IsAppearedInTaskBar() 
            {
                return true;
            }

            void CocoaNativeWindow::EnableActivate() 
            {
                // not configurable
            }

            void CocoaNativeWindow::DisableActivate() 
            {
                // not configurable
            }

            bool CocoaNativeWindow::IsEnabledActivate() 
            {
                return true;
            }

            
            bool CocoaNativeWindow::RequireCapture() 
            {
                return true;
            }

            bool CocoaNativeWindow::ReleaseCapture() 
            {
                return true;
            }

            bool CocoaNativeWindow::IsCapturing() 
            {
                return true;
            }

            bool CocoaNativeWindow::GetMaximizedBox() 
            {
                NSWindowCollectionBehavior behavior = [nativeContainer->window collectionBehavior];
                return behavior & NSWindowCollectionBehaviorFullScreenPrimary;
            }

            void CocoaNativeWindow::SetMaximizedBox(bool visible) 
            {
                NSWindowCollectionBehavior behavior = [nativeContainer->window collectionBehavior];
                if(visible)
                    behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
                else
                    behavior ^= NSWindowCollectionBehaviorFullScreenPrimary;
                [nativeContainer->window setCollectionBehavior:behavior];
            }

            bool CocoaNativeWindow::GetMinimizedBox() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return styleMask & NSMiniaturizableWindowMask;
            }

            void CocoaNativeWindow::SetMinimizedBox(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSMiniaturizableWindowMask;
                else
                    styleMask ^= NSMiniaturizableWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaNativeWindow::GetBorder() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return !(styleMask & NSBorderlessWindowMask);
            }

            void CocoaNativeWindow::SetBorder(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSBorderlessWindowMask;
                else
                    styleMask ^= NSBorderlessWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaNativeWindow::GetSizeBox() 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                return styleMask & NSResizableWindowMask;
            }

            void CocoaNativeWindow::SetSizeBox(bool visible) 
            {
                NSUInteger styleMask = [nativeContainer->window styleMask];
                if(visible)
                    styleMask |= NSResizableWindowMask;
                else
                    styleMask ^= NSResizableWindowMask;
                [nativeContainer->window setStyleMask:styleMask];
            }

            bool CocoaNativeWindow::GetIconVisible() 
            {
                // no such thing
                return false;
            }

            void CocoaNativeWindow::SetIconVisible(bool visible) 
            {
                (void)visible;
            }

            bool CocoaNativeWindow::GetTitleBar() 
            {
                return GetBorder();
            }

            void CocoaNativeWindow::SetTitleBar(bool visible) 
            {
                SetBorder(visible);
            }

            bool CocoaNativeWindow::GetTopMost() 
            {
                return [nativeContainer->window isKeyWindow];
            }

            void CocoaNativeWindow::SetTopMost(bool topmost) 
            {
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            void CocoaNativeWindow::SupressAlt()
            {
                
            }

            bool CocoaNativeWindow::InstallListener(INativeWindowListener* listener) 
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

            bool CocoaNativeWindow::UninstallListener(INativeWindowListener* listener) 
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

            void CocoaNativeWindow::RedrawContent() 
            {
                [nativeContainer->window display];
            }

            NSContainer* CocoaNativeWindow::GetNativeContainer() const
            {
                return nativeContainer;
            }

        }
    }
}