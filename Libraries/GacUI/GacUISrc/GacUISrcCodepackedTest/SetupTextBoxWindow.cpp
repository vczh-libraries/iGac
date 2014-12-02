#include "..\..\Public\Source\GacUI.h"

using namespace vl::stream;
using namespace vl::regex;
using namespace vl::regex_internal;
using namespace vl::parsing;
using namespace vl::parsing::tabling;
using namespace vl::parsing::definitions;
using namespace vl::collections;

namespace colorization
{

/***********************************************************************
XmlGrammarColorizer
***********************************************************************/

	class XmlGrammarColorizer : public GuiGrammarColorizer
	{
	public:
		XmlGrammarColorizer()
			:GuiGrammarColorizer(CreateAutoRecoverParser(xml::XmlLoadTable()), L"XDocument")
		{
			SetColor(L"Boundary", Color(0, 0, 255));
			SetColor(L"Comment", Color(0, 128, 0));
			SetColor(L"TagName", Color(163, 21, 21));
			SetColor(L"AttName", Color(255, 0, 0));
			SetColor(L"AttValue", Color(128, 0, 255));
			EndSetColors();
		}
	};

/***********************************************************************
JsonGrammarColorizer
***********************************************************************/

	class JsonGrammarColorizer : public GuiGrammarColorizer
	{
	public:
		JsonGrammarColorizer()
			:GuiGrammarColorizer(CreateAutoRecoverParser(json::JsonLoadTable()), L"JRoot")
		{
			SetColor(L"Boundary", Color(255, 0, 0));
			SetColor(L"Keyword", Color(0, 0, 255));
			SetColor(L"AttName", Color(64, 64, 64));
			SetColor(L"Number", Color(128, 0, 255));
			SetColor(L"String", Color(163, 21, 2));
			EndSetColors();
		}
	};

/***********************************************************************
SymbolLookup
***********************************************************************/

	Ptr<ParsingScopeSymbol> CreateSymbolFromNode(Ptr<ParsingTreeObject> obj, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder);
	void CreateSubSymbols(ParsingScopeSymbol* symbol, Ptr<ParsingTreeObject> node, const WString& memberName, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder);

	class GrammarSymbol : public ParsingScopeSymbol
	{
	public:
		GrammarSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder, const WString& semantic)
			:ParsingScopeSymbol(finder->Node(node->GetMember(L"name")).Cast<ParsingTreeToken>()->GetValue(), executor->GetSemanticId(semantic))
		{
			SetNode(node);
		}
	};

	class EnumFieldSymbol : public GrammarSymbol
	{
	protected:
		WString GetDisplayInternal(vint semanticId)
		{
			return literalString;
		}
	public:
		WString literalString;

		EnumFieldSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:GrammarSymbol(node, executor, finder, L"EnumValue")
		{
			WString value=finder->Node(node->GetMember(L"name")).Cast<ParsingTreeToken>()->GetValue();
			literalString=SerializeString(value);
		}
	};

	class ClassFieldSymbol : public GrammarSymbol
	{
	public:
		ClassFieldSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:GrammarSymbol(node, executor, finder, L"Field")
		{
		}
	};

	class TypeSymbol : public GrammarSymbol
	{
	public:
		TypeSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:GrammarSymbol(node, executor, finder, L"Type")
		{
		}
	};

	class EnumSymbol : public TypeSymbol
	{
	public:
		EnumSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:TypeSymbol(node, executor, finder)
		{
			CreateScope();
			CreateSubSymbols(this, node, L"members", executor, finder);
		}
	};

	class ClassSymbol : public TypeSymbol
	{
	public:
		ClassSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:TypeSymbol(node, executor, finder)
		{
			CreateScope();
			CreateSubSymbols(this, node, L"members", executor, finder);
			CreateSubSymbols(this, node, L"subTypes", executor, finder);
		}
	};

	class TokenSymbol : public GrammarSymbol
	{
	protected:
		WString GetDisplayInternal(vint semanticId)
		{
			return semanticId==literalId?literalString:ParsingScopeSymbol::GetDisplayInternal(semanticId);
		}
	public:
		vint literalId;
		WString literalString;

		TokenSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:GrammarSymbol(node, executor, finder, L"Token")
			,literalId(-1)
		{
			WString value=finder->Node(node->GetMember(L"regex")).Cast<ParsingTreeToken>()->GetValue();
			WString regex=DeserializeString(value);
			if(IsRegexEscapedListeralString(regex))
			{
				literalString=SerializeString(UnescapeTextForRegex(regex));
				AddSemanticId(literalId=executor->GetSemanticId(L"Literal"));
			}
		}
	};

	class RuleSymbol : public GrammarSymbol
	{
	public:
		RuleSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
			:GrammarSymbol(node, executor, finder, L"Rule")
		{
		}
	};

	class ParserDefSymbol : public ParsingScopeSymbol
	{
	public:
		ParserDefSymbol(Ptr<ParsingTreeObject> node, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
		{
			SetNode(node.Obj());
			CreateScope();
			CreateSubSymbols(this, node, L"definitions", executor, finder);
		}
	};


	void CreateSubSymbols(ParsingScopeSymbol* symbol, Ptr<ParsingTreeObject> node, const WString& memberName, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
	{
		if(Ptr<ParsingTreeArray> members=finder->Node(node->GetMember(memberName)).Cast<ParsingTreeArray>())
		{
			FOREACH(Ptr<ParsingTreeNode>, node, members->GetItems())
			{
				if(Ptr<ParsingTreeObject> obj=finder->Node(node).Cast<ParsingTreeObject>())
				{
					symbol->GetScope()->AddSymbol(CreateSymbolFromNode(obj, executor, finder));
				}
			}
		}
	}

	Ptr<ParsingScopeSymbol> CreateSymbolFromNode(Ptr<ParsingTreeObject> obj, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
	{
		if(obj->GetType()==L"EnumMemberDef")
		{
			return new EnumFieldSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"EnumTypeDef")
		{
			return new EnumSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"ClassMemberDef")
		{
			return new ClassFieldSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"ClassTypeDef")
		{
			return new ClassSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"TokenDef")
		{
			return new TokenSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"RuleDef")
		{
			return new RuleSymbol(obj, executor, finder);
		}
		else if(obj->GetType()==L"ParserDef")
		{
			return new ParserDefSymbol(obj, executor, finder);
		}
		else
		{
			return 0;
		}
	}

	LazyList<Ptr<ParsingScopeSymbol>> FindReferencedSymbols(ParsingTreeObject* obj, ParsingScopeFinder* finder)
	{
		ParsingScope* scope=finder->GetScopeFromNode(obj);
		if(obj->GetType()==L"PrimitiveTypeObj")
		{
			WString name=obj->GetMember(L"name").Cast<ParsingTreeToken>()->GetValue();
			return finder->GetSymbolsRecursively(scope, name);
		}
		else if(obj->GetType()==L"SubTypeObj")
		{
			if(Ptr<ParsingTreeObject> parentType=obj->GetMember(L"parentType").Cast<ParsingTreeObject>())
			{
				WString name=obj->GetMember(L"name").Cast<ParsingTreeToken>()->GetValue();
				LazyList<Ptr<ParsingScopeSymbol>> types=FindReferencedSymbols(parentType.Obj(), finder);
				return types
					.SelectMany([=](Ptr<ParsingScopeSymbol> type)
					{
						return finder->GetSymbols(type->GetScope(), name);
					});
			}
		}
		else if(obj->GetType()==L"PrimitiveGrammarDef")
		{
			WString name=obj->GetMember(L"name").Cast<ParsingTreeToken>()->GetValue();
			return finder->GetSymbolsRecursively(scope, name);
		}
		return LazyList<Ptr<ParsingScopeSymbol>>();
	}

	typedef List<Ptr<ParsingScopeSymbol>> TypeList;
	typedef Ptr<TypeList> PtrTypeList;

	PtrTypeList SearchAllTypes(ParsingTreeObject* obj, ParsingScopeFinder* finder)
	{
		PtrTypeList allTypes=new TypeList;
		ParsingScope* scope=finder->GetScopeFromNode(obj);
		while(scope)
		{
			ParsingScope* parentScope=finder->ParentScope(scope->GetOwnerSymbol());
			if(parentScope)
			{
				scope=parentScope;
			}
			else
			{
				break;
			}
		}

		CopyFrom(
			*allTypes.Obj(),
			From(finder->GetSymbolsRecursively(scope))
				.Where([](Ptr<ParsingScopeSymbol> symbol)
				{
					return symbol.Cast<TypeSymbol>();
				})
			);
		vint last=0;

		while(true)
		{
			vint count=allTypes->Count();
			CopyFrom(
				*allTypes.Obj(),
				From(*allTypes.Obj())
					.Skip(last)
					.SelectMany([=](Ptr<ParsingScopeSymbol> symbol)
					{
						return finder->GetSymbols(symbol->GetScope());
					})
					.Where([](Ptr<ParsingScopeSymbol> symbol)
					{
						return symbol.Cast<TypeSymbol>();
					}),
				true
				);
			if(allTypes->Count()==count)
			{
				break;
			}
			last=count;
		}

		return allTypes;
	}

	PtrTypeList IntersectTypes(PtrTypeList firstTypes, PtrTypeList secondTypes)
	{
		if(!firstTypes)
		{
			return secondTypes;
		}
		else if(!secondTypes)
		{
			return firstTypes;
		}
		else
		{
			PtrTypeList types=new TypeList;
			CopyFrom(*types.Obj(), From(*firstTypes.Obj()).Intersect(*secondTypes.Obj()));
			return types;
		}
	}

	PtrTypeList SearchGrammarTypes(ParsingTreeObject* obj, ParsingScopeFinder* finder)
	{
		if(obj->GetType()==L"SequenceGrammarDef" || obj->GetType()==L"AlternativeGrammarDef")
		{
			PtrTypeList firstTypes=SearchGrammarTypes(finder->Node(obj->GetMember(L"first")).Cast<ParsingTreeObject>().Obj(), finder);
			PtrTypeList secondTypes=SearchGrammarTypes(finder->Node(obj->GetMember(L"second")).Cast<ParsingTreeObject>().Obj(), finder);
			return IntersectTypes(firstTypes, secondTypes);
		}
		else if(
			obj->GetType()==L"LoopGrammarDef"
			|| obj->GetType()==L"OptionalGrammarDef"
			|| obj->GetType()==L"AssignGrammarDef"
			|| obj->GetType()==L"UseGrammarDef"
			|| obj->GetType()==L"SetterGrammarDef")
		{
			return SearchGrammarTypes(finder->Node(obj->GetMember(L"grammar")).Cast<ParsingTreeObject>().Obj(), finder);
		}
		else if(obj->GetType()==L"CreateGrammarDef")
		{
			Ptr<ParsingScopeSymbol> type=FindReferencedSymbols(finder->Node(obj->GetMember(L"type")).Cast<ParsingTreeObject>().Obj(), finder)
				.Where([](Ptr<ParsingScopeSymbol> symbol)
				{
					return symbol.Cast<TypeSymbol>();
				})
				.First(0);
			if(type)
			{
				PtrTypeList types=new List<Ptr<ParsingScopeSymbol>>;
				types->Add(type);
				return types;
			}
		}
		return 0;
	}

	LazyList<Ptr<ParsingScopeSymbol>> DetermineGrammarTypes(ParsingTreeObject* obj, ParsingScopeFinder* finder)
	{
		PtrTypeList selectedTypes;
		ParsingTreeObject* currentObj=obj;
		ParsingTreeObject* lastObj=0;
		while(currentObj)
		{
			if(currentObj->GetType()==L"SequenceGrammarDef")
			{
				ParsingTreeObject* first=dynamic_cast<ParsingTreeObject*>(finder->Node(currentObj->GetMember(L"first").Obj()));
				ParsingTreeObject* second=dynamic_cast<ParsingTreeObject*>(finder->Node(currentObj->GetMember(L"second").Obj()));
				PtrTypeList alternativeTypes=lastObj==first?SearchGrammarTypes(second, finder):SearchGrammarTypes(first, finder);
				selectedTypes=IntersectTypes(selectedTypes, alternativeTypes);
			}
			else if(currentObj->GetType()==L"CreateGrammarDef")
			{
				Ptr<ParsingScopeSymbol> type=FindReferencedSymbols(finder->Node(currentObj->GetMember(L"type")).Cast<ParsingTreeObject>().Obj(), finder)
					.Where([](Ptr<ParsingScopeSymbol> symbol)
					{
						return symbol.Cast<TypeSymbol>();
					})
					.First(0);
				if(type)
				{
					PtrTypeList types=new List<Ptr<ParsingScopeSymbol>>;
					types->Add(type);
					selectedTypes=types;
				}
			}
			else if(currentObj->GetType()==L"AssignGrammarDef" || currentObj->GetType()==L"SetterGrammarDef")
			{
				ParsingTreeObject* grammar=dynamic_cast<ParsingTreeObject*>(finder->Node(currentObj->GetMember(L"grammar").Obj()));
				PtrTypeList alternativeTypes=SearchGrammarTypes(grammar, finder);
				selectedTypes=IntersectTypes(selectedTypes, alternativeTypes);
			}
			lastObj=currentObj;
			currentObj=dynamic_cast<ParsingTreeObject*>(finder->ParentNode(currentObj));
		}

		return selectedTypes?selectedTypes:SearchAllTypes(obj, finder);
	}

	LazyList<Ptr<ParsingScopeSymbol>> FindPossibleSymbols(ParsingTreeObject* obj, const WString& field, ParsingScopeFinder* finder)
	{
		ParsingScope* scope=finder->GetScopeFromNode(obj);
		if(obj->GetType()==L"PrimitiveTypeObj")
		{
			if(field==L"name")
			{
				return finder->GetSymbolsRecursively(scope);
			}
		}
		else if(obj->GetType()==L"SubTypeObj")
		{
			if(field==L"name")
			{
				if(Ptr<ParsingTreeObject> parentType=obj->GetMember(L"parentType").Cast<ParsingTreeObject>())
				{
					WString name=obj->GetMember(L"name").Cast<ParsingTreeToken>()->GetValue();
					LazyList<Ptr<ParsingScopeSymbol>> types=FindReferencedSymbols(parentType.Obj(), finder);
					return types
						.SelectMany([=](Ptr<ParsingScopeSymbol> type)
						{
							return finder->GetSymbols(type->GetScope());
						});
				}
			}
		}
		else if(obj->GetType()==L"PrimitiveGrammarDef")
		{
			if(field==L"name")
			{
				return finder->GetSymbolsRecursively(scope);
			}
		}
		else if(obj->GetType()==L"TextGrammarDef")
		{
			if(field==L"text")
			{
				return From(finder->GetSymbolsRecursively(scope))
					.Where([](Ptr<ParsingScopeSymbol> symbol)
					{
						return symbol.Cast<TokenSymbol>();
					});
			}
		}
		else if(obj->GetType()==L"AssignGrammarDef")
		{
			if(field==L"memberName")
			{
				return DetermineGrammarTypes(obj, finder)
					.SelectMany([=](Ptr<ParsingScopeSymbol> type)
					{
						return finder->GetSymbols(type->GetScope());
					})
					.Where([](Ptr<ParsingScopeSymbol> type)
					{
						return type.Cast<ClassFieldSymbol>();
					});
			}
		}
		else if(obj->GetType()==L"SetterGrammarDef")
		{
			if(field==L"memberName")
			{
				return DetermineGrammarTypes(obj, finder)
					.SelectMany([=](Ptr<ParsingScopeSymbol> type)
					{
						return finder->GetSymbols(type->GetScope());
					})
					.Where([](Ptr<ParsingScopeSymbol> type)
					{
						return type.Cast<ClassFieldSymbol>();
					});
			}
			else if(field==L"value")
			{
				WString memberName=finder->Node(obj->GetMember(L"memberName")).Cast<ParsingTreeToken>()->GetValue();
				Ptr<ParsingScopeSymbol> field=FindPossibleSymbols(obj, L"memberName", finder)
					.Where([=](Ptr<ParsingScopeSymbol> type)
					{
						return type->GetName()==memberName;
					})
					.First(0);
				if(field)
				{
					Ptr<ParsingTreeObject> type=finder->Node(field->GetNode()->GetMember(L"type")).Cast<ParsingTreeObject>();
					return FindReferencedSymbols(type.Obj(), finder)
						.SelectMany([=](Ptr<ParsingScopeSymbol> type)
						{
							return finder->GetSymbols(type->GetScope());
						})
						.Where([](Ptr<ParsingScopeSymbol> type)
						{
							return type.Cast<EnumFieldSymbol>();
						});
				}
			}
		}
		return LazyList<Ptr<ParsingScopeSymbol>>();
	}

/***********************************************************************
GrammarLanguageProvider
***********************************************************************/

	class GrammarLanguageProvider : public Object, public ILanguageProvider
	{
	public:
		Ptr<ParsingScopeSymbol> CreateSymbolFromNode(Ptr<ParsingTreeObject> obj, RepeatingParsingExecutor* executor, ParsingScopeFinder* finder)
		{
			return colorization::CreateSymbolFromNode(obj, executor, finder);
		}

		LazyList<Ptr<ParsingScopeSymbol>> FindReferencedSymbols(ParsingTreeObject* obj, parsing::ParsingScopeFinder* finder)
		{
			return colorization::FindReferencedSymbols(obj, finder);
		}

		LazyList<Ptr<ParsingScopeSymbol>> FindPossibleSymbols(ParsingTreeObject* obj, const WString& field, ParsingScopeFinder* finder)
		{
			return colorization::FindPossibleSymbols(obj, field, finder);
		}
	};

/***********************************************************************
ParserGrammarExecutor
***********************************************************************/

	class ParserGrammarExecutor : public RepeatingParsingExecutor
	{
	protected:

		void OnContextFinishedAsync(RepeatingParsingOutput& context)override
		{
			context.finder=new ParsingScopeFinder();
			context.symbol=CreateSymbolFromNode(context.node, this, context.finder.Obj());
			context.finder->InitializeQueryCache(context.symbol.Obj());
		}
	public:
		ParserGrammarExecutor()
			:RepeatingParsingExecutor(CreateBootstrapAutoRecoverParser(), L"ParserDecl", new GrammarLanguageProvider)
		{
		}
	};

/***********************************************************************
ParserGrammarColorizer
***********************************************************************/

class ParserGrammarColorizer : public GuiGrammarColorizer
{
public:
	ParserGrammarColorizer(Ptr<ParserGrammarExecutor> executor)
		:GuiGrammarColorizer(executor)
	{
		SetColor(L"Keyword", Color(0, 0, 255));
		SetColor(L"Attribute", Color(0, 0, 255));
		SetColor(L"String", Color(163, 21, 21));
		SetColor(L"Type", Color(43, 145, 175));
		SetColor(L"Token", Color(163, 73, 164));
		SetColor(L"Rule", Color(255, 127, 39));
		EndSetColors();
	}
};

/***********************************************************************
ParserGrammarAutoComplete
***********************************************************************/

class ParserGrammarAutoComplete : public GuiGrammarAutoComplete
{
public:
	ParserGrammarAutoComplete(Ptr<ParserGrammarExecutor> executor)
		:GuiGrammarAutoComplete(executor)
	{
	}
};

/***********************************************************************
Event Handlers
***********************************************************************/

	void textBox_SwitchLanguage(const WString& sampleCodePath, GuiGrammarColorizer* colorizer, GuiGrammarAutoComplete* autoComplete, GuiMultilineTextBox* textBox)
	{
		textBox->SetColorizer(colorizer);
		textBox->SetAutoComplete(autoComplete);
		FileStream fileStream(sampleCodePath, FileStream::ReadOnly);
		BomDecoder decoder;
		DecoderStream decoderStream(fileStream, decoder);
		StreamReader reader(decoderStream);
		textBox->SetText(reader.ReadToEnd());
		textBox->Select(TextPos(), TextPos());
	}

	void radioGrammar_SelectedChanged(GuiSelectableButton* radio, GuiMultilineTextBox* textBox)
	{
		if(radio->GetSelected())
		{
			Ptr<ParserGrammarExecutor> executor=new ParserGrammarExecutor;
			ParserGrammarColorizer* colorizer=new ParserGrammarColorizer(executor);
			ParserGrammarAutoComplete* autoComplete=new ParserGrammarAutoComplete(executor);
			textBox_SwitchLanguage(L"Resources\\CalculatorDefinition.txt", colorizer, autoComplete, textBox);
		}
	}

	void radioXml_SelectedChanged(GuiSelectableButton* radio, GuiMultilineTextBox* textBox)
	{
		if(radio->GetSelected())
		{
			textBox_SwitchLanguage(L"Resources\\XmlResource.xml", new XmlGrammarColorizer, 0, textBox);
		}
	}

	void radioJson_SelectedChanged(GuiSelectableButton* radio, GuiMultilineTextBox* textBox)
	{
		if(radio->GetSelected())
		{
			textBox_SwitchLanguage(L"Resources\\JsonSample.txt", new JsonGrammarColorizer, 0, textBox);
		}
	}
}

using namespace colorization;

void SetupTextBoxWindow(GuiControlHost* controlHost, GuiGraphicsComposition* container)
{
	container->SetMinSizeLimitation(GuiGraphicsComposition::LimitToElementAndChildren);
	
	GuiMultilineTextBox* textBox=0;
	GuiSelectableButton* radioGrammar=0;
	GuiSelectableButton* radioXml=0;
	GuiSelectableButton* radioJson=0;
	GuiSelectableButton::MutexGroupController* controller=new GuiSelectableButton::MutexGroupController;
	controlHost->AddComponent(controller);

	GuiTableComposition* table=new GuiTableComposition;
	table->SetAlignmentToParent(Margin(0, 0, 0, 0));
	container->AddChild(table);

	table->SetCellPadding(5);
	table->SetRowsAndColumns(2, 4);
	table->SetRowOption(0, GuiCellOption::MinSizeOption());
	table->SetRowOption(1, GuiCellOption::PercentageOption(1.0));
	table->SetColumnOption(0, GuiCellOption::MinSizeOption());
	table->SetColumnOption(1, GuiCellOption::MinSizeOption());
	table->SetColumnOption(2, GuiCellOption::MinSizeOption());
	table->SetColumnOption(3, GuiCellOption::PercentageOption(1.0));
	{
		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(1, 0, 1, 4);

		textBox=g::NewMultilineTextBox();
		textBox->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
		cell->AddChild(textBox->GetBoundsComposition());
	}
	{
		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(0, 0, 1, 1);

		radioGrammar=g::NewRadioButton();
		radioGrammar->SetGroupController(controller);
		radioGrammar->SetText(L"Grammar");
		radioGrammar->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
		radioGrammar->SelectedChanged.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			radioGrammar_SelectedChanged(radioGrammar, textBox);
		});
		cell->AddChild(radioGrammar->GetBoundsComposition());
	}
	{
		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(0, 1, 1, 1);

		radioXml=g::NewRadioButton();
		radioXml->SetGroupController(controller);
		radioXml->SetText(L"Xml");
		radioXml->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
		radioXml->SelectedChanged.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			radioXml_SelectedChanged(radioXml, textBox);
		});
		cell->AddChild(radioXml->GetBoundsComposition());
	}
	{
		GuiCellComposition* cell=new GuiCellComposition;
		table->AddChild(cell);
		cell->SetSite(0, 2, 1, 1);

		radioJson=g::NewRadioButton();
		radioJson->SetGroupController(controller);
		radioJson->SetText(L"Json");
		radioJson->GetBoundsComposition()->SetAlignmentToParent(Margin(0, 0, 0, 0));
		radioJson->SelectedChanged.AttachLambda([=](GuiGraphicsComposition* sender, GuiEventArgs& arguments)
		{
			radioJson_SelectedChanged(radioJson, textBox);
		});
		cell->AddChild(radioJson->GetBoundsComposition());
	}
	radioGrammar->SetSelected(true);
}