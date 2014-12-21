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

using namespace vl::presentation;
using namespace vl::presentation::elements_coregraphics;

@interface GuiElementsTextCell: NSObject<NSTextAttachmentCell>
{
    NSTextAttachment* attachment;
}

@property (nonatomic) NSRange textRange;
@property (nonatomic) IGuiGraphicsElement* graphicsElement;
@property (nonatomic) IGuiGraphicsParagraph::InlineObjectProperties properties;

- (id)initWithGraphicsElement:(IGuiGraphicsElement*)element andProperties:(IGuiGraphicsParagraph::InlineObjectProperties)properties NS_DESIGNATED_INITIALIZER;

@end

@implementation GuiElementsTextCell

- (id)initWithGraphicsElement:(IGuiGraphicsElement*)element andProperties:(IGuiGraphicsParagraph::InlineObjectProperties)properties
{
    if(self = [super init])
    {
        _graphicsElement = element;
        _properties = properties;
    }
    return self;
}

- (void)draw:(NSRect)cellFrame
{
    CGContextRef context = (CGContextRef)(GetCurrentRenderTarget()->GetCGContext());

    IGuiGraphicsRenderer* graphicsRenderer = _graphicsElement->GetRenderer();
    if(graphicsRenderer)
    {
        vl::presentation::Rect bounds(vl::presentation::Point((vl::vint)cellFrame.origin.x,
                                                              (vl::vint)cellFrame.origin.y),
                                      _properties.size);
        graphicsRenderer->Render(bounds);
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

- (BOOL)wantsToTrackMouseForEvent:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex
{
    return NO;
}

- (BOOL)trackMouse:(NSEvent *)theEvent inRect:(NSRect)cellFrame ofView:(NSView *)controlView atCharacterIndex:(NSUInteger)charIndex untilMouseUp:(BOOL)flag
{
    return NO;
}

- (NSRect)cellFrameForTextContainer:(NSTextContainer *)textContainer proposedLineFragment:(NSRect)lineFrag glyphPosition:(NSPoint)position characterIndex:(NSUInteger)charIndex
{
    return NSMakeRect(0, 0, _properties.size.x, _properties.size.y);
}

@end

namespace vl {
    
    namespace presentation {
        
        using namespace elements;
        using namespace collections;
        using namespace osx;
        
        namespace elements_coregraphics {
            
            // todo
            class CoreTextParagraph : public Object, public IGuiGraphicsParagraph
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
                    GuiElementsTextCell* textCell;
                    
                    TextCellContainer(GuiElementsTextCell* c): textCell(c) {}
                    TextCellContainer() {}
                };
                
                typedef Dictionary<IGuiGraphicsElement*, TextCellContainer>     InlineElementList;
                typedef Dictionary<TextRange, IGuiGraphicsElement*>             GraphicsElementMap;
                
            protected:
                IGuiGraphicsLayoutProvider*				provider;
                ICoreGraphicsRenderTarget*              renderTarget;
                WString									paragraphText;
                bool									wrapLine;
                vint									maxWidth;
                List<Color>								usedColors;
                
                GraphicsElementMap						graphicsElements;
                InlineElementList                       inlineElements;
                
                vint									caret;
                Color									caretColor;
                bool									caretFrontSide;
                
                Alignment                               textAlignment;
                
                NSMutableAttributedString*              attributedText;
                NSMutableAttributedString*              renderingTextCopy;
                NSMutableParagraphStyle*                paragrahStyle;
                
            public:
                CoreTextParagraph(IGuiGraphicsLayoutProvider* _provider, const WString& _text, ICoreGraphicsRenderTarget* _renderTarget):
                    provider(_provider),
                    renderTarget(_renderTarget),
                    paragraphText(_text),
                    wrapLine(true),
                    maxWidth(-1),
                    caret(-1),
                    caretFrontSide(false),
                    textAlignment(Alignment::Left)
                {
                    usedColors.Add(Color(0, 0, 0));
                    
                    graphicsElements.Add(TextRange(0, _text.Length()), 0);
                    
                    paragrahStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
                    
                    attributedText = [[NSMutableAttributedString alloc] initWithString:WStringToNSString(_text) attributes:@{NSParagraphStyleAttributeName: paragrahStyle}];

                }
                
            public:
                IGuiGraphicsLayoutProvider* GetProvider()
                {
                    return provider;
                }
                
                IGuiGraphicsRenderTarget*   GetRenderTarget()
                {
                    return renderTarget;
                }
                
                bool GetWrapLine()
                {
                    return wrapLine;
                }
                
                void SetWrapLine(bool value)
                {
                    wrapLine = value;
                }
                
                vint GetMaxWidth()
                {
                    return maxWidth;
                }
                
                void SetMaxWidth(vint value)
                {
                    maxWidth = value;
                }
                
                Alignment GetParagraphAlignment()
                {
                    return textAlignment;
                }
                
                void SetParagraphAlignment(Alignment value)
                {
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
                    
                    [attributedText enumerateAttributesInRange:NSMakeRange(0, attributedText.length)
                                                       options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSParagraphStyle* style = [attrs objectForKey:NSParagraphStyleAttributeName];
                         if(style)
                         {
                             [attributedText removeAttribute:NSParagraphStyleAttributeName range:range];
                         }
                     }];
                     [attributedText addAttribute:NSParagraphStyleAttributeName value:paragrahStyle range:NSMakeRange(0, attributedText.length)];
                }
                
                bool SetFont(vint start, vint length, const WString& value)
                {
                    // remove old fonts
                    [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
                                                       options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                    {
                        NSFont* font = [attrs objectForKey:NSFontAttributeName];
                        if(font)
                        {
                            [attributedText removeAttribute:NSFontAttributeName range:range];
                            
                            font = [[NSFontManager sharedFontManager] convertFont:font toFamily:WStringToNSString(value)];
                        }
                        
                        if(!font)
                        {
                            font = [[NSFontManager sharedFontManager] fontWithFamily:GAC_OSX_DEFAULT_FONT_FAMILY_NAME traits:0 weight:0 size:12];
                            
                        }
                        
                        [attributedText addAttribute:NSFontAttributeName value:font range:range];
                    }];
                    
                    return true;
                }
                
                bool SetSize(vint start, vint length, vint value)
                {
                    [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
                                                       options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSFont* font = [attrs objectForKey:NSFontAttributeName];
                         if(font)
                         {
                             [attributedText removeAttribute:NSFontAttributeName range:range];
                             font = [[NSFontManager sharedFontManager] convertFont:font toSize:value];
                         }
                         if(!font)
                         {
                             font = [[NSFontManager sharedFontManager] fontWithFamily:GAC_OSX_DEFAULT_FONT_FAMILY_NAME traits:0 weight:0 size:value];
                         }
                         [attributedText addAttribute:NSFontAttributeName value:font range:range];
                     }];
                    
                    return true;
                }
                
                bool SetStyle(vint start, vint length, TextStyle value)
                {
                    [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
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
                             [attributedText removeAttribute:NSFontAttributeName range:range];
                           //  font = [[NSFontManager sharedFontManager] convertFont:font toNotHaveTrait:traitMask];
                             
                             NSFontDescriptor* desp = font.fontDescriptor;
                             
                             NSInteger originalSize = [[desp.fontAttributes
                                                        objectForKey:NSFontSizeAttribute] integerValue];
                             if(!originalSize)
                                 originalSize = 12;
                             font = [[NSFontManager sharedFontManager] fontWithFamily:font.familyName
                                                                               traits:traitMask
                                                                               weight:0
                                                                                 size:originalSize];
                             
                         }
                         if(!font)
                         {
                             font = [[NSFontManager sharedFontManager] fontWithFamily:GAC_OSX_DEFAULT_FONT_FAMILY_NAME
                                                                               traits:traitMask
                                                                               weight:0
                                                                                 size:12];
                         }
                         [attributedText addAttribute:NSFontAttributeName value:font range:range];
                         
                         if(value & TextStyle::Underline)
                         {
                             NSNumber* style = [attrs objectForKey:NSUnderlineStyleAttributeName];
                             if(style)
                             {
                                 [attributedText removeAttribute:NSUnderlineStyleAttributeName range:range];
                             }
                         }
                         
                         if(value & TextStyle::Strikeline)
                         {
                             NSNumber* style = [attrs objectForKey:NSStrikethroughStyleAttributeName];
                             if(style)
                             {
                                 [attributedText removeAttribute:NSStrikethroughStyleAttributeName range:range];
                             }
                         }
                    }];
                    
                    if(value & TextStyle::Strikeline)
                    {
                        [attributedText addAttribute:NSStrikethroughStyleAttributeName
                                               value:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]
                                               range:NSMakeRange(start, length)];
                    }
                    
                    if(value & TextStyle::Underline)
                    {
                        [attributedText addAttribute:NSUnderlineStyleAttributeName
                                               value:[NSNumber numberWithInteger:NSUnderlinePatternSolid | NSUnderlineStyleSingle]
                                               range:NSMakeRange(start, length)];
                    }
                    
                    return true;
                }
                
                bool SetColor(vint start, vint length, Color value)
                {
                    [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
                                                       options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSColor* color = [attrs objectForKey:NSForegroundColorAttributeName];
                         if(color)
                         {
                             [attributedText removeAttribute:NSForegroundColorAttributeName range:range];
                         }
                     }];
                    
                    [attributedText addAttribute:NSForegroundColorAttributeName
                                           value:[NSColor colorWithRed:value.r / 255.0f
                                                                 green:value.g / 255.0f
                                                                  blue:value.b / 255.0f
                                                                 alpha:value.a / 255.0f]
                                           range:NSMakeRange(start, length)];
                    
                    return true;
                }
                
                bool SetBackgroundColor(vint start, vint length, Color value)
                {
                    [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
                                                       options:0
                                                    usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                     {
                         NSColor* color = [attrs objectForKey:NSBackgroundColorAttributeName];
                         if(color)
                         {
                             [attributedText removeAttribute:NSBackgroundColorAttributeName range:range];
                         }
                     }];
                    
                    [attributedText addAttribute:NSBackgroundColorAttributeName
                                           value:[NSColor colorWithRed:value.r / 255.0f
                                                                 green:value.g / 255.0f
                                                                  blue:value.b / 255.0f
                                                                 alpha:value.a / 255.0f]
                                           range:NSMakeRange(start, length)];
                    return true;
                }
                
                bool SetInlineObject(vint start, vint length, const InlineObjectProperties& properties, Ptr<IGuiGraphicsElement> value)
                {
                    if(inlineElements.Keys().Contains(value.Obj()))
                    {
                        return false;
                    }
                    for(vint i=0; i<inlineElements.Count(); ++i)
                    {
                        GuiElementsTextCell* cell = inlineElements.Values().Get(i).textCell;
                        if(start < cell.textRange.location + cell.textRange.length &&
                           cell.textRange.location < start + length)
                            return false;
                    }
                
                    GuiElementsTextCell* textCell = [[GuiElementsTextCell alloc] initWithGraphicsElement:value.Obj() andProperties:properties];
                    NSTextAttachment* attachment = [[NSTextAttachment alloc] init];
                    [attachment setAttachmentCell:textCell];
                    
                    NSAttributedString* attachmentStr = [NSAttributedString attributedStringWithAttachment:attachment];
                    
                    [attributedText replaceCharactersInRange:NSMakeRange(start, 1)
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
                        [attributedText replaceCharactersInRange:NSMakeRange(start+1, length-1) withString:str];
                    }
                   
                    IGuiGraphicsRenderer* renderer = value->GetRenderer();
                    if(renderer)
                    {
                        renderer->SetRenderTarget(renderTarget);
                    }
                    inlineElements.Add(value.Obj(), textCell);
                    SetMap(graphicsElements, start, length, value.Obj());
                    
                    return true;
                }
                
                bool ResetInlineObject(vint start, vint length)
                {
                    IGuiGraphicsElement* element = 0;
                    if(GetMap(graphicsElements, start, element) && element)
                    {
                        GuiElementsTextCell* textCell = inlineElements[element].textCell;
                        NSTextAttachment* attachment = textCell.attachment;
                        
                        [attributedText enumerateAttributesInRange:NSMakeRange(start, length)
                                                           options:0
                                                        usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop)
                         {
                             NSFont* font = [attrs objectForKey:NSAttachmentAttributeName];
                             if(font)
                             {
                                 [attributedText removeAttribute:NSAttachmentAttributeName range:range];
                             }
                         }];
                        
                        [attributedText addAttribute:NSAttachmentAttributeName value:attachment range:textCell.textRange];
                    }
                    
                    return false;
                }
                
                vint GetHeight()
                {
                    CGRect bounds = [attributedText boundingRectWithSize:NSMakeSize(maxWidth, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin];
                //    printf("Height: %f", bounds.size.height);
                    return bounds.size.height;
                }
                
                bool OpenCaret(vint _caret, Color _color, bool _frontSide)
                {
                    if(!IsValidCaret(_caret))
                        return false;
                    if(caret != -1)
                        CloseCaret();
                    
                    caret = _caret;
                    caretColor = _color;
                    caretFrontSide = _frontSide;
                    return true;
                }
                
                bool CloseCaret()
                {
                    if(caret == -1)
                        return false;
                    caret = -1;
                    return true;
                }
                
                void Render(Rect bounds)
                {
                    // todo
                    CGContextRef context = (CGContextRef)(GetCurrentRenderTarget()->GetCGContext());

                    NSRect rect = NSMakeRect((CGFloat)bounds.Left(),
                                             (CGFloat)bounds.Top(),
                                             maxWidth,
                                             CGFLOAT_MAX);
                    
                    [attributedText drawInRect:rect];
                    
                    if(caret != -1)
                    {
                        Rect caretBounds = GetCaretBounds(caret, caretFrontSide);
                        vint x = caretBounds.x1 + bounds.x1;
                        vint y1 = caretBounds.y1 + bounds.y1;
                        vint y2 = y1+caretBounds.Height();
                        
                        CGPoint points[2];
                        CGContextSetLineWidth(context, 2.0f);
                        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
                        
                        points[0] = CGPointMake(x, y1);
                        points[1] = CGPointMake(x, y2);
                        CGContextStrokeLineSegments(context, points, 2);
                    }
                }
                
                vint GetCaret(vint comparingCaret, CaretRelativePosition position, bool& preferFrontSide)
                {
                    return -1;
                }
                
                Rect GetCaretBounds(vint caret, bool frontSide)
                {
                    return Rect();
                }
                
                vint GetCaretFromPoint(Point point)
                {
                    return -1;
                }
                
                Ptr<IGuiGraphicsElement> GetInlineObjectFromPoint(Point point, vint& start, vint& length)
                {
                    return Ptr<IGuiGraphicsElement>();
                }
                
                vint GetNearestCaretFromTextPos(vint textPos, bool frontSide)
                {
                    return -1;
                }
                
                bool IsValidCaret(vint caret)
                {
                    return false;
                }
                
                bool IsValidTextPos(vint textPos)
                {
                    return false;
                }
                
                protected:
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
            
            Ptr<elements::IGuiGraphicsParagraph> CoreTextLayoutProvider::CreateParagraph(const WString& str, elements::IGuiGraphicsRenderTarget* renderTarget)
            {
                return new CoreTextParagraph(this, str, (ICoreGraphicsRenderTarget*)renderTarget);
            }
            
        }
        
    }
    
}