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
#include "ServicesImpl/CocoaResourceService.h"

using namespace vl::presentation;

@interface CocoaWindowDelegate : NSObject<NSWindowDelegate>

@property (nonatomic, readonly) INativeWindow::WindowSizeState sizeState;
@property (assign) INativeWindow* nativeWindow;

- (id)initWithNativeWindow:(INativeWindow*)window;

@end

@interface CocoaNSWindow : NSWindow


@end

@implementation CocoaNSWindow

- (BOOL)canBecomeKeyWindow
{
    return YES;
}

- (BOOL)canBecomeMainWindow
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    return YES;
}

- (BOOL)becomeFirstResponder
{
    return YES;
}

- (BOOL)resignFirstResponder
{
    return YES;
}

@end

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            CocoaWindow::CocoaWindow():
                nativeContainer(0),
                parentWindow(0),
                alwaysPassFocusToParent(false),
                mouseLastX(0),
                mouseLastY(0),
                mouseHoving(false),
                graphicsHandler(0),
                customFrameMode(false),
                supressingAlt(false),
                enabled(false)
            {
                CreateWindow();
                
                InitKeyNameMappings();
            }
            
            CocoaWindow::~CocoaWindow()
            {
                if(nativeContainer)
                {
                    [nativeContainer->window close];
                    delete nativeContainer;
                }
            }
            
            void CocoaWindow::CreateWindow()
            {
                NSUInteger windowStyle = NSTitledWindowMask | NSClosableWindowMask | NSMiniaturizableWindowMask | NSResizableWindowMask;
                
                NSRect windowRect = NSMakeRect(0, 0, 0, 0);
                
                NSWindow* window = [[CocoaNSWindow alloc] initWithContentRect:windowRect
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
                
                currentCursor = GetCurrentController()->ResourceService()->GetDefaultSystemCursor();
            }
            
            Rect CocoaWindow::GetBounds()
            {
                NSRect nsbounds = [nativeContainer->window frame];
                
                return FlipRect(nativeContainer->window,
                                Rect(nsbounds.origin.x,
                                     nsbounds.origin.y,
                                     nsbounds.size.width + nsbounds.origin.x,
                                     nsbounds.size.height + nsbounds.origin.y));
            }

            void CocoaWindow::SetBounds(const Rect& bounds) 
            {
                Rect newBounds = bounds;
                for(vint i=0; i<listeners.Count(); ++i)
                {
                    listeners[i]->Moving(newBounds, true);
                }
                NSRect nsbounds = NSMakeRect(newBounds.Left(),
                                             FlipY(nativeContainer->window, newBounds.Bottom()),
                                             newBounds.Width(),
                                             newBounds.Height());
                
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
                NSRect contentFrame = [nativeContainer->window convertRectToScreen:[nativeContainer->window.contentView frame]];
                
                if(!([nativeContainer->window screen]))
                    contentFrame = [nativeContainer->window frame];
                
                return FlipRect(nativeContainer->window,
                                Rect(contentFrame.origin.x,
                                     contentFrame.origin.y,
                                     contentFrame.size.width + contentFrame.origin.x,
                                     contentFrame.size.height + contentFrame.origin.y));
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
                return currentCursor;
            }

            void CocoaWindow::SetWindowCursor(INativeCursor* cursor) 
            {
                currentCursor = cursor;
                
                dynamic_cast<CocoaCursor*>(cursor)->Set();
                
                [nativeContainer->window invalidateCursorRectsForView:nativeContainer->window.contentView];
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
                CocoaWindow* cocoaParent = dynamic_cast<CocoaWindow*>(parent);
                if(!cocoaParent)
                {
                    if(parentWindow)
                        [parentWindow->GetNativeContainer()->window removeChildWindow:nativeContainer->window];
                }
                else
                {
                    [cocoaParent->GetNativeContainer()->window addChildWindow:nativeContainer->window ordered:NSWindowAbove];
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
                [nativeContainer->window makeKeyAndOrderFront:nil];
            }

            void CocoaWindow::ShowDeactivated() 
            {
              //  [nativeContainer->window orderOut:nil];
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
                // HidesOnDeactivate
                [nativeContainer->window orderOut:nil];
            }

            bool CocoaWindow::IsVisible() 
            {
                return [nativeContainer->window isMainWindow] && [nativeContainer->window isVisible];
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
                
                [[nativeContainer->window standardWindowButton:NSWindowZoomButton] setHidden:!visible];
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
                
                [[nativeContainer->window standardWindowButton:NSWindowMiniaturizeButton] setHidden:!visible];
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
                    styleMask ^= NSBorderlessWindowMask;
                else
                    styleMask = NSBorderlessWindowMask;
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
                [nativeContainer->window.contentView setNeedsDisplay:YES];
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
            
            NSContainer* GetNSNativeContainer(INativeWindow* window)
            {
                return (dynamic_cast<CocoaWindow*>(window))->GetNativeContainer();
            }
            
            NativeWindowMouseInfo CreateMouseInfo(NSWindow* window, NSEvent* event)
            {
                NativeWindowMouseInfo info;
                
                if(event.type == NSScrollWheel && [event respondsToSelector:@selector(scrollingDeltaY)])
                {
                    double deltaY;
                    
#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
                    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
                    {
                        deltaY = [event scrollingDeltaY];
                        
                        if ([event hasPreciseScrollingDeltas])
                        {
                            deltaY *= 0.1;
                        }
                    }
                    else
#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
                    {
                        deltaY = [event deltaY];
                    }
                    
                    info.wheel = (int)deltaY;
                }
                
                info.left = event.type == NSLeftMouseDown;
                info.right = event.type == NSRightMouseDown;
                // assuming its middle mouse
                info.middle = (event.type == NSOtherMouseDown);
                
                info.ctrl = event.modifierFlags & NSControlKeyMask;
                info.shift = event.modifierFlags & NSShiftKeyMask;
                
                const NSRect contentRect = [window.contentView frame];
                const NSPoint p = [event locationInWindow];
                
                info.x = p.x;
                info.y = contentRect.size.height - p.y;
                
                return info;
            }
            
            NativeWindowKeyInfo CreateKeyInfo(NSWindow* window, NSEvent* event)
            {
                NativeWindowKeyInfo info;
             
                info.ctrl = event.modifierFlags & NSControlKeyMask;
                info.shift = event.modifierFlags & NSShiftKeyMask;
                info.alt = event.modifierFlags & NSAlternateKeyMask;
                info.capslock = event.modifierFlags & NSAlphaShiftKeyMask;
                
                info.code = NSEventKeyCodeToGacKeyCode(event.keyCode);
                
                return info;
            }
            
            void CocoaWindow::InitKeyNameMappings()
            {
                asciiLowerMap[VKEY_0] = '0';
                asciiLowerMap[VKEY_0] = '1';
                asciiLowerMap[VKEY_2] = '2';
                asciiLowerMap[VKEY_3] = '3';
                asciiLowerMap[VKEY_4] = '4';
                asciiLowerMap[VKEY_5] = '5';
                asciiLowerMap[VKEY_6] = '6';
                asciiLowerMap[VKEY_7] = '7';
                asciiLowerMap[VKEY_8] = '8';
                asciiLowerMap[VKEY_9] = '9';
                asciiLowerMap[VKEY_OEM_1] = ';';
                asciiLowerMap[VKEY_OEM_6] = '[';
                asciiLowerMap[VKEY_OEM_4] = ']';
                asciiLowerMap[VKEY_OEM_7] = '\'';
                asciiLowerMap[VKEY_OEM_COMMA] = ',';
                asciiLowerMap[VKEY_OEM_PERIOD] = '.';
                asciiLowerMap[VKEY_OEM_2] = '/';
                asciiLowerMap[VKEY_OEM_5] = '\\';
                asciiLowerMap[VKEY_OEM_MINUS] = '-';
                asciiLowerMap[VKEY_OEM_PLUS] = '=';
                asciiLowerMap[VKEY_OEM_3] = '`';
                asciiLowerMap[VKEY_SPACE] = ' ';
                for(int i=VKEY_A; i<=VKEY_Z; ++i)
                    asciiLowerMap[i] = 'a' + (i-VKEY_A);
                for(int i=VKEY_NUMPAD0; i<VKEY_NUMPAD9; ++i)
                    asciiLowerMap[i] = '0' + (i-VKEY_NUMPAD0);
                
                
                asciiUpperMap[VKEY_0] = ')';
                asciiUpperMap[VKEY_1] = '!';
                asciiUpperMap[VKEY_2] = '@';
                asciiUpperMap[VKEY_3] = '#';
                asciiUpperMap[VKEY_4] = '$';
                asciiUpperMap[VKEY_5] = '%';
                asciiUpperMap[VKEY_6] = '^';
                asciiUpperMap[VKEY_7] = '&';
                asciiUpperMap[VKEY_8] = '*';
                asciiUpperMap[VKEY_9] = '(';
                asciiUpperMap[VKEY_OEM_1] = ':';
                asciiUpperMap[VKEY_OEM_6] = '{';
                asciiUpperMap[VKEY_OEM_4] = '}';
                asciiUpperMap[VKEY_OEM_7] = '\"';
                asciiUpperMap[VKEY_OEM_COMMA] = '<';
                asciiUpperMap[VKEY_OEM_PERIOD] = '>';
                asciiUpperMap[VKEY_OEM_2] = '?';
                asciiUpperMap[VKEY_OEM_5] = '|';
                asciiUpperMap[VKEY_OEM_MINUS] = '_';
                asciiUpperMap[VKEY_OEM_PLUS] = '+';
                asciiUpperMap[VKEY_OEM_3] = '~';
                asciiUpperMap[VKEY_SPACE] = ' ';
                for(int i=VKEY_A; i<=VKEY_Z; ++i)
                    asciiUpperMap[i] = 'A' + (i-VKEY_A);
                for(int i=VKEY_NUMPAD0; i<VKEY_NUMPAD9; ++i)
                    asciiLowerMap[i] = '0' + (i-VKEY_NUMPAD0);
            }
            
            bool CocoaWindow::ConvertToPrintable(NativeWindowCharInfo& info, NSEvent* event)
            {
                info.ctrl = event.modifierFlags & NSControlKeyMask;
                info.shift = event.modifierFlags & NSShiftKeyMask;
                info.alt = event.modifierFlags & NSAlternateKeyMask;
                info.capslock = event.modifierFlags & NSAlphaShiftKeyMask;
                
                if(info.ctrl || info.alt)
                    return false;
                
                vint code = NSEventKeyCodeToGacKeyCode(event.keyCode);
                if(code >= 256)
                    return false;
                
                if(info.capslock || info.shift) {
                    return asciiUpperMap[code];
                }
                return asciiLowerMap[code];
            }
            
            void CocoaWindow::InsertText(const WString& str)
            {
                NativeWindowCharInfo info;
                
                unsigned long modifierFlags = [NSEvent modifierFlags];
                info.ctrl = modifierFlags & NSControlKeyMask;
                info.shift = modifierFlags & NSShiftKeyMask;
                info.alt = modifierFlags & NSAlternateKeyMask;
                info.capslock = modifierFlags & NSAlphaShiftKeyMask;
                
                for(int i=0; i<str.Length(); ++i)
                {
                    info.code = str[i];

                    for(int i=0; i<listeners.Count(); ++i)
                    {
                        listeners[i]->Char(info);
                    }
                }
            }
            
            void CocoaWindow::HandleEventInternal(NSEvent* event)
            {
                switch([event type])
                {
                    case NSCursorUpdate:
//                        SetWindowCursor(currentCursor);
                        break;
                        
                    case NSLeftMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
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
                        }
                        break;
                    }
                        
                    case NSLeftMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->LeftButtonUp(info);
                        }
                        break;
                    }
                        
                    case NSRightMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
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
                        
                    case NSRightMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->RightButtonUp(info);
                        }
                        break;
                    }
                        
                    case NSMouseMoved:
                    case NSLeftMouseDragged:
                    case NSRightMouseDragged:
                    case NSOtherMouseDragged:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        info.nonClient = !mouseHoving;
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseMoving(info);
                        }
                        mouseLastX = info.x;
                        mouseLastY = info.y;
                        break;
                    }
                        
                    case NSMouseEntered:
                    {
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseEntered();
                        }
                        mouseHoving = true;
                        break;
                    }
                        
                    case NSMouseExited:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MouseLeaved();
                        }
                        mouseHoving = false;
                        break;
                    }
                        
                    case NSOtherMouseDown:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
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
                        
                    case NSOtherMouseUp:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->MiddleButtonUp(info);
                        }
                        break;
                    }
                        
                    case NSScrollWheel:
                    {
                        NativeWindowMouseInfo info = CreateMouseInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->HorizontalWheel(info);
                        }
                        break;
                    }
                        
                    case NSKeyDown:
                    {
                        NativeWindowKeyInfo info = CreateKeyInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->KeyDown(info);
                        }
                        break;
                    }
                        
                    case NSKeyUp:
                    {
                        NativeWindowKeyInfo info = CreateKeyInfo(nativeContainer->window, event);
                        
                        for(vint i=0; i<listeners.Count(); ++i)
                        {
                            listeners[i]->KeyUp(info);
                        }
                        break;
                    }
                        
                    case NSFlagsChanged: // modifier flags
                        break;
                        
                    default:
                        break;
                }
            }
        }
    }
}


@implementation CocoaWindowDelegate
{
    bool firstTime;
}

- (id)initWithNativeWindow:(INativeWindow*)window
{
    if(self = [super init])
    {
        _nativeWindow = window;
        _sizeState = vl::presentation::INativeWindow::Restored;
        
        firstTime = true;
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

- (void)windowDidMove:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeMoved();
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
    // this is a hack... but works for now
    if(firstTime)
    {
        (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeOpened();
        firstTime = false;
    }
    
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeGotFocus();
}

- (void)windowDidResignKey:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeLostFocus();
}

- (void)windowDidBecomeMain:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeAcivate();
}

- (void)windowDidResignMain:(NSNotification *)notification
{
    (dynamic_cast<osx::CocoaWindow*>(_nativeWindow))->InvokeDeactivate();

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
