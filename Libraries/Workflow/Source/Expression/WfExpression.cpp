#include "WfExpression.h"

namespace vl
{
	namespace workflow
	{
		using namespace stream;
		using namespace collections;

/***********************************************************************
Unescaping Functions
***********************************************************************/

		void UnescapeStringInternal(vl::parsing::ParsingToken& value, bool formatString)
		{
			MemoryStream memoryStream;
			{
				WString input = formatString ? value.value.Sub(2, value.value.Length() - 3) : value.value.Sub(1, value.value.Length() - 2);
				const wchar_t* reading = input.Buffer();
				StreamWriter writer(memoryStream);

				while (wchar_t c = *reading++)
				{
					if (c == L'\\')
					{
						switch (wchar_t e = *reading++)
						{
						case L'r':
							writer.WriteChar('\r');
							break;
						case L'n':
							writer.WriteChar('\n');
							break;
						case L't':
							writer.WriteChar('\t');
							break;
						default:
							writer.WriteChar(e);
						}
					}
					else
					{
						writer.WriteChar(c);
					}
				}
			}

			memoryStream.SeekFromBegin(0);
			{
				StreamReader reader(memoryStream);
				value.value = reader.ReadToEnd();
			}
		}

		void UnescapeFormatString(vl::parsing::ParsingToken& value, const vl::collections::List<vl::regex::RegexToken>& tokens)
		{
			UnescapeStringInternal(value, true);
		}

		void UnescapeString(vl::parsing::ParsingToken& value, const vl::collections::List<vl::regex::RegexToken>& tokens)
		{
			UnescapeStringInternal(value, false);
		}

		void EscapeString(const WString& text, TextWriter& writer)
		{
			writer.WriteChar(L'\"');
			const wchar_t* reading = text.Buffer();
			while (wchar_t c = *reading++)
			{
				switch (c)
				{
				case '\r':
					writer.WriteString(L"\\r");
					break;
				case '\n':
					writer.WriteString(L"\\n");
					break;
				case '\t':
					writer.WriteString(L"\\t");
					break;
				case '\"':
					writer.WriteString(L"\\\"");
					break;
				case '\\':
					writer.WriteString(L"\\\\");
					break;
				default:
					writer.WriteChar(c);
				}
			}
			writer.WriteChar(L'\"');
		}

/***********************************************************************
Print (Type)
***********************************************************************/

		class PrintTypeVisitor : public Object, public WfType::IVisitor
		{
		public:
			WString								indent;
			TextWriter&							writer;

			PrintTypeVisitor(const WString& _indent, stream::TextWriter& _writer)
				:indent(_indent), writer(_writer)
			{
			}

			void Visit(WfPredefinedType* node)override
			{
				switch (node->name)
				{
				case WfPredefinedTypeName::Void:
					writer.WriteString(L"void");
					break;
				case WfPredefinedTypeName::Object:
					writer.WriteString(L"object");
					break;
				case WfPredefinedTypeName::Interface:
					writer.WriteString(L"interface");
					break;
				case WfPredefinedTypeName::Int:
					writer.WriteString(L"int");
					break;
				case WfPredefinedTypeName::UInt:
					writer.WriteString(L"uint");
					break;
				case WfPredefinedTypeName::Float:
					writer.WriteString(L"float");
					break;
				case WfPredefinedTypeName::Double:
					writer.WriteString(L"double");
					break;
				case WfPredefinedTypeName::String:
					writer.WriteString(L"string");
					break;
				case WfPredefinedTypeName::Char:
					writer.WriteString(L"char");
					break;
				case WfPredefinedTypeName::Bool:
					writer.WriteString(L"bool");
					break;
				}
			}

			void Visit(WfTopQualifiedType* node)override
			{
				writer.WriteString(L"::" + node->name.value);
			}

			void Visit(WfReferenceType* node)override
			{
				writer.WriteString(node->name.value);
			}

			void Visit(WfRawPointerType* node)override
			{
				WfPrint(node->element, indent, writer);
				writer.WriteString(L"*");
			}

			void Visit(WfSharedPointerType* node)override
			{
				WfPrint(node->element, indent, writer);
				writer.WriteString(L"^");
			}

			void Visit(WfNullableType* node)override
			{
				WfPrint(node->element, indent, writer);
				writer.WriteString(L"?");
			}

			void Visit(WfEnumerableType* node)override
			{
				WfPrint(node->element, indent, writer);
				writer.WriteString(L"{}");
			}

			void Visit(WfMapType* node)override
			{
				if (node->writability == WfMapWritability::Readonly)
				{
					writer.WriteString(L"const ");
				}
				WfPrint(node->value, indent, writer);
				writer.WriteString(L"[");
				if (node->key)
				{
					WfPrint(node->key, indent, writer);
				}
				writer.WriteString(L"]");
			}

			void Visit(WfFunctionType* node)override
			{
				writer.WriteString(L"func ");
				writer.WriteString(L"(");
				FOREACH_INDEXER(Ptr<WfType>, type, index, node->arguments)
				{
					if (index > 0)
					{
						writer.WriteString(L", ");
					}
					WfPrint(type, indent, writer);
				}
				writer.WriteString(L")");

				writer.WriteString(L" : ");
				WfPrint(node->result, indent, writer);
			}

			void Visit(WfChildType* node)override
			{
				WfPrint(node->parent, indent, writer);
				writer.WriteString(L"::");
				writer.WriteString(node->name.value);
			}
		};

		void WfPrint(Ptr<WfType> node, const WString& indent, stream::TextWriter& writer)
		{
			PrintTypeVisitor visitor(indent, writer);
			node->Accept(&visitor);
		}

/***********************************************************************
Print (Expression)
***********************************************************************/

		class PrintExpressionVisitor : public Object, public WfExpression::IVisitor
		{
		public:
			WString								indent;
			TextWriter&							writer;

			PrintExpressionVisitor(const WString& _indent, stream::TextWriter& _writer)
				:indent(_indent), writer(_writer)
			{
			}

			void Visit(WfTopQualifiedExpression* node)override
			{
				writer.WriteString(L"::");
				writer.WriteString(node->name.value);
			}

			void Visit(WfReferenceExpression* node)override
			{
				writer.WriteString(node->name.value);
			}

			void Visit(WfOrderedNameExpression* node)override
			{
				writer.WriteString(node->name.value);
			}

			void Visit(WfOrderedLambdaExpression* node)override
			{
				writer.WriteString(L"[");
				WfPrint(node->body, indent, writer);
				writer.WriteString(L"]");
			}

			void Visit(WfMemberExpression* node)override
			{
				WfPrint(node->parent, indent, writer);
				writer.WriteString(L".");
				writer.WriteString(node->name.value);
			}

			void Visit(WfChildExpression* node)override
			{
				WfPrint(node->parent, indent, writer);
				writer.WriteString(L"::");
				writer.WriteString(node->name.value);
			}

			void Visit(WfLiteralExpression* node)override
			{
				switch (node->value)
				{
				case WfLiteralValue::Null:
					writer.WriteString(L"null");
					break;
				case WfLiteralValue::True:
					writer.WriteString(L"true");
					break;
				case WfLiteralValue::False:
					writer.WriteString(L"false");
					break;
				}
			}

			void Visit(WfFloatingExpression* node)override
			{
				writer.WriteString(node->value.value);
			}

			void Visit(WfIntegerExpression* node)override
			{
				writer.WriteString(node->value.value);
			}

			void Visit(WfStringExpression* node)override
			{
				EscapeString(node->value.value, writer);
			}

			void Visit(WfFormatExpression* node)override
			{
				if (node->expandedExpression)
				{
					WfPrint(node->expandedExpression, indent, writer);
				}
				else
				{
					writer.WriteString(L"$");
					EscapeString(node->value.value, writer);
				}
			}

			void Visit(WfUnaryExpression* node)override
			{
				writer.WriteString(L"(");
				switch (node->op)
				{
				case WfUnaryOperator::Positive:
					writer.WriteString(L"+");
					break;
				case WfUnaryOperator::Negative:
					writer.WriteString(L"-");
					break;
				case WfUnaryOperator::Not:
					writer.WriteString(L"!");
					break;
				}
				WfPrint(node->operand, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfBinaryExpression* node)override
			{
				if (node->op == WfBinaryOperator::Index)
				{
					WfPrint(node->first, indent, writer);
					writer.WriteString(L"[");
					WfPrint(node->second, indent, writer);
					writer.WriteString(L"]");
				}
				else
				{
					writer.WriteString(L"(");
					WfPrint(node->first, indent, writer);
					switch (node->op)
					{
					case WfBinaryOperator::Assign:
						writer.WriteString(L" = ");
						break;
					case WfBinaryOperator::Concat:
						writer.WriteString(L" & ");
						break;
					case WfBinaryOperator::FailedThen:
						writer.WriteString(L" ?? ");
						break;
					case WfBinaryOperator::Exp:
						writer.WriteString(L" ^ ");
						break;
					case WfBinaryOperator::Add:
						writer.WriteString(L" + ");
						break;
					case WfBinaryOperator::Sub:
						writer.WriteString(L" - ");
						break;
					case WfBinaryOperator::Mul:
						writer.WriteString(L" * ");
						break;
					case WfBinaryOperator::Div:
						writer.WriteString(L" / ");
						break;
					case WfBinaryOperator::Mod:
						writer.WriteString(L" % ");
						break;
					case WfBinaryOperator::Shl:
						writer.WriteString(L" shl ");
						break;
					case WfBinaryOperator::Shr:
						writer.WriteString(L" shr ");
						break;
					case WfBinaryOperator::LT:
						writer.WriteString(L" < ");
						break;
					case WfBinaryOperator::GT:
						writer.WriteString(L" > ");
						break;
					case WfBinaryOperator::LE:
						writer.WriteString(L" <= ");
						break;
					case WfBinaryOperator::GE:
						writer.WriteString(L" >= ");
						break;
					case WfBinaryOperator::EQ:
						writer.WriteString(L" == ");
						break;
					case WfBinaryOperator::NE:
						writer.WriteString(L" != ");
						break;
					case WfBinaryOperator::Xor:
						writer.WriteString(L" xor ");
						break;
					case WfBinaryOperator::And:
						writer.WriteString(L" and ");
						break;
					case WfBinaryOperator::Or:
						writer.WriteString(L" or ");
						break;
					default:;
					}
					WfPrint(node->second, indent, writer);
					writer.WriteString(L")");
				}
			}

			void Visit(WfLetExpression* node)override
			{
				writer.WriteString(L"let ");
				FOREACH_INDEXER(Ptr<WfLetVariable>, var, index, node->variables)
				{
					if (index > 0)
					{
						writer.WriteString(L", ");
					}
					writer.WriteString(var->name.value);
					writer.WriteString(L" = ");
					WfPrint(var->value, indent, writer);
				}
				writer.WriteString(L" in (");
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfIfExpression* node)override
			{
				WfPrint(node->condition, indent, writer);
				writer.WriteString(L" ? ");
				WfPrint(node->trueBranch, indent, writer);
				writer.WriteString(L" : ");
				WfPrint(node->falseBranch, indent, writer);
			}

			void Visit(WfRangeExpression* node)override
			{
				writer.WriteString(L"range ");
				writer.WriteString(node->beginBoundary == WfRangeBoundary::Exclusive ? L"(" : L"[");
				WfPrint(node->begin, indent, writer);
				writer.WriteString(L", ");
				WfPrint(node->end, indent, writer);
				writer.WriteString(node->endBoundary == WfRangeBoundary::Exclusive ? L")" : L"]");
			}

			void Visit(WfSetTestingExpression* node)override
			{
				WfPrint(node->element, indent, writer);
				if (node->test == WfSetTesting::NotIn)
				{
					writer.WriteString(L" not");
				}
				writer.WriteString(L" in ");
				WfPrint(node->collection, indent, writer);
			}

			void Visit(WfConstructorExpression* node)override
			{
				writer.WriteString(L"{");
				FOREACH_INDEXER(Ptr<WfConstructorArgument>, argument, index, node->arguments)
				{
					if (index > 0)
					{
						writer.WriteString(L" ");
					}
					WfPrint(argument->key, indent, writer);
					if (argument->value)
					{
						writer.WriteString(L" : ");
						WfPrint(argument->value, indent, writer);
					}
				}
				writer.WriteString(L"}");
			}

			void Visit(WfInferExpression* node)override
			{
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L" of (");
				WfPrint(node->type, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfTypeCastingExpression* node)override
			{
				if (node->strategy == WfTypeCastingStrategy::Strong)
				{
					writer.WriteString(L"cast (");
					WfPrint(node->type, indent, writer);
					writer.WriteString(L") ");
					WfPrint(node->expression, indent, writer);
				}
				else
				{
					WfPrint(node->expression, indent, writer);
					writer.WriteString(L" as (");
					WfPrint(node->type, indent, writer);
					writer.WriteString(L")");
				}
			}

			void Visit(WfTypeTestingExpression* node)override
			{
				WfPrint(node->expression, indent, writer);
				switch (node->test)
				{
				case WfTypeTesting::IsType:
					writer.WriteString(L" is (");
					WfPrint(node->type, indent, writer);
					writer.WriteString(L")");
					break;
				case WfTypeTesting::IsNotType:
					writer.WriteString(L" is not (");
					WfPrint(node->type, indent, writer);
					writer.WriteString(L")");
					break;
				case WfTypeTesting::IsNull:
					writer.WriteString(L" is null");
					break;
				case WfTypeTesting::IsNotNull:
					writer.WriteString(L" is not null");
					break;
				}
			}

			void Visit(WfTypeOfTypeExpression* node)override
			{
				writer.WriteString(L"typeof(");
				WfPrint(node->type, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfTypeOfExpressionExpression* node)override
			{
				writer.WriteString(L"type(");
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfAttachEventExpression* node)override
			{
				writer.WriteString(L"attach(");
				WfPrint(node->event, indent, writer);
				writer.WriteString(L", ");
				WfPrint(node->function, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfDetachEventExpression* node)override
			{
				writer.WriteString(L"detach(");
				WfPrint(node->handler, indent, writer);
				writer.WriteString(L")");
			}

			void Visit(WfBindExpression* node)override
			{
				if (node->expandedExpression)
				{
					WfPrint(node->expandedExpression, indent, writer);
				}
				else
				{
					writer.WriteString(L"bind(");
					WfPrint(node->expression, indent, writer);
					writer.WriteString(L")");
				}
			}

			void Visit(WfObserveExpression* node)override
			{
				WfPrint(node->parent, indent, writer);
				writer.WriteString(L".observe");
				if (node->observeType == WfObserveType::ExtendedObserve)
				{
					writer.WriteString(L" as ");
					writer.WriteString(node->name.value);
				}
				writer.WriteString(L"(");
				WfPrint(node->expression, indent, writer);
				if (node->events.Count() > 0)
				{
					writer.WriteString(L" on ");
					FOREACH_INDEXER(Ptr<WfExpression>, argument, index, node->events)
					{
						if (index > 0)
						{
							writer.WriteString(L", ");
						}
						WfPrint(argument, indent, writer);
					}
				}
				writer.WriteString(L")");
			}

			void Visit(WfCallExpression* node)override
			{
				WfPrint(node->function, indent, writer);
				writer.WriteString(L"(");
				FOREACH_INDEXER(Ptr<WfExpression>, argument, index, node->arguments)
				{
					if (index > 0)
					{
						writer.WriteString(L", ");
					}
					WfPrint(argument, indent, writer);
				}
				writer.WriteString(L")");
			}

			void Visit(WfFunctionExpression* node)override
			{
				WfPrint(Ptr<WfDeclaration>(node->function), indent, writer);
			}

			void Visit(WfNewTypeExpression* node)override
			{
				writer.WriteString(L"new (");
				WfPrint(node->type, indent, writer);
				writer.WriteString(L")");
				if (node->functions.Count() == 0)
				{
					writer.WriteString(L"(");
					FOREACH_INDEXER(Ptr<WfExpression>, argument, index, node->arguments)
					{
						if (index > 0)
						{
							writer.WriteString(L", ");
						}
						WfPrint(argument, indent, writer);
					}
					writer.WriteString(L")");
				}
				else
				{
					writer.WriteLine(L"");
					writer.WriteString(indent);
					writer.WriteLine(L"{");
					FOREACH_INDEXER(Ptr<WfFunctionDeclaration>, function, index, node->functions)
					{
						if (index > 0)
						{
							writer.WriteLine(L"");
						}
						writer.WriteString(indent + L"    ");
						WfPrint(Ptr<WfDeclaration>(function), indent + L"    ", writer);
						writer.WriteLine(L"");
					}
					writer.WriteString(indent);
					writer.WriteString(L"}");
				}
			}
		};

		void WfPrint(Ptr<WfExpression> node, const WString& indent, stream::TextWriter& writer)
		{
			PrintExpressionVisitor visitor(indent, writer);
			node->Accept(&visitor);
		}

/***********************************************************************
Print (Statement)
***********************************************************************/

		class PrintStatementVisitor : public Object, public WfStatement::IVisitor
		{
		public:
			WString								indent;
			TextWriter&							writer;

			PrintStatementVisitor(const WString& _indent, stream::TextWriter& _writer)
				:indent(_indent), writer(_writer)
			{
			}

			void Visit(WfBreakStatement* node)override
			{
				writer.WriteString(L"break;");
			}

			void Visit(WfContinueStatement* node)override
			{
				writer.WriteString(L"continue;");
			}

			void Visit(WfReturnStatement* node)override
			{
				if (node->expression)
				{
					writer.WriteString(L"return ");
					WfPrint(node->expression, indent, writer);
					writer.WriteString(L";");
				}
				else
				{
					writer.WriteString(L"return;");
				}
			}

			void Visit(WfDeleteStatement* node)override
			{
				writer.WriteString(L"delete ");
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L";");
			}

			void Visit(WfRaiseExceptionStatement* node)override
			{
				if (node->expression)
				{
					writer.WriteString(L"raise ");
					WfPrint(node->expression, indent, writer);
					writer.WriteString(L";");
				}
				else
				{
					writer.WriteString(L"raise;");
				}
			}

			void Visit(WfIfStatement* node)override
			{
				writer.WriteString(L"if (");
				if (node->type)
				{
					writer.WriteString(L"var ");
					writer.WriteString(node->name.value);
					writer.WriteString(L" : ");
					WfPrint(node->type, indent, writer);
					writer.WriteString(L" = ");
				}
				WfPrint(node->expression, indent, writer);
				writer.WriteLine(L")");

				writer.WriteString(indent);
				WfPrint(node->trueBranch, indent, writer);
				if (node->falseBranch)
				{
					writer.WriteLine(L"");
					writer.WriteString(indent);
					writer.WriteLine(L"else");
					writer.WriteString(indent);
					WfPrint(node->trueBranch, indent, writer);
				}
			}

			void Visit(WfSwitchStatement* node)override
			{
				writer.WriteString(L"switch (");
				WfPrint(node->expression, indent, writer);
				writer.WriteLine(L")");

				writer.WriteString(indent);
				writer.WriteLine(L"{");

				FOREACH(Ptr<WfSwitchCase>, switchCase, node->caseBranches)
				{
					writer.WriteString(indent);
					writer.WriteString(L"case ");
					WfPrint(switchCase->expression, indent, writer);
					writer.WriteLine(L":");
					writer.WriteString(indent + L"    ");
					WfPrint(switchCase->statement, indent + L"    ", writer);
					writer.WriteLine(L"");
				}
				if (node->defaultBranch)
				{
					writer.WriteString(indent);
					writer.WriteLine(L"default:");
					writer.WriteString(indent + L"    ");
					WfPrint(node->defaultBranch, indent + L"    ", writer);
					writer.WriteLine(L"");
				}

				writer.WriteString(indent);
				writer.WriteString(L"}");
			}

			void Visit(WfWhileStatement* node)override
			{
				writer.WriteString(L"while (");
				WfPrint(node->condition, indent, writer);
				writer.WriteLine(L")");
				writer.WriteString(indent);
				WfPrint(node->statement, indent, writer);
			}

			void Visit(WfForEachStatement* node)override
			{
				writer.WriteString(L"for (");
				writer.WriteString(node->name.value);
				writer.WriteString(L" in ");
				if (node->direction == WfForEachDirection::Reversed)
				{
					writer.WriteString(L"reversed ");
				}
				WfPrint(node->collection, indent, writer);
				writer.WriteLine(L")");
				writer.WriteString(indent);
				WfPrint(node->statement, indent, writer);
			}

			void Visit(WfTryStatement* node)override
			{
				writer.WriteLine(L"try");
				writer.WriteString(indent);
				WfPrint(node->protectedStatement, indent, writer);

				if (node->catchStatement)
				{
					writer.WriteLine(L"");
					writer.WriteString(indent);
					writer.WriteString(L"catch (");
					writer.WriteString(node->name.value);
					writer.WriteLine(L")");
					writer.WriteString(indent);
					WfPrint(node->catchStatement, indent, writer);
				}

				if (node->finallyStatement)
				{
					writer.WriteLine(L"");
					writer.WriteString(indent);
					writer.WriteLine(L"finally");
					writer.WriteString(indent);
					WfPrint(node->finallyStatement, indent, writer);
				}
			}

			void Visit(WfBlockStatement* node)override
			{
				writer.WriteLine(L"{");
				FOREACH(Ptr<WfStatement>, statement, node->statements)
				{
					writer.WriteString(indent + L"    ");
					WfPrint(statement, indent + L"    ", writer);
					writer.WriteLine(L"");
				}
				writer.WriteString(indent);
				writer.WriteString(L"}");
			}

			void Visit(WfExpressionStatement* node)override
			{
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L";");
			}

			void Visit(WfVariableStatement* node)override
			{
				WfPrint(Ptr<WfDeclaration>(node->variable), indent, writer);
			}
		};

		void WfPrint(Ptr<WfStatement> node, const WString& indent, stream::TextWriter& writer)
		{
			PrintStatementVisitor visitor(indent, writer);
			node->Accept(&visitor);
		}

/***********************************************************************
Print (Declaration)
***********************************************************************/

		class PrintDeclarationVisitor : public Object, public WfDeclaration::IVisitor
		{
		public:
			WString								indent;
			TextWriter&							writer;

			PrintDeclarationVisitor(const WString& _indent, stream::TextWriter& _writer)
				:indent(_indent), writer(_writer)
			{
			}

			void Visit(WfNamespaceDeclaration* node)override
			{
				writer.WriteLine(L"namespace " + node->name.value);
				writer.WriteString(indent);
				writer.WriteLine(L"{");
				FOREACH_INDEXER(Ptr<WfDeclaration>, decl, index, node->declarations)
				{
					if (index > 0)
					{
						writer.WriteLine(L"");
						writer.WriteLine(L"");
					}
					WfPrint(decl, indent + L"    ", writer);
				}
				writer.WriteString(indent);
				writer.WriteString(L"}");
			}

			void Visit(WfFunctionDeclaration* node)override
			{
				writer.WriteString(L"func ");
				if (node->anonymity == WfFunctionAnonymity::Named)
				{
					writer.WriteString(node->name.value);
				}

				writer.WriteString(L"(");
				FOREACH_INDEXER(Ptr<WfFunctionArgument>, argument, index, node->arguments)
				{
					if (index > 0)
					{
						writer.WriteString(L", ");
					}
					writer.WriteString(argument->name.value);
					writer.WriteString(L" : ");
					WfPrint(argument->type, indent, writer);
				}
				writer.WriteString(L")");

				writer.WriteString(L" : ");
				WfPrint(node->returnType, indent, writer);
				writer.WriteLine(L"");

				writer.WriteString(indent);
				WfPrint(node->statement, indent, writer);
			}

			void Visit(WfVariableDeclaration* node)override
			{
				writer.WriteString(L"var ");
				writer.WriteString(node->name.value);
				if (node->type)
				{
					writer.WriteString(L" : ");
					WfPrint(node->type, indent, writer);
				}
				writer.WriteString(L" = ");
				WfPrint(node->expression, indent, writer);
				writer.WriteString(L";");
			}
		};

		void WfPrint(Ptr<WfDeclaration> node, const WString& indent, stream::TextWriter& writer)
		{
			PrintDeclarationVisitor visitor(indent, writer);
			node->Accept(&visitor);
		}

/***********************************************************************
Print (Module)
***********************************************************************/

		void WfPrint(Ptr<WfModule> node, const WString& indent, stream::TextWriter& writer)
		{
			writer.WriteString(indent);
			switch (node->moduleType)
			{
			case WfModuleType::Module:
				writer.WriteLine(L"module " + node->name.value + L";");
				break;
			case WfModuleType::Unit:
				writer.WriteLine(L"unit " + node->name.value + L";");
				break;
			}

			FOREACH(Ptr<WfModuleUsingPath>, path, node->paths)
			{
				writer.WriteString(indent);
				writer.WriteString(L"using ");
				FOREACH_INDEXER(Ptr<WfModuleUsingItem>, item, index, path->items)
				{
					if (index > 0)
					{
						writer.WriteString(L"::");
					}
					FOREACH(Ptr<WfModuleUsingFragment>, fragment, item->fragments)
					{
						if (auto name = fragment.Cast<WfModuleUsingNameFragment>())
						{
							writer.WriteString(name->name.value);
						}
						else
						{
							writer.WriteString(L"*");
						}
					}
				}
				writer.WriteLine(L";");
			}

			FOREACH(Ptr<WfDeclaration>, decl, node->declarations)
			{
				writer.WriteLine(L"");
				writer.WriteString(indent);
				WfPrint(decl, indent, writer);
				writer.WriteLine(L"");
			}
		}
	}
}
