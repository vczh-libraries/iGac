/***********************************************************************
Vczh Library++ 3.0
Developer: Zihan Chen(vczh)
GacUI::Control System

Interfaces:
***********************************************************************/

#ifndef VCZH_PRESENTATION_CONTROLS_GUITEXTCOLORIZER
#define VCZH_PRESENTATION_CONTROLS_GUITEXTCOLORIZER

#include "GuiTextGeneralOperations.h"

namespace vl
{
	namespace presentation
	{
		namespace controls
		{

/***********************************************************************
GuiTextBoxColorizerBase
***********************************************************************/
			
			/// <summary>The base class of text box colorizer.</summary>
			class GuiTextBoxColorizerBase : public Object, public virtual ICommonTextEditCallback
			{
			public:
				typedef collections::Array<elements::text::ColorEntry>			ColorArray;
			protected:
				elements::GuiColorizedTextElement*			element;
				SpinLock*									elementModifyLock;
				volatile vint								colorizedLineCount;
				volatile bool								isColorizerRunning;
				volatile bool								isFinalizing;
				SpinLock									colorizerRunningEvent;

				static void									ColorizerThreadProc(void* argument);

				void										StartColorizer();
				void										StopColorizer(bool forever);
				void										StopColorizerForever();
			public:
				GuiTextBoxColorizerBase();
				~GuiTextBoxColorizerBase();

				void										Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)override;
				void										Detach()override;
				void										TextEditPreview(TextEditPreviewStruct& arguments)override;
				void										TextEditNotify(const TextEditNotifyStruct& arguments)override;
				void										TextCaretChanged(const TextCaretChangedStruct& arguments)override;
				void										TextEditFinished(vuint editVersion)override;
				void										RestartColorizer();

				/// <summary>Get the lexical analyzer start state for the first line.</summary>
				/// <returns>The lexical analyzer start state for the first line.</returns>
				virtual vint								GetLexerStartState()=0;
				/// <summary>Get the context sensitive start state for the first line.</summary>
				/// <returns>The context sensitive start state for the first line.</returns>
				virtual vint								GetContextStartState()=0;
				/// <summary>Colorizer one line with a start state.</summary>
				/// <param name="lineIndex">Line index.</param>
				/// <param name="text">Text buffer.</param>
				/// <param name="colors">Color index buffer. The index should be in [0 .. [M:vl.presentation.controls.GuiTextBoxColorizerBase.GetColors]()-1].</param>
				/// <param name="length">The length of the buffer.</param>
				/// <param name="lexerState">The lexical analyzer state for this line. After executing this function, the new value of this argument indicates the new state.</param>
				/// <param name="contextState">The context sensitive state for this line. After executing this function, the new value of this argument indicates the new state.</param>
				virtual void								ColorizeLineWithCRLF(vint lineIndex, const wchar_t* text, vuint32_t* colors, vint length, vint& lexerState, vint& contextState)=0;
				/// <summary>Get the supported colors ordered by their indices.</summary>
				/// <returns>The supported colors ordered by their indices.</returns>
				virtual const ColorArray&					GetColors()=0;
			};

/***********************************************************************
GuiTextBoxRegexColorizer
***********************************************************************/

			/// <summary>Regex based colorizer.</summary>
			class GuiTextBoxRegexColorizer : public GuiTextBoxColorizerBase
			{
			protected:
				Ptr<regex::RegexLexer>										lexer;
				Ptr<regex::RegexLexerColorizer>								colorizer;
				ColorArray													colors;

				elements::text::ColorEntry									defaultColor;
				collections::List<WString>									tokenRegexes;
				collections::List<elements::text::ColorEntry>				tokenColors;
				collections::List<elements::text::ColorEntry>				extraTokenColors;

				static void													ColorizerProc(void* argument, vint start, vint length, vint token);
			public:
				/// <summary>Create the colorizer.</summary>
				GuiTextBoxRegexColorizer();
				~GuiTextBoxRegexColorizer();

				/// <summary>Get the default color.</summary>
				/// <returns>The default color.</returns>
				elements::text::ColorEntry									GetDefaultColor();
				/// <summary>Get all regular expressions for tokens.</summary>
				/// <returns>All regular expressions for tokens.</returns>
				collections::List<WString>&									GetTokenRegexes();
				/// <summary>Get all colors for tokens.</summary>
				/// <returns>All colors for tokens.</returns>
				collections::List<elements::text::ColorEntry>&				GetTokenColors();
				/// <summary>Get all colors for extra tokens.</summary>
				/// <returns>All colors for extra tokens.</returns>
				collections::List<elements::text::ColorEntry>&				GetExtraTokenColors();
				/// <summary>Get the first token index for the first extra token.</summary>
				/// <returns>The first token index for the first extra token. Returns -1 if this operation failed.</returns>
				vint														GetExtraTokenIndexStart();
				
				/// <summary>Set the default color. Call [M:vl.presentation.controls.GuiTextBoxRegexColorizer.Setup] after finishing all configuration.</summary>
				/// <returns>Returns the token index of this token. Returns -1 if this operation failed.</returns>
				/// <param name="value">The default color.</param>
				bool														SetDefaultColor(elements::text::ColorEntry value);
				/// <summary>Add a token type. Call [M:vl.presentation.controls.GuiTextBoxRegexColorizer.Setup] after finishing all configuration.</summary>
				/// <returns>Returns the token index of this token. Returns -1 if this operation failed.</returns>
				/// <param name="regex">The regular expression for this token type.</param>
				/// <param name="color">The color for this token type.</param>
				vint														AddToken(const WString& regex, elements::text::ColorEntry color);
				/// <summary>Add an extra  token type. Call [M:vl.presentation.controls.GuiTextBoxRegexColorizer.Setup] after finishing all configuration.</summary>
				/// <returns>Returns the extra token index of this token. The token index for this token is regex-token-count + extra-token-index Returns -1 if this operation failed.</returns>
				/// <param name="color">The color for this token type.</param>
				vint														AddExtraToken(elements::text::ColorEntry color);
				/// <summary>Clear all token color settings.</summary>
				void														ClearTokens();
				/// <summary>Setup the colorizer. After that, the colorizer cannot be changed.</summary>
				void														Setup();
				/// <summary>Callback function to set context sensitive state and change token accordingly.</summary>
				/// <param name="lineIndex">Line index.</param>
				/// <param name="text">Text buffer.</param>
				/// <param name="start">The start position of the token.</param>
				/// <param name="length">The length of the token.</param>
				/// <param name="token">The token type. After executing this function, the new value of this argument indicates the new token type.</param>
				/// <param name="contextState">The context sensitive state. After executing this function, the new value of this argument indicates the new state.</param>
				virtual void												ColorizeTokenContextSensitive(vint lineIndex, const wchar_t* text, vint start, vint length, vint& token, vint& contextState);

				vint														GetLexerStartState()override;
				vint														GetContextStartState()override;
				void														ColorizeLineWithCRLF(vint lineIndex, const wchar_t* text, vuint32_t* colors, vint length, vint& lexerState, vint& contextState)override;
				const ColorArray&											GetColors()override;
			};

/***********************************************************************
GuiGrammarColorizer
***********************************************************************/

			/// <summary>Grammar based colorizer.</summary>
			class GuiGrammarColorizer : public GuiTextBoxRegexColorizer, private RepeatingParsingExecutor::CallbackBase
			{
				typedef collections::Pair<WString, WString>					FieldDesc;
				typedef collections::Dictionary<FieldDesc, vint>			FieldContextColors;
				typedef collections::Dictionary<FieldDesc, vint>			FieldSemanticColors;
				typedef elements::text::ColorEntry							ColorEntry;
			public:
				/// <summary>Context for doing semantic colorizing.</summary>
				struct SemanticColorizeContext : ParsingContext
				{
					/// <summary>Output semantic id that comes from one the argument in the @Semantic attribute.</summary>
					vint													semanticId;
				};
			private:
				collections::Dictionary<WString, ColorEntry>				colorSettings;
				collections::Dictionary<vint, vint>							semanticColorMap;

				SpinLock													contextLock;
				RepeatingParsingOutput										context;

				void														OnParsingFinishedAsync(const RepeatingParsingOutput& output)override;
			protected:
				/// <summary>Called when the node is parsed successfully before restarting colorizing.</summary>
				/// <param name="context">The result of the parsing.</param>
				virtual void												OnContextFinishedAsync(const RepeatingParsingOutput& context);

				void														Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)override;
				void														Detach()override;
				void														TextEditPreview(TextEditPreviewStruct& arguments)override;
				void														TextEditNotify(const TextEditNotifyStruct& arguments)override;
				void														TextCaretChanged(const TextCaretChangedStruct& arguments)override;
				void														TextEditFinished(vuint editVersion)override;

				/// <summary>Called when a @SemanticColor attribute in a grammar is activated during colorizing to determine a color for the token. If there is a <see cref="ILanguageProvider"/> binded to the <see cref="RepeatingParsingExecutor"/>, this function can be automatically done.</summary>
				/// <param name="context">Context for doing semantic colorizing.</param>
				/// <param name="input">The corressponding result from the <see cref="RepeatingParsingExecutor"/>.</param>
				virtual void												OnSemanticColorize(SemanticColorizeContext& context, const RepeatingParsingOutput& input);

				/// <summary>Call this function in the derived class's destructor when it overrided <see cref="OnSemanticColorize"/>.</summary>
				void														EnsureColorizerFinished();
			public:
				/// <summary>Create the colorizer with a created parsing executor.</summary>
				/// <param name="_parsingExecutor">The parsing executor.</param>
				GuiGrammarColorizer(Ptr<RepeatingParsingExecutor> _parsingExecutor);
				/// <summary>Create the colorizer with a specified grammar and start rule to create a <see cref="RepeatingParsingExecutor"/>.</summary>
				/// <param name="_grammarParser">Parser generated from a grammar.</param>
				/// <param name="_grammarRule"></param>
				GuiGrammarColorizer(Ptr<parsing::tabling::ParsingGeneralParser> _grammarParser, const WString& _grammarRule);
				~GuiGrammarColorizer();

				/// <summary>Reset all color settings.</summary>
				void														BeginSetColors();
				/// <summary>Get all color names.</summary>
				/// <returns>All color names.</returns>
				const collections::SortedList<WString>&						GetColorNames();
				/// <summary>Get the color for a token theme name (@Color or @ContextColor("theme-name") in the grammar).</summary>
				/// <returns>The color.</returns>
				/// <param name="name">The token theme name.</param>
				ColorEntry													GetColor(const WString& name);
				/// <summary>Set a color for a token theme name (@Color or @ContextColor("theme-name") in the grammar).</summary>
				/// <param name="name">The token theme name.</param>
				/// <param name="entry">The color.</param>
				void														SetColor(const WString& name, const ColorEntry& entry);
				/// <summary>Set a color for a token theme name (@Color or @ContextColor("theme-name") in the grammar).</summary>
				/// <param name="name">The token theme name.</param>
				/// <param name="entry">The color.</param>
				void														SetColor(const WString& name, const Color& color);
				/// <summary>Submit all color settings.</summary>
				void														EndSetColors();
				void														ColorizeTokenContextSensitive(vint lineIndex, const wchar_t* text, vint start, vint length, vint& token, vint& contextState)override;

				/// <summary>Get the internal parsing executor.</summary>
				/// <returns>The parsing executor.</returns>
				Ptr<RepeatingParsingExecutor>								GetParsingExecutor();
			};
		}
	}
}

#endif