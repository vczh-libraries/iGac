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
            
                switch(element->GetShape())
                {
                    case ElementShape::Rectangle:
                        CGContextFillRect(context, ConvertToCGRect(bounds));
                        break;
                        
                    case ElementShape::Ellipse:
                        CGContextFillEllipseInRect(context, ConvertToCGRect(bounds));
                        break;
                }
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
            
            ////
            
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
                        
                        CGPathRelease(path);
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
                CGFloat components[8] =
                {
                    oldColor.key.r / 255.0f, oldColor.key.g / 255.0f, oldColor.key.b / 255.0f, oldColor.key.a / 255.0f,
                    oldColor.value.r / 255.0f, oldColor.value.g / 255.0f, oldColor.value.b / 255.0f, oldColor.value.a / 255.0f
                };
                
                cgGradient = CGGradientCreateWithColorComponents(cgColorSpace, components, locations, 2);
            }
            
            ///////
            
            GuiSolidLabelElementRenderer::GuiSolidLabelElementRenderer():
            oldText(L""),
            oldMaxWidth(-1)
            {
                nsParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
            }
            
            void GuiSolidLabelElementRenderer::CreateFont()
            {
                FontProperties font = element->GetFont();
                GetCoreGraphicsResourceManager()->DestroyCoreTextFont(oldFont);
                coreTextFont = GetCoreGraphicsResourceManager()->CreateCoreTextFont(font);
                
                [coreTextFont->attributes setObject:nsParagraphStyle forKey:NSParagraphStyleAttributeName];
                CreateColor();
            }
            
            void GuiSolidLabelElementRenderer::CreateColor()
            {
                Color color = element->GetColor();
                [coreTextFont->attributes setObject:[NSColor colorWithRed:color.r/255.0f green:color.g/255.0f blue:color.b/255.0f alpha:color.a/255.0f]
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
                                                attributes:coreTextFont->attributes];
                
                minSize = Size(rect.size.width, rect.size.height);
            }
            
            void GuiSolidLabelElementRenderer::InitializeInternal()
            {
                CreateFont();
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
                
                if(!element->GetEllipse() && !element->GetMultiline() && !element->GetWrapLine())
                {
                    [coreTextFont->font set];
                    [nsText drawAtPoint:NSMakePoint(bounds.Left(), bounds.Top())
                         withAttributes:coreTextFont->attributes];
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
                    
                    [nsText drawInRect:textBounds withAttributes:coreTextFont->attributes];
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
            
            ///////
            
            GuiPolygonElementRenderer::GuiPolygonElementRenderer():
            cgBorderPath(0),
            cgColorSpace(0)
            {
                cgColorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
            }
            
            GuiPolygonElementRenderer::~GuiPolygonElementRenderer()
            {
                CGColorSpaceRelease(cgColorSpace);
                DestroyGeometry();
            }
            
            void GuiPolygonElementRenderer::InitializeInternal()
            {
                CreateGeometry();
            }
            
            void GuiPolygonElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiPolygonElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                CreateGeometry();
            }
            
            void GuiPolygonElementRenderer::CreateGeometry()
            {
                oldPoints.Resize(element->GetPointCount());
                if(oldPoints.Count() > 0)
                {
                    memcpy(&oldPoints[0], &element->GetPoint(0), sizeof(Point)*element->GetPointCount());
                }
                
                cgBorderPath = CGPathCreateMutable();
                for(vint i=0; i < oldPoints.Count(); ++i)
                {
                    Point p = oldPoints[i];
                    if(i == 0)
                        CGPathMoveToPoint(cgBorderPath, 0, p.x + 0.5f, p.y + 0.5f);
                    else
                        CGPathAddLineToPoint(cgBorderPath, 0, p.x + 0.5f, p.y + 0.5f);
                }
                if(oldPoints.Count() > 0)
                {
                    Point p = oldPoints[0];
                    CGPathAddLineToPoint(cgBorderPath, 0, p.x + 0.5f, p.y + 0.5f);
                }
            }
            
            void GuiPolygonElementRenderer::DestroyGeometry()
            {
                if(cgBorderPath)
                    CGPathRelease(cgBorderPath);
            }
            
            void GuiPolygonElementRenderer::Render(Rect bounds)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();

                CGContextSaveGState(context);
                
                vint offsetX = (bounds.Width() - minSize.x) / 2 + bounds.x1;
                vint offsetY = (bounds.Height() - minSize.y) / 2 + bounds.y1;
                CGContextTranslateCTM(context, offsetX, offsetY);
                
                CGContextAddPath(context, cgBorderPath);
                
                SetCGContextFillColor(context, element->GetBackgroundColor());
                CGContextFillPath(context);
                
                SetCGContextStrokeColor(context, element->GetBorderColor());
                CGContextStrokePath(context);
                

                CGContextRestoreGState(context);
               
            }
            
            void GuiPolygonElementRenderer::OnElementStateChanged()
            {
                minSize = element->GetSize();
                
                bool polygonModified = false;
                if(oldPoints.Count() != element->GetPointCount())
                {
                    polygonModified=true;
                }
                else
                {
                    for(vint i = 0; i<oldPoints.Count(); i++)
                    {
                        if(oldPoints[i] != element->GetPoint(i))
                        {
                            polygonModified=true;
                            break;
                        }
                    }
                }
                if(polygonModified)
                {
                    DestroyGeometry();
                    CreateGeometry();
                }
            }
            
            ///
            
            GuiImageFrameElementRenderer::GuiImageFrameElementRenderer()
            {

            }
            
            void GuiImageFrameElementRenderer::InitializeInternal()
            {
                
            }
            
            void GuiImageFrameElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiImageFrameElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                
            }
            
            void GuiImageFrameElementRenderer::Render(Rect bounds)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();

            }
            
            void GuiImageFrameElementRenderer::OnElementStateChanged()
            {
                
            }
            
            //
            
            GuiColorizedTextElementRenderer::GuiColorizedTextElementRenderer()
            {
                
            }
            
            void GuiColorizedTextElementRenderer::InitializeInternal()
            {
                
                coreTextFont = 0;
                element->SetCallback(this);
            }
            
            void GuiColorizedTextElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiColorizedTextElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                
            }
            
            void GuiColorizedTextElementRenderer::Render(Rect bounds)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
            }
            
            void GuiColorizedTextElementRenderer::OnElementStateChanged()
            {
                
            }
            
            void GuiColorizedTextElementRenderer::FontChanged()
            {
                ICoreGraphicsResourceManager* rm = GetCoreGraphicsResourceManager();
                if(coreTextFont)
                {
                    rm->DestroyCharMeasurer(oldFont);
                    rm->DestroyCoreTextFont(oldFont);
                }
                oldFont = element->GetFont();
                coreTextFont = rm->CreateCoreTextFont(oldFont);
                element->GetLines().SetCharMeasurer(rm->CreateCharMeasurer(oldFont).Obj());
            }
            
            void GuiColorizedTextElementRenderer::ColorChanged()
            {
            }
            
            ///
        
            
            Gui3DBorderElementRenderer::Gui3DBorderElementRenderer()
            {
                
            }
            
            void Gui3DBorderElementRenderer::InitializeInternal()
            {
                
            }
            
            void Gui3DBorderElementRenderer::FinalizeInternal()
            {
                
            }
            
            void Gui3DBorderElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                
            }
            
            void Gui3DBorderElementRenderer::Render(Rect bounds)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
            }
            
            void Gui3DBorderElementRenderer::OnElementStateChanged()
            {
                
            }
            
            
            ///
            
            
            Gui3DSplitterElementRenderer::Gui3DSplitterElementRenderer()
            {
                
            }
            
            void Gui3DSplitterElementRenderer::InitializeInternal()
            {
                
            }
            
            void Gui3DSplitterElementRenderer::FinalizeInternal()
            {
                
            }
            
            void Gui3DSplitterElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                
            }
            
            void Gui3DSplitterElementRenderer::Render(Rect bounds)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
            }
            
            void Gui3DSplitterElementRenderer::OnElementStateChanged()
            {
                
            }
            
        }
    }
    
}
