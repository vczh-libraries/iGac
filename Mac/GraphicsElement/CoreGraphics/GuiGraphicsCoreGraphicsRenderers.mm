//
//  CoreGraphicsRenderer.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsCoreGraphicsRenderers.h"

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
            
            inline void SetCGContextFillColor(CGContextRef context, const Color& c)
            {
                CGContextSetRGBFillColor(context, c.r/255.0f, c.g/255.0f, c.b/255.0f, c.a/255.0f);
            }
            
            inline void SetCGContextStrokeColor(CGContextRef context, const Color& c)
            {
                CGContextSetRGBStrokeColor(context, c.r/255.0f, c.g/255.0f, c.b/255.0f, c.a/255.0f);
            }
            
            inline CGRect ConvertToCGRect(const Rect& rect, float extends = 0.0f)
            {
                return CGRectMake(rect.Left() - extends, rect.Top() - extends, rect.Width() + extends * 2, rect.Height() + extends * 2);
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBackgroundElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                SetCGContextFillColor(context, element->GetColor());
            
                CGContextFillRect(context, ConvertToCGRect(bounds));
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBorderElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                SetCGContextStrokeColor(context, element->GetColor());
                
                switch(element->GetShape())
                {
                    case ElementShape::Rectangle:
                        CGContextStrokeRect(context, ConvertToCGRect(bounds, -0.5f));
                        break;
                        
                    case ElementShape::Ellipse:
                        CGContextStrokeEllipseInRect(context, ConvertToCGRect(bounds));
                        break;
                }
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiRoundBorderElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                SetCGContextStrokeColor(context, element->GetColor());

                CGRect rect = ConvertToCGRect(bounds, -0.5f);
                CGFloat radius = (CGFloat)element->GetRadius();
                
                CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
                CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
                
                CGContextMoveToPoint(context, minx, midy);
                CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
                CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
                CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
                CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
                CGContextClosePath(context);
                CGContextDrawPath(context, kCGPathFillStroke);
            }
            
            GuiGradientBackgroundElementRenderer::GuiGradientBackgroundElementRenderer():
            cgGradient(0),
            cgColorSpace(0)
            {
                cgColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            }
            
            GuiGradientBackgroundElementRenderer::~GuiGradientBackgroundElementRenderer()
            {
                CGColorSpaceRelease(cgColorSpace);
                if(cgGradient)
                    CGGradientRelease(cgGradient);
            }
            
            
            void GuiGradientBackgroundElementRenderer::InitializeInternal()
            {
                
            }
            
            void GuiGradientBackgroundElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiGradientBackgroundElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                CreateCGGradient();
            }
            
            void GuiGradientBackgroundElementRenderer::Render(Rect bounds)
            {
                CGPoint points[2];
                
                switch(element->GetDirection())
                {
                    case GuiGradientBackgroundElement::Horizontal:
                    {
                        points[0].x = (CGFloat)bounds.x1;
                        points[0].y = (CGFloat)bounds.y1;
                        points[1].x = (CGFloat)bounds.x2;
                        points[1].y = (CGFloat)bounds.y1;
                        break;
                    }
                        
                    case GuiGradientBackgroundElement::Vertical:
                    {
                        points[0].x = (CGFloat)bounds.x1;
                        points[0].y = (CGFloat)bounds.y1;
                        points[1].x = (CGFloat)bounds.x1;
                        points[1].y = (CGFloat)bounds.y2;
                        break;
                    }
                        
                    case GuiGradientBackgroundElement::Slash:
                    {
                        points[0].x = (CGFloat)bounds.x2;
                        points[0].y = (CGFloat)bounds.y1;
                        points[1].x = (CGFloat)bounds.x1;
                        points[1].y = (CGFloat)bounds.y2;
                        break;
                    }
                        
                    case GuiGradientBackgroundElement::Backslash:
                    {
                        points[0].x = (CGFloat)bounds.x1;
                        points[0].y = (CGFloat)bounds.y1;
                        points[1].x = (CGFloat)bounds.x2;
                        points[1].y = (CGFloat)bounds.y2;
                        break;
                    }
                }
                
                CGContextRef context = GetCurrentCGContextFromRenderTarget();

                switch(element->GetShape())
                {
                    case ElementShape::Rectangle:
                        CGContextSaveGState(context);
                        
                        CGContextBeginPath(context);
                        CGContextAddRect(context, ConvertToCGRect(bounds));
                        CGContextClip(context);
                        
                        CGContextDrawLinearGradient(context, cgGradient, points[0], points[1], kCGGradientDrawsBeforeStartLocation);
                        
                        CGContextRestoreGState(context);
                        break;
                        
                    case ElementShape::Ellipse:
                    {
                        CGContextSaveGState(context);
                        
                        CGMutablePathRef path = CGPathCreateMutable();
                        float cx = (bounds.x1 + bounds.x2) / 2,
                              cy = (bounds.y1 + bounds.y2) / 2;
                        
                        CGAffineTransform t = CGAffineTransformMakeTranslation(cx, cy);
                        t = CGAffineTransformConcat(CGAffineTransformMakeScale(1.0, bounds.Height() / bounds.Width()), t);
                        
                        CGPathAddArc(path, &t, 0, 0, bounds.Width()/2, 0, 6.28318531, false);
                        
                        CGContextAddPath(context, path);
                        CGContextClip(context);
                        
                        CGContextDrawLinearGradient(context, cgGradient, points[0], points[1], kCGGradientDrawsBeforeStartLocation);

                        CGContextRestoreGState(context);
                        break;
                    }
                }
            }
            
            void GuiGradientBackgroundElementRenderer::OnElementStateChanged()
            {
                if(renderTarget)
                {
                    collections::Pair<Color, Color> color = collections::Pair<Color, Color>(element->GetColor1(), element->GetColor2());
                    if(color != oldColor)
                    {
                        CreateCGGradient();
                    }
                }
            }
            
            void GuiGradientBackgroundElementRenderer::CreateCGGradient()
            {
                oldColor = collections::Pair<Color, Color>(element->GetColor1(), element->GetColor2());
                if(cgGradient)
                {
                    CGGradientRelease(cgGradient);
                }
                
                CGFloat locations[2] = { 0.0f, 1.0f };
                CGFloat components[8] = {
                    oldColor.key.r / 255.0f, oldColor.key.g / 255.0f, oldColor.key.b / 255.0f, oldColor.key.a / 255.0f,
                    oldColor.value.r / 255.0f, oldColor.value.g / 255.0f, oldColor.value.b / 255.0f, oldColor.value.a / 255.0f
                };
                
                cgGradient = CGGradientCreateWithColorComponents(cgColorSpace, components, locations, 2);
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
