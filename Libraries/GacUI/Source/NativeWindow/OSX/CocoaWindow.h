//
//  OSXObjcWrapper.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_OBJC_WRAPPER__
#define __GAC_OSX_OBJC_WRAPPER__

#include "../GuiNativeWindow.h"

#include "OSXPredef.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaWindow;
            
            class CocoaWindow : public Object, public INativeWindow
            {
            protected:
                NSContainer* nativeContainer;
                
                Point                                           caretPoint;
                CocoaWindow*                              parentWindow;
                bool                                            alwaysPassFocusToParent;
                collections::List<INativeWindowListener*>       listeners;
                vint                                            mouseLastX;
                vint                                            mouseLastY;
                vint                                            mouseHoving;
                Interface*                                      graphicsHandler;
                bool                                            customFrameMode;
                bool                                            supressingAlt;
                bool                                            enabled;
                
            protected:
                void _CreateWindow();
                
            public:
                CocoaWindow();
                virtual ~CocoaWindow();
                
                NSContainer* GetNativeContainer() const;
                
                
                // INativeWindow
                
                Rect				GetBounds() override;
                void				SetBounds(const Rect& bounds) override;
                Size				GetClientSize() override;
                void				SetClientSize(Size size) override;
                Rect				GetClientBoundsInScreen() override;
                WString				GetTitle() override;
                void				SetTitle(WString title) override;
                INativeCursor*		GetWindowCursor() override;
                void				SetWindowCursor(INativeCursor* cursor) override;
                Point				GetCaretPoint() override;
                void				SetCaretPoint(Point point) override;
                
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
                void				Hide() override;
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
            };
            
        }
        
    }
    
}

#endif
