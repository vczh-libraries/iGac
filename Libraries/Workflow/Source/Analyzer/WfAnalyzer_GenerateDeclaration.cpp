#include "WfAnalyzer.h"

namespace vl
{
	namespace workflow
	{
		namespace analyzer
		{
			using namespace collections;
			using namespace regex;
			using namespace parsing;
			using namespace reflection;
			using namespace reflection::description;
			using namespace runtime;

			typedef WfInstruction Ins;

#define INSTRUCTION(X) context.assembly->instructions.Add(X)

/***********************************************************************
GenerateGlobalDeclarationMetadata
***********************************************************************/

			void GenerateFunctionDeclarationMetadata(WfCodegenContext& context, WfFunctionDeclaration* node, Ptr<WfAssemblyFunction> meta)
			{
				FOREACH(Ptr<WfFunctionArgument>, argument, node->arguments)
				{
					meta->argumentNames.Add(argument->name.value);
				}
				{
					vint index = context.manager->functionLambdaCaptures.Keys().IndexOf(node);
					if (index != -1)
					{
						FOREACH(Ptr<WfLexicalSymbol>, symbol, context.manager->functionLambdaCaptures.GetByIndex(index))
						{
							meta->capturedVariableNames.Add(L"<captured>" + symbol->name);
						}
					}
				}
			}

			class GenerateGlobalDeclarationMetadataVisitor : public Object, public WfDeclaration::IVisitor
			{
			public:
				WfCodegenContext&						context;
				WString									namePrefix;

				GenerateGlobalDeclarationMetadataVisitor(WfCodegenContext& _context, const WString& _namePrefix)
					:context(_context)
					, namePrefix(_namePrefix)
				{
				}

				void Visit(WfNamespaceDeclaration* node)override
				{
					FOREACH(Ptr<WfDeclaration>, decl, node->declarations)
					{
						GenerateGlobalDeclarationMetadata(context, decl, namePrefix + node->name.value + L"::");
					}
				}

				void Visit(WfFunctionDeclaration* node)override
				{
					auto meta = MakePtr<WfAssemblyFunction>();
					meta->name = namePrefix + node->name.value;
					GenerateFunctionDeclarationMetadata(context, node, meta);

					vint index = context.assembly->functions.Add(meta);
					context.assembly->functionByName.Add(meta->name, index);

					auto scope = context.manager->declarationScopes[node]->parentScope.Obj();
					auto symbol = From(scope->symbols[node->name.value])
						.Where([=](Ptr<WfLexicalSymbol> symbol)
						{
							return symbol->creatorDeclaration == node;
						})
						.First();
					context.globalFunctions.Add(symbol.Obj(), index);
				}

				void Visit(WfVariableDeclaration* node)override
				{
					vint index = context.assembly->variableNames.Add(namePrefix + node->name.value);

					auto scope = context.manager->declarationScopes[node].Obj();
					auto symbol = scope->symbols[node->name.value][0];
					context.globalVariables.Add(symbol.Obj(), index);
				}
			};

			void GenerateGlobalDeclarationMetadata(WfCodegenContext& context, Ptr<WfDeclaration> declaration, const WString& namePrefix)
			{
				GenerateGlobalDeclarationMetadataVisitor visitor(context, namePrefix);
				declaration->Accept(&visitor);
			}

/***********************************************************************
GenerateInstructions(Initialize)
***********************************************************************/

			class GenerateInitializeInstructionsVisitor : public Object, public WfDeclaration::IVisitor
			{
			public:
				WfCodegenContext&						context;

				GenerateInitializeInstructionsVisitor(WfCodegenContext& _context)
					:context(_context)
				{
				}

				void Visit(WfNamespaceDeclaration* node)override
				{
				}

				void Visit(WfFunctionDeclaration* node)override
				{
				}

				void Visit(WfVariableDeclaration* node)override
				{
					auto scope = context.manager->declarationScopes[node].Obj();
					auto symbol = scope->symbols[node->name.value][0];
					vint variableIndex = context.globalVariables[symbol.Obj()];
					GenerateExpressionInstructions(context, node->expression);
					INSTRUCTION(Ins::StoreGlobalVar(variableIndex));
				}
			};

			void GenerateInitializeInstructions(WfCodegenContext& context, Ptr<WfDeclaration> declaration)
			{
				GenerateInitializeInstructionsVisitor visitor(context);
				declaration->Accept(&visitor);
			}

/***********************************************************************
GenerateInstructions(Declaration)
***********************************************************************/

			void GenerateFunctionInstructions(WfCodegenContext& context, WfLexicalScope* scope, Ptr<WfAssemblyFunction> meta, Ptr<ITypeInfo> returnType, Ptr<WfLexicalSymbol> recursiveLambdaSymbol, const List<Ptr<WfLexicalSymbol>>& argumentSymbols, const List<Ptr<WfLexicalSymbol>>& capturedSymbols, Ptr<WfStatement> statementBody, Ptr<WfExpression> expressionBody)
			{
				auto functionContext = MakePtr<WfCodegenFunctionContext>();
				functionContext->function = meta;
				context.functionContext = functionContext;
				{
					FOREACH_INDEXER(Ptr<WfLexicalSymbol>, argumentSymbol, index, argumentSymbols)
					{
						functionContext->arguments.Add(argumentSymbol.Obj(), index);
					}
					FOREACH_INDEXER(Ptr<WfLexicalSymbol>, capturedSymbol, index, capturedSymbols)
					{
						functionContext->capturedVariables.Add(capturedSymbol.Obj(), index);
					}
				}
				if (recursiveLambdaSymbol)
				{
					vint variableIndex = meta->argumentNames.Count() + meta->localVariableNames.Add(L"<recursive-lambda>" + recursiveLambdaSymbol->name);
					functionContext->localVariables.Add(recursiveLambdaSymbol.Obj(), variableIndex);
				}
					
				meta->firstInstruction = context.assembly->instructions.Count();
				if (recursiveLambdaSymbol)
				{
					for (vint i = 0; i < functionContext->capturedVariables.Count(); i++)
					{
						INSTRUCTION(Ins::LoadCapturedVar(i));
					}
					INSTRUCTION(Ins::LoadClosure(context.assembly->functions.IndexOf(meta.Obj()), functionContext->capturedVariables.Count()));
					INSTRUCTION(Ins::StoreLocalVar(functionContext->localVariables[recursiveLambdaSymbol.Obj()]));
				}
				if (statementBody)
				{
					GenerateStatementInstructions(context, statementBody);
				}
				if (expressionBody)
				{
					GenerateExpressionInstructions(context, expressionBody);
					INSTRUCTION(Ins::Return());
				}
				if (returnType->GetDecorator() == ITypeInfo::TypeDescriptor && returnType->GetTypeDescriptor()->GetValueSerializer())
				{
					auto serializer = returnType->GetTypeDescriptor()->GetValueSerializer();
					auto defaultText = serializer->GetDefaultText();
					Value result;
					serializer->Parse(defaultText, result);
					INSTRUCTION(Ins::LoadValue(result));
				}
				else
				{
					INSTRUCTION(Ins::LoadValue(Value()));
				}
				INSTRUCTION(Ins::Return());
				meta->lastInstruction = context.assembly->instructions.Count() - 1;
				context.functionContext = 0;

				GenerateClosureInstructions(context, functionContext);
			}

			void GenerateFunctionDeclarationInstructions(WfCodegenContext& context, WfFunctionDeclaration* node, WfLexicalScope* scope, Ptr<WfAssemblyFunction> meta, Ptr<WfLexicalSymbol> recursiveLambdaSymbol)
			{
				List<Ptr<WfLexicalSymbol>> argumentSymbols, capturedSymbols;
				{
					FOREACH(Ptr<WfFunctionArgument>, argument, node->arguments)
					{
						auto symbol = scope->symbols[argument->name.value][0];
						argumentSymbols.Add(symbol);
					}

					vint index = context.manager->functionLambdaCaptures.Keys().IndexOf(node);
					if (index != -1)
					{
						FOREACH(Ptr<WfLexicalSymbol>, symbol, context.manager->functionLambdaCaptures.GetByIndex(index))
						{
							capturedSymbols.Add(symbol);
						}
					}
				}

				auto returnType = CreateTypeInfoFromType(scope, node->returnType);
				GenerateFunctionInstructions(context, scope, meta, returnType, recursiveLambdaSymbol, argumentSymbols, capturedSymbols, node->statement, 0);
			}

			class GenerateDeclarationInstructionsVisitor : public Object, public WfDeclaration::IVisitor
			{
			public:
				WfCodegenContext&						context;

				GenerateDeclarationInstructionsVisitor(WfCodegenContext& _context)
					:context(_context)
				{
				}

				void Visit(WfNamespaceDeclaration* node)override
				{
				}

				void Visit(WfFunctionDeclaration* node)override
				{
					auto scope = context.manager->declarationScopes[node].Obj();
					auto symbol = From(scope->parentScope->symbols[node->name.value])
						.Where([=](Ptr<WfLexicalSymbol> symbol)
						{
							return symbol->creatorDeclaration == node;
						})
						.First();
					auto meta = context.assembly->functions[context.globalFunctions[symbol.Obj()]];
					GenerateFunctionDeclarationInstructions(context, node, scope, meta, 0);
				}

				void Visit(WfVariableDeclaration* node)override
				{
				}
			};

			void GenerateDeclarationInstructions(WfCodegenContext& context, Ptr<WfDeclaration> declaration)
			{
				GenerateDeclarationInstructionsVisitor visitor(context);
				declaration->Accept(&visitor);
			}

/***********************************************************************
GenerateInstructions(Closure)
***********************************************************************/

			void GenerateClosureInstructions_StaticMethod(WfCodegenContext& context, vint functionIndex, WfExpression* expression)
			{
				auto result = context.manager->expressionResolvings[expression];
				auto methodInfo = result.methodInfo;
				auto meta = context.assembly->functions[functionIndex];

				for (vint j = 0; j < methodInfo->GetParameterCount(); j++)
				{
					meta->argumentNames.Add(methodInfo->GetParameter(j)->GetName());
				}

				meta->firstInstruction = context.assembly->instructions.Count();
				for (vint j = 0; j < methodInfo->GetParameterCount(); j++)
				{
					INSTRUCTION(Ins::LoadLocalVar(j));
				}
				INSTRUCTION(Ins::LoadValue(Value()));
				INSTRUCTION(Ins::InvokeMethod(methodInfo, methodInfo->GetParameterCount()));
				INSTRUCTION(Ins::Return());
				meta->lastInstruction = context.assembly->instructions.Count() - 1;
			}

			void GenerateClosureInstructions_Method(WfCodegenContext& context, vint functionIndex, WfMemberExpression* expression)
			{
				auto result = context.manager->expressionResolvings[expression];
				auto methodInfo = result.methodInfo;
				auto meta = context.assembly->functions[functionIndex];

				for (vint j = 0; j < methodInfo->GetParameterCount(); j++)
				{
					meta->argumentNames.Add(methodInfo->GetParameter(j)->GetName());
				}
				meta->capturedVariableNames.Add(L"<this>");

				meta->firstInstruction = context.assembly->instructions.Count();
				for (vint j = 0; j < methodInfo->GetParameterCount(); j++)
				{
					INSTRUCTION(Ins::LoadLocalVar(j));
				}
				INSTRUCTION(Ins::LoadCapturedVar(0));
				INSTRUCTION(Ins::InvokeMethod(methodInfo, methodInfo->GetParameterCount()));
				INSTRUCTION(Ins::Return());
				meta->lastInstruction = context.assembly->instructions.Count() - 1;
			}

			void GenerateClosureInstructions_Function(WfCodegenContext& context, vint functionIndex, WfFunctionDeclaration* declaration, bool createInterface)
			{
				auto scope = context.manager->declarationScopes[declaration].Obj();
				auto meta = context.assembly->functions[functionIndex];
				GenerateFunctionDeclarationMetadata(context, declaration, meta);
				Ptr<WfLexicalSymbol> recursiveLambdaSymbol;
				if (!createInterface && declaration->name.value != L"")
				{
					recursiveLambdaSymbol = scope->symbols[declaration->name.value][0];
				}
				GenerateFunctionDeclarationInstructions(context, declaration, scope, meta, recursiveLambdaSymbol);
			}

			void GenerateClosureInstructions_Ordered(WfCodegenContext& context, vint functionIndex, WfOrderedLambdaExpression* expression)
			{
				auto scope = context.manager->expressionScopes[expression].Obj();
				List<Ptr<WfLexicalSymbol>> argumentSymbols, capturedSymbols;
				CopyFrom(
					argumentSymbols,
					Range<vint>(0, scope->symbols.Count())
						.Select([scope](vint index)->Ptr<WfLexicalSymbol>{return scope->symbols.GetByIndex(index)[0];})
						.OrderBy([](Ptr<WfLexicalSymbol> a, Ptr<WfLexicalSymbol> b)
						{
							vint aId = wtoi(a->name.Sub(1, a->name.Length() - 1));
							vint bId = wtoi(b->name.Sub(1, a->name.Length() - 1));
							return aId - bId;
						})
					);

				auto meta = context.assembly->functions[functionIndex];
				FOREACH(Ptr<WfLexicalSymbol>, symbol, argumentSymbols)
				{
					meta->argumentNames.Add(symbol->name);
				}
				{
					vint index = context.manager->orderedLambdaCaptures.Keys().IndexOf(expression);
					if (index != -1)
					{
						FOREACH(Ptr<WfLexicalSymbol>, symbol, context.manager->orderedLambdaCaptures.GetByIndex(index))
						{
							meta->capturedVariableNames.Add(L"<captured>" + symbol->name);
							capturedSymbols.Add(symbol);
						}
					}
				}

				auto result = context.manager->expressionResolvings[expression];
				auto returnType = CopyTypeInfo(result.type->GetElementType()->GetGenericArgument(0));
				GenerateFunctionInstructions(context, scope, meta, returnType, 0, argumentSymbols, capturedSymbols, 0, expression->body);
			}

			void GenerateClosureInstructions(WfCodegenContext& context, Ptr<WfCodegenFunctionContext> functionContext)
			{
				for (vint i = 0; i < functionContext->closuresToCodegen.Count(); i++)
				{
					vint functionIndex = functionContext->closuresToCodegen.Keys()[i];
					auto closure = functionContext->closuresToCodegen.Values()[i];
					
					if (closure.staticMethodReferenceExpression)
					{
						GenerateClosureInstructions_StaticMethod(context, functionIndex, closure.staticMethodReferenceExpression);
					}
					else if (closure.methodReferenceExpression)
					{
						GenerateClosureInstructions_Method(context, functionIndex, closure.methodReferenceExpression);
					}
					else if (closure.functionExpression)
					{
						GenerateClosureInstructions_Function(context, functionIndex, closure.functionExpression->function.Obj(), false);
					}
					else if (closure.orderedLambdaExpression)
					{
						GenerateClosureInstructions_Ordered(context, functionIndex, closure.orderedLambdaExpression);
					}
					else if (closure.functionDeclaration)
					{
						GenerateClosureInstructions_Function(context, functionIndex, closure.functionDeclaration, true);
					}
				}
			}

#undef INSTRUCTION
		}
	}
}