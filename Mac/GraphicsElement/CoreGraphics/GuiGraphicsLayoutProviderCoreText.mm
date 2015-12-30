//
//  GuiGraphicsLayoutProviderCoreText.mm
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsLayoutProviderCoreText.h"

#include "../../NativeWindow/OSX/CocoaHelper.h"
#include "../../NativeWindow/OSX/ServicesImpl/CocoaImageService.h"

#include "GuiGraphicsCoreGraphics.h"
#include "GuiGraphicsCoreGraphicsRenderers.h"

#include <vector>

using namespace vl::presentation;
using namespace vl::presentation::elements_coregraphics;

class IGuiTextCellCallback {
public:
    virtual vl::presentation::Point GetParagraphOffset() = 0;
    virtual IGuiGraphicsParagraphCallback* GetParagraphCallback() = 0;
};

@interface GuiElementsTextCell: NSObject<NSTextAttachmentCell>
{
    NSTextAttachment* attachment;
}

@property (nonatomic) NSRange textRange;
@property (nonatomic) NSRect cellFrame;
@property (nonatomic) vl::Ptr<IGuiGraphicsElement> graphicsElement;
@property (nonatomic) IGuiGraphicsParagraph::InlineObjectProperties properties;
@property (nonatomic) IGuiTextCellCallback* callback;

#ifndef NS_DESIGNATED_INITIALIZER
#define NS_DESIGNATED_INITIALIZER
#endif

- (instancetype)initWithGraphicsElement:(vl::Ptr<IGuiGraphicsElement>)element properties:(IGuiGraphicsParagraph::InlineObjectProperties)properties andCallback:(IGuiTextCellCallback*)callback NS_DESIGNATED_INITIALIZER;

@end

@implementation GuiElementsTextCell

- (instancetype)initWithGraphicsElement:(vl::Ptr<IGuiGraphicsElement>)element properties:(IGuiGraphicsParagraph::InlineObjectProperties)properties andCallback:(IGuiTextCellCallback*)callback
{
    if(self = [super init])
    {
        _graphicsElement = element;
        _properties = properties;
        _callback = callback;
    }
    return self;
}


- (void)draw:(NSRect)cellFrame
{
    _cellFrame = cellFrame;
    
    if(_properties.backgroundImage)
    {
        IGuiGraphicsRenderer* graphicsRenderer = _properties.backgroundImage->GetRenderer();
        if(graphicsRenderer)
        {
            vl::presentation::Rect bounds(vl::presentation::Point((vl::vint)cellFrame.origin.x,
                                                                  (vl::vint)cellFrame.origin.y),
                                          _properties.size);
            graphicsRenderer->Render(bounds);
        }
    }
    
    if(_properties.callbackId != -1)
    {
        if(auto paraCallback = _callback->GetParagraphCallback())
        {
            auto offset = _callback->GetParagraphOffset();
            vl::presentation::Rect bounds(vl::presentation::Point((vl::vint)cellFrame.origin.x - offset.x,
                                                                  (vl::vint)cellFrame.origin.y - offset.y),
                                          _properties.size);
            auto size = paraCallback->OnRenderInlineObject(_properties.callbackId, bounds);
            _properties.size = size;
        }
    }
    
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [self draw:cellFrame];
}

- (BOOL)wantsToTrackMouse
{
    return NO;
}

- (void)highlight:(BOOL)flag withFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView untilMouseUp:(BOOL)flag
{
    return NO;
}

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex
{
    return NO;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag
{
    return NO;
}

- (NSSize)cellSize
{
    return NSMakeSize(_properties.size.x, _properties.size.y);
}

- (NSPoint)cellBaselineOffset
{
    return NSMakePoint(0, _properties.baseline == -1 ? _properties.size.y : _properties.baseline);
}

- (void)setAttachment:(NSTextAttachment *)anObject
{
    attachment = anObject;
}

- (NSTextAttachment *)attachment
{
    return attachment;
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex
{
    [self drawWithFrame:cellFrame inView:controlView];
}

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView characterIndex:(NSUInteger)charIndex layoutManager:(NSLayoutManager *)layoutManager
{
    [self drawWithFrame:cellFrame inView:controlView];
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex
{
    _cellFrame = NSMakeRect(position.x, position.y, _properties.size.x, _properties.size.y);
    return NSMakeRect(0, 0, _properties.size.x, _properties.size.y);
}

@end

namespace vl {
    
    namespace presentation {
        
        using namespace elements;
        using namespace collections;
        using namespace osx;
        
        namespace elements_coregraphics {
            
            class CoreTextParagraph : public Object, public IGuiGraphicsParagraph, public IGuiTextCellCallback
            {
            protected:
                struct TextRange
                {
                    vint    start;
                    vint    end;
                    
                    TextRange() { }
                    TextRange(vint _start, vint _end):
                        start(_start),
                        end(_end)
                    {
                        
                    }
                    
                    bool operator == (const TextRange& range) const { return start == range.start; }
                    bool operator != (const TextRange& range) const { return start != range.start; }
                    bool operator <  (const TextRange& range) const { return start <  range.start; }
                    bool operator <= (const TextRange& range) const { return start <= range.start; }
                    bool operator >  (const TextRange& range) const { return start >  range.start; }
                    bool operator >= (const TextRange& range) const { return start >= range.start; }
                };
                
                struct TextCellContainer
                {
                    __unsafe_unretained GuiElementsTextCell* textCell;
                    
                    TextCellContainer(GuiElementsTextCell* c): textCell(c) {}
                    TextCellContainer() {}
                };
                
                typedef Dictionary<IGuiGraphicsElement*, TextCellContainer>     InlineElementMap;
                typedef Dictionary<TextRange, IGuiGraphicsElement*>             GraphicsElementMap;
                typedef Dictionary<TextRange, Color>                            BackgroundColorMap;
                
                struct BoundingMetrics
                {
                    vint textPosition;
                    vint textLength;
                    CGFloat lineHeight;
                    CGFloat yOffset;
                    Rect boundingRect;
                    
                    BoundingMetrics():textPosition(-1), textLength(-1), lineHeight(0), yOffset(0) {}
                    BoundingMetrics(vint _textPosition, vint _textLength, CGFloat _lineHeight, CGFloat _yOffset, const Rect& _rect):
                        textPosition(_textPosition),
                        textLength(_textLength),
                        lineHeight(_lineHeight),
                        yOffset(_yOffset),
                        boundingRect(_rect)
                    {
                        
                    }
                };
                
            protected:
                IGuiGraphicsLayoutProvider*				provider;
                ICoreGraphicsRenderTarget*              renderTarget;
                WString									paragraphText;
                bool									wrapLine;
                vint									maxWidth;
                List<Color>								usedColors;
                
                GraphicsElementMap						graphicsElements;
                InlineElementMap                        inlineElements;
                BackgroundColorMap                      backgroundColors;
                
                NSMutableArray*                         textCellStorage;
                
                vint									caretPos;
                Color									caretColor;
                bool									caretFrontSide;
                
                Alignment                               textAlignment;
                
                NSTextStorage*                          textStorage;
                NSTextContainer*                        textContainer;
                NSLayoutManager*                        layoutManager;

                bool                                    needFormatData;
                Dictionary<vint, BoundingMetrics>       glyphBoundingRects;
                Array<vint>                             charBoundingMetricsMap;
                Array<BoundingMetrics>                  lineFragments;
                Dictionary<vint, vint>                  charLineFragmentsMap;
                
                IGuiGraphicsParagraphCallback*          paraCallback;
                vl::presentation::Point                 paraOffset;
                
            public:
                // todo callback
                CoreTextParagraph(IGuiGraphicsLayoutProvider* _provider, const WString& _text, ICoreGraphicsRenderTarget* _renderTarget, IGuiGraphicsParagraphCallback* _callback):
                    provider(_provider),
                    renderTarget(_renderTarget),
                    paragraphText(_text),
                    wrapLine(true),
                    maxWidth(-1),
                    caretPos(-1),
                    caretFrontSide(false),
                    textAlignment(Alignment::Left),
                    paraCallback(_callback)
                {
                    usedColors.Add(Color(0, 0, 0));
                    
                    graphicsElements.Add(TextRange(0, _text.Length()), 0);
                    backgroundColors.Add(TextRange(0, _text.Length()), Color(0, 0, 0, 0));

                    textStorage = [[NSTextStorage alloc] initWithString:WStringToNSString(_text) attributes:@{NSParagraphStyleAttributeName: [NSParagraphStyle defaultParagraphStyle]}];
                    
                    textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(maxWidth == -1 ? CGFLOAT_MAX : maxWidth, CGFLOAT_MAX)];
                    layoutManager = [[NSLayoutManager alloc] init];
                    
                    [layoutManager addTextContainer:textContainer];
                    [textStorage addLayoutManager:layoutManager];
                    
                    textCellStorage = [NSMutableArray new];
                    
                    needFormatData = true;
                }
                
                ~CoreTextParagraph()
                {
                    
                }
                
            public:
                IGuiGraphicsLayoutProvider* GetProvider() override
                {
                    return provider;
                }
                
                IGuiGraphicsRenderTarget* GetRenderTarget() override
                {
                    return renderTarget;
                }
                
                bool GetWrapLine() override
                {
                    return wrapLine;
                }
                
                void SetWrapLine(bool value) override
                {
                    wrapLine = value;
                    
                    NSMutableParagraphStyle* paragrahStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    [paragrahStyle setLineBreakMode:value ? NSLineBreakByTruncatingTail : NSLineBreakByWordWrapping];
                    
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(0, textStorage.length)
                                                    options:0
                                                 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSParagraphStyle* style = [attrs objectForKey:NSParagraphStyleAttributeName];
                         if(style)
                         {
                             [textStorage removeAttribute:NSParagraphStyleAttributeName range:range];
                         }
                     }];
                    [textStorage addAttribute:NSParagraphStyleAttributeName
                                        value:paragrahStyle
                                        range:NSMakeRange(0, textStorage.length)];
                    [textStorage endEditing];
                    
                    needFormatData = true;
                }
                
                vint GetMaxWidth() override
                {
                    return maxWidth;
                }
                
                void SetMaxWidth(vint value) override
                {
                    maxWidth = value;
                    [textContainer setContainerSize:NSMakeSize(value != -1 ? value : CGFLOAT_MAX, CGFLOAT_MAX)];
                    needFormatData = true;
                }
                
                Alignment GetParagraphAlignment() override
                {
                    return textAlignment;
                }
                
                void SetParagraphAlignment(Alignment value) override
                {
                    NSMutableParagraphStyle* paragrahStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    
                    switch(value)
                    {
                        case Alignment::Left:
                            [paragrahStyle setAlignment:NSLeftTextAlignment];
                            break;
                            
                        case Alignment::Right:
                            [paragrahStyle setAlignment:NSRightTextAlignment];
                            break;
                            
                        case Alignment::Center:
                            [paragrahStyle setAlignment:NSCenterTextAlignment];
                            break;
                    }
                    textAlignment = value;
                    
                    
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(0, textStorage.length)
                                                    options:0
                                                usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSParagraphStyle* style = [attrs objectForKey:NSParagraphStyleAttributeName];
                         if(style)
                         {
                             [textStorage removeAttribute:NSParagraphStyleAttributeName range:range];
                         }
                     }];
                    [textStorage addAttribute:NSParagraphStyleAttributeName
                                        value:paragrahStyle
                                        range:NSMakeRange(0, textStorage.length)];
                    [textStorage endEditing];
                    
                    needFormatData = true;
                }
                
                bool SetFont(vint start, vint length, const WString& value) override
                {
                    // remove old fonts
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(start, length)
                                                    options:0
                                                usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                    {
                        NSFont* font = [attrs objectForKey:NSFontAttributeName];
                        if(font)
                        {
                            [textStorage removeAttribute:NSFontAttributeName range:range];
                            
                            font = [[NSFontManager sharedFontManager] convertFont:font toFamily:WStringToNSString(value)];
                        }
                        
                        if(!font)
                        {
                            font = CreateFontWithFontFamily(GAC_APPLE_DEFAULT_FONT_FAMILY_NAME, 0, 12);
                            
                        }
                        
                        [textStorage addAttribute:NSFontAttributeName value:font range:range];
                        needFormatData = true;
                    }];
                    [textStorage endEditing];
                    
                    return true;
                }
                
                bool SetSize(vint start, vint length, vint value) override
                {
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(start, length)
                                                    options:0
                                                usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         
                         NSFont* font = [attrs objectForKey:NSFontAttributeName];
                         if(font)
                         {
                             [textStorage removeAttribute:NSFontAttributeName range:range];
                             font = [[NSFontManager sharedFontManager] convertFont:font toSize:value];
                         }
                         if(!font)
                         {
                             font = CreateFontWithFontFamily(GAC_APPLE_DEFAULT_FONT_FAMILY_NAME, 0, 12);
                         }
                         [textStorage addAttribute:NSFontAttributeName value:font range:range];
                         needFormatData = true;
                     }];
                    [textStorage endEditing];
                    
                    return true;
                }
                
                bool SetStyle(vint start, vint length, TextStyle value) override
                {
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(start, length)
                                                options:0
                                            usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSFontTraitMask traitMask = 0;
                         if(value & TextStyle::Bold)
                             traitMask |= NSBoldFontMask;
                         if(value & TextStyle::Italic)
                             traitMask |= NSItalicFontMask;
                         
                         NSFont* font = [attrs objectForKey:NSFontAttributeName];
                         if(font)
                         {
                             [textStorage removeAttribute:NSFontAttributeName range:range];
                           //  font = [[NSFontManager sharedFontManager] convertFont:font toNotHaveTrait:traitMask];
                             
                             NSFontDescriptor* desp = font.fontDescriptor;
                             
                             NSInteger originalSize = [[desp.fontAttributes
                                                        objectForKey:NSFontSizeAttribute] integerValue];
                             if(!originalSize)
                                 originalSize = 12;
                             font = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                               traits:traitMask
                                                                               weight:5
                                                                                 size:originalSize];
                             
                         }
                         if(!font)
                         {
                             font = CreateFontWithFontFamily(GAC_APPLE_DEFAULT_FONT_FAMILY_NAME, traitMask, 12);
                         }
                         [textStorage addAttribute:NSFontAttributeName value:font range:range];
                         
                         if(value & TextStyle::Underline)
                         {
                             NSNumber* style = [attrs objectForKey:NSUnderlineStyleAttributeName];
                             if(style)
                             {
                                 [textStorage removeAttribute:NSUnderlineStyleAttributeName range:range];
                             }
                         }
                         
                         if(value & TextStyle::Strikeline)
                         {
                             NSNumber* style = [attrs objectForKey:NSStrikethroughStyleAttributeName];
                             if(style)
                             {
                                 [textStorage removeAttribute:NSStrikethroughStyleAttributeName range:range];
                             }
                         }
                         needFormatData = true;
                    }];
                    
                    if(value & TextStyle::Strikeline)
                    {
                        [textStorage addAttribute:NSStrikethroughStyleAttributeName
                                            value:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]
                                            range:NSMakeRange(start, length)];
                        needFormatData = true;
                    }
                    
                    if(value & TextStyle::Underline)
                    {
                        [textStorage addAttribute:NSUnderlineStyleAttributeName
                                            value:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]
                                            range:NSMakeRange(start, length)];
                        needFormatData = true;
                    }
                    [textStorage endEditing];
                    
                    return true;
                }
                
                bool SetColor(vint start, vint length, Color value) override
                {
                    [textStorage beginEditing];
                    [textStorage enumerateAttributesInRange:NSMakeRange(start, length)
                                                    options:0
                                                 usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSColor* color = [attrs objectForKey:NSForegroundColorAttributeName];
                         if(color)
                         {
                             [textStorage removeAttribute:NSForegroundColorAttributeName range:range];
                         }
                     }];
                    
                    [textStorage addAttribute:NSForegroundColorAttributeName
                                        value:[NSColor colorWithRed:value.r / 255.0f
                                                              green:value.g / 255.0f
                                                               blue:value.b / 255.0f
                                                              alpha:value.a / 255.0f]
                                        range:NSMakeRange(start, length)];
                    [textStorage endEditing];
                    
                    needFormatData = true;
                    
                    return true;
                }
                
                bool SetBackgroundColor(vint start, vint length, Color value) override
                {
                    SetMap(backgroundColors, start, length, value);
                    return true;
                }
                
                bool SetInlineObject(vint start, vint length, const InlineObjectProperties& properties) override
                {
                    if(inlineElements.Keys().Contains(properties.backgroundImage.Obj()))
                    {
                        return false;
                    }
                    for(vint i = 0; i < inlineElements.Count(); ++i)
                    {
                        GuiElementsTextCell* cell = inlineElements.Values().Get(i).textCell;
                        if(start < cell.textRange.location + cell.textRange.length &&
                           cell.textRange.location < start + length)
                            return false;
                    }
                    
                    GuiElementsTextCell* textCell = [[GuiElementsTextCell alloc] initWithGraphicsElement:properties.backgroundImage
                                                                                              properties:properties
                                                                                             andCallback:this];
                    textCell.textRange = NSMakeRange(start, length);
                    
                    NSTextAttachment* attachment = [[NSTextAttachment alloc] init];
                    [attachment setAttachmentCell:textCell];
                    
                    NSAttributedString* attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
                    
                    [textCellStorage addObject:textCell];
                    
                    
                    [textStorage beginEditing];
                    [textStorage replaceCharactersInRange:NSMakeRange(start, 1)
                                     withAttributedString:attachmentStr];
                    
                    if(length > 1)
                    {
                        // well, this is really a hack too
                        // NSTextAttachment has a special character NSAttachmentCharacter 0xfffc to identify attachments
                        // it does NOT run through N characters
                        //
                        // so here we are replacing unused chars with ZERO WIDTH SPACE
                        // we cannot just remove them because it will effect length and also attributes applied at different locations
                        // maybe there are better solutions here?
                        
                        NSString* str = [@"" stringByPaddingToLength:length-1 withString:@"\u200d" startingAtIndex:0];
                        [textStorage replaceCharactersInRange:NSMakeRange(start+1, length-1) withString:str];
                    }
                    [textStorage endEditing];
                    
                    if(properties.backgroundImage)
                    {
                        IGuiGraphicsRenderer* renderer = properties.backgroundImage->GetRenderer();
                        if(renderer)
                        {
                            renderer->SetRenderTarget(renderTarget);
                        }
                        inlineElements.Add(properties.backgroundImage.Obj(), textCell);
                    }
                    
                    SetMap(graphicsElements, start, length, properties.backgroundImage.Obj());
                    needFormatData = true;
                    
                    return true;
                }
                
                bool ResetInlineObject(vint start, vint length) override
                {
                    IGuiGraphicsElement* element = 0;
                    
                    [textStorage beginEditing];
                    if(GetMap(graphicsElements, start, element) && element)
                    {
                        GuiElementsTextCell* textCell = inlineElements[element].textCell;
                        
                        [textStorage enumerateAttributesInRange:NSMakeRange(start, length)
                                                        options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                         {
                             NSTextAttachment* attachment = [attrs objectForKey:NSAttachmentAttributeName];
                             if(attachment)
                             {
                                 [textStorage removeAttribute:NSAttachmentAttributeName range:range];
                                 [textStorage replaceCharactersInRange:NSMakeRange(range.location, 1) withString:@"\u200d"];
                                 
                                 needFormatData = true;
                             }
                         }];
                        
                        [textCellStorage removeObject:textCell];
                    }
                    [textStorage endEditing];
                    
                    return true;
                }
                
                vint GetHeight() override
                {
                    [layoutManager glyphRangeForTextContainer:textContainer];
                    
                    return [layoutManager usedRectForTextContainer:textContainer].size.height;
                }
                
                bool OpenCaret(vint _caret, Color _color, bool _frontSide) override
                {
                    if(!IsValidCaret(_caret))
                        return false;
                    if(caretPos != -1)
                        CloseCaret();
                    
                    caretPos = _caret;
                    caretColor = _color;
                    caretFrontSide = _frontSide;
                    return true;
                }
                
                bool CloseCaret() override
                {
                    if(caretPos == -1)
                        return false;
                    caretPos = -1;
                    return true;
                }
                
                void Render(Rect bounds) override
                {
                    paraOffset = bounds.LeftTop();
                    
                    GenerateFormatData();
                    CGContextRef context = (CGContextRef)(GetCurrentRenderTarget()->GetCGContext());

                    for(vint i = 0; i < backgroundColors.Count(); i++)
                    {
                        TextRange key = backgroundColors.Keys()[i];
                        Color color = backgroundColors.Values()[i];
                        if(color.a > 0)
                        {
                            vint start = key.start;
                            if(start < 0)
                            {
                                start = 0;
                            }
                            
                            CGContextSetRGBFillColor(context, color.r / 255.0f, color.g / 255.0f, color.b / 255.0f, color.a / 255.0f);

                            while(start < charBoundingMetricsMap.Count() && start < key.end)
                            {
                                vint index = charBoundingMetricsMap[start];
                                const BoundingMetrics& charMetrics = glyphBoundingRects[index];
                                
                                CGRect rect = CGRectMake(charMetrics.boundingRect.Left() + (CGFloat)bounds.x1,
                                                         charMetrics.boundingRect.Top() + (CGFloat)bounds.y1,
                                                         charMetrics.boundingRect.Width() + 1.0f,
                                                         charMetrics.boundingRect.Height() + 1.0f);
                                
                                CGContextFillRect(context, rect);
                                
                                start = charMetrics.textPosition + charMetrics.textLength;
                            }
                        }
                    }
                    
                    NSRect rect = NSMakeRect((CGFloat)bounds.Left(),
                                             (CGFloat)bounds.Top(),
                                             maxWidth,
                                             CGFLOAT_MAX);
                    
                    NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
                    [layoutManager drawGlyphsForGlyphRange:glyphRange atPoint:rect.origin];
                    
                    if(caretPos != -1)
                    {
                        Rect caretBounds = GetCaretBounds(caretPos, caretFrontSide);
                        vint x = caretBounds.x1 + bounds.x1;
                        vint y1 = caretBounds.y1 + bounds.y1;
                        vint y2 = y1 + caretBounds.Height();
                        
                        CGPoint points[2];
                        CGContextSetLineWidth(context, 2.0f);
                        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                        
                        points[0] = CGPointMake(x, y1);
                        points[1] = CGPointMake(x, y2);
                        CGContextStrokeLineSegments(context, points, 2);
                    }
                }
                
                vint GetCaret(vint comparingCaret, CaretRelativePosition position, bool& preferFrontSide) override
                {
                    GenerateFormatData();
                    if(position == CaretFirst) return 0;
                    if(position == CaretLast) return paragraphText.Length();
                    if(!IsValidCaret(comparingCaret)) return -1;
                    
                    vint frontLineIndex = -1;
                    vint backLineIndex = -1;
                    GetLineIndexFromTextPos(comparingCaret, frontLineIndex, backLineIndex);
                    vint lineIndex = preferFrontSide ? frontLineIndex : backLineIndex;
                    
                    if(lineIndex == -1)
                        return 0;
                    
                    BoundingMetrics& lineMetrics = lineFragments[lineIndex];
                    
                    vint lineStart = lineMetrics.textPosition;
                    vint lineEnd = lineMetrics.textPosition + lineMetrics.textLength;
                    
                    switch(position)
                    {
                        case CaretLineFirst:
                            return lineStart;
                            
                        case CaretLineLast:
                            return lineEnd;
                            
                        case CaretMoveLeft:
                        {
                            if(comparingCaret == 0)
                            {
                                return 0;
                            }
                            
                            const BoundingMetrics& metrics = glyphBoundingRects[charBoundingMetricsMap[comparingCaret-1]];
                            return metrics.textPosition;
                        }
                            
                        case CaretMoveRight:
                        {
                            if(comparingCaret >= paragraphText.Length()-1)
                            {
                                return paragraphText.Length();
                            }
                            
                            vint index = charBoundingMetricsMap[comparingCaret+1];
                            if(index == glyphBoundingRects.Count()-1)
                                return paragraphText.Length();
                            
                            if(index == charBoundingMetricsMap[comparingCaret])
                            {
                                vint newCaret = glyphBoundingRects[index].textPosition + glyphBoundingRects[index].textLength;
                                if(newCaret == lineEnd)
                                    preferFrontSide = false;
                                return newCaret;
                            }
                            
                            return glyphBoundingRects[index].textPosition;
                        }
                            
                        case CaretMoveUp:
                        {
                            if(lineIndex == 0)
                            {
                                return comparingCaret;
                            }
                            else
                            {
                                Rect bounds = GetCaretBounds(comparingCaret, preferFrontSide);
                                preferFrontSide = true;
                                return GetCaretFromXWithLine(bounds.x1, lineIndex-1);
                            }
                        }
                        case CaretMoveDown:
                        {
                            if(lineIndex == lineFragments.Count()-1)
                            {
                                return comparingCaret;
                            }
                            else
                            {
                                Rect bounds = GetCaretBounds(comparingCaret, preferFrontSide);
                                preferFrontSide = false;
                                return GetCaretFromXWithLine(bounds.x1, lineIndex+1);
                            }
                        }
                            
                        default:
                            break;
                    }
                    return -1;
                }
                
                Rect GetCaretBounds(vint caret, bool frontSide) override
                {
                    GenerateFormatData();
                    
                    if(!IsValidCaret(caret)) return Rect();
                    if(paragraphText.Length() == 0) return Rect(Point(0, 0), Size(0, GetHeight()));
                    
                    vint frontLineIndex = -1;
                    vint backLineIndex = -1;
                    GetLineIndexFromTextPos(caret, frontLineIndex, backLineIndex);
                    vint lineIndex = frontSide ? frontLineIndex : backLineIndex;
                    
                    BoundingMetrics& lineMetrics = lineFragments[lineIndex];
                    
                    vint lineStart = lineMetrics.textPosition;
                    vint lineEnd = lineMetrics.textPosition + lineMetrics.textLength;
                    if(caret == lineStart)
                        frontSide = false;
                    else if(caret == lineEnd)
                        frontSide = true;
                    
                    if(frontSide)
                        caret--;
                    
                    const BoundingMetrics& charMetrics = glyphBoundingRects[charBoundingMetricsMap[caret]];
                    
                    if(frontSide)
                    {
                        return Rect(Point(charMetrics.boundingRect.Right(),
                                          charMetrics.boundingRect.Top() + charMetrics.yOffset),
                                    Size(0, charMetrics.lineHeight));
                    }
                    else
                    {
                        return Rect(Point(charMetrics.boundingRect.Left(),
                                          charMetrics.boundingRect.Top() + charMetrics.yOffset),
                                    Size(0, charMetrics.lineHeight));
                    }
                }
                
                vint GetCaretFromPoint(Point point) override
                {
                    GenerateFormatData();
                    
                    vint lineIndex = GetLineIndexFromY(point.y);
                    return GetCaretFromXWithLine(point.x, lineIndex);
                }
                
                Nullable<InlineObjectProperties> GetInlineObjectFromPoint(Point point, vint& start, vint& length) override
                {
                    GenerateFormatData();
                    
                    NSPoint nsp = NSMakePoint(point.x, point.y);
                    for(vint i=0; i<inlineElements.Count(); ++i)
                    {
                        GuiElementsTextCell* cell = inlineElements.Values().Get(i).textCell;
                        
                        if(NSPointInRect(nsp, cell.cellFrame))
                        {
                            IGuiGraphicsElement* element = 0;
                            if(GetMap(graphicsElements, cell.textRange.location, element) && element)
                            {
                                start = cell.textRange.location;
                                length = cell.textRange.length;
                                
                                return cell.properties;
                            }
                        }
                    }
                    return InlineObjectProperties();
                }
                
                vint GetNearestCaretFromTextPos(vint textPos, bool frontSide) override
                {
                    GenerateFormatData();
                    
                    if(!IsValidTextPos(textPos)) return -1;
                    if(textPos == 0 || textPos == paragraphText.Length()) return textPos;
                    
                    vint index = charBoundingMetricsMap[textPos];
                    const BoundingMetrics& metrics = glyphBoundingRects[index];
                    if(metrics.textPosition == textPos)
                        return textPos;
                    else if(frontSide)
                        return metrics.textPosition;
                    else
                        return metrics.textPosition + metrics.textPosition;
                }
                
                bool IsValidCaret(vint caret) override
                {
                    GenerateFormatData();
                    
                    if(!IsValidTextPos(caret)) return false;
                    if(caret == 0 || caret == paragraphText.Length()) return true;
                    if(glyphBoundingRects[charBoundingMetricsMap[caret]].textPosition == caret) return true;
                    
                    return false;
                }
                
                bool IsValidTextPos(vint textPos) override
                {
                    return 0 <= textPos && textPos <= paragraphText.Length();
                }
                
                ///// IGuiTextCellBack
                
                vl::presentation::Point GetParagraphOffset() override
                {
                    return paraOffset;
                }
                
                IGuiGraphicsParagraphCallback* GetParagraphCallback() override
                {
                    return paraCallback;
                }
                
            protected:
                void GenerateFormatData()
                {
                    if(needFormatData)
                    {
                        needFormatData = false;
                        
                        NSRange glyphRange = [layoutManager glyphRangeForTextContainer:textContainer];
                        
                        glyphBoundingRects.Clear();
                        charBoundingMetricsMap.Resize(glyphRange.length);
                        
                        for(NSUInteger i = glyphRange.location; i < glyphRange.length+glyphRange.location; )
                        {
                            NSRect bounding = [layoutManager boundingRectForGlyphRange:NSMakeRange(i, 1) inTextContainer:textContainer];
                            
                            NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:i];
                            
                            // retrieve line height for font at index
                            // since bounding rect may not reflect the line height of the glyph (if there are smaller / larger glyphs within the same line)
                            CGFloat fontLineHeight = bounding.size.height;
                            CGFloat descender = 0;
                            NSDictionary* attrs = [textStorage attributesAtIndex:charIndex effectiveRange:0];
                            NSFont* font = [attrs objectForKey:NSFontAttributeName];
                            if(font)
                            {
                                fontLineHeight = [layoutManager defaultLineHeightForFont:font];
                                descender = [font descender];
                            }
                            
                            CGFloat baselineOffset = [[layoutManager typesetter] baselineOffsetInLayoutManager:layoutManager glyphIndex:i];
                            
                            IGuiGraphicsElement* element = 0;
                            GuiElementsTextCell* cell = 0;
                            if(GetMap(graphicsElements, i, element) && element)
                            {
                                cell = inlineElements.Get(element).textCell;
                                for(vint j=0; j<cell.textRange.length; ++j)
                                {
                                    charBoundingMetricsMap[i-glyphRange.location+j] = charIndex;
                                }
                                
                                fontLineHeight = cell.properties.size.y;
                            }
                            else
                            {
                                charBoundingMetricsMap[i-glyphRange.location] = charIndex;
                            }
                            
                            assert(cell ? cell.textRange.location <= i && i < cell.textRange.location + cell.textRange.length : true);
                            
                            float yOff = 0;
                            if(cell == 0 && bounding.size.height - fontLineHeight != 0)
                            {
                                yOff = bounding.size.height - baselineOffset - descender - fontLineHeight + 1;
                            }
                            
                            vint textLength = cell ? cell.textRange.length : (paragraphText[charIndex] == '\r' ? 2 : 1);
                            
                            glyphBoundingRects.Add(charIndex, BoundingMetrics(i,
                                                                              textLength,
                                                                              fontLineHeight,
                                                                              yOff,
                                                                              Rect(bounding.origin.x,
                                                                                   bounding.origin.y,
                                                                                   bounding.size.width + bounding.origin.x,
                                                                                   bounding.size.height + bounding.origin.y)));
                            
                            if(element)
                            {
                                i += cell.textRange.length;
                            }
                            else
                            {
                                if(paragraphText[charIndex] == '\r')
                                {
                                    i += 1;
                                    charBoundingMetricsMap[i-glyphRange.location] = charIndex;
                                }
                                i += 1;
                            }
                        }
                        
                        NSRange lineFragmentRange;
                        NSUInteger glyphIndex = glyphRange.location;
                        
                        std::vector<BoundingMetrics> metrics;
                        
                        charLineFragmentsMap.Clear();
                        for(;;)
                        {
                            if(![layoutManager isValidGlyphIndex:glyphIndex])
                                break;
                            
                            NSRect lineFragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:glyphIndex
                                                                                      effectiveRange:&lineFragmentRange];
                            
                            if(paragraphText[lineFragmentRange.location + lineFragmentRange.length - 2] == L'\r')
                            {
                                lineFragmentRange.length -= 2;
                            }
                            else if(paragraphText[lineFragmentRange.location + lineFragmentRange.length - 1] == L'\n')
                            {
                                lineFragmentRange.length -= 1;
                            }
                            metrics.push_back(BoundingMetrics(lineFragmentRange.location,
                                                              lineFragmentRange.length,
                                                              lineFragmentRect.size.height,
                                                              0,
                                                              Rect(lineFragmentRect.origin.x,
                                                                   lineFragmentRect.origin.y,
                                                                   lineFragmentRect.size.width + lineFragmentRect.origin.x,
                                                                   lineFragmentRect.size.height + lineFragmentRect.origin.y)));
                            
                            for(NSUInteger i=lineFragmentRange.location; i<lineFragmentRange.location+lineFragmentRange.length; ++i)
                            {
                                NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:i];

                                charLineFragmentsMap.Set(charIndex, metrics.size()-1);
                            }
                            
                            glyphIndex += lineFragmentRange.length;
                            
                        }
                        lineFragments.Resize(metrics.size());
                        for(size_t i=0; i<metrics.size(); ++i)
                        {
                            lineFragments.Set(i, metrics[i]);
                        }
                    }
                }
                
                vint GetLineIndexFromY(vint y)
                {
                    for(vint i=0; i<lineFragments.Count(); ++i)
                    {
                        const BoundingMetrics& metrics = lineFragments[i];
                        if(metrics.boundingRect.Top() <= y &&
                           metrics.boundingRect.Bottom() >= y)
                        {
                            return i;
                        }
                    }
                    return -1;
                }
                
                vint GetCaretFromXWithLine(vint x, vint lineIndex)
                {
                    if(lineIndex == -1) return -1;
                    
                    const BoundingMetrics& metrics = lineFragments[lineIndex];
                    vint lineStart = metrics.textPosition;
                    vint lineEnd = metrics.textPosition + metrics.textLength;
                    
                    float minLineX = 0;
                    float maxLineX = 0;
                    
                    for(vint i = lineStart; i < lineEnd; )
                    {
                        NSUInteger charIndex = [layoutManager characterIndexForGlyphAtIndex:i];

                        const BoundingMetrics& charMetrics = glyphBoundingRects[charBoundingMetricsMap[charIndex]];

                        float minX = charMetrics.boundingRect.Left();
                        float maxX = minX + charMetrics.boundingRect.Width();
                        
                        if(minLineX > minX) minLineX = minX;
                        if(maxLineX < maxX) maxLineX = maxX;
                        
                        if(minX <= x && x < maxX)
                        {
                            // todo, check NSGlyphAttributeBidiLevel for layout direction
                            float d1 = x-minX;
                            float d2 = maxX-x;
                            if(d1 <= d2)
                            {
                                return i;
                            }
                            else
                            {
                                return i + charMetrics.textLength;
                            }
                        }
                        i += charMetrics.textLength;
                    }
                    
                    if(x < minLineX) return lineStart;
                    if(x >= maxLineX) return lineEnd;
                    return lineStart;
                }
                
                void GetLineIndexFromTextPos(vint textPos, vint& frontLineIndex, vint& backLineIndex)
                {
                    frontLineIndex = -1;
                    backLineIndex = -1;
                    vint start = 0;
                    vint end = lineFragments.Count() - 1;
                    while(start <= end)
                    {
                        vint middle = (start + end) / 2;
                        BoundingMetrics& metrics = lineFragments[middle];
                        vint lineStart = metrics.textPosition;
                        vint lineEnd = metrics.textPosition + metrics.textLength;
                        
                        if(textPos < lineStart)
                        {
                            end = middle - 1;
                        }
                        else if(textPos > lineEnd)
                        {
                            start = middle + 1;
                        }
                        else if(textPos == lineStart && middle != 0)
                        {
                            // BoundingMetrics& anotherLine = lineFragments[middle - 1];
                            frontLineIndex = middle - 1;
                            backLineIndex = middle;
                            return;
                        }
                        else if(textPos == lineEnd && middle != lineFragments.Count() - 1)
                        {
                            frontLineIndex = middle;
                            backLineIndex = middle + 1;
                            return;
                        }
                        else
                        {
                            frontLineIndex = middle;
                            backLineIndex = middle;
                            return;
                        }
                    }
                }
                
                // copy pasta!
                 template<typename T>
                 void CutMap(Dictionary<TextRange, T>& map, vint start, vint length)
                 {
                     vint end=start+length;
                     for(vint i=map.Count()-1;i>=0;i--)
                     {
                         TextRange key=map.Keys()[i];
                         if(key.start<end && start<key.end)
                         {
                             T value=map.Values()[i];
                             
                             vint s1=key.start;
                             vint s2=key.start>start?key.start:start;
                             vint s3=key.end<end?key.end:end;
                             vint s4=key.end;
                             
                             map.Remove(key);
                             if(s1<s2)
                             {
                                 map.Add(TextRange(s1, s2), value);
                             }
                             if(s2<s3)
                             {
                                 map.Add(TextRange(s2, s3), value);
                             }
                             if(s3<s4)
                             {
                                 map.Add(TextRange(s3, s4), value);
                             }
                         }
                     }
                 }
                 
                 template<typename T>
                 void UpdateOverlappedMap(Dictionary<TextRange, T>& map, vint start, vint length, const T& value)
                 {
                     vint end=start+length;
                     for(vint i=map.Count()-1;i>=0;i--)
                     {
                         TextRange key=map.Keys()[i];
                         if(key.start<end && start<key.end)
                         {
                             map.Set(key, value);
                         }
                     }
                 }
                 
                 template<typename T>
                 void DefragmentMap(Dictionary<TextRange, T>& map)
                 {
                     vint lastIndex=map.Count()-1;
                     T lastValue=map.Values()[lastIndex];
                     for(vint i=map.Count()-2;i>=-1;i--)
                     {
                         if(i==-1 || map.Values()[i]!=lastValue)
                         {
                             if(lastIndex-i>0)
                             {
                                 vint start=map.Keys()[i+1].start;
                                 vint end=map.Keys()[lastIndex].end;
                                 TextRange key(start, end);
                                 
                                 for(vint j=lastIndex;j>i;j--)
                                 {
                                     map.Remove(map.Keys()[j]);
                                 }
                                 map.Add(key, lastValue);
                             }
                             lastIndex=i;
                             if(i!=-1)
                             {
                                 lastValue=map.Values()[i];
                             }
                         }
                     }
                 }
                 
                 template<typename T>
                 void SetMap(Dictionary<TextRange, T>& map, vint start, vint length, const T& value)
                 {
                     CutMap(map, start, length);
                     UpdateOverlappedMap(map, start, length, value);
                     DefragmentMap(map);
                 }
                 
                 template<typename T>
                 bool GetMap(Dictionary<TextRange, T>& map, vint textPosition, T& value)
                 {
                     vint start=0;
                     vint end=map.Count()-1;
                     while(start<=end)
                     {
                         vint middle=(start+end)/2;
                         TextRange key=map.Keys()[middle];
                         if(textPosition<key.start)
                         {
                             end=middle-1;
                         }
                         else if(textPosition>=key.end)
                         {
                             start=middle+1;
                         }
                         else
                         {
                             value=map.Values()[middle];
                             return true;
                         }
                     }
                     return false;
                 }
            };
            
            Ptr<elements::IGuiGraphicsParagraph> CoreTextLayoutProvider::CreateParagraph(const WString& text, elements::IGuiGraphicsRenderTarget* renderTarget, elements::IGuiGraphicsParagraphCallback* callback)
            {
                return new CoreTextParagraph(this, text, (ICoreGraphicsRenderTarget*)renderTarget, callback);
            }
            
        }
        
    }
    
}