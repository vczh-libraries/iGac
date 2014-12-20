//
//  GuiGraphicsLayoutProviderCoreText.mm
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "GuiGraphicsLayoutProviderCoreText.h"

#include "GuiGraphicsCoreGraphics.h"
#include "GuiGraphicsCoreGraphicsRenderers.h"

namespace vl {
    
    namespace presentation {
        
        using namespace elements;
        using namespace collections;
        
        namespace elements_coregraphics {
            
            // todo
            class CoreTextParagraph : public Object, public IGuiGraphicsParagraph
            {
            protected:
                struct TextRange
                {
                    vint								start;
                    vint								end;
                    
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
                
                typedef List<IGuiGraphicsElement*>                          InlineElementList;
                typedef Dictionary<TextRange, Color>                        ColorMap;
                typedef Dictionary<TextRange, IGuiGraphicsElement*>			GraphicsElementMap;
                
            protected:
                IGuiGraphicsLayoutProvider*				provider;
                ICoreGraphicsRenderTarget*              renderTarget;
                WString									paragraphText;
                bool									wrapLine;
                vint									maxWidth;
                List<Color>								usedColors;
                
                GraphicsElementMap						graphicsElements;
                ColorMap								backgroundColors;
                InlineElementList                       inlineElements;
                
                vint									caret;
                Color									caretColor;
                bool									caretFrontSide;
                
                Alignment                               textAlignment;

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
                    backgroundColors.Add(TextRange(0, _text.Length()), Color(0, 0, 0, 0));
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
                    textAlignment = value;
                }
                
                
                bool SetFont(vint start, vint length, const WString& value)
                {
                    return false;
                }
                
                bool SetSize(vint start, vint length, vint value)
                {
                    return false;
                }
                
                bool SetStyle(vint start, vint length, TextStyle value)
                {
                    return false;
                }
                
                bool SetColor(vint start, vint length, Color value)
                {
                    return false;
                }
                
                bool SetBackgroundColor(vint start, vint length, Color value)
                {
                    return false;
                }
                
                bool SetInlineObject(vint start, vint length, const InlineObjectProperties& properties, Ptr<IGuiGraphicsElement> value)
                {
                    return false;
                }
                
                bool ResetInlineObject(vint start, vint length)
                {
                    return false;
                }
                
                
                vint GetHeight()
                {
                    return false;
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
                
            };
            
            Ptr<elements::IGuiGraphicsParagraph> CoreTextLayoutProvider::CreateParagraph(const WString& str, elements::IGuiGraphicsRenderTarget* renderTarget)
            {
                return new CoreTextParagraph(this, str, (ICoreGraphicsRenderTarget*)renderTarget);
            }
            
        }
        
    }
    
}