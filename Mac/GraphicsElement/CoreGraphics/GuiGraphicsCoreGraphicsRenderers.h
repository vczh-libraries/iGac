//
//  CoreGraphicsRenderer.h
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COREGRAPHICS_RENDERER_H__
#define __GAC_OSX_COREGRAPHICS_RENDERER_H__

#include "GuiGraphicsCoreGraphics.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            // this is actually higher level stuff
            // real CTFont stuff to do
            class CoreTextFontPackage
            {
            public:
                __unsafe_unretained NSFont*                 font;
                __unsafe_unretained NSMutableDictionary*    attributes;
                
                
                void Retain()
                {
                    CFRetain(attributes);
                    CFRetain(font);
                }
                
                void Release()
                {
                    CFRelease(attributes);
                    CFRelease(font);
                }
                
            };
            
            
            using namespace elements;
            
#define DEFINE_ELEMENT_RENDERER(TELEMENT, TRENDERER, TBRUSHPROPERTY)\
            public:\
                TRENDERER();\
                void    Render(Rect bounds) override;\
                void    OnElementStateChanged() override;\
                void    InitializeInternal();\
                void    FinalizeInternal();\
                void    RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);\

            
            class GuiSolidBorderElementRenderer : public GuiElementRendererBase<GuiSolidBorderElement, GuiSolidBorderElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiSolidBorderElement, GuiSolidBorderElementRenderer, ICoreGraphicsRenderTarget>;
                DEFINE_ELEMENT_RENDERER(GuiSolidBorderElement, GuiSolidBorderElementRenderer, Color)
            };

            class GuiSolidBackgroundElementRenderer : public GuiElementRendererBase<GuiSolidBackgroundElement, GuiSolidBackgroundElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiSolidBackgroundElement, GuiSolidBackgroundElementRenderer, ICoreGraphicsRenderTarget>;
                DEFINE_ELEMENT_RENDERER(GuiSolidBackgroundElement, GuiSolidBackgroundElementRenderer, Color)
            };
            
            class GuiGradientBackgroundElementRenderer : public GuiElementRendererBase<GuiGradientBackgroundElement, GuiGradientBackgroundElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiGradientBackgroundElement, GuiGradientBackgroundElementRenderer, ICoreGraphicsRenderTarget>;

                typedef collections::Pair<Color, Color> ColorPair;
                DEFINE_ELEMENT_RENDERER(GuiGradientBackgroundElement, GuiGradientBackgroundElementRenderer, ColorPair)
                
                virtual ~GuiGradientBackgroundElementRenderer();
                
            protected:
                collections::Pair<Color, Color>     oldColor;
                CGGradientRef                       cgGradient;
                CGColorSpaceRef                     cgColorSpace;
                
                void CreateCGGradient();
            };
            
            class GuiSolidLabelElementRenderer : public GuiElementRendererBase<GuiSolidLabelElement, GuiSolidLabelElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiSolidLabelElement, GuiSolidLabelElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                Color                       oldColor;
                FontProperties              oldFont;
                WString                     oldText;
                vint                        oldMaxWidth;
                
                __unsafe_unretained NSString*                   nsText;
                __unsafe_unretained NSMutableParagraphStyle*    nsParagraphStyle;
                __unsafe_unretained NSMutableDictionary*        nsAttributes;
                Ptr<CoreTextFontPackage>                        coreTextFont;
             
                void CreateFont();
                void CreateColor();
                void UpdateParagraphStyle();
                void UpdateMinSize();
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                GuiSolidLabelElementRenderer();
                ~GuiSolidLabelElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class GuiPolygonElementRenderer: public GuiElementRendererBase<GuiPolygonElement, GuiPolygonElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiPolygonElement, GuiPolygonElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                collections::Array<Point>   oldPoints;
                
                CGMutablePathRef            cgBorderPath;
                CGMutablePathRef            cgBackgroundPath;
                CGColorSpaceRef             cgColorSpace;
                
                void CreateGeometry();
                void DestroyGeometry();
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                GuiPolygonElementRenderer();
                ~GuiPolygonElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class GuiImageFrameElementRenderer : public GuiElementRendererBase<GuiImageFrameElement, GuiImageFrameElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiImageFrameElement, GuiImageFrameElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                GuiImageFrameElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class GuiColorizedTextElementRenderer : public GuiElementRendererBase<GuiColorizedTextElement, GuiColorizedTextElementRenderer, ICoreGraphicsRenderTarget>, public GuiColorizedTextElement::ICallback
            {
                friend class GuiElementRendererBase<GuiColorizedTextElement, GuiColorizedTextElementRenderer, ICoreGraphicsRenderTarget>;
                
            public:
                struct ColorItemResource
                {
                    Color   text;
                    Color   background;
                };
                
                struct ColorEntryResource
                {
                    ColorItemResource			normal;
                    ColorItemResource			selectedFocused;
                    ColorItemResource			selectedUnfocused;
                    
                    bool						operator==(const ColorEntryResource& value){return false;}
                    bool						operator!=(const ColorEntryResource& value){return true;}
                };
                
                typedef collections::Array<ColorEntryResource>			ColorArray;
                
            protected:
                Ptr<CoreTextFontPackage>        coreTextFont;
                FontProperties                  oldFont;
                ColorArray                      colors;
                __unsafe_unretained NSMutableDictionary*            nsAttributes;
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
                void ColorChanged() override;
                void FontChanged() override;
                
            public:
                GuiColorizedTextElementRenderer();
                ~GuiColorizedTextElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class Gui3DBorderElementRenderer : public GuiElementRendererBase<Gui3DBorderElement, Gui3DBorderElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<Gui3DBorderElement, Gui3DBorderElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                Gui3DBorderElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class Gui3DSplitterElementRenderer : public GuiElementRendererBase<Gui3DSplitterElement, Gui3DSplitterElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<Gui3DSplitterElement, Gui3DSplitterElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
                
            public:
                Gui3DSplitterElementRenderer();
                
                void Render(Rect bounds) override;
                void OnElementStateChanged() override;
            };
            
            class GuiCoreGraphicsElementRenderer : public GuiElementRendererBase<GuiCoreGraphicsElement, GuiCoreGraphicsElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiCoreGraphicsElement, GuiCoreGraphicsElementRenderer, ICoreGraphicsRenderTarget>;
                
            protected:
                
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
            public:
                GuiCoreGraphicsElementRenderer();
                ~GuiCoreGraphicsElementRenderer();
                
                void Render(Rect bounds)override;
                void OnElementStateChanged()override;
            };

            class GuiInnerShadowElementRenderer : public GuiElementRendererBase<GuiInnerShadowElement, GuiInnerShadowElementRenderer, ICoreGraphicsRenderTarget>
            {
            friend class GuiElementRendererBase<GuiInnerShadowElement, GuiInnerShadowElementRenderer, ICoreGraphicsRenderTarget>;

            protected:
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
            public:
                GuiInnerShadowElementRenderer();
                ~GuiInnerShadowElementRenderer();

                void Render(Rect bounds)override;
                void OnElementStateChanged()override;
            };

            class GuiFocusRectangleElementRenderer : public GuiElementRendererBase<GuiFocusRectangleElement, GuiFocusRectangleElementRenderer, ICoreGraphicsRenderTarget>
            {
                friend class GuiElementRendererBase<GuiFocusRectangleElement, GuiFocusRectangleElementRenderer, ICoreGraphicsRenderTarget>;

            protected:
                void InitializeInternal();
                void FinalizeInternal();
                void RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget);
            public:
                GuiFocusRectangleElementRenderer();
                ~GuiFocusRectangleElementRenderer();

                void Render(Rect bounds)override;
                void OnElementStateChanged()override;
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