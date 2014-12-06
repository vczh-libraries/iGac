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
                CGContextSetRGBFillColor(context, c.r/255.0f, c.g/255.0f, c.b/255.0f, c.a/255.0f);
                
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
            
            GuiSolidLabelElementRenderer::GuiSolidLabelElementRenderer():
            oldText(L""),
            oldMaxWidth(-1)
            {
                nsParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
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
                
                nsAttributes = [NSMutableDictionary dictionaryWithDictionary:@{ NSFontAttributeName: nsFont }];
                
                if(font.underline)
                {
                    [nsAttributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSUnderlineStyleAttributeName];
                }
                
                if(font.strikeline)
                {
                    [nsAttributes setObject:[NSNumber numberWithInt:NSUnderlineStyleSingle] forKey:NSStrikethroughStyleAttributeName];
                }
                
                [nsAttributes setObject:nsParagraphStyle forKey:NSParagraphStyleAttributeName];
                CreateColor();
            }
            
            void GuiSolidLabelElementRenderer::CreateColor()
            {
                Color color = element->GetColor();
                [nsAttributes setObject:[NSColor colorWithRed:color.r/255.0f green:color.g/255.0f blue:color.b/255.0f alpha:color.a/255.0f]
                                 forKey:NSForegroundColorAttributeName];
            }
            
            void GuiSolidLabelElementRenderer::UpdateParagraphStyle()
            {
                switch(element->GetHorizontalAlignment())
                {
                    case Alignment::Left:
                        [nsParagraphStyle setAlignment:NSLeftTextAlignment];
                        break;
                        
                    case Alignment::Right:
                        [nsParagraphStyle setAlignment:NSRightTextAlignment];
                        break;
                        
                    case Alignment::Center:
                        [nsParagraphStyle setAlignment:NSCenterTextAlignment];
                        break;
                }
                
                if(element->GetEllipse())
                {
                    [nsParagraphStyle setLineBreakMode:NSLineBreakByTruncatingTail];
                }
                else
                {
                    [nsParagraphStyle setLineBreakMode:NSLineBreakByClipping];
                }
            }
            
            void GuiSolidLabelElementRenderer::UpdateMinSize()
            {
                CGRect rect = [nsText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:nsAttributes];
                
                minSize = Size(rect.size.width, rect.size.height);
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
                CreateColor();
                UpdateMinSize();
            }
            
            void GuiSolidLabelElementRenderer::Render(Rect bounds)
            {
                vint x=0;
                vint y=0;
                
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
                
                if(!element->GetEllipse() && !element->GetMultiline() && !element->GetWrapLine())
                {
                    [nsFont set];
                    [nsText drawAtPoint:NSMakePoint(bounds.Left(), bounds.Top())
                         withAttributes:nsAttributes];
                }
                else
                {
                    CGRect textBounds = CGRectMake(bounds.Left(),
                                                   bounds.Top(),
                                                   bounds.Width(),
                                                   bounds.Height());
                    if(element->GetEllipse() && !element->GetMultiline() && !element->GetWrapLine())
                    {
                        textBounds = CGRectMake(textBounds.origin.x, y, bounds.Width(), minSize.y);
                    }
                    
                    [nsText drawInRect:textBounds withAttributes:nsAttributes];
                }
            }
            
            void GuiSolidLabelElementRenderer::OnElementStateChanged()
            {
                if(renderTarget)
                {
                    Color color = element->GetColor();
                    if(oldColor != color)
                    {
                        CreateColor();
                    }
                    
                    FontProperties font = element->GetFont();
                    if(oldFont != font)
                    {
                        CreateFont();
                    }
                }
                
                UpdateParagraphStyle();
                
                oldText = element->GetText();
                nsText = osx::WStringToNSString(element->GetText());
                
                UpdateMinSize();
            }
            
        }
    }
    
}
