/***********************************************************************
Vczh Library++ 3.0
Developer: Zihan Chen(vczh)
GacUI::Control System

Interfaces:
***********************************************************************/

#ifndef VCZH_PRESENTATION_CONTROLS_GUITEXTAUTOCOMPLETE
#define VCZH_PRESENTATION_CONTROLS_GUITEXTAUTOCOMPLETE

#include "GuiTextGeneralOperations.h"
#include "../ListControlPackage/GuiTextListControls.h"
#include "../GuiWindowControls.h"

namespace vl
{
	namespace presentation
	{
		namespace controls
		{

/***********************************************************************
GuiTextBoxAutoCompleteBase
***********************************************************************/
			
			/// <summary>The base class of text box auto complete controller.</summary>
			class GuiTextBoxAutoCompleteBase : public Object, public virtual ICommonTextEditCallback
			{
			protected:
				elements::GuiColorizedTextElement*					element;
				SpinLock*											elementModifyLock;
				compositions::GuiGraphicsComposition*				ownerComposition;
				GuiPopup*											autoCompletePopup;
				GuiTextList*										autoCompleteList;
				TextPos												autoCompleteStartPosition;

				bool												IsPrefix(const WString& prefix, const WString& candidate);
			public:
				GuiTextBoxAutoCompleteBase();
				~GuiTextBoxAutoCompleteBase();

				void												Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)override;
				void												Detach()override;
				void												TextEditPreview(TextEditPreviewStruct& arguments)override;
				void												TextEditNotify(const TextEditNotifyStruct& arguments)override;
				void												TextCaretChanged(const TextCaretChangedStruct& arguments)override;
				void												TextEditFinished(vuint editVersion)override;

				/// <summary>Get the list state.</summary>
				/// <returns>Returns true if the list is visible.</returns>
				bool												IsListOpening();
				/// <summary>Notify the list to be visible.</summary>
				/// <param name="startPosition">The text position to show the list.</param>
				void												OpenList(TextPos startPosition);
				/// <summary>Notify the list to be invisible.</summary>
				void												CloseList();
				/// <summary>Set the content of the list.</summary>
				/// <param name="list">The content of the list.</param>
				void												SetListContent(const collections::SortedList<WString>& items);
				/// <summary>Get the last start position when the list is opened.</summary>
				/// <returns>The start position.</returns>
				TextPos												GetListStartPosition();
				/// <summary>Select the previous item.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				bool												SelectPreviousListItem();
				/// <summary>Select the next item.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				bool												SelectNextListItem();
				/// <summary>Apply the selected item into the text box.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				bool												ApplySelectedListItem();
				/// <summary>Get the selected item.</summary>
				/// <returns>The text of the selected item. Returns empty if there is no selected item.</returns>
				WString												GetSelectedListItem();
				/// <summary>Highlight a candidate item in the list.</summary>
				/// <param name="editingText">The text to match an item.</param>
				void												HighlightList(const WString& editingText);
			};

/***********************************************************************
GuiGrammarAutoComplete
***********************************************************************/
			
			/// <summary>Grammar based auto complete controller.</summary>
			class GuiGrammarAutoComplete
				: public GuiTextBoxAutoCompleteBase
				, private RepeatingParsingExecutor::CallbackBase
				, private RepeatingTaskExecutor<RepeatingParsingOutput>
			{
				typedef collections::List<Ptr<parsing::ParsingScopeSymbol>>		ParsingScopeSymbolList;
			public:
				/// <summary>The auto complete list data.</summary>
				struct AutoCompleteData : ParsingContext
				{
					/// <summary>Available candidate tokens (in lexer token index).</summary>
					collections::List<vint>							candidates;
					/// <summary>Available candidate tokens (in lexer token index) that marked with @AutoCompleteCandidate().</summary>
					collections::List<vint>							shownCandidates;
					/// <summary>Candidate symbols.</summary>
					ParsingScopeSymbolList							candidateSymbols;
					/// <summary>The start position of the editing token in global coordination.</summary>
					TextPos											startPosition;
				};

				/// <summary>The analysed data from an input code.</summary>
				struct Context
				{
					/// <summary>The input data.</summary>
					RepeatingParsingOutput							input;
					/// <summary>The rule name that can parse the code of the selected context.</summary>
					WString											rule;
					/// <summary>Range of the original context in the input.</summary>
					parsing::ParsingTextRange						originalRange;
					/// <summary>The original context in the syntax tree.</summary>
					Ptr<parsing::ParsingTreeObject>					originalNode;
					/// <summary>The modified context in the syntax tree.</summary>
					Ptr<parsing::ParsingTreeObject>					modifiedNode;
					/// <summary>The modified code of the selected context.</summary>
					WString											modifiedCode;
					/// <summary>The edit version of modified code.</summary>
					vuint											modifiedEditVersion;
					/// <summary>The analysed auto complete list data.</summary>
					Ptr<AutoCompleteData>							autoComplete;

					Context()
						:modifiedEditVersion(0)
					{
					}
				};
			private:
				Ptr<parsing::tabling::ParsingGeneralParser>			grammarParser;
				collections::SortedList<WString>					leftRecursiveRules;
				bool												editing;

				SpinLock											editTraceLock;
				collections::List<TextEditNotifyStruct>				editTrace;

				SpinLock											contextLock;
				Context												context;
				
				void												Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)override;
				void												Detach()override;
				void												TextEditPreview(TextEditPreviewStruct& arguments)override;
				void												TextEditNotify(const TextEditNotifyStruct& arguments)override;
				void												TextCaretChanged(const TextCaretChangedStruct& arguments)override;
				void												TextEditFinished(vuint editVersion)override;
				void												OnParsingFinishedAsync(const RepeatingParsingOutput& output)override;
				void												CollectLeftRecursiveRules();

				vint												UnsafeGetEditTraceIndex(vuint editVersion);
				TextPos												ChooseCorrectTextPos(TextPos pos, const regex::RegexTokens& tokens);
				void												ExecuteRefresh(Context& newContext);

				bool												NormalizeTextPos(Context& newContext, elements::text::TextLines& lines, TextPos& pos);
				void												ExecuteEdit(Context& newContext);

				void												DeleteFutures(collections::List<parsing::tabling::ParsingState::Future*>& futures);
				regex::RegexToken*									TraverseTransitions(
																		parsing::tabling::ParsingState& state,
																		parsing::tabling::ParsingTransitionCollector& transitionCollector,
																		TextPos stopPosition,
																		collections::List<parsing::tabling::ParsingState::Future*>& nonRecoveryFutures,
																		collections::List<parsing::tabling::ParsingState::Future*>& recoveryFutures
																		);
				regex::RegexToken*									SearchValidInputToken(
																		parsing::tabling::ParsingState& state,
																		parsing::tabling::ParsingTransitionCollector& transitionCollector,
																		TextPos stopPosition,
																		Context& newContext,
																		collections::SortedList<vint>& tableTokenIndices
																		);

				TextPos												GlobalTextPosToModifiedTextPos(Context& newContext, TextPos pos);
				TextPos												ModifiedTextPosToGlobalTextPos(Context& newContext, TextPos pos);
				void												ExecuteCalculateList(Context& newContext);

				void												Execute(const RepeatingParsingOutput& input)override;
				void												PostList(const Context& newContext, bool byGlobalCorrection);
				void												Initialize();
			protected:

				/// <summary>Called when the context of the code is selected. It is encouraged to set the "candidateSymbols" field in "context.autoComplete". If there is a <see cref="ILanguageProvider"/> binded to the <see cref="RepeatingParsingExecutor"/>, this function can be automatically done.</summary>
				/// <param name="context">The selected context.</param>
				virtual void										OnContextFinishedAsync(Context& context);

				/// <summary>Call this function in the derived class's destructor when it overrided <see cref="OnContextFinishedAsync"/>.</summary>
				void												EnsureAutoCompleteFinished();
			public:
				/// <summary>Create the auto complete controller with a created parsing executor.</summary>
				/// <param name="_parsingExecutor">The parsing executor.</param>
				GuiGrammarAutoComplete(Ptr<RepeatingParsingExecutor> _parsingExecutor);
				/// <summary>Create the auto complete controller with a specified grammar and start rule to create a <see cref="RepeatingParsingExecutor"/>.</summary>
				/// <param name="_grammarParser">Parser generated from a grammar.</param>
				/// <param name="_grammarRule"></param>
				GuiGrammarAutoComplete(Ptr<parsing::tabling::ParsingGeneralParser> _grammarParser, const WString& _grammarRule);
				~GuiGrammarAutoComplete();

				/// <summary>Get the internal parsing executor.</summary>
				/// <returns>The parsing executor.</returns>
				Ptr<RepeatingParsingExecutor>						GetParsingExecutor();
			};
		}
	}
}

#endif