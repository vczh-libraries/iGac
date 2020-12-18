//
//  CoreGraphicsRenderer.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsCoreGraphicsRenderers.h"

#include "../../NativeWindow/OSX/CocoaHelper.h"
#include "../../NativeWindow/OSX/ServicesImpl/CocoaImageService.h"

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>

static float SCALING_FACTOR = 1.0f;

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
                return CGRectMake((rect.Left() - extends) * SCALING_FACTOR,
                                  (rect.Top() - extends) * SCALING_FACTOR,
                                  (rect.Width() + extends * 2) * SCALING_FACTOR,
                                  (rect.Height() + extends * 2) * SCALING_FACTOR);
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBackgroundElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                SetCGContextFillColor(context, element->GetColor());
            
                switch(element->GetShape().shapeType)
                {
                    case ElementShapeType::RoundRect:
                    case ElementShapeType::Rectangle:
                        CGContextFillRect(context, ConvertToCGRect(bounds));
                        break;
                        
                    case ElementShapeType::Ellipse:
                        CGContextFillEllipseInRect(context, ConvertToCGRect(bounds));
                        break;
                }
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBorderElementRenderer)
            {
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                SetCGContextStrokeColor(context, element->GetColor());
                
                switch(element->GetShape().shapeType)
                {
                    case ElementShapeType::RoundRect:
                    case ElementShapeType::Rectangle:
                        CGContextStrokeRect(context, ConvertToCGRect(bounds, -0.5f));
                        break;
                        
                    case ElementShapeType::Ellipse:
                        CGContextStrokeEllipseInRect(context, ConvertToCGRect(bounds, -0.5f));
                        break;
                }
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
                switch(element->GetShape().shapeType)
                {
                    case ElementShapeType::Rectangle:
                        CGContextSaveGState(context);
                        
                        CGContextBeginPath(context);
                        CGContextAddRect(context, ConvertToCGRect(bounds));
                        CGContextClip(context);
                        
                        CGContextDrawLinearGradient(context, cgGradient, points[0], points[1], kCGGradientDrawsBeforeStartLocation);
                        
                        CGContextRestoreGState(context);
                        break;
                        
                    case ElementShapeType::Ellipse:
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
            oldMaxWidth(-1),
            nsText(0),
            nsAttributes(0)
            {
                nsParagraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                CFRetain(nsParagraphStyle);
            }
            
            GuiSolidLabelElementRenderer::~GuiSolidLabelElementRenderer()
            {
                if(nsAttributes)
                    CFRelease(nsAttributes);
                if(nsText)
                    CFRelease(nsText);
                if(nsParagraphStyle)
                    CFRelease(nsParagraphStyle);
            }
            
            void GuiSolidLabelElementRenderer::CreateFont()
            {
                FontProperties font = element->GetFont();
                GetCoreGraphicsResourceManager()->DestroyCoreTextFont(oldFont);
                
                
                if(coreTextFont)
                    coreTextFont->Release();
                coreTextFont = GetCoreGraphicsResourceManager()->CreateCoreTextFont(font);
                coreTextFont->Retain();
                
                if(nsAttributes)
                    CFRelease(nsAttributes);
                nsAttributes = [NSMutableDictionary dictionaryWithDictionary:coreTextFont->attributes];
                CFRetain(nsAttributes);
                
                [nsAttributes setObject:nsParagraphStyle forKey:NSParagraphStyleAttributeName];
                CreateColor();
                
                oldFont = font;
            }
            
            void GuiSolidLabelElementRenderer::CreateColor()
            {
                oldColor = element->GetColor();
                [nsAttributes setObject:[NSColor colorWithRed:oldColor.r/255.0f
                                                        green:oldColor.g/255.0f
                                                         blue:oldColor.b/255.0f
                                                        alpha:oldColor.a/255.0f]
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
                vint x = 0;
                vint y = 0;
                
                switch(element->GetVerticalAlignment())
                {
                    case Alignment::Top:
                        y = bounds.Top();
                        break;
                        
                    case Alignment::Center:
                        y = bounds.Top() + (bounds.Height() - minSize.y) / 2;
                        break;
                        
                    case Alignment::Bottom:
                        y = bounds.Bottom() - minSize.y;
                        break;
                }
                
                switch(element->GetHorizontalAlignment())
                {
                    case Alignment::Left:
                        x = bounds.Left();
                        break;
                        
                    case Alignment::Center:
                        x = bounds.Left() + (bounds.Width() - minSize.x) / 2;
                        break;
                        
                    case Alignment::Right:
                        x = bounds.Right() - minSize.x;
                        break;
                }
                
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                SetCGContextFillColor(context, element->GetColor());
                
                if(!element->GetEllipse() && !element->GetMultiline() && !element->GetWrapLine())
                {
                    [coreTextFont->font set];
                    [nsText drawAtPoint:NSMakePoint(x, y) withAttributes:nsAttributes];
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
                
                UpdateParagraphStyle();
                
                oldText = element->GetText();
                
                if(nsText)
                    CFRelease(nsText);
                if(oldFont.fontFamily == L"Webdings" && oldText.Length() > 0)
                {
                    // map webdings to unicode
                    wchar_t* wsStr = new wchar_t[oldText.Length()];
                    for(vint i=0; i<oldText.Length(); ++i)
                    {
                        switch(oldText[i])
                        {
                            case L'a': wsStr[i] = 0x00002713; break;
                            case L'r': wsStr[i] = 0x00002715; break;
                            case L'0': wsStr[i] = 0x0000035F; break;
                            case L'1': wsStr[i] = 0x0000002B; break;
                            case L'2': wsStr[i] = 0x0000002B; break;
                                // more todo
                                
                            default: wsStr[i] = oldText[i];
                        }
                    }
                    
                    nsText = osx::WStringToNSString(wsStr);
                    delete[] wsStr;
                }
                else
                {
                    nsText = osx::WStringToNSString(element->GetText());
                }
                if(nsText)
                    CFRetain(nsText);
               
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
                SetCGContextStrokeColor(context, element->GetBorderColor());
                CGContextDrawPath(context, kCGPathFillStroke);
                
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

                if(element->GetImage())
                {
                    CocoaImageFrame* frame = static_cast<CocoaImageFrame*>(element->GetImage()->GetFrame(element->GetFrameIndex()));
                    
                    CGImageRef image = frame->GetCGImage();
                    
                    CGRect dest;
                    if(element->GetStretch())
                    {
                        dest = CGRectMake((CGFloat)bounds.x1, (CGFloat)bounds.y1, (CGFloat)bounds.Width(), (CGFloat)bounds.Height());
                    }
                    else
                    {
                        vint x = 0;
                        vint y = 0;
                        
                        switch(element->GetVerticalAlignment())
                        {
                            case Alignment::Top:
                                y=bounds.Top();
                                break;
                                
                            case Alignment::Center:
                                y=bounds.Top() + (bounds.Height() - minSize.y) / 2;
                                break;
                                
                            case Alignment::Bottom:
                                y=bounds.Bottom() - minSize.y;
                                break;
                        }
                        
                        switch(element->GetHorizontalAlignment())
                        {
                            case Alignment::Left:
                                x=bounds.Left();
                                break;
                                
                            case Alignment::Center:
                                x=bounds.Left() + (bounds.Width() - minSize.x) / 2;
                                break;
                                
                            case Alignment::Right:
                                x=bounds.Right() - minSize.x;
                                break;
                        }
                        dest = CGRectMake((CGFloat)x, (CGFloat)y, (CGFloat)(minSize.x), (CGFloat)(minSize.y));
                    }
                    
                    CGContextSaveGState(context);
                    
                    CGContextTranslateCTM(context, dest.origin.x, dest.origin.y + dest.size.height);
                    CGContextScaleCTM(context, 1.0, -1.0);
                    
                    CGContextDrawImage(context, CGRectMake(0, 0, dest.size.width, dest.size.height), image);
                    
                    CGContextRestoreGState(context);
                }
                
            }
            
            void GuiImageFrameElementRenderer::OnElementStateChanged()
            {
                if(element->GetImage())
                {
                    INativeImageFrame* frame = element->GetImage()->GetFrame(element->GetFrameIndex());
                    minSize = frame->GetSize();
                }
                else
                    minSize = Size(0, 0);
            }
            
            //
            
            GuiColorizedTextElementRenderer::GuiColorizedTextElementRenderer():
            nsAttributes(0)
            {
                
            }
            
            GuiColorizedTextElementRenderer::~GuiColorizedTextElementRenderer()
            {
                if(nsAttributes)
                    CFRelease(nsAttributes);
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
                // todo, make this thing faster
                // NSAttributedString can be prebuild here
                
                CGContextRef context = GetCurrentCGContextFromRenderTarget();
                
                
                if(renderTarget)
                {
                    CGContextSaveGState(context);
                    
                    wchar_t passwordChar = element->GetPasswordChar();
                    NSString* nsPassWordChar = WStringToNSString(&passwordChar, 1);
                    
                    Point viewPosition = element->GetViewPosition();
                    Rect viewBounds(viewPosition, bounds.GetSize());
                    
                    vint startRow = element->GetLines().GetTextPosFromPoint(Point(viewBounds.x1, viewBounds.y1)).row;
                    vint endRow = element->GetLines().GetTextPosFromPoint(Point(viewBounds.x2, viewBounds.y2)).row;
                    
                    TextPos selectionBegin = element->GetCaretBegin() < element->GetCaretEnd() ? element->GetCaretBegin() : element->GetCaretEnd();
                    TextPos selectionEnd = element->GetCaretBegin() > element->GetCaretEnd() ? element->GetCaretBegin() :element->GetCaretEnd();
                    
                    bool focused = element->GetFocused();
                    
                    for(vint row = startRow; row <= endRow; row++)
                    {
                        Rect startRect = element->GetLines().GetRectFromTextPos(TextPos(row, 0));
                        Point startPoint = startRect.LeftTop();
                        
                        vint startColumn = element->GetLines().GetTextPosFromPoint(Point(viewBounds.x1, startPoint.y)).column;
                        vint endColumn = element->GetLines().GetTextPosFromPoint(Point(viewBounds.x2, startPoint.y)).column;
                        
                        text::TextLine& line = element->GetLines().GetLine(row);
                        
                        vint x = startColumn == 0 ? 0 : line.att[startColumn-1].rightOffset;
                        
                        NSString* nsLine = WStringToNSString(line.text, (uint32_t)line.dataLength);
                        for(vint column = startColumn; column <= endColumn; column++)
                        {
                            bool inSelection=false;
                            if(selectionBegin.row == selectionEnd.row)
                            {
                                inSelection = (row == selectionBegin.row && selectionBegin.column <= column && column < selectionEnd.column);
                            }
                            else if(row == selectionBegin.row)
                            {
                                inSelection = selectionBegin.column <= column;
                            }
                            else if(row == selectionEnd.row)
                            {
                                inSelection = column<selectionEnd.column;
                            }
                            else
                            {
                                inSelection = selectionBegin.row < row && row < selectionEnd.row;
                            }
                            
                            bool crlf = (column == line.dataLength);
                            vint colorIndex = crlf ? 0 : line.att[column].colorIndex;
                            if(colorIndex >= colors.Count())
                            {
                                colorIndex = 0;
                            }
                            ColorItemResource& color = !inSelection ? colors[colorIndex].normal : (focused ? colors[colorIndex].selectedFocused : colors[colorIndex].selectedUnfocused);
                           
                            vint x2 = crlf ? x + startRect.Height() / 2 : line.att[column].rightOffset;
                            vint tx = x - viewPosition.x + bounds.x1;
                            vint ty = startPoint.y - viewPosition.y + bounds.y1;
                            
                            if(color.background.a > 0)
                            {
                                SetCGContextFillColor(context, color.background);
                                
                                CGRect fillRect = CGRectMake(tx, ty + 2, (x2 - x), startRect.Height() + 2);
                                CGContextFillRect(context, fillRect);
                                
                            }
                            if(!crlf)
                            {
                                Color textColor = color.text;
                                
                                [nsAttributes setObject:[NSColor colorWithRed:textColor.r/255.0f green:textColor.g/255.0f blue:textColor.b/255.0f alpha:textColor.a/255.0f]
                                                 forKey:NSForegroundColorAttributeName];
                                
                                NSString* str = passwordChar ? nsPassWordChar : [nsLine substringWithRange:NSMakeRange(column, 1)];
                                
                                [str drawAtPoint:NSMakePoint(tx, ty) withAttributes:nsAttributes];
                            }
                            x = x2;
                        }
                    }
                    
                    if(element->GetCaretVisible() && element->GetLines().IsAvailable(element->GetCaretEnd()))
                    {
                        Point caretPoint = element->GetLines().GetPointFromTextPos(element->GetCaretEnd());
                        vint height = element->GetLines().GetRowHeight();
                        Point p1(caretPoint.x - viewPosition.x + bounds.x1,
                                 caretPoint.y - viewPosition.y + bounds.y1 + 2);
                        
                        Point p2(caretPoint.x - viewPosition.x + bounds.x1,
                                 caretPoint.y + height - viewPosition.y + bounds.y1 + 2);
                        
                        SetCGContextStrokeColor(context, element->GetCaretColor());
                        
                        CGPoint points[2];
                        
                        CGContextSetLineWidth(context, 2.0f);
                        
                        points[0] = CGPointMake(p1.x, p1.y);
                        points[1] = CGPointMake(p2.x, p2.y);
                        CGContextStrokeLineSegments(context, points, 2);
                        
                    }
                    
                    CGContextRestoreGState(context);
                }
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
                
                if(coreTextFont)
                    coreTextFont->Release();
                coreTextFont = rm->CreateCoreTextFont(oldFont);
                coreTextFont->Retain();
                
                element->GetLines().SetCharMeasurer(rm->CreateCharMeasurer(oldFont).Obj());
                
                if(nsAttributes)
                    CFRelease(nsAttributes);
                nsAttributes = [NSMutableDictionary dictionaryWithDictionary:coreTextFont->attributes];
                CFRetain(nsAttributes);
            }
            
            void GuiColorizedTextElementRenderer::ColorChanged()
            {
                colors.Resize(element->GetColors().Count());
                for(vint i = 0; i < colors.Count(); i++)
                {
                    text::ColorEntry entry=element->GetColors().Get(i);
                    ColorEntryResource newEntry;
                    
                    newEntry.normal.text=entry.normal.text;
                    newEntry.normal.background=entry.normal.background;
                    
                    newEntry.selectedFocused.text=entry.selectedFocused.text;
                    newEntry.selectedFocused.background=entry.selectedFocused.background;
                    
                    newEntry.selectedUnfocused.text=entry.selectedUnfocused.text;
                    newEntry.selectedUnfocused.background=entry.selectedUnfocused.background;
                    
                    colors[i]=newEntry;
                }
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
                
                CGPoint points[4];
                points[0] = CGPointMake((CGFloat)bounds.x1+0.5f, (CGFloat)bounds.y1+0.5f);
                points[1] = CGPointMake((CGFloat)bounds.x2-0.5f, (CGFloat)bounds.y1+0.5f);
                points[0] = CGPointMake((CGFloat)bounds.x1+0.5f, (CGFloat)bounds.y1+0.5f);
                points[3] = CGPointMake((CGFloat)bounds.x1+0.5f, (CGFloat)bounds.y2-0.5f);
                
                SetCGContextStrokeColor(context, element->GetColor1());
                CGContextStrokeLineSegments(context, points, 4);
                
                points[1] = CGPointMake((CGFloat)bounds.x2-0.5f, (CGFloat)bounds.y2-0.5f);
                points[1] = CGPointMake((CGFloat)bounds.x1+0.5f, (CGFloat)bounds.y2-0.5f);
                points[1] = CGPointMake((CGFloat)bounds.x2-0.5f, (CGFloat)bounds.y2-0.5f);
                points[1] = CGPointMake((CGFloat)bounds.x2-0.5f, (CGFloat)bounds.y1+0.5f);
                
                SetCGContextStrokeColor(context, element->GetColor2());
                CGContextStrokeLineSegments(context, points, 4);
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
                
                CGPoint points[4];
                switch (element->GetDirection()) {
                    case Gui3DSplitterElement::Horizontal:
                    {
                        vint y = bounds.y1 + bounds.Height() / 2;
                        
                        points[0] = CGPointMake((CGFloat)bounds.x1, (CGFloat)y+0.5f);
                        points[1] = CGPointMake((CGFloat)bounds.x2, (CGFloat)y+0.5f);
                        points[2] = CGPointMake((CGFloat)bounds.x1, (CGFloat)y+1.5f);
                        points[3] = CGPointMake((CGFloat)bounds.x2, (CGFloat)y+1.5f);
                        break;
                    }
                        
                    case Gui3DSplitterElement::Vertical:
                    {
                        vint x = bounds.x1 + bounds.Width() / 2;
                        
                        points[0] = CGPointMake((CGFloat)x+0.5f, (CGFloat)bounds.y1);
                        points[1] = CGPointMake((CGFloat)x+0.5f, (CGFloat)bounds.y2);
                        points[2] = CGPointMake((CGFloat)x+1.5f, (CGFloat)bounds.y1);
                        points[3] = CGPointMake((CGFloat)x+1.5f, (CGFloat)bounds.y2);
                        break;
                    }
                }
                
                SetCGContextStrokeColor(context, element->GetColor1());
                CGContextStrokeLineSegments(context, points, 2);
                SetCGContextStrokeColor(context, element->GetColor2());
                CGContextStrokeLineSegments(context, points+2, 2);
            }
            
            void Gui3DSplitterElementRenderer::OnElementStateChanged()
            {
                
            }
            
            ///////
            
            void GuiCoreGraphicsElementRenderer::InitializeInternal()
            {
                
            }
            
            void GuiCoreGraphicsElementRenderer::FinalizeInternal()
            {
                
            }
            
            void GuiCoreGraphicsElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
                ICoreGraphicsRenderTarget* newCGTarget = (ICoreGraphicsRenderTarget*)newRenderTarget;
                ICoreGraphicsRenderTarget* oldCGTarget = (ICoreGraphicsRenderTarget*)oldRenderTarget;
                if(oldRenderTarget)
                {
                    GuiCoreGraphicsElementEventArgs arguments(element, Rect(), oldCGTarget? oldCGTarget->GetCGContext() : 0);
                    element->BeforeRenderTargetChanged.Execute(arguments);
                }
                if(newRenderTarget)
                {
                    GuiCoreGraphicsElementEventArgs arguments(element, Rect(), newCGTarget ? newCGTarget->GetCGContext() : 0);
                    element->AfterRenderTargetChanged.Execute(arguments);
                }
            }
            
            GuiCoreGraphicsElementRenderer::GuiCoreGraphicsElementRenderer()
            {
                
            }
            
            GuiCoreGraphicsElementRenderer::~GuiCoreGraphicsElementRenderer()
            {
                
            }
            
            void GuiCoreGraphicsElementRenderer::Render(Rect bounds)
            {
                if(renderTarget)
                {
                    
                    renderTarget->PushClipper(bounds);
                    if(!renderTarget->IsClipperCoverWholeTarget())
                    {
                        GuiCoreGraphicsElementEventArgs arguments(element, bounds, GetCurrentCGContextFromRenderTarget());
                        element->Rendering.Execute(arguments);
                    }
                    renderTarget->PopClipper();
                }
            }
            
            void GuiCoreGraphicsElementRenderer::OnElementStateChanged()
            {
                
            }

            ///////

            void GuiInnerShadowElementRenderer::InitializeInternal()
            {

            }

            void GuiInnerShadowElementRenderer::FinalizeInternal()
            {

            }

            void GuiInnerShadowElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
            }

            GuiInnerShadowElementRenderer::GuiInnerShadowElementRenderer()
            {

            }

            GuiInnerShadowElementRenderer::~GuiInnerShadowElementRenderer()
            {

            }

            void GuiInnerShadowElementRenderer::Render(Rect bounds)
            {
            }

            void GuiInnerShadowElementRenderer::OnElementStateChanged()
            {

            }

            ///////

            void GuiFocusRectangleElementRenderer::InitializeInternal()
            {

            }

            void GuiFocusRectangleElementRenderer::FinalizeInternal()
            {

            }

            void GuiFocusRectangleElementRenderer::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)
            {
            }

            GuiFocusRectangleElementRenderer::GuiFocusRectangleElementRenderer()
            {

            }

            GuiFocusRectangleElementRenderer::~GuiFocusRectangleElementRenderer()
            {

            }

            void GuiFocusRectangleElementRenderer::Render(Rect bounds)
            {
            }

            void GuiFocusRectangleElementRenderer::OnElementStateChanged()
            {

            }
        }
    }
    
}
