/***********************************************************************
Vczh Library++ 3.0
Developer: Zihan Chen(vczh)
GacUI::Control System

Interfaces:
***********************************************************************/

#ifndef VCZH_PRESENTATION_CONTROLS_GUITEXTELEMENTOPERATOR
#define VCZH_PRESENTATION_CONTROLS_GUITEXTELEMENTOPERATOR

#include "../GuiContainerControls.h"

namespace vl
{
	namespace presentation
	{
		namespace controls
		{

/***********************************************************************
Common Operations
***********************************************************************/
			
			/// <summary>An text edit callback for text box controls.</summary>
			class ICommonTextEditCallback : public virtual IDescriptable, public Description<ICommonTextEditCallback>
			{
			public:
				/// <summary>Callback data for text editing preview.</summary>
				struct TextEditPreviewStruct
				{
					/// <summary>The start position of the selection before replacing. This field can be modified.</summary>
					TextPos								originalStart;
					/// <summary>The end position of the selection before replacing. This field can be modified.</summary>
					TextPos								originalEnd;
					/// <summary>The text of the selection before replacing.</summary>
					WString								originalText;
					/// <summary>The text of the selection after replacing. This field can be modified.</summary>
					WString								inputText;
					/// <summary>The base edit version.</summary>
					vuint								editVersion;
					/// <summary>True if this modification is raised by the keyboard.</summary>
					bool								keyInput;

					TextEditPreviewStruct()
						:editVersion(0)
						,keyInput(false)
					{
					}
				};

				/// <summary>Callback data for text editing.</summary>
				struct TextEditNotifyStruct
				{
					/// <summary>The start position of the selection before replacing.</summary>
					TextPos								originalStart;
					/// <summary>The end position of the selection before replacing.</summary>
					TextPos								originalEnd;
					/// <summary>The text of the selection before replacing.</summary>
					WString								originalText;
					/// <summary>The start position of the selection after replacing.</summary>
					TextPos								inputStart;
					/// <summary>The end position of the selection after replacing.</summary>
					TextPos								inputEnd;
					/// <summary>The text of the selection after replacing.</summary>
					WString								inputText;
					/// <summary>The created edit version.</summary>
					vuint								editVersion;
					/// <summary>True if this modification is raised by the keyboard.</summary>
					bool								keyInput;

					TextEditNotifyStruct()
						:editVersion(0)
						,keyInput(false)
					{
					}
				};
				
				/// <summary>Callback data for text caret changing.</summary>
				struct TextCaretChangedStruct
				{
					/// <summary>The start position of the selection before caret changing.</summary>
					TextPos								oldBegin;
					/// <summary>The end position of the selection before caret changing.</summary>
					TextPos								oldEnd;
					/// <summary>The start position of the selection after caret changing.</summary>
					TextPos								newBegin;
					/// <summary>The end position of the selection after caret changing.</summary>
					TextPos								newEnd;
					/// <summary>The current edit version.</summary>
					vuint								editVersion;

					TextCaretChangedStruct()
						:editVersion(0)
					{
					}
				};

				/// <summary>Called when the callback is attached to a text box control.</summary>
				/// <param name="element">The element that used in the text box control.</param>
				/// <param name="elementModifyLock">The lock that pretect the element.</param>
				/// <param name="ownerComposition">The owner composition of this element.</param>
				/// <param name="editVersion">The current edit version.</param>
				virtual void							Attach(elements::GuiColorizedTextElement* element, SpinLock& elementModifyLock, compositions::GuiGraphicsComposition* ownerComposition, vuint editVersion)=0;
				/// <summary>Called when the callback is detached from a text box control.</summary>
				virtual void							Detach()=0;
				/// <summary>Called before the text is edited.</summary>
				/// <param name="arguments">The data for this callback.</param>
				virtual void							TextEditPreview(TextEditPreviewStruct& arguments)=0;
				/// <summary>Called after the text is edited and before the caret is changed.</summary>
				/// <param name="arguments">The data for this callback.</param>
				virtual void							TextEditNotify(const TextEditNotifyStruct& arguments)=0;
				/// <summary>Called after the caret is changed.</summary>
				/// <param name="arguments">The data for this callback.</param>
				virtual void							TextCaretChanged(const TextCaretChangedStruct& arguments)=0;
				/// <summary>Called after the text is edited and after the caret is changed.</summary>
				/// <param name="editVersion">The current edit version.</param>
				virtual void							TextEditFinished(vuint editVersion)=0;
			};

/***********************************************************************
RepeatingParsingExecutor
***********************************************************************/

			/// <summary>A data structure storing the parsing input for text box control.</summary>
			struct RepeatingParsingInput
			{
				/// <summary>The text box edit version of the code.</summary>
				vuint									editVersion;
				/// <summary>The code.</summary>
				WString									code;

				RepeatingParsingInput()
					:editVersion(0)
				{
				}
			};

			/// <summary>A data structure storing the parsing result for text box control.</summary>
			struct RepeatingParsingOutput
			{
				/// <summary>The parsed syntax tree.</summary>
				Ptr<parsing::ParsingTreeObject>			node;
				/// <summary>The text box edit version of the code.</summary>
				vuint									editVersion;
				/// <summary>The code.</summary>
				WString									code;
				/// <summary>The root symbol from semantic analyzing.</summary>
				Ptr<parsing::ParsingScopeSymbol>		symbol;
				/// <summary>The finder for the root symbol from semantic analyzing.</summary>
				Ptr<parsing::ParsingScopeFinder>		finder;

				RepeatingParsingOutput()
					:editVersion(0)
				{
				}
			};

			class RepeatingParsingExecutor;

			/// <summary>Language semantic metadata provider for text box that editing code.</summary>
			class ILanguageProvider : public IDescriptable, public Description<ILanguageProvider>
			{
			public:
				/// <summary>Create a symbol from a node.</summary>
				/// <param name="obj">The node.</param>
				/// <param name="executor">The executor storing metadatas for a grammar.</param>
				/// <param name="finder">The finder for traversing nodes and symbols.</param>
				/// <returns>The created symbol.</returns>
				virtual Ptr<parsing::ParsingScopeSymbol>							CreateSymbolFromNode(Ptr<parsing::ParsingTreeObject> obj, RepeatingParsingExecutor* executor, parsing::ParsingScopeFinder* finder)=0;
				
				/// <summary>Get all referenced symbols (in most cases, one) for a node.</summary>
				/// <param name="obj">The node.</param>
				/// <param name="finder">The finder for traversing nodes and symbols.</param>
				/// <returns>All referenced symbols.</returns>
				virtual collections::LazyList<Ptr<parsing::ParsingScopeSymbol>>		FindReferencedSymbols(parsing::ParsingTreeObject* obj, parsing::ParsingScopeFinder* finder)=0;
				
				/// <summary>Get all possible symbols for a specified field of a node.</summary>
				/// <param name="obj">The node.</param>
				/// <param name="field">The field name.</param>
				/// <param name="finder">The finder for traversing nodes and symbols.</param>
				/// <returns>All possible symbols.</returns>
				virtual collections::LazyList<Ptr<parsing::ParsingScopeSymbol>>		FindPossibleSymbols(parsing::ParsingTreeObject* obj, const WString& field, parsing::ParsingScopeFinder* finder)=0;
			};

			/// <summary>Repeating parsing executor.</summary>
			class RepeatingParsingExecutor : public RepeatingTaskExecutor<RepeatingParsingInput>, public Description<RepeatingParsingExecutor>
			{
			public:
				/// <summary>Callback.</summary>
				class ICallback : public virtual Interface
				{
				public:
					/// <summary>Callback when a parsing task is finished.</summary>
					/// <param name="output">the result of the parsing.</param>
					virtual void											OnParsingFinishedAsync(const RepeatingParsingOutput& output)=0;
					/// <summary>Callback when <see cref="RepeatingParsingExecutor"/> requires enabling or disabling automatically repeating calling to the SubmitTask function.</summary>
					/// <param name="enabled">Set to true to require an automatically repeating calling to the SubmitTask function</param>
					virtual void											RequireAutoSubmitTask(bool enabled)=0;
				};

				/// <summary>A base class for implementing a callback.</summary>
				class CallbackBase : public virtual ICallback, public virtual ICommonTextEditCallback
				{
				private:
					bool													callbackAutoPushing;
					elements::GuiColorizedTextElement*						callbackElement;
					SpinLock*												callbackElementModifyLock;

				protected:
					Ptr<RepeatingParsingExecutor>							parsingExecutor;

				public:
					CallbackBase(Ptr<RepeatingParsingExecutor> _parsingExecutor);
					~CallbackBase();

					void													RequireAutoSubmitTask(bool enabled)override;
					void													Attach(elements::GuiColorizedTextElement* _element, SpinLock& _elementModifyLock, compositions::GuiGraphicsComposition* _ownerComposition, vuint editVersion)override;
					void													Detach()override;
					void													TextEditPreview(TextEditPreviewStruct& arguments)override;
					void													TextEditNotify(const TextEditNotifyStruct& arguments)override;
					void													TextCaretChanged(const TextCaretChangedStruct& arguments)override;
					void													TextEditFinished(vuint editVersion)override;
				};

				struct TokenMetaData
				{
					vint													tableTokenIndex;
					vint													lexerTokenIndex;
					vint													defaultColorIndex;
					bool													hasContextColor;
					bool													hasAutoComplete;
					bool													isCandidate;
					WString													unescapedRegexText;
				};

				struct FieldMetaData
				{
					vint													colorIndex;
					Ptr<collections::List<vint>>							semantics;
				};
			private:
				Ptr<parsing::tabling::ParsingGeneralParser>					grammarParser;
				WString														grammarRule;
				Ptr<ILanguageProvider>										languageProvider;
				collections::List<ICallback*>								callbacks;
				collections::List<ICallback*>								activatedCallbacks;
				ICallback*													autoPushingCallback;

				typedef collections::Pair<WString, WString>					FieldDesc;
				collections::Dictionary<WString, vint>						tokenIndexMap;
				collections::SortedList<WString>							semanticIndexMap;
				collections::Dictionary<vint, TokenMetaData>				tokenMetaDatas;
				collections::Dictionary<FieldDesc, FieldMetaData>			fieldMetaDatas;

			protected:

				void														Execute(const RepeatingParsingInput& input)override;
				void														PrepareMetaData();

				/// <summary>Called when semantic analyzing is needed. It is encouraged to set the "symbol" and "finder" fields in "context" argument.</summary>
				/// <param name="context">The parsing result.</param>
				virtual void												OnContextFinishedAsync(RepeatingParsingOutput& context);
			public:
				/// <summary>Initialize the parsing executor.</summary>
				/// <param name="_grammarParser">Parser generated from a grammar.</param>
				/// <param name="_grammarRule">The rule name to parse a complete code.</param>
				/// <param name="_languageProvider">The language provider to create semantic metadats, it can be null.</param>
				RepeatingParsingExecutor(Ptr<parsing::tabling::ParsingGeneralParser> _grammarParser, const WString& _grammarRule, Ptr<ILanguageProvider> _languageProvider=0);
				~RepeatingParsingExecutor();
				
				/// <summary>Get the internal parser that parse the text.</summary>
				Ptr<parsing::tabling::ParsingGeneralParser>					GetParser();
				/// <summary>Detach callback.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				/// <param name="value">The callback.</param>
				bool														AttachCallback(ICallback* value);
				/// <summary>Detach callback.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				/// <param name="value">The callback.</param>
				bool														DetachCallback(ICallback* value);
				/// <summary>Activate a callback. Activating a callback means that the callback owner has an ability to watch a text box modification, e.g., an attached <see cref="ICommonTextEditCallback"/> that is also an <see cref="ICallback"/>. The <see cref="RepeatingParsingExecutor"/> may require one of the activated callback to push code for parsing automatically via a call to <see cref="ICallback::RequireAutoSubmitTask"/>.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				/// <param name="value">The callback.</param>
				bool														ActivateCallback(ICallback* value);
				/// <summary>Deactivate a callback. See <see cref="ActivateCallback"/> for deatils.</summary>
				/// <returns>Returns true if this operation succeeded.</returns>
				/// <param name="value">The callback.</param>
				bool														DeactivateCallback(ICallback* value);
				/// <summary>Get the language provider.</summary>
				/// <returns>The language provider.</returns>
				Ptr<ILanguageProvider>										GetLanguageProvider();

				vint														GetTokenIndex(const WString& tokenName);
				vint														GetSemanticId(const WString& name);
				WString														GetSemanticName(vint id);
				const TokenMetaData&										GetTokenMetaData(vint regexTokenIndex);
				const FieldMetaData&										GetFieldMetaData(const WString& type, const WString& field);

				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetAttribute(vint index, const WString& name, vint argumentCount);
				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetColorAttribute(vint index);
				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetContextColorAttribute(vint index);
				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetSemanticAttribute(vint index);
				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetCandidateAttribute(vint index);
				Ptr<parsing::tabling::ParsingTable::AttributeInfo>			GetAutoCompleteAttribute(vint index);

				/*
				@Color(ColorName)
					field:	color of the token field when the token type is marked with @ContextColor
					token:	color of the token
				@ContextColor()
					token:	the color of the token may be changed if the token field is marked with @Color or @Semantic
				@Semantic(Type1, Type2, ...)
					field:	After resolved symbols for this field, only types of symbols that specified in the arguments are acceptable.
				@Candidate()
					token:	when the token can be available after the editing caret, than it will be in the auto complete list.
				@AutoComplete()
					token:	when the token is editing, an auto complete list will appear if possible
				*/
			};

/***********************************************************************
ParsingContext
***********************************************************************/

			struct ParsingContext
			{
				/// <summary>Token syntax tree for the selected token.</summary>
				parsing::ParsingTreeToken*								foundToken;
				/// <summary>The object syntax tree parent of the token.</summary>
				parsing::ParsingTreeObject*								tokenParent;
				/// <summary>Type of the parent.</summary>
				WString													type;
				/// <summary>Field of the parent that contains the token.</summary>
				WString													field;
				/// <summary>All acceptable semantic ids.</summary>
				Ptr<collections::List<vint>>							acceptableSemanticIds;
				
				ParsingContext()
					:foundToken(0)
					,tokenParent(0)
				{
				}

				static bool												RetriveContext(ParsingContext& output, parsing::ParsingTreeNode* foundNode, RepeatingParsingExecutor* executor);
				static bool												RetriveContext(ParsingContext& output, parsing::ParsingTextPos pos, parsing::ParsingTreeObject* rootNode, RepeatingParsingExecutor* executor);
				static bool												RetriveContext(ParsingContext& output, parsing::ParsingTextRange range, parsing::ParsingTreeObject* rootNode, RepeatingParsingExecutor* executor);
			};
		}
	}
}

#endif