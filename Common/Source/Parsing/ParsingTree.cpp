#include "ParsingTree.h"
#include "../Collections/Operation.h"
#include "../Collections/OperationForEach.h"

namespace vl
{
	using namespace collections;

	namespace parsing
	{
		vint CompareTextRange(Ptr<ParsingTreeNode> r1, Ptr<ParsingTreeNode> r2)
		{
			return r1->GetCodeRange().start.index-r2->GetCodeRange().start.index;
		}

/***********************************************************************
ParsingTreeNode::TraversalVisitor
***********************************************************************/

		ParsingTreeNode::TraversalVisitor::TraversalVisitor(TraverseDirection _direction)
			:direction(_direction)
		{
		}

		void ParsingTreeNode::TraversalVisitor::BeforeVisit(ParsingTreeToken* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::AfterVisit(ParsingTreeToken* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::BeforeVisit(ParsingTreeObject* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::AfterVisit(ParsingTreeObject* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::BeforeVisit(ParsingTreeArray* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::AfterVisit(ParsingTreeArray* node)
		{
		}

		void ParsingTreeNode::TraversalVisitor::Visit(ParsingTreeToken* node)
		{
			BeforeVisit(node);
			AfterVisit(node);
		}

		void ParsingTreeNode::TraversalVisitor::Visit(ParsingTreeObject* node)
		{
			BeforeVisit(node);
			switch(direction)
			{
			case TraverseDirection::ByTextPosition:
				{
					FOREACH(Ptr<ParsingTreeNode>, node, node->GetSubNodes())
					{
						node->Accept(this);
					}
				}
				break;
			case TraverseDirection::ByStorePosition:
				{
					FOREACH(Ptr<ParsingTreeNode>, node, node->GetMembers().Values())
					{
						node->Accept(this);
					}
				}
				break;
			}
			AfterVisit(node);
		}

		void ParsingTreeNode::TraversalVisitor::Visit(ParsingTreeArray* node)
		{
			BeforeVisit(node);
			switch(direction)
			{
			case TraverseDirection::ByTextPosition:
				{
					FOREACH(Ptr<ParsingTreeNode>, node, node->GetSubNodes())
					{
						node->Accept(this);
					}
				}
				break;
			case TraverseDirection::ByStorePosition:
				{
					FOREACH(Ptr<ParsingTreeNode>, node, node->GetItems())
					{
						node->Accept(this);
					}
				}
				break;
			}
			AfterVisit(node);
		}

/***********************************************************************
ParsingTreeNode
***********************************************************************/

		bool ParsingTreeNode::BeforeAddChild(Ptr<ParsingTreeNode> node)
		{
			return node->parent==0;
		}

		void ParsingTreeNode::AfterAddChild(Ptr<ParsingTreeNode> node)
		{
			node->parent=this;
			ClearQueryCache();
		}

		bool ParsingTreeNode::BeforeRemoveChild(Ptr<ParsingTreeNode> node)
		{
			return node->parent!=0;
		}

		void ParsingTreeNode::AfterRemoveChild(Ptr<ParsingTreeNode> node)
		{
			node->parent=0;
			ClearQueryCache();
		}

		ParsingTreeNode::ParsingTreeNode(const ParsingTextRange& _codeRange)
			:codeRange(_codeRange)
			,parent(0)
		{
		}

		ParsingTreeNode::~ParsingTreeNode()
		{
		}

		ParsingTextRange ParsingTreeNode::GetCodeRange()
		{
			return codeRange;
		}

		void ParsingTreeNode::SetCodeRange(const ParsingTextRange& range)
		{
			codeRange=range;
		}

		void ParsingTreeNode::InitializeQueryCache()
		{
			const NodeList& subNodes=GetSubNodesInternal();
			ClearQueryCache();
			if(&subNodes)
			{
				ParsingTextRange emptyRange;
				CopyFrom(
					cachedOrderedSubNodes,
					From(subNodes)
						.Where([=](Ptr<ParsingTreeNode> node)
						{
							return node->GetCodeRange()!=emptyRange;
						})
						.OrderBy(&CompareTextRange)
					);
				FOREACH(Ptr<ParsingTreeNode>, node, cachedOrderedSubNodes)
				{
					node->InitializeQueryCache();
				}
			}
		}

		void ParsingTreeNode::ClearQueryCache()
		{
			cachedOrderedSubNodes.Clear();
		}

		ParsingTreeNode* ParsingTreeNode::GetParent()
		{
			return parent;
		}

		const ParsingTreeNode::NodeList& ParsingTreeNode::GetSubNodes()
		{
			return cachedOrderedSubNodes;
		}

		ParsingTreeNode* ParsingTreeNode::FindSubNode(const ParsingTextPos& position)
		{
			return FindSubNode(ParsingTextRange(position, position));
		}

		ParsingTreeNode* ParsingTreeNode::FindSubNode(const ParsingTextRange& range)
		{
			if(codeRange.start<=range.start && range.end<=codeRange.end)
			{
				vint start=0;
				vint end=cachedOrderedSubNodes.Count()-1;
				while(start<=end)
				{
					vint selected=(start+end)/2;
					ParsingTreeNode* selectedNode=cachedOrderedSubNodes[selected].Obj();
					const ParsingTextRange& selectedRange=selectedNode->codeRange;
					if(range.end<selectedRange.start)
					{
						end=selected-1;
					}
					else if(range.start>selectedRange.end)
					{
						start=selected+1;
					}
					else if(selectedRange.start<=range.start && range.end<=selectedRange.end)
					{
						return selectedNode;
					}
					else
					{
						return this;
					}
				}
			}
			return this;
		}

		ParsingTreeNode* ParsingTreeNode::FindDeepestNode(const ParsingTextPos& position)
		{
			return FindDeepestNode(ParsingTextRange(position, position));
		}

		ParsingTreeNode* ParsingTreeNode::FindDeepestNode(const ParsingTextRange& range)
		{
			ParsingTreeNode* result=0;
			ParsingTreeNode* node=this;
			do
			{
				result=node;
				node=node->FindSubNode(range);
			}while(result!=node);
			return result;
		}

/***********************************************************************
ParsingTreeToken
***********************************************************************/

		const ParsingTreeToken::NodeList& ParsingTreeToken::GetSubNodesInternal()
		{
			return *(NodeList*)0;
		}

		ParsingTreeToken::ParsingTreeToken(const WString& _value, vint _tokenIndex, const ParsingTextRange& _codeRange)
			:ParsingTreeNode(_codeRange)
			,value(_value)
			,tokenIndex(_tokenIndex)
		{
		}

		ParsingTreeToken::~ParsingTreeToken()
		{
		}

		void ParsingTreeToken::Accept(IVisitor* visitor)
		{
			visitor->Visit(this);
		}

		Ptr<ParsingTreeNode> ParsingTreeToken::Clone()
		{
			Ptr<ParsingTreeToken> clone=new ParsingTreeToken(value, tokenIndex, codeRange);
			return clone;
		}

		vint ParsingTreeToken::GetTokenIndex()
		{
			return tokenIndex;
		}

		void ParsingTreeToken::SetTokenIndex(vint _tokenIndex)
		{
			tokenIndex=_tokenIndex;
		}

		const WString& ParsingTreeToken::GetValue()
		{
			return value;
		}

		void ParsingTreeToken::SetValue(const WString& _value)
		{
			value=_value;
		}

/***********************************************************************
ParsingTreeObject
***********************************************************************/

		const ParsingTreeObject::NodeList& ParsingTreeObject::GetSubNodesInternal()
		{
			return members.Values();
		}

		ParsingTreeObject::ParsingTreeObject(const WString& _type, const ParsingTextRange& _codeRange)
			:ParsingTreeNode(_codeRange)
			,type(_type)
		{
		}

		ParsingTreeObject::~ParsingTreeObject()
		{
		}

		void ParsingTreeObject::Accept(IVisitor* visitor)
		{
			visitor->Visit(this);
		}

		Ptr<ParsingTreeNode> ParsingTreeObject::Clone()
		{
			Ptr<ParsingTreeObject> clone=new ParsingTreeObject(type, codeRange);
			CopyFrom(clone->rules, rules);
			for(vint i=0;i<members.Count();i++)
			{
				WString name=members.Keys().Get(i);
				Ptr<ParsingTreeNode> node=members.Values().Get(i)->Clone();
				clone->SetMember(name, node);
			}
			return clone;
		}

		const WString& ParsingTreeObject::GetType()
		{
			return type;
		}

		void ParsingTreeObject::SetType(const WString& _type)
		{
			type=_type;
		}

		ParsingTreeObject::NodeMap& ParsingTreeObject::GetMembers()
		{
			return members;
		}

		Ptr<ParsingTreeNode> ParsingTreeObject::GetMember(const WString& name)
		{
			vint index=members.Keys().IndexOf(name);
			if(index==-1) return 0;
			return members.Values().Get(index);
		}

		bool ParsingTreeObject::SetMember(const WString& name, Ptr<ParsingTreeNode> node)
		{
			vint index=members.Keys().IndexOf(name);
			if(index!=-1)
			{
				Ptr<ParsingTreeNode> previous=members.Values().Get(index);
				if(previous==node) return true;
				if(!BeforeRemoveChild(previous) || !BeforeAddChild(node)) return false;
				members.Remove(name);
				AfterRemoveChild(previous);
			}
			members.Add(name, node);
			AfterAddChild(node);
			return true;
		}

		bool ParsingTreeObject::RemoveMember(const WString& name)
		{
			vint index=members.Keys().IndexOf(name);
			if(index!=-1)
			{
				Ptr<ParsingTreeNode> previous=members.Values().Get(index);
				if(BeforeRemoveChild(previous))
				{
					members.Remove(name);
					AfterRemoveChild(previous);
					return true;
				}
			}
			return false;
		}

		const ParsingTreeObject::NameList& ParsingTreeObject::GetMemberNames()
		{
			return members.Keys();
		}

		ParsingTreeObject::RuleList& ParsingTreeObject::GetCreatorRules()
		{
			return rules;
		}

/***********************************************************************
ParsingTreeArray
***********************************************************************/

		const ParsingTreeArray::NodeList& ParsingTreeArray::GetSubNodesInternal()
		{
			return items;
		}

		ParsingTreeArray::ParsingTreeArray(const WString& _elementType, const ParsingTextRange& _codeRange)
			:ParsingTreeNode(_codeRange)
			,elementType(_elementType)
		{
		}

		ParsingTreeArray::~ParsingTreeArray()
		{
		}

		void ParsingTreeArray::Accept(IVisitor* visitor)
		{
			visitor->Visit(this);
		}

		Ptr<ParsingTreeNode> ParsingTreeArray::Clone()
		{
			Ptr<ParsingTreeArray> clone=new ParsingTreeArray(elementType, codeRange);
			for(vint i=0;i<items.Count();i++)
			{
				Ptr<ParsingTreeNode> node=items.Get(i)->Clone();
				clone->AddItem(node);
			}
			return clone;
		}

		const WString& ParsingTreeArray::GetElementType()
		{
			return elementType;
		}

		void ParsingTreeArray::SetElementType(const WString& _elementType)
		{
			elementType=_elementType;
		}

		ParsingTreeArray::NodeArray& ParsingTreeArray::GetItems()
		{
			return items;
		}

		Ptr<ParsingTreeNode> ParsingTreeArray::GetItem(vint index)
		{
			if(0<=index && index<items.Count())
			{
				return items[index];
			}
			else
			{
				return 0;
			}
		}

		bool ParsingTreeArray::SetItem(vint index, Ptr<ParsingTreeNode> node)
		{
			if(0<=index && index<items.Count())
			{
				items[index]=node;
				return true;
			}
			else
			{
				return false;
			}
		}

		bool ParsingTreeArray::AddItem(Ptr<ParsingTreeNode> node)
		{
			return InsertItem(items.Count(), node);
		}

		bool ParsingTreeArray::InsertItem(vint index, Ptr<ParsingTreeNode> node)
		{
			if(0<=index && index<=items.Count())
			{
				if(BeforeAddChild(node))
				{
					items.Insert(index, node);
					AfterAddChild(node);
					return true;
				}
			}
			return false;
		}

		bool ParsingTreeArray::RemoveItem(vint index)
		{
			if(0<=index && index<items.Count())
			{
				Ptr<ParsingTreeNode> previous=items[index];
				if(BeforeRemoveChild(previous))
				{
					items.RemoveAt(index);
					AfterRemoveChild(previous);
					return true;
				}
			}
			return false;
		}

		bool ParsingTreeArray::RemoveItem(ParsingTreeNode* node)
		{
			return RemoveItem(items.IndexOf(node));
		}

		vint ParsingTreeArray::IndexOfItem(ParsingTreeNode* node)
		{
			return items.IndexOf(node);
		}

		bool ParsingTreeArray::ContainsItem(ParsingTreeNode* node)
		{
			return items.Contains(node);
		}

		vint ParsingTreeArray::Count()
		{
			return items.Count();
		}

		bool ParsingTreeArray::Clear()
		{
			FOREACH(Ptr<ParsingTreeNode>, node, items)
			{
				if(!BeforeRemoveChild(node)) return false;
			}
			FOREACH(Ptr<ParsingTreeNode>, node, items)
			{
				AfterRemoveChild(node);
			}
			items.Clear();
			return true;
		}

/***********************************************************************
ParsingError
***********************************************************************/

		ParsingError::ParsingError()
			:token(0)
			,parsingTree(0)
		{
		}

		ParsingError::ParsingError(const WString& _errorMessage)
			:token(0)
			,parsingTree(0)
			,errorMessage(_errorMessage)
		{
		}

		ParsingError::ParsingError(const regex::RegexToken* _token, const WString& _errorMessage)
			:token(_token)
			,parsingTree(0)
			,errorMessage(_errorMessage)
		{
			if(token)
			{
				codeRange.start.row=_token->rowStart;
				codeRange.start.column=_token->columnStart;
				codeRange.start.index=_token->start;
				codeRange.end.row=_token->rowEnd;
				codeRange.end.column=_token->columnEnd;
				codeRange.end.index=_token->start+_token->length-1;
				codeRange.codeIndex = _token->codeIndex;
			}
		}

		ParsingError::ParsingError(ParsingTreeCustomBase* _parsingTree, const WString& _errorMessage)
			:codeRange(_parsingTree->codeRange)
			,token(0)
			,parsingTree(_parsingTree)
			,errorMessage(_errorMessage)
		{
		}

		ParsingError::~ParsingError()
		{
		}

/***********************************************************************
ParsingScope
***********************************************************************/

		const ParsingScope::SymbolList ParsingScope::emptySymbolList;

		ParsingScope::ParsingScope(ParsingScopeSymbol* _ownerSymbol)
			:ownerSymbol(_ownerSymbol)
		{
		}

		ParsingScope::~ParsingScope()
		{
		}

		ParsingScopeSymbol* ParsingScope::GetOwnerSymbol()
		{
			return ownerSymbol;
		}

		bool ParsingScope::AddSymbol(Ptr<ParsingScopeSymbol> value)
		{
			if(!value) return false;
			if(value->parentScope) return false;
			symbols.Add(value->GetName(), value);
			value->parentScope=this;
			return true;
		}

		bool ParsingScope::RemoveSymbol(Ptr<ParsingScopeSymbol> value)
		{
			if(!value) return false;
			if(value->parentScope!=this) return false;
			vint index=symbols.Keys().IndexOf(value->GetName());
			if(index==-1) return false;
			const SymbolList& values=symbols.GetByIndex(index);
			index=values.IndexOf(value.Obj());
			if(index==-1) return false;
			symbols.Remove(value->GetName(), value.Obj());
			value->parentScope=0;
			return true;
		}

		const ParsingScope::SymbolKeyList& ParsingScope::GetSymbolNames()
		{
			return symbols.Keys();
		}

		const ParsingScope::SymbolList& ParsingScope::GetSymbols(const WString& name)
		{
			vint index=symbols.Keys().IndexOf(name);
			return index==-1
				?emptySymbolList
				:symbols.GetByIndex(index);
		}

/***********************************************************************
ParsingScopeSymbol
***********************************************************************/

		WString ParsingScopeSymbol::GetDisplayInternal(vint semanticId)
		{
			return name;
		}

		ParsingScopeSymbol::ParsingScopeSymbol(const WString& _name, vint _semanticId)
			:parentScope(0)
			,name(_name)
		{
			if(_semanticId!=-1)
			{
				semanticIds.Add(_semanticId);
			}
		}

		ParsingScopeSymbol::~ParsingScopeSymbol()
		{
		}

		ParsingScope* ParsingScopeSymbol::GetParentScope()
		{
			return parentScope;
		}

		const WString& ParsingScopeSymbol::GetName()
		{
			return name;
		}

		const collections::List<vint>& ParsingScopeSymbol::GetSemanticIds()
		{
			return semanticIds;
		}

		bool ParsingScopeSymbol::AddSemanticId(vint semanticId)
		{
			if(semanticId==-1 || semanticIds.Contains(semanticId)) return false;
			semanticIds.Add(semanticId);
			return true;
		}

		Ptr<ParsingTreeObject> ParsingScopeSymbol::GetNode()
		{
			return node;
		}

		void ParsingScopeSymbol::SetNode(Ptr<ParsingTreeObject> value)
		{
			node=value;
		}

		bool ParsingScopeSymbol::CreateScope()
		{
			if(scope) return false;
			scope=new ParsingScope(this);
			return true;
		}

		bool ParsingScopeSymbol::DestroyScope()
		{
			if(!scope) return false;
			scope=0;
			return true;
		}

		ParsingScope* ParsingScopeSymbol::GetScope()
		{
			return scope.Obj();
		}

		WString ParsingScopeSymbol::GetDisplay(vint semanticId)
		{
			return semanticIds.Contains(semanticId)?GetDisplayInternal(semanticId):L"";
		}

/***********************************************************************
ParsingScopeFinder::DirectSymbolMapper
***********************************************************************/

		ParsingScopeFinder::DirectSymbolMapper::DirectSymbolMapper()
		{
		}

		ParsingScopeFinder::DirectSymbolMapper::~DirectSymbolMapper()
		{
		}

		ParsingTreeNode* ParsingScopeFinder::DirectSymbolMapper::ParentNode(ParsingTreeNode* node)
		{
			return node->GetParent();
		}

		ParsingTreeNode* ParsingScopeFinder::DirectSymbolMapper::Node(ParsingTreeNode* node)
		{
			return node;
		}

		ParsingScope* ParsingScopeFinder::DirectSymbolMapper::ParentScope(ParsingScopeSymbol* symbol)
		{
			return symbol->GetParentScope();
		}

		ParsingScopeSymbol* ParsingScopeFinder::DirectSymbolMapper::Symbol(ParsingScopeSymbol* symbol)
		{
			return symbol;
		}

/***********************************************************************
ParsingScopeFinder::IndirectSymbolMapper
***********************************************************************/

		ParsingScopeFinder::IndirectSymbolMapper::IndirectSymbolMapper(ParsingScopeSymbol* _originalSymbol, ParsingScopeSymbol* _replacedSymbol, ParsingTreeNode* _originalNode, ParsingTreeNode* _replacedNode)
			:originalSymbol(_originalSymbol)
			,replacedSymbol(_replacedSymbol)
			,originalNode(_originalNode)
			,replacedNode(_replacedNode)
		{
		}

		ParsingScopeFinder::IndirectSymbolMapper::~IndirectSymbolMapper()
		{
		}

		ParsingTreeNode* ParsingScopeFinder::IndirectSymbolMapper::ParentNode(ParsingTreeNode* node)
		{
			return (node==replacedNode?originalNode:node)->GetParent();
		}

		ParsingTreeNode* ParsingScopeFinder::IndirectSymbolMapper::Node(ParsingTreeNode* node)
		{
			return node==originalNode?replacedNode:node;
		}

		ParsingScope* ParsingScopeFinder::IndirectSymbolMapper::ParentScope(ParsingScopeSymbol* symbol)
		{
			return (symbol==replacedSymbol?originalSymbol:symbol)->GetParentScope();
		}

		ParsingScopeSymbol* ParsingScopeFinder::IndirectSymbolMapper::Symbol(ParsingScopeSymbol* symbol)
		{
			return symbol==originalSymbol?replacedSymbol:symbol;
		}

/***********************************************************************
ParsingScopeFinder::Traversal Functions
***********************************************************************/

		ParsingTreeNode* ParsingScopeFinder::ParentNode(ParsingTreeNode* node)
		{
			return symbolMapper->ParentNode(node);
		}

		ParsingTreeNode* ParsingScopeFinder::ParentNode(Ptr<ParsingTreeNode> node)
		{
			return symbolMapper->ParentNode(node.Obj());
		}

		ParsingTreeNode* ParsingScopeFinder::Node(ParsingTreeNode* node)
		{
			return symbolMapper->Node(node);
		}

		Ptr<ParsingTreeNode> ParsingScopeFinder::Node(Ptr<ParsingTreeNode> node)
		{
			return symbolMapper->Node(node.Obj());
		}

		ParsingScope* ParsingScopeFinder::ParentScope(ParsingScopeSymbol* symbol)
		{
			return symbolMapper->ParentScope(symbol);
		}

		ParsingScope* ParsingScopeFinder::ParentScope(Ptr<ParsingScopeSymbol> symbol)
		{
			return symbolMapper->ParentScope(symbol.Obj());
		}

		ParsingScopeSymbol* ParsingScopeFinder::Symbol(ParsingScopeSymbol* symbol)
		{
			return symbolMapper->Symbol(symbol);
		}

		Ptr<ParsingScopeSymbol> ParsingScopeFinder::Symbol(Ptr<ParsingScopeSymbol> symbol)
		{
			return symbolMapper->Symbol(symbol.Obj());
		}

		ParsingScopeFinder::LazySymbolList ParsingScopeFinder::Symbols(const ParsingScope::SymbolList& symbols)
		{
			return From(symbols).Select([this](Ptr<ParsingScopeSymbol> symbol)
			{
				return Symbol(symbol);
			});
		}

/***********************************************************************
ParsingScopeFinder
***********************************************************************/

		void ParsingScopeFinder::InitializeQueryCacheInternal(ParsingScopeSymbol* symbol)
		{
			if(ParsingTreeObject* obj=Obj(symbol->GetNode().Obj()))
			{
				nodeSymbols.Add(obj, symbol);
			}
			if(symbol->GetScope())
			{
				ParsingScope* scope=symbol->GetScope();
				FOREACH(WString, name, scope->GetSymbolNames())
				{
					FOREACH(Ptr<ParsingScopeSymbol>, subSymbol, Symbols(scope->GetSymbols(name)))
					{
						InitializeQueryCacheInternal(subSymbol.Obj());
					}
				}
			}
		}

		ParsingScopeFinder::ParsingScopeFinder( Ptr<SymbolMapper> _symbolMapper)
			:symbolMapper(_symbolMapper)
			,previousFinder(0)
		{
		}

		ParsingScopeFinder::~ParsingScopeFinder()
		{
		}

		void ParsingScopeFinder::InitializeQueryCache(ParsingScopeSymbol* symbol, ParsingScopeFinder* _previousFinder)
		{
			previousFinder=_previousFinder;
			InitializeQueryCacheInternal(symbol);
		}

		ParsingScopeSymbol* ParsingScopeFinder::GetSymbolFromNode(ParsingTreeObject* node)
		{
			vint index=nodeSymbols.Keys().IndexOf(node);
			if(index!=-1)
			{
				return nodeSymbols.Values()[index];
			}
			else if(previousFinder)
			{
				return previousFinder->GetSymbolFromNode(node);
			}
			else
			{
				return 0;
			}
		}

		ParsingScope* ParsingScopeFinder::GetScopeFromNode(ParsingTreeNode* node)
		{
			while(node)
			{
				ParsingTreeObject* obj=dynamic_cast<ParsingTreeObject*>(node);
				if(obj)
				{
					ParsingScopeSymbol* symbol=GetSymbolFromNode(obj);
					if(symbol && symbol->GetScope())
					{
						return symbol->GetScope();
					}
				}
				node=ParentNode(node);
			}
			if(previousFinder)
			{
				return previousFinder->GetScopeFromNode(node);
			}
			else
			{
				return 0;
			}
		}

		ParsingScopeFinder::LazySymbolList ParsingScopeFinder::GetSymbols(ParsingScope* scope, const WString& name)
		{
			if(!scope) return LazySymbolList();
			return Symbols(scope->GetSymbols(name));
		}

		ParsingScopeFinder::LazySymbolList ParsingScopeFinder::GetSymbols(ParsingScope* scope)
		{
			if(!scope) return LazySymbolList();
			return From(scope->GetSymbolNames())
				.SelectMany([=](const WString& name)
				{
					return Symbols(scope->GetSymbols(name));
				});
		}

		ParsingScopeFinder::LazySymbolList ParsingScopeFinder::GetSymbolsRecursively(ParsingScope* scope, const WString& name)
		{
			if(!scope) return LazySymbolList();
			while(scope)
			{
				const ParsingScope::SymbolList& symbols=scope->GetSymbols(name);
				if(symbols.Count()>0) return Symbols(symbols);

				if(scope->ownerSymbol)
				{
					scope=ParentScope(scope->ownerSymbol);
				}
				else
				{
					break;
				}
			}
			if(previousFinder)
			{
				return previousFinder->GetSymbols(scope, name);
			}
			else
			{
				return ParsingScope::emptySymbolList;
			}
		}

		ParsingScopeFinder::LazySymbolList ParsingScopeFinder::GetSymbolsRecursively(ParsingScope* scope)
		{
			if(!scope) return LazySymbolList();
			LazySymbolList result;
			while(scope)
			{
				result=result.Concat(GetSymbols(scope));

				if(scope->ownerSymbol)
				{
					scope=ParentScope(scope->ownerSymbol);
				}
				else
				{
					break;
				}
			}
			return result;
		}
	}
}
