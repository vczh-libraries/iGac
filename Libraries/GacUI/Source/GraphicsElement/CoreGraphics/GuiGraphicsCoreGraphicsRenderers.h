//
//  CoreGraphicsRenderer.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COREGRAPHICS_RENDERER_H__
#define __GAC_OSX_COREGRAPHICS_RENDERER_H__

#include "../GuiGraphicsElement.h"
#include "../../GraphicsComposition/GuiGraphicsComposition.h"

#include "GuiGraphicsCoreGraphics.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            using namespace elements;
            
#define DEFINE_ELEMENT_RENDERER(TELEMENT, TRENDERER, TBRUSHPROPERTY)\
    DEFINE_GUI_GRAPHICS_RENDERER(TELEMENT, TRENDERER, ICoreGraphicsRenderTarget)\
            public:\
            TRENDERER();\
            void    Render(Rect bounds) override;\
            void    OnElementStateChanged() override;\
            void    InitializeInternal();\
            void    FinalizeInternal();\
            void    RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);\

            
            class GuiSolidBorderElementRenderer : public Object, public IGuiGraphicsRenderer
            {
                DEFINE_ELEMENT_RENDERER(GuiSolidBorderElement, GuiSolidBorderElementRenderer, Color)
            };
            
            class GuiRoundBorderElementRenderer : public Object, public IGuiGraphicsRenderer
            {
                DEFINE_ELEMENT_RENDERER(GuiRoundBorderElement, GuiRoundBorderElementRenderer, Color)
            };
            
            class GuiSolidBackgroundElementRenderer : public Object, public IGuiGraphicsRenderer
            {
                DEFINE_ELEMENT_RENDERER(GuiSolidBackgroundElement, GuiSolidBackgroundElementRenderer, Color)
            };
            
            class GuiGradientBackgroundElementRenderer : public Object, public IGuiGraphicsRenderer
            {
                typedef collections::Pair<Color, Color> ColorPair;
                DEFINE_ELEMENT_RENDERER(GuiGradientBackgroundElement, GuiGradientBackgroundElementRenderer, ColorPair)
            };
            
            class GuiSolidLabelElementRenderer : public Object, public IGuiGraphicsRenderer
            {
                DEFINE_GUI_GRAPHICS_RENDERER(GuiSolidLabelElement, GuiSolidLabelElementRenderer, ICoreGraphicsRenderTarget)
                
            protected:
                Color                       oldColor;
                FontProperties              oldFont;
                WString                     oldText;
                vint                        oldMaxWidth;
                
                NSString*                   nsText;
                NSFont*                     nsFont;
                NSMutableDictionary*        nsAttributes;
                NSMutableParagraphStyle*    nsParagraphStyle;
             
                void CreateFont();
                void CreateColor();
                void UpdateParagraphStyle();
                void UpdateMinSize();
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                GuiSolidLabelElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            
            class FontNotFoundException: public Exception
            {
            public:
                FontNotFoundException(const WString& _message=WString::Empty):
                    Exception(_message)
                {
                    
                }
            };
            
        }

    }

}

#endif