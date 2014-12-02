#include "GuiTextColorizer.h"
#include "../Styles/GuiThemeStyleFactory.h"
#include <math.h>

namespace vl
{
	namespace presentation
	{
		namespace controls
		{
			using namespace elements;
			using namespace elements::text;
			using namespace compositions;
			using namespace parsing;
			using namespace parsing::tabling;
			using namespace collections;
			using namespace theme;

/***********************************************************************
GuiTextBoxColorizerBase
***********************************************************************/

			void GuiTextBoxColorizerBase::ColorizerThreadProc(void* argument)
			{
				GuiTextBoxColorizerBase* colorizer=(GuiTextBoxColorizerBase*)argument;
				while(!colorizer->isFinalizing)
				{
					vint lineIndex=-1;
					wchar_t* text=0;
					vuint32_t* colors=0;
					vint length=0;
					vint lexerState=-1;
					vint contextState=-1;

					SPIN_LOCK(*colorizer->elementModifyLock)
					{
						if(colorizer->colorizedLineCount>=colorizer->element->GetLines().GetCount())
						{
							colorizer->isColorizerRunning=false;
							goto CANCEL_COLORIZING;
						}

						lineIndex=colorizer->colorizedLineCount++;
						TextLine& line=colorizer->element->GetLines().GetLine(lineIndex);
						length=line.dataLength;
						text=new wchar_t[length+2];
						colors=new vuint32_t[length+2];
						memcpy(text, line.text, sizeof(wchar_t)*length);
						text[length]=L'\r';
						text[length+1]=L'\n';
						lexerState=lineIndex==0?colorizer->GetLexerStartState():colorizer->element->GetLines().GetLine(lineIndex-1).lexerFinalState;
						contextState=lineIndex==0?colorizer->GetContextStartState():colorizer->element->GetLines().GetLine(lineIndex-1).contextFinalState;
					}

					colorizer->ColorizeLineWithCRLF(lineIndex, text, colors, length+2, lexerState, contextState);

					SPIN_LOCK(*colorizer->elementModifyLock)
					{
						if(lineIndex<colorizer->colorizedLineCount && lineIndex<colorizer->element->GetLines().GetCount())
						{
							TextLine& line=colorizer->element->GetLines().GetLine(lineIndex);
							line.lexerFinalState=lexerState;
							line.contextFinalState=contextState;
							for(vint i=0;i<length;i++)
							{
								line.att[i].colorIndex=colors[i];
							}
						}
						delete[] text;
						delete[] colors;
					}
				}
			CANCEL_COLORIZING:
				colorizer->colorizerRunningEvent.Leave();
			}

			void GuiTextBoxColorizerBase::StartColorizer()
			{
				if(!isColorizerRunning)
				{
					isColorizerRunning=true;
					colorizerRunningEvent.Enter();
					ThreadPoolLite::Queue(&GuiTextBoxColorizerBase::ColorizerThreadProc, this);
				}
			}

			void GuiTextBoxColorizerBase::StopColorizer(bool forever)
			{
				isFinalizing=true;
				colorizerRunningEvent.Enter();
				colorizerRunningEvent.Leave();
				colorizedLineCount=0;
				if(!forever)
				{
					isFinalizing=false;
				}
			}

			void GuiTextBoxColorizerBase::StopColorizerForever()
			{
				StopColorizer(true);
			}

			GuiTextBoxColorizerBase::GuiTextBoxColorizerBase()
				:element(0)
				,elementModifyLock(0)
				,colorizedLineCount(0)
				,isColorizerRunning(false)
				,isFinalizing(false)
			{
			}

			GuiTextBoxColorizerBase::~GuiTextBoxColorizerBase()
			{
				StopColorizerForever();
			}

			void GuiTextBoxColorizerBase::Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)
			{
				if(_element)
				{
					SPIN_LOCK(_elementModifyLock)
					{
						element=_element;
						elementModifyLock=&_elementModifyLock;
						StartColorizer();
					}
				}
			}

			void GuiTextBoxColorizerBase::Detach()
			{
				if(element && elementModifyLock)
				{
					StopColorizer(false);
					SPIN_LOCK(*elementModifyLock)
					{
						element=0;
						elementModifyLock=0;
					}
				}
			}

			void GuiTextBoxColorizerBase::TextEditPreview(TextEditPreviewStruct& arguments)
			{
			}

			void GuiTextBoxColorizerBase::TextEditNotify(const TextEditNotifyStruct& arguments)
			{
				if(element && elementModifyLock)
				{
					SPIN_LOCK(*elementModifyLock)
					{
						vint line
							=arguments.originalStart.row<arguments.originalEnd.row
							?arguments.originalStart.row
							:arguments.originalEnd.row;
						if(colorizedLineCount>line)
						{
							colorizedLineCount=line;
						}
						StartColorizer();
					}
				}
			}

			void GuiTextBoxColorizerBase::TextCaretChanged(const TextCaretChangedStruct& arguments)
			{
			}

			void GuiTextBoxColorizerBase::TextEditFinished(vuint editVersion)
			{
			}

			void GuiTextBoxColorizerBase::RestartColorizer()
			{
				if(element && elementModifyLock)
				{
					SPIN_LOCK(*elementModifyLock)
					{
						colorizedLineCount=0;
						StartColorizer();
					}
				}
			}

/***********************************************************************
GuiTextBoxRegexColorizer
***********************************************************************/

			struct GuiTextBoxRegexColorizerProcData
			{
				GuiTextBoxRegexColorizer*		colorizer;
				vint							lineIndex;
				const wchar_t*					text;
				vuint32_t*						colors;
				vint							contextState;
			};

			void GuiTextBoxRegexColorizer::ColorizerProc(void* argument, vint start, vint length, vint token)
			{
				GuiTextBoxRegexColorizerProcData& data=*(GuiTextBoxRegexColorizerProcData*)argument;
				data.colorizer->ColorizeTokenContextSensitive(data.lineIndex, data.text, start, length, token, data.contextState);
				for(vint i=0;i<length;i++)
				{
					data.colors[start+i]=(int)token+1;
				}
			}

			GuiTextBoxRegexColorizer::GuiTextBoxRegexColorizer()
			{
				colors.Resize(1);
			}

			GuiTextBoxRegexColorizer::~GuiTextBoxRegexColorizer()
			{
				StopColorizerForever();
			}

			elements::text::ColorEntry GuiTextBoxRegexColorizer::GetDefaultColor()
			{
				return defaultColor;
			}

			collections::List<WString>& GuiTextBoxRegexColorizer::GetTokenRegexes()
			{
				return tokenRegexes;
			}

			collections::List<elements::text::ColorEntry>& GuiTextBoxRegexColorizer::GetTokenColors()
			{
				return tokenColors;
			}

			collections::List<elements::text::ColorEntry>& GuiTextBoxRegexColorizer::GetExtraTokenColors()
			{
				return extraTokenColors;
			}

			vint GuiTextBoxRegexColorizer::GetExtraTokenIndexStart()
			{
				if(lexer)
				{
					return tokenColors.Count();
				}
				else
				{
					return -1;
				}
			}

			bool GuiTextBoxRegexColorizer::SetDefaultColor(elements::text::ColorEntry value)
			{
				if(lexer)
				{
					return false;
				}
				else
				{
					defaultColor=value;
					return true;
				}
			}

			vint GuiTextBoxRegexColorizer::AddToken(const WString& regex, elements::text::ColorEntry color)
			{
				if(lexer)
				{
					return -1;
				}
				else
				{
					tokenRegexes.Add(regex);
					tokenColors.Add(color);
					return tokenColors.Count()-1;
				}
			}

			vint GuiTextBoxRegexColorizer::AddExtraToken(elements::text::ColorEntry color)
			{
				if(lexer)
				{
					return -1;
				}
				else
				{
					extraTokenColors.Add(color);
					return extraTokenColors.Count()-1;
				}
			}

			void GuiTextBoxRegexColorizer::ClearTokens()
			{
				tokenRegexes.Clear();
				tokenColors.Clear();
				extraTokenColors.Clear();
				lexer=0;
			}

			void GuiTextBoxRegexColorizer::Setup()
			{
				if(lexer || tokenRegexes.Count()==0)
				{
					colors.Resize(1);
					colors[0]=defaultColor;
				}
				else
				{
					lexer=new regex::RegexLexer(tokenRegexes);
					colors.Resize(1+tokenRegexes.Count()+extraTokenColors.Count());
					colors[0]=defaultColor;
					for(vint i=0;i<tokenColors.Count();i++)
					{
						colors[i+1]=tokenColors[i];
					}
					for(vint i=0;i<extraTokenColors.Count();i++)
					{
						colors[i+1+tokenColors.Count()]=extraTokenColors[i];
					}
					colorizer=new regex::RegexLexerColorizer(lexer->Colorize());
				}
			}

			void GuiTextBoxRegexColorizer::ColorizeTokenContextSensitive(vint lineIndex, const wchar_t* text, vint start, vint length, vint& token, vint& contextState)
			{
			}

			vint GuiTextBoxRegexColorizer::GetLexerStartState()
			{
				return lexer?colorizer->GetStartState():-1;
			}

			vint GuiTextBoxRegexColorizer::GetContextStartState()
			{
				return 0;
			}

			void GuiTextBoxRegexColorizer::ColorizeLineWithCRLF(vint lineIndex, const wchar_t* text, vuint32_t* colors, vint length, vint& lexerState, vint& contextState)
			{
				memset(colors, 0, sizeof(*colors)*length);
				if(lexer)
				{
					GuiTextBoxRegexColorizerProcData data;
					data.colorizer=this;
					data.lineIndex=lineIndex;
					data.text=text;
					data.colors=colors;
					data.contextState=contextState;

					colorizer->Reset(lexerState);
					colorizer->Colorize(text, length, &GuiTextBoxRegexColorizer::ColorizerProc, &data);

					lexerState=colorizer->GetCurrentState();
					contextState=data.contextState;
				}
				else
				{
					lexerState=-1;
					contextState=-1;
				}
			}

			const GuiTextBoxRegexColorizer::ColorArray& GuiTextBoxRegexColorizer::GetColors()
			{
				return colors;
			}

/***********************************************************************
GuiGrammarColorizer
***********************************************************************/

			void GuiGrammarColorizer::OnParsingFinishedAsync(const RepeatingParsingOutput& output)
			{
				SPIN_LOCK(contextLock)
				{
					context=output;
					OnContextFinishedAsync(context);
				}
				RestartColorizer();
			}

			void GuiGrammarColorizer::OnContextFinishedAsync(const RepeatingParsingOutput& context)
			{
			}

			void GuiGrammarColorizer::Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)
			{
				GuiTextBoxRegexColorizer::Attach(_element, _elementModifyLock, _ownerComposition, editVersion);
				RepeatingParsingExecutor::CallbackBase::Attach(_element, _elementModifyLock, _ownerComposition, editVersion);
			}

			void GuiGrammarColorizer::Detach()
			{
				GuiTextBoxRegexColorizer::Detach();
				RepeatingParsingExecutor::CallbackBase::Detach();
				if(element && elementModifyLock)
				{
					parsingExecutor->EnsureTaskFinished();
					StopColorizer(false);
				}
			}

			void GuiGrammarColorizer::TextEditPreview(TextEditPreviewStruct& arguments)
			{
				GuiTextBoxRegexColorizer::TextEditPreview(arguments);
				RepeatingParsingExecutor::CallbackBase::TextEditPreview(arguments);
			}

			void GuiGrammarColorizer::TextEditNotify(const TextEditNotifyStruct& arguments)
			{
				GuiTextBoxRegexColorizer::TextEditNotify(arguments);
				RepeatingParsingExecutor::CallbackBase::TextEditNotify(arguments);
			}

			void GuiGrammarColorizer::TextCaretChanged(const TextCaretChangedStruct& arguments)
			{
				GuiTextBoxRegexColorizer::TextCaretChanged(arguments);
				RepeatingParsingExecutor::CallbackBase::TextCaretChanged(arguments);
			}

			void GuiGrammarColorizer::TextEditFinished(vuint editVersion)
			{
				GuiTextBoxRegexColorizer::TextEditFinished(editVersion);
				RepeatingParsingExecutor::CallbackBase::TextEditFinished(editVersion);
			}

			void GuiGrammarColorizer::OnSemanticColorize(SemanticColorizeContext& context, const RepeatingParsingOutput& input)
			{
				Ptr<ILanguageProvider> languageProvider=parsingExecutor->GetLanguageProvider();
				if(languageProvider)
				{
					if(Ptr<ParsingScopeSymbol> symbol=languageProvider->FindReferencedSymbols(context.tokenParent, input.finder.Obj()).First(0))
					{
						vint semanticId=From(symbol->GetSemanticIds())
							.Intersect(*context.acceptableSemanticIds.Obj())
							.First(-1);
						if(semanticId!=-1)
						{
							context.semanticId=semanticId;
						}
					}
				}
			}

			void GuiGrammarColorizer::EnsureColorizerFinished()
			{
				parsingExecutor->EnsureTaskFinished();
				StopColorizerForever();
				SPIN_LOCK(contextLock)
				{
					context=RepeatingParsingOutput();
				}
			}

			GuiGrammarColorizer::GuiGrammarColorizer(Ptr<RepeatingParsingExecutor> _parsingExecutor)
				:RepeatingParsingExecutor::CallbackBase(_parsingExecutor)
			{
				parsingExecutor->AttachCallback(this);
				BeginSetColors();
			}

			GuiGrammarColorizer::GuiGrammarColorizer(Ptr<parsing::tabling::ParsingGeneralParser> _grammarParser, const WString& _grammarRule)
				:RepeatingParsingExecutor::CallbackBase(new RepeatingParsingExecutor(_grammarParser, _grammarRule))
			{
				parsingExecutor->AttachCallback(this);
				BeginSetColors();
			}

			GuiGrammarColorizer::~GuiGrammarColorizer()
			{
				EnsureColorizerFinished();
				parsingExecutor->DetachCallback(this);
			}

			void GuiGrammarColorizer::BeginSetColors()
			{
				ClearTokens();
				colorSettings.Clear();
				text::ColorEntry entry=GetCurrentTheme()->GetDefaultTextBoxColorEntry();
				SetDefaultColor(entry);
				colorSettings.Add(L"Default", entry);
			}

			const collections::SortedList<WString>& GuiGrammarColorizer::GetColorNames()
			{
				return colorSettings.Keys();
			}

			GuiGrammarColorizer::ColorEntry GuiGrammarColorizer::GetColor(const WString& name)
			{
				vint index=colorSettings.Keys().IndexOf(name);
				return index==-1?GetDefaultColor():colorSettings.Values().Get(index);
			}

			void GuiGrammarColorizer::SetColor(const WString& name, const ColorEntry& entry)
			{
				colorSettings.Set(name, entry);
			}

			void GuiGrammarColorizer::SetColor(const WString& name, const Color& color)
			{
				text::ColorEntry entry=GetDefaultColor();
				entry.normal.text=color;
				SetColor(name, entry);
			}

			void GuiGrammarColorizer::EndSetColors()
			{
				SortedList<WString> tokenColors;
				Ptr<ParsingTable> table=parsingExecutor->GetParser()->GetTable();
				semanticColorMap.Clear();

				vint tokenCount=table->GetTokenCount();
				for(vint token=ParsingTable::UserTokenStart;token<tokenCount;token++)
				{
					const ParsingTable::TokenInfo& tokenInfo=table->GetTokenInfo(token);
					const RepeatingParsingExecutor::TokenMetaData& md=parsingExecutor->GetTokenMetaData(token-ParsingTable::UserTokenStart);
					if(md.defaultColorIndex==-1)
					{
						AddToken(tokenInfo.regex, GetDefaultColor());
					}
					else
					{
						WString name=parsingExecutor->GetSemanticName(md.defaultColorIndex);
						vint color=AddToken(tokenInfo.regex, GetColor(name));
						semanticColorMap.Set(md.defaultColorIndex, color);
						tokenColors.Add(name);
					}
				}

				FOREACH_INDEXER(WString, color, index, colorSettings.Keys())
				{
					if(!tokenColors.Contains(color))
					{
						vint semanticId=parsingExecutor->GetSemanticId(color);
						if(semanticId!=-1)
						{
							vint tokenId=AddExtraToken(colorSettings.Values().Get(index));
							vint color=tokenId+tokenCount-ParsingTable::UserTokenStart;
							semanticColorMap.Set(semanticId, color);
						}
					}
				}
				Setup();
			}

			void GuiGrammarColorizer::ColorizeTokenContextSensitive(vint lineIndex, const wchar_t* text, vint start, vint length, vint& token, vint& contextState)
			{
				SPIN_LOCK(contextLock)
				{
					ParsingTreeObject* node=context.node.Obj();
					if(node && token!=-1 && parsingExecutor->GetTokenMetaData(token).hasContextColor)
					{
						ParsingTextPos pos(lineIndex, start);
						SemanticColorizeContext scContext;
						if(SemanticColorizeContext::RetriveContext(scContext, pos, node, parsingExecutor.Obj()))
						{
							const RepeatingParsingExecutor::FieldMetaData& md=parsingExecutor->GetFieldMetaData(scContext.type, scContext.field);
							vint semantic=md.colorIndex;
							scContext.semanticId=-1;

							if(scContext.acceptableSemanticIds)
							{
								OnSemanticColorize(scContext, context);
								if(md.semantics->Contains(scContext.semanticId))
								{
									semantic=scContext.semanticId;
								}
							}

							if(semantic!=-1)
							{
								vint index=semanticColorMap.Keys().IndexOf(semantic);
								if(index!=-1)
								{
									token=semanticColorMap.Values()[index];
								}
							}
						}
					}
				}
			}

			Ptr<RepeatingParsingExecutor> GuiGrammarColorizer::GetParsingExecutor()
			{
				return parsingExecutor;
			}
		}
	}
}