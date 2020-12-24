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

#import "CocoaBaseView.h"

#include "CocoaHelper.h"
#include "ServicesImpl/CocoaInputService.h"
#include "ServicesImpl/CocoaResourceService.h"

using namespace vl::presentation;

@interface CocoaWindowDelegate : NSObject<NSWindowDelegate>

@property (nonatomic) INativeWindow::WindowSizeState sizeState;
@property (assign) INativeWindow* nativeWindow;

- (id)initWithNativeWindow:(INativeWindow*)window;

- (void)reset;

@end

@interface CocoaNSWindow : NSWindow


@end

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaWindow::CocoaWindow():
                parentWindow(0),
                alwaysPassFocusToParent(false),
                mouseLastX(0),
                mouseLastY(0),
                mouseDownX(0),
                mouseDownY(0),
                mouseHoving(false),
                graphicsHandler(0),
                customFrameMode(false),
                supressingAlt(false),
                enabled(false),
                capturing(false),
                resizing(false),
                moving(false),
                opened(false),
                resizingBorder(INativeWindowListener::NoDecision),
                nsWindow(0),
                nsController(0),
                nsDelegate(0)
            {
                CreateWindow();
            }
            
            CocoaWindow::~CocoaWindow()
            {
                [nsWindow close];
            }
            
            void CocoaWindow::CreateWindow()
            {
                NSWindowStyleMask windowStyle = NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskResizable;
                
                NSRect windowRect = NSMakeRect(0, 0, 0, 0);
                
                NSWindow* window = [[CocoaNSWindow alloc] initWithContentRect:windowRect
                                                                    styleMask:windowStyle
                                                                      backing:NSBackingStoreBuffered
                                                                        defer:YES];
                NSWindowController* controller = [[NSWindowController alloc] initWithWindow:window];
                [window orderFrontRegardless];
                
                [window setAcceptsMouseMovedEvents:YES];
                
                // hide on diactivate
                //[window setHidesOnDeactivate:YES];
                
                // disable auto restore...
                // which actually sucks for our usage
                [window setRestorable:NO];
                
                nsWindow = window;
                nsController = controller;
                nsDelegate = [[CocoaWindowDelegate alloc] initWithNativeWindow:this];
                [window setDelegate:nsDelegate];
                
                currentCursor = GetCurrentController()->ResourceService()->GetDefaultSystemCursor();
            }

            NativeRect CocoaWindow::GetBounds()
            {
                NSRect nsbounds = [nsWindow frame];

                return FlipRect(nsWindow,
                                NativeRect(nsbounds.origin.x,
                                     nsbounds.origin.y,
                                     nsbounds.size.width + nsbounds.origin.x,
                                     nsbounds.size.height + nsbounds.origin.y));
            }

            void CocoaWindow::SetBounds(const NativeRect& bounds)
            {
                NativeRect newBounds = bounds;
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Moving(newBounds, true);
                }
                NSRect nsbounds = NSMakeRect(newBounds.Left().value,
                                             FlipY(nsWindow, newBounds.Bottom().value),
                                             newBounds.Width().value,
                                             newBounds.Height().value);
                
                [nsWindow setFrame:nsbounds display:YES];
                
                previousBounds = GetBounds();
                Show();
            }

            NativeSize CocoaWindow::GetClientSize()
            {
                return GetClientBoundsInScreen().GetSize();
            }

            void CocoaWindow::SetClientSize(NativeSize size)
            {
                NativeRect bounds = GetBounds();
                NativeRect newBounds = NativeRect(bounds.Left(), bounds.Top(), size.x + bounds.Left(), size.y + bounds.Top());

                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Moving(newBounds, true);
                }
                
                [nsWindow setContentSize:NSMakeSize(newBounds.Width().value, newBounds.Height().value)];
            }

            NativeRect CocoaWindow::GetClientBoundsInScreen()
            {
                NSRect contentFrame = [nsWindow convertRectToScreen:[nsWindow.contentView frame]];
                
                if(!([nsWindow screen]))
                    contentFrame = [nsWindow frame];
                
                return FlipRect(nsWindow,
                                NativeRect(contentFrame.origin.x,
                                     contentFrame.origin.y,
                                     contentFrame.size.width + contentFrame.origin.x,
                                     contentFrame.size.height + contentFrame.origin.y));
            }

            WString CocoaWindow::GetTitle() 
            {
                NSString* title = [nsWindow title];
                return NSStringToWString(title);
            }

            void CocoaWindow::SetTitle(WString title) 
            {
                [nsWindow setTitle:WStringToNSString(title)];
            }

            INativeCursor* CocoaWindow::GetWindowCursor() 
            {
                return currentCursor;
            }

            void CocoaWindow::SetWindowCursor(INativeCursor* cursor) 
            {
                currentCursor = cursor;
                
                dynamic_cast<CocoaCursor*>(cursor)->Set();
                
                [nsWindow invalidateCursorRectsForView:nsWindow.contentView];
            }

            NativePoint CocoaWindow::GetCaretPoint()
            {
                return caretPoint;
            }
            
            void CocoaWindow::SetCaretPoint(NativePoint point)
            {
                caretPoint = point;
                
                if(nsWindow.contentView)
                    [(CocoaBaseView*)nsWindow.contentView updateIMEComposition];
            }

            INativeWindow* CocoaWindow::GetParent() 
            {
                return parentWindow;
            }

            void CocoaWindow::SetParent(INativeWindow* parent) 
            {
                CocoaWindow* cocoaParent = dynamic_cast<CocoaWindow*>(parent);
                if(!cocoaParent)
                {
                    if(parentWindow) {
                        [parentWindow->GetNativeWindow() removeChildWindow:nsWindow];
                    }
                }
                else
                {
                    if(!parentWindow)
                    {
                        [cocoaParent->GetNativeWindow() addChildWindow:nsWindow ordered:NSWindowAbove];
                        
                        // why prior to 10.10 this will be disabled...
                        [nsWindow setAcceptsMouseMovedEvents:YES];
                    }
                }
                parentWindow = cocoaParent;
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
                [nsWindow setMovableByWindowBackground:YES];
            }

            void CocoaWindow::DisableCustomFrameMode() 
            {
                customFrameMode = false;
                [nsWindow setMovableByWindowBackground:NO];
            }

            bool CocoaWindow::IsCustomFrameModeEnabled() 
            {
                return customFrameMode;
            }

            INativeWindow::WindowSizeState CocoaWindow::GetSizeState()
            {
                CocoaWindowDelegate* delegate = (CocoaWindowDelegate*)[nsWindow delegate];
                return [delegate sizeState];
            }

            void CocoaWindow::Show() 
            {
                if(parentWindow)
                {
                    [nsWindow orderFront:nil];
                    [nsWindow makeFirstResponder:nsWindow.contentView];
                }
                else
                {
                    [nsWindow makeKeyAndOrderFront:nil];
                    [nsWindow makeMainWindow];
                }
                [nsWindow.contentView setNeedsDisplay:YES];
                
                if(!opened)
                {
                    InvokeOpened();
                    opened = true;
                }
            }

            void CocoaWindow::ShowDeactivated() 
            {
                [nsWindow orderFront:nil];
                [nsWindow makeFirstResponder:nsWindow.contentView];

                if(!opened)
                {
                    InvokeOpened();
                    opened = true;
                }
            }

            void CocoaWindow::ShowRestored() 
            {
                // SetBounds -> Show
                SetBounds(previousBounds);
                
                [nsDelegate setSizeState:INativeWindow::Restored];
            }

            void CocoaWindow::ShowMaximized() 
            {
                NSScreen* screen = [nsWindow screen];
                
                while(!screen && [nsWindow  parentWindow])
                {
                    screen = [[nsWindow  parentWindow] screen];
                }
                if(!screen)
                    screen = [NSScreen mainScreen];
                
                previousBounds = GetBounds();
                [nsWindow setFrame:[screen visibleFrame] display:YES];
                [nsDelegate setSizeState:INativeWindow::Maximized];
                
                if(!opened)
                {
                    InvokeOpened();
                    opened = true;
                }
            }

            void CocoaWindow::ShowMinimized() 
            {
                previousBounds = GetBounds();
                [nsWindow miniaturize:nil];
            }

            void CocoaWindow::Hide(bool closeWindow)
            {
                // actually close it as we need to trigger closing / closed events for GuiMenu to work
                if (closeWindow)
                {
                    [nsWindow close];
                }
                else
                {
                    [nsWindow setIsVisible:false];
                }
                opened = false;
                InvokeClosed();
            }

            bool CocoaWindow::IsVisible()
            {
                return [nsWindow isVisible] && [nsWindow frame].size.width > 0;
            }

            void CocoaWindow::Enable() 
            {
                // todo
                [nsWindow orderFront:nil];
                [nsWindow makeFirstResponder:nsWindow];
                enabled = true;
            }

            void CocoaWindow::Disable() 
            {
                // todo
                [nsWindow orderOut:nil];
                [nsWindow makeFirstResponder:nil];
                enabled = false;
            }

            bool CocoaWindow::IsEnabled() 
            {
                return enabled;
            }

            void CocoaWindow::SetFocus() 
            {
                [nsWindow makeKeyWindow];
                [nsWindow makeFirstResponder:nsWindow.contentView];
                if(parentWindow)
                {
                    [nsWindow orderFront:nil];
                }
            }

            bool CocoaWindow::IsFocused() 
            {
                return [nsWindow isKeyWindow];
            }

            void CocoaWindow::SetActivate() 
            {
                [nsWindow makeKeyWindow];
            }

            bool CocoaWindow::IsActivated() 
            {
                // todo
                return [nsWindow isKeyWindow];
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
                // todo
                capturing = true;
                return true;
            }

            bool CocoaWindow::ReleaseCapture() 
            {
                // todo
                capturing = false;
                return true;
            }

            bool CocoaWindow::IsCapturing() 
            {
                return capturing;
            }

            bool CocoaWindow::GetMaximizedBox() 
            {
                NSWindowCollectionBehavior behavior = [nsWindow collectionBehavior];
                return behavior & NSWindowCollectionBehaviorFullScreenPrimary;
            }

            void CocoaWindow::SetMaximizedBox(bool visible) 
            {
                NSWindowCollectionBehavior behavior = [nsWindow collectionBehavior];
                if(visible)
                    behavior |= NSWindowCollectionBehaviorFullScreenPrimary;
                else
                    behavior ^= NSWindowCollectionBehaviorFullScreenPrimary;
                [nsWindow setCollectionBehavior:behavior];
                
                [[nsWindow standardWindowButton:NSWindowZoomButton] setHidden:!visible];
            }

            bool CocoaWindow::GetMinimizedBox() 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                return styleMask & NSWindowStyleMaskMiniaturizable;
            }

            void CocoaWindow::SetMinimizedBox(bool visible) 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                if(visible)
                    styleMask |= NSWindowStyleMaskMiniaturizable;
                else
                    styleMask ^= NSWindowStyleMaskMiniaturizable;
                [nsWindow setStyleMask:styleMask];
                
                [[nsWindow standardWindowButton:NSWindowMiniaturizeButton] setHidden:!visible];
            }

            bool CocoaWindow::GetBorder() 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                return !(styleMask & NSWindowStyleMaskBorderless);
            }

            void CocoaWindow::SetBorder(bool visible) 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                if(visible)
                    styleMask ^= NSWindowStyleMaskBorderless;
                else 
                    styleMask = NSWindowStyleMaskBorderless;
                [nsWindow setStyleMask:styleMask];
            }

            bool CocoaWindow::GetSizeBox() 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                return styleMask & NSWindowStyleMaskResizable;
            }

            void CocoaWindow::SetSizeBox(bool visible) 
            {
                NSWindowStyleMask styleMask = [nsWindow styleMask];
                if(visible)
                    styleMask |= NSWindowStyleMaskResizable;
                else
                    styleMask ^= NSWindowStyleMaskResizable;
                [nsWindow setStyleMask:styleMask];
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
                return [nsWindow isKeyWindow];
            }

            void CocoaWindow::SetTopMost(bool topmost) 
            {
                [nsWindow makeKeyAndOrderFront:nil];
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
                [nsWindow.contentView setNeedsDisplay:YES];
                [nsWindow display];
            }

            NSWindow* CocoaWindow::GetNativeWindow() const
            {
                return nsWindow;
            }
            
            NSWindowController* CocoaWindow::GetNativeController() const
            {
                return nsController;
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
                if(nsWindow.contentView)
                    [(CocoaBaseView*)nsWindow.contentView updateIMEComposition];
                
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Moved();
                }
            }
            
            void CocoaWindow::InvokeOpened()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Opened();
                }
            }
            
            void CocoaWindow::InvokeClosed()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Closed();
                }
            }

            bool CocoaWindow::InvokeClosing()
            {
                bool cancel = false;
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Closing(cancel);
                }
                return cancel;
            }
            
            void CocoaWindow::InvokeAcivate()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Activated();
                }
            }
            
            void CocoaWindow::InvokeDeactivate()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Deactivated();
                }
            }
            
            void CocoaWindow::InvokeGotFocus()
            {
                [nsWindow makeFirstResponder:nsWindow.contentView];

                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->GotFocus();
                }
            }
            
            void CocoaWindow::InvokeLostFocus()
            {
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->LostFocus();
                }
            }
            
            NSWindow* GetNativeWindow(INativeWindow* window)
            {
                return (dynamic_cast<CocoaWindow*>(window))->GetNativeWindow();
            }
            
            NativeWindowMouseInfo CreateMouseInfo(NSWindow* window, NSEvent* event)
            {
                NativeWindowMouseInfo info{};
                
                info.left = event.type == NSEventTypeLeftMouseDown;
                info.right = event.type == NSEventTypeRightMouseDown;
                // assuming its middle mouse
                info.middle = (event.type == NSEventTypeOtherMouseDown);
                
                info.ctrl = event.modifierFlags & NSEventModifierFlagControl;
                info.shift = event.modifierFlags & NSEventModifierFlagShift;
                
                const NSRect contentRect = [window.contentView frame];
                const NSPoint p = [event locationInWindow];
                
                info.x = p.x;
                info.y = contentRect.size.height - p.y;
                
                info.nonClient = false;
                if(info.x < 0 || info.y < 0 ||
                   info.x > contentRect.size.width || info.y > contentRect.size.height)
                    info.nonClient = true;
                
                
                return info;
            }
            
            NativeWindowKeyInfo CreateKeyInfo(NSWindow* window, NSEvent* event)
            {
                NativeWindowKeyInfo info{};
             
                info.ctrl = event.modifierFlags & NSEventModifierFlagCommand;
                info.shift = event.modifierFlags & NSEventModifierFlagShift;
                info.alt = event.modifierFlags & NSEventModifierFlagOption;
                info.capslock = event.modifierFlags & NSEventModifierFlagCapsLock;
                
                info.code = NSEventKeyCodeToGacKeyCode(event.keyCode);
                
                return info;
            }
            
            void CocoaWindow::InsertText(const WString& str)
            {
                NativeWindowCharInfo info{};

                NSEventModifierFlags modifierFlags = [NSEvent modifierFlags];
                info.ctrl = modifierFlags & NSEventModifierFlagCommand;
                info.shift = modifierFlags & NSEventModifierFlagShift;
                info.alt = modifierFlags & NSEventModifierFlagOption;
                info.capslock = modifierFlags & NSEventModifierFlagCapsLock;
                
                for(int i=0; i<str.Length(); ++i)
                {
                    info.code = str[i];

                    for(int i=0; i<listeners.Count(); ++i)
                    {
                        listeners[i]->Char(info);
                    }
                }
            }
            
            void CocoaWindow::SetResizingBorder(INativeWindowListener::HitTestResult border)
            {
                resizingBorder = border;
                INativeResourceService* resourceService = GetCurrentController()->ResourceService();

                switch(border)
                {
                    case INativeWindowListener::BorderLeft:
                    case INativeWindowListener::BorderRight:
                        SetWindowCursor(resourceService->GetSystemCursor(INativeCursor::SizeWE));
                        break;
                        
                    case INativeWindowListener::BorderTop:
                    case INativeWindowListener::BorderBottom:
                        SetWindowCursor(resourceService->GetSystemCursor(INativeCursor::SizeNS));
                        break;
                        
                    case INativeWindowListener::BorderLeftTop:
                    case INativeWindowListener::BorderRightBottom:
                        SetWindowCursor(resourceService->GetSystemCursor(INativeCursor::SizeNWSE));
                        break;
                        
                    case INativeWindowListener::BorderRightTop:
                    case INativeWindowListener::BorderLeftBottom:
                        SetWindowCursor(resourceService->GetSystemCursor(INativeCursor::SizeNESW));
                        break;
                        
                    case INativeWindowListener::Title:
                       // SetWindowCursor(resourceService->GetSystemCursor(INativeCursor::Hand));
                        break;
                        
                    default:
                        break;
                }
            }
            
            void CocoaWindow::HitTestMouseDown(NativeCoordinate x, NativeCoordinate y)
            {
                NativePoint p(x, y);
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    INativeWindowListener::HitTestResult r = listeners[i]->HitTest(p);
                    
                    switch(r)
                    {
                        case INativeWindowListener::BorderLeft:
                        case INativeWindowListener::BorderRight:
                        case INativeWindowListener::BorderTop:
                        case INativeWindowListener::BorderBottom:
                        case INativeWindowListener::BorderLeftTop:
                        case INativeWindowListener::BorderRightTop:
                        case INativeWindowListener::BorderLeftBottom:
                        case INativeWindowListener::BorderRightBottom:
                            resizing = true;
                            lastBorder = GetBounds();
                            return;
                            
                        case INativeWindowListener::Title:
                            lastBorder = GetBounds();
                            moving = true;
                            return;
                            
                        default:
                            break;
                    }
                }
            }
            
            void CocoaWindow::HitTestMouseMove(NativeCoordinate x, NativeCoordinate y)
            {
                NativePoint p(x, y);
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    INativeWindowListener::HitTestResult r = listeners[i]->HitTest(p);
                    
                    switch(r)
                    {
                        case INativeWindowListener::BorderLeft:
                        case INativeWindowListener::BorderRight:
                        case INativeWindowListener::BorderTop:
                        case INativeWindowListener::BorderBottom:
                        case INativeWindowListener::BorderLeftTop:
                        case INativeWindowListener::BorderRightTop:
                        case INativeWindowListener::BorderLeftBottom:
                        case INativeWindowListener::BorderRightBottom:
                        case INativeWindowListener::Title:
                            SetResizingBorder(r);
                            return;
                            
                        default:
                            SetResizingBorder(INativeWindowListener::NoDecision);
                            break;
                    }
                }
            }
            
            void CocoaWindow::HitTestMouseUp(NativeCoordinate x, NativeCoordinate y)
            {
                if(resizing)
                {
                    resizing = false;
                    SetWindowCursor(GetCurrentController()->ResourceService()->GetDefaultSystemCursor());
                }
                else if(moving)
                {
                    moving = false;
                    SetWindowCursor(GetCurrentController()->ResourceService()->GetDefaultSystemCursor());
                }
                else
                {
                    NativePoint p(x, y);
                    for(vint i=0;i<listeners.Count();i++)
                    {
                        switch(listeners[i]->HitTest(p))
                        {
                            case INativeWindowListener::ButtonMinimum:
                                ShowMinimized();
                                return;
                                
                            case INativeWindowListener::ButtonMaximum:
                                if (GetSizeState() == INativeWindow::Maximized)
                                {
                                    ShowRestored();
                                }
                                else
                                {
                                    ShowMaximized();
                                }
                                return;
                                
                            case INativeWindowListener::ButtonClose:
                                Hide(true);
                                return;
                                
                            default:
                                break;
                        }
                    }
                }
            }
            
            void CocoaWindow::MovingDragged()
            {
                vint diffX = [NSEvent mouseLocation].x - mouseDownX;
                vint diffY = -([NSEvent mouseLocation].y - mouseDownY);
                
                NativeRect bounds = lastBorder;
                
                bounds.x1 += diffX;
                bounds.y1 += diffY;
                bounds.x2 += diffX;
                bounds.y2 += diffY;
                
                NSScreen* screen = GetWindowScreen(nsWindow);
                NSRect visibleFrame = screen.visibleFrame;
                visibleFrame.origin.y = screen.frame.size.height - (visibleFrame.origin.y + visibleFrame.size.height);
                
                if(bounds.x2 < visibleFrame.origin.x + 10)
                    bounds.x2 = visibleFrame.origin.x + 10;
                if(bounds.y2 < visibleFrame.origin.y + 10)
                    bounds.y2 = visibleFrame.origin.y + 10;
                
                if(bounds.x1 > visibleFrame.size.width + visibleFrame.origin.x - 10)
                    bounds.x1 = visibleFrame.size.width + visibleFrame.origin.x - 10;
                if(bounds.y1 > visibleFrame.size.height + visibleFrame.origin.y - 10)
                    bounds.y1 = visibleFrame.size.height + visibleFrame.origin.y - 10;
                
                SetBounds(bounds);
            }
            
            void CocoaWindow::ResizingDragged()
            {
                vint diffX = [NSEvent mouseLocation].x - mouseDownX;
                vint diffY = -([NSEvent mouseLocation].y - mouseDownY);
                
                NativeRect bounds = lastBorder;
                NSScreen* screen = GetWindowScreen(nsWindow);
                
#define CHECK_X1 if(bounds.x1 > bounds.x2 - 1) bounds.x1 = bounds.x2 - 1;
#define CHECK_X2 if(bounds.x2 < bounds.x1 + 1) bounds.x2 = bounds.x1 + 1;
#define CHECK_Y1 if(bounds.y1 > bounds.y2 - 1) bounds.y1 = bounds.y2 - 1;
#define CHECK_Y2 if(bounds.y2 < bounds.y1 + 1) bounds.y2 = bounds.y1 + 1;
                
                switch(resizingBorder)
                {
                    case INativeWindowListener::BorderLeft:
                        bounds.x1 += diffX;
                        
                        CHECK_X1;
                        break;
                        
                    case INativeWindowListener::BorderRight:
                        bounds.x2 += diffX;
                        
                        CHECK_X2;
                        break;
                        
                    case INativeWindowListener::BorderTop:
                        bounds.y1 += diffY;
                        
                        CHECK_Y1;
                        break;
                        
                    case INativeWindowListener::BorderBottom:
                        bounds.y2 += diffY;
                        
                        CHECK_Y2;
                        break;
                        
                    case INativeWindowListener::BorderLeftTop:
                        bounds.x1 += diffX;
                        bounds.y1 += diffY;
                        
                        CHECK_X1;
                        CHECK_Y1;
                        break;
                        
                    case INativeWindowListener::BorderRightTop:
                        bounds.x2 += diffX;
                        bounds.y1 += diffY;
                        
                        CHECK_X2;
                        CHECK_Y1;
                        break;
                        
                    case INativeWindowListener::BorderLeftBottom:
                        bounds.x1 += diffX;
                        bounds.y2 += diffY;
                        
                        CHECK_X1;
                        CHECK_Y2;
                        break;
                        
                    case INativeWindowListener::BorderRightBottom:
                        bounds.x2 += diffX;
                        bounds.y2 += diffY;
                        
                        CHECK_X2;
                        CHECK_Y2;
                        break;
                        
                    default:
                        break;
                }
                
                NSRect visibleFrame = screen.visibleFrame;
                visibleFrame.origin.y = screen.frame.size.height - (visibleFrame.origin.y + visibleFrame.size.height);
                
                if(bounds.x1 < visibleFrame.origin.x)
                    bounds.x1 = visibleFrame.origin.x;
                if(bounds.x2 > visibleFrame.size.width + visibleFrame.origin.x)
                    bounds.x2 = visibleFrame.size.width + visibleFrame.origin.x;
                if(bounds.y1 < visibleFrame.origin.y)
                    bounds.y1 = visibleFrame.origin.y;
                if(bounds.y2 > visibleFrame.size.height + visibleFrame.origin.y)
                    bounds.y2 = visibleFrame.size.height + visibleFrame.origin.y;
                
                bounds = FlipRect(nsWindow, bounds);
                NSRect nsBounds = NSMakeRect((CGFloat)bounds.Left().value,
                                             (CGFloat)bounds.Top().value,
                                             (CGFloat)bounds.Width().value,
                                             (CGFloat)bounds.Height().value);
                [nsWindow setFrame:nsBounds  display:YES];
            }
            
            void CocoaWindow::HandleEventInternal(NSEvent* event)
            {
                switch([event type])
                {
                    case NSEventTypeCursorUpdate:
//                        SetWindowCursor(currentCursor);
                        break;
                        
                    case NSEventTypeLeftMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        if(event.clickCount == 2)
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->LeftButtonDoubleClick(info);
                            }
                        }
                        else
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->LeftButtonDown(info);
                            }
                            
                            mouseDownX = [NSEvent mouseLocation].x;
                            mouseDownY = [NSEvent mouseLocation].y;
                            
                            if(customFrameMode)
                            {
                                HitTestMouseDown(info.x, info.y);
                            }
                        }
                        break;
                    }
                        
                    case NSEventTypeLeftMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->LeftButtonUp(info);
                        }
                        
                        if(customFrameMode)
                        {
                            HitTestMouseUp(info.x, info.y);
                        }
                        break;
                    }
                        
                    case NSEventTypeRightMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        if(event.clickCount == 2)
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->RightButtonDoubleClick(info);
                            }
                        }
                        else
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->RightButtonDown(info);
                            }
                        }
                        break;
                    }
                        
                    case NSEventTypeRightMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->RightButtonUp(info);
                        }
                        break;
                    }
                        
                    case NSEventTypeMouseMoved:
                    case NSEventTypeLeftMouseDragged:
                    case NSEventTypeRightMouseDragged:
                    case NSEventTypeOtherMouseDragged:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        info.nonClient = !mouseHoving;
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseMoving(info);
                        }
                        mouseLastX = info.x.value;
                        mouseLastY = info.y.value;
                        
                        if(customFrameMode)
                        {
                            if(event.type == NSEventTypeMouseMoved)
                            {
                                if(!resizing)
                                    HitTestMouseMove(mouseLastX, mouseLastY);
                            }
                            
                            if(event.type == NSEventTypeLeftMouseDragged ||
                               event.type == NSEventTypeMouseMoved)
                            {
                                if(resizing)
                                    ResizingDragged();
                                
                                if(moving)
                                    MovingDragged();
                            }
                        }
                        
                        break;
                    }
                        
                    case NSEventTypeMouseEntered:
                    {
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseEntered();
                        }
                        mouseHoving = true;
                        break;
                    }
                        
                    case NSEventTypeMouseExited:
                    {
//                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseLeaved();
                        }
                        mouseHoving = false;
                        break;
                    }
                        
                    case NSEventTypeOtherMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        if(event.clickCount == 2)
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->MiddleButtonDoubleClick(info);
                            }
                        }
                        else
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->MiddleButtonDown(info);
                            }
                        }
                        break;
                    }
                        
                    case NSEventTypeOtherMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MiddleButtonUp(info);
                        }
                        break;
                    }
                        
                    case NSEventTypeScrollWheel:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nsWindow, event);
                        
                        
                        if([event respondsToSelector:@selector(scrollingDeltaY)])
                        {
                            double deltaY;
                            
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
                            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                            {
                                deltaY = [event scrollingDeltaY];
                                
                                if ([event hasPreciseScrollingDeltas])
                                {
                                    deltaY *= 0.2;
                                }
                            }
                            else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
                            {
                                deltaY = [event deltaY];
                            }
                            
                            info.wheel = (int)deltaY;
                            
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->VerticalWheel(info);
                            }
                            break;
                        }
                        
                        if([event respondsToSelector:@selector(scrollingDeltaX)])
                        {
                            double deltaX;
                            
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
                            if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                            {
                                deltaX = [event scrollingDeltaY];
                                
                                if ([event hasPreciseScrollingDeltas])
                                {
                                    deltaX *= 0.2;
                                }
                            }
                            else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
                            {
                                deltaX = [event deltaY];
                            }
                            
                            info.wheel = (int)deltaX;
                            
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->HorizontalWheel(info);
                            }
                            break;
                        }

                    }
                        
                    case NSEventTypeKeyDown:
                    {
                        NativeWindowKeyInfo info = CreateKeyInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->KeyDown(info);
                        }
                        
                        NativeWindowCharInfo charInfo{};
                        if(GetCocoaInputService()->ConvertToPrintable(charInfo, event))
                        {
                            for(vint i=0; i<listeners.Count(); ++i)
                            {
                                listeners[i]->Char(charInfo);
                            }
                        }
                        break;
                    }
                        
                    case NSEventTypeKeyUp:
                    {
                        NativeWindowKeyInfo info = CreateKeyInfo(nsWindow, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->KeyUp(info);
                        }
                        break;
                    }
                        
                    case NSEventTypeFlagsChanged: // modifier flags
                        break;
                        
                    default:
                        break;
                }
            }
            
            void CocoaWindow::DragEntered()
            {
                
            }
            
            void CocoaWindow::PrepareDrag()
            {
                
            }
            
            void CocoaWindow::PerformFileDrag(const vl::collections::List<WString>& files)
            {
                for(vint i=0; i<draggingListeners.Count(); ++i)
                {
                    draggingListeners[i]->PerformFileDrag(files);
                }
            }
            
            void CocoaWindow::ConcludeDrag()
            {
                
            }
            
            void CocoaWindow::InstallDraggingListener(IDraggingListener* listener)
            {
                draggingListeners.Add(listener);
            }
            
            void CocoaWindow::UninstallDraggingListener(IDraggingListener* listener)
            {
                draggingListeners.Remove(listener);
            }

            NativeMargin CocoaWindow::GetCustomFramePadding()
            {
                if (GetSizeBox() || GetTitleBar())
                {
                    return customFramePadding;
                }
                else
                {
                    return NativeMargin(0, 0, 0, 0);
                }
            }

            Ptr<GuiImageData> CocoaWindow::GetIcon()
            {
                return Ptr<GuiImageData>();
            }

            void CocoaWindow::SetIcon(Ptr<GuiImageData> icon)
            {
            }

            Point CocoaWindow::Convert(NativePoint value)
            {
                return Point(value.x.value, value.y.value);
            }

            NativePoint CocoaWindow::Convert(Point value)
            {
                return NativePoint(value.x, value.y);
            }

            Size CocoaWindow::Convert(NativeSize value)
            {
                return Size(value.x.value, value.y.value);
            }

            NativeSize CocoaWindow::Convert(Size value)
            {
                return NativeSize(value.x, value.y);
            }

            Margin CocoaWindow::Convert(NativeMargin value)
            {
                return Margin(value.left.value, value.top.value, value.right.value, value.bottom.value);
            }

            NativeMargin CocoaWindow::Convert(Margin value)
            {
                return NativeMargin(value.left, value.top, value.right, value.bottom);
            }
        }
    }
}



@implementation CocoaNSWindow

- (BOOL)canBecomeKeyWindow
{
    // NSPanel
    return (self.parentWindow != nil) ? (self.styleMask & NSWindowStyleMaskBorderless): YES;
}

- (BOOL)canBecomeMainWindow
{
    return self.parentWindow == nil;
}


@end

@implementation CocoaWindowDelegate
{

}

- (id)initWithNativeWindow:(INativeWindow*)window
{
    if(self = [super init])
    {
        _nativeWindow = window;
        _sizeState = vl::presentation::INativeWindow::Restored;
    }
    return self;
}

- (void)reset
{

}

- (void)windowDidChangeBackingProperties:(NSNotification *)notification
{
    
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

- (void)windowDidMove:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeMoved();
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeGotFocus();
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeAcivate();
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeLostFocus();
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeDeactivate();
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
}

- (void)windowDidResignMain:(NSNotification *)notification
{
}

- (BOOL)windowShouldClose:(id)sender
{
    // !cancel
    return !(dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeClosing();
}

- (void)windowWillClose:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeClosed();
}

- (void)windowDidResize:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeMoved();
}

@end
