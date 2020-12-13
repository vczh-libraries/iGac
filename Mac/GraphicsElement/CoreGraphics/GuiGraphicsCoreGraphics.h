//
//  GuiGraphicsCoreGraphics.h
//  GacOSX
//
//  Created by Robert Bu on 12/4/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_GUIGRAPHICS_COREGRAPHICS_H__
#define __GAC_OSX_GUIGRAPHICS_COREGRAPHICS_H__

#include "GacUI.h"

typedef struct CGContext *CGContextRef;

namespace vl {
    
    namespace presentation {
        
        namespace elements {
            
            class GuiCoreGraphicsElement;
            
            struct GuiCoreGraphicsElementEventArgs : compositions::GuiEventArgs
            {
            public:
                GuiCoreGraphicsElement*				element;
                Rect                                bounds;
                CGContextRef                        context;
                
                GuiCoreGraphicsElementEventArgs(GuiCoreGraphicsElement* _element, Rect _bounds, CGContextRef _context):
                    element(_element),
                    bounds(_bounds),
                    context(_context)
                {
                }
            };
            
            class GuiCoreGraphicsElement : public GuiElementBase<GuiCoreGraphicsElement>
            {
                DEFINE_GUI_GRAPHICS_ELEMENT(GuiCoreGraphicsElement, L"CoreGraphicsElement")
                
            protected:
                GuiCoreGraphicsElement();
                
            public:
                ~GuiCoreGraphicsElement();
                
                compositions::GuiGraphicsEvent<GuiCoreGraphicsElementEventArgs>		BeforeRenderTargetChanged;
                
                compositions::GuiGraphicsEvent<GuiCoreGraphicsElementEventArgs>		AfterRenderTargetChanged;
                
                compositions::GuiGraphicsEvent<GuiCoreGraphicsElementEventArgs>		Rendering;
            };
            
        }
        
        namespace elements_coregraphics {
            
            using namespace elements;
            
            class ICoreGraphicsRenderTarget : public elements::IGuiGraphicsRenderTarget
            {
            public:
                virtual CGContextRef GetCGContext() const = 0;
            };
            
            
            class ICoreGrpahicsObjectProvider : public Interface
            {
            public:
                virtual void								RecreateRenderTarget(INativeWindow* window) = 0;
                virtual ICoreGraphicsRenderTarget*			GetNativeCoreGraphicsRenderTarget(INativeWindow* window) = 0;
                virtual ICoreGraphicsRenderTarget*          GetBindedRenderTarget(INativeWindow* window) = 0;
                virtual void								SetBindedRenderTarget(INativeWindow* window, ICoreGraphicsRenderTarget* renderTarget) = 0;
            };
            
            class CoreTextFontPackage;
           
            
            class ICoreGraphicsResourceManager: public Interface
            {
            public:
                virtual Ptr<elements::text::CharMeasurer>   CreateCharMeasurer(const FontProperties& fontProperties) = 0;
                virtual void                                DestroyCharMeasurer(const FontProperties& fontProperties) = 0;
                
                virtual Ptr<CoreTextFontPackage>            CreateCoreTextFont(const FontProperties& fontProperties) = 0;
                virtual void                                DestroyCoreTextFont(const FontProperties& fontProperties) = 0;
                
            };
            
            
            extern ICoreGrpahicsObjectProvider*			GetCoreGraphicsObjectProvider();
            extern void									SetCoreGraphicsObjectProvider(ICoreGrpahicsObjectProvider* provider);
            
            extern void                                 SetCurrentRenderTarget(ICoreGraphicsRenderTarget* renderTarget);
            extern ICoreGraphicsRenderTarget*           GetCurrentRenderTarget();
            
            extern ICoreGraphicsResourceManager*        GetCoreGraphicsResourceManager();
        }
        
    }
    
}

#endif
