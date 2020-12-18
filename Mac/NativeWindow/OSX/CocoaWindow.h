//
//  OSXObjcWrapper.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_WINDOWS__
#define __GAC_OSX_COCOA_WINDOWS__

#include "GacUI.h"

#include "CocoaPredef.h"

@class NSEvent;
@class CocoaWindowDelegate;
@class NSWindow;
@class NSWindowController;

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaWindow : public Object, public INativeWindow
            {
            protected:
                NativePoint                                     caretPoint;
                CocoaWindow*                                    parentWindow;
                bool                                            alwaysPassFocusToParent;
                collections::List<INativeWindowListener*>       listeners;
                vint                                            mouseLastX;
                vint                                            mouseLastY;
                vint                                            mouseDownX;
                vint                                            mouseDownY;
                vint                                            mouseHoving;
                Interface*                                      graphicsHandler;
                bool                                            customFrameMode;
                bool                                            supressingAlt;
                bool                                            enabled;
                bool                                            capturing;
                bool                                            resizing;
                bool                                            moving;
                bool                                            opened;
                INativeWindowListener::HitTestResult            resizingBorder;
                
                NativeRect                                      lastBorder;
                INativeCursor*                                  currentCursor;
                NativeRect                                      previousBounds;
                NativeMargin						            customFramePadding;

                collections::List<IDraggingListener*>           draggingListeners;
                
                NSWindow*                                       nsWindow;
                NSWindowController*                             nsController;
                CocoaWindowDelegate*                            nsDelegate;
            
            public:
                CocoaWindow();
                virtual ~CocoaWindow();
                
                NSWindow*           GetNativeWindow() const;
                NSWindowController* GetNativeController() const;
                
                void                SetGraphicsHandler(Interface* handelr);
                Interface*          GetGraphicsHandler() const;
                
                // INativeWindow
                
                NativeRect			GetBounds() override;
                void				SetBounds(const NativeRect& bounds) override;
                NativeSize			GetClientSize() override;
                void				SetClientSize(NativeSize size) override;
                NativeRect			GetClientBoundsInScreen() override;
                WString				GetTitle() override;
                void				SetTitle(WString title) override;
                INativeCursor*		GetWindowCursor() override;
                void				SetWindowCursor(INativeCursor* cursor) override;
                NativePoint			GetCaretPoint() override;
                void				SetCaretPoint(NativePoint point) override;
                
                INativeWindow*		GetParent() override;
                void				SetParent(INativeWindow* parent) override;
                bool				GetAlwaysPassFocusToParent() override;
                void				SetAlwaysPassFocusToParent(bool value) override;
                void				EnableCustomFrameMode() override;
                void				DisableCustomFrameMode() override;
                bool				IsCustomFrameModeEnabled() override;
                
                WindowSizeState		GetSizeState() override;
                void				Show() override;
                void				ShowDeactivated() override;
                void				ShowRestored() override;
                void				ShowMaximized() override;
                void				ShowMinimized() override;
                void				Hide(bool closeWindow) override;
                bool				IsVisible() override;
                void				Enable() override;
                void				Disable() override;
                bool				IsEnabled() override;
                void				SetFocus() override;
                bool				IsFocused() override;
                void				SetActivate() override;
                bool				IsActivated() override;
                void				ShowInTaskBar() override;
                void				HideInTaskBar() override;
                bool				IsAppearedInTaskBar() override;
                void				EnableActivate() override;
                void				DisableActivate() override;
                bool				IsEnabledActivate() override;
                
                bool				RequireCapture() override;
                bool				ReleaseCapture() override;
                bool				IsCapturing() override;
                bool				GetMaximizedBox() override;
                void				SetMaximizedBox(bool visible) override;
                bool				GetMinimizedBox() override;
                void				SetMinimizedBox(bool visible) override;
                bool				GetBorder() override;
                void				SetBorder(bool visible) override;
                bool				GetSizeBox() override;
                void				SetSizeBox(bool visible) override;
                bool				GetIconVisible() override;
                void				SetIconVisible(bool visible) override;
                bool				GetTitleBar() override;
                void				SetTitleBar(bool visible) override;
                bool				GetTopMost() override;
                void				SetTopMost(bool topmost) override;
                void				SupressAlt() override;
                bool				InstallListener(INativeWindowListener* listener) override;
                bool				UninstallListener(INativeWindowListener* listener) override;
                void				RedrawContent() override;
                NativeMargin        GetCustomFramePadding() override;
                Ptr<GuiImageData>   GetIcon() override;
                void                SetIcon(Ptr<GuiImageData> icon) override;
                Point               Convert(NativePoint value) override;
                NativePoint         Convert(Point value) override;
                Size                Convert(NativeSize value) override;
                NativeSize          Convert(Size value) override;
                Margin              Convert(NativeMargin value) override;
                NativeMargin        Convert(Margin value) override;

                ///
                void                HandleEventInternal(NSEvent* event);
                void                InvokeClosed();
                void                InvokeOpened();
                bool                InvokeClosing();
                void                InvokeAcivate();
                void                InvokeDeactivate();
                void                InvokeGotFocus();
                void                InvokeLostFocus();
                void                InvokeMoved();
                void                InsertText(const WString& str);
                void                SetResizingBorder(INativeWindowListener::HitTestResult border);
                void                ResizingDragged();
                void                MovingDragged();
                void                HitTestMouseDown(NativeCoordinate x, NativeCoordinate y);
                void                HitTestMouseMove(NativeCoordinate x, NativeCoordinate y);
                void                HitTestMouseUp(NativeCoordinate x, NativeCoordinate y);
                void                DragEntered();
                void                PrepareDrag();
                void                PerformFileDrag(const vl::collections::List<WString>& files);
                void                ConcludeDrag();
                
                void                InstallDraggingListener(IDraggingListener* listener);
                void                UninstallDraggingListener(IDraggingListener* listener);

            protected:
                void                CreateWindow();
    
            };
            
            extern NSWindow* GetNativeWindow(INativeWindow* window);
            
        }
        
    }
    
}

#endif
