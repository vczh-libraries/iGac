//
//  CoreGraphicsRenderer.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsCoreGraphicsRenderers.h"
#include "../../Controls/GuiApplication.h"
#include "../../NativeWindow/OSX/CocoaHelper.h"

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            using namespace osx;
            
#define IMPLEMENT_ELEMENT_RENDERER(TRENDERER)\
    TRENDERER::TRENDERER()\
    {\
    }\
    void TRENDERER::InitializeInternal()\
    {\
    }\
    void TRENDERER::FinalizeInternal()\
    {\
    }\
    void TRENDERER::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)\
    {\
    }\
    void TRENDERER::OnElementStateChanged()\
    {\
    }\
    void TRENDERER::Render(Rect bounds)\

            inline CGContextRef GetCurrentCGContextFromRenderTarget()
            {
                return (CGContextRef)(GetCurrentRenderTarget()->GetCGContext());
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBackgroundElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                Color c = element->GetColor();
                CGContextSetRGBFillColor(context, c.r, c.g, c.b, c.a);
                
                CGRect rect = CGRectMake(bounds.Left(), bounds.Top(), bounds.Width(), bounds.Height());
                CGContextFillRect(context, rect);
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBorderElementRenderer)
            {
                
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiRoundBorderElementRenderer)
            {
                
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiGradientBackgroundElementRenderer)
            {
                
            }
            
            void GuiSolidLabelElementRenderer::CreateFont()
            {
                FontProperties font = element->GetFont();
                
                NSFontManager* fontManager = [NSFontManager sharedFontManager];
                
                NSFontTraitMask traitMask = 0;
                if(font.bold)
                    traitMask |= NSBoldFontMask;
                if(font.italic)
                    traitMask |= NSItalicFontMask;
                
                nsFont = [fontManager fontWithFamily:WStringToNSString(font.fontFamily)
                                              traits:traitMask
                                              weight:0
                                                size:font.size];
                
                // this is just a pretty naive fall back here
                // but its safe to assume that this is availabe in every OS X
                if(!nsFont)
                {
                    nsFont = [fontManager fontWithFamily:@"Lucida Grande" traits:traitMask weight:0 size:font.size];
                }
                
                if(!nsFont)
                {
                    throw FontNotFoundException(L"Font " + font.fontFamily + L" cannot be found.");
                }
                    
            }
            
            void GuiSolidLabelElementRenderer::InitializeInternal()
            {
            }
            
            void GuiSolidLabelElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiSolidLabelElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                CreateFont();
            }
            
            GuiSolidLabelElementRenderer::GuiSolidLabelElementRenderer():
                oldText(L""),
                oldMaxWidth(-1)
            {
            }
            
            void GuiSolidLabelElementRenderer::Render(Rect bounds)
            {
                vint x=0;
                vint y=0;
                switch(element->GetHorizontalAlignment())
                {
                    case Alignment::Left:
                        x=bounds.Left();
                        break;
                    case Alignment::Center:
                        x=bounds.Left()+(bounds.Width()-minSize.x)/2;
                        break;
                    case Alignment::Right:
                        x=bounds.Right()-minSize.x;
                        break;
                }
                switch(element->GetVerticalAlignment())
                {
                    case Alignment::Top:
                        y=bounds.Top();
                        break;
                    case Alignment::Center:
                        y=bounds.Top()+(bounds.Height()-minSize.y)/2;
                        break;
                    case Alignment::Bottom:
                        y=bounds.Bottom()-minSize.y;
                        break;
                }
                
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                Color c = element->GetColor();
                CGFloat components[] = { static_cast<CGFloat>(c.r), static_cast<CGFloat>(c.g), static_cast<CGFloat>(c.b), static_cast<CGFloat>(c.a) };
                CGContextSetFillColor(context, components);
                
                if(!element->GetEllipse() && !element->GetMultiline() && !element->GetWrapLine())
                {
                    [nsFont set];
                    [nsText drawAtPoint:NSMakePoint(bounds.Left(), bounds.Top())
                         withAttributes:@{ NSFontAttributeName: nsFont }];
                }
                else
                {
                    // ct requires here
                    // todo
                }
            }
            
            void GuiSolidLabelElementRenderer::OnElementStateChanged()
            {
                if(renderTarget)
                {
                    Color color = element->GetColor();
                    if(oldColor != color)
                    {
                        
                    }
                    
                    FontProperties font = element->GetFont();
                    if(oldFont != font)
                    {
                        CreateFont();
                    }
                }
                oldText = element->GetText();
                nsText = osx::WStringToNSString(element->GetText());
            }
            
        }
    }
    
}
