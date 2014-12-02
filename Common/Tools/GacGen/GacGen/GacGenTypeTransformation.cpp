#include "GacGen.h"

/***********************************************************************
CppTypeTransformation
***********************************************************************/

bool DetermineCppType(
	Ptr<CodegenConfig> config,
	Dictionary<WString, Ptr<Instance>>& instances,
	Ptr<Instance> instance,
	GuiConstructorRepr* ctor,
	GlobalStringKey& typeName,
	IGuiInstanceLoader*& loader,
	const Func<bool()>& stop
	)
{
	Ptr<GuiResourcePathResolver> resolver = new GuiResourcePathResolver(config->resource, config->resource->GetWorkingDirectory());
	Ptr<GuiInstanceContext> currentContext = instance->context;
	GuiConstructorRepr* currentCtor = ctor;
	typeName = GlobalStringKey::Empty;
	loader = 0;

	while (currentContext)
	{
		Ptr<GuiInstanceEnvironment> env = new GuiInstanceEnvironment(currentContext, resolver);
		auto loadingSource = FindInstanceLoadingSource(env->context, currentCtor);
		currentContext = loadingSource.context;
		currentCtor = currentContext ? currentContext->instance.Obj() : 0;
		typeName = loadingSource.typeName;
		loader = loadingSource.loader;

		if (stop())
		{
			return true;
		}
	}

	return false;
}

WString GetCppTypeName(ITypeDescriptor* typeDescriptor)
{
	return L"vl::" + typeDescriptor->GetTypeName();
}

WString GetCppTypeName(Ptr<CodegenConfig> config, Dictionary<WString, Ptr<Instance>>& instances, Ptr<Instance> instance, GuiConstructorRepr* ctor)
{
	GlobalStringKey typeName;
	IGuiInstanceLoader* loader = 0;
	if (DetermineCppType(config, instances, instance, ctor, typeName, loader, [&]()
		{
			return instances.Keys().Contains(typeName.ToString());
		}))
	{
		return typeName.ToString();
	}
	else
	{
		auto manager = GetInstanceLoaderManager();
		return GetCppTypeName(manager->GetTypeDescriptorForType(typeName));
	}
}

IGuiInstanceLoader::TypeInfo GetCppTypeInfo(Ptr<CodegenConfig> config, Dictionary<WString, Ptr<Instance>>& instances, Ptr<Instance> instance, GuiConstructorRepr* ctor)
{
	GlobalStringKey typeName;
	IGuiInstanceLoader* loader = 0;
	DetermineCppType(config, instances, instance, ctor, typeName, loader, [&]()
	{
		return loader != 0;
	});
	auto manager = GetInstanceLoaderManager();
	ITypeDescriptor* typeDescriptor = manager->GetTypeDescriptorForType(typeName);
	return IGuiInstanceLoader::TypeInfo(typeName, typeDescriptor);
}

/***********************************************************************
WorkflowTypeTransformation
***********************************************************************/

class GetCppTypeNameFromWorkflowTypeVisitor : public Object, public WfType::IVisitor
{
public:
	WString					result;

	static WString Call(Ptr<WfType> node)
	{
		GetCppTypeNameFromWorkflowTypeVisitor visitor;
		node->Accept(&visitor);
		return visitor.result;
	}

	void VisitReferenceType(WfType* node)
	{
		WString typeName;
		{
			MemoryStream stream;
			{
				StreamWriter writer(stream);
				WfPrint(node, L"", writer);
			}

			stream.SeekFromBegin(0);
			StreamReader reader(stream);
			typeName = reader.ReadToEnd();
		}

		auto td = description::GetTypeDescriptor(typeName);
		if (td)
		{
			typeName = td->GetTypeName();
			if (typeName == L"system::Void")
			{
				result = L"void";
			}
			else if (typeName == L"system::Interface")
			{
				result = L"IDescriptable";
			}
			else if (typeName == L"system::ReferenceType")
			{
				result = L"DescriptableObject";
			}
			else if (typeName == L"system::Object")
			{
				result = L"descriptable::Value";
			}
			else if (typeName == L"system::UInt8")
			{
				result = L"vuint8_t";
			}
			else if (typeName == L"system::UInt16")
			{
				result = L"vuint16_t";
			}
			else if (typeName == L"system::UInt32")
			{
				result = L"vuint32_t";
			}
			else if (typeName == L"system::UInt64")
			{
				result = L"vuint64_t";
			}
			else if (typeName == L"system::Int8")
			{
				result = L"vint8_t";
			}
			else if (typeName == L"system::Int16")
			{
				result = L"vint16_t";
			}
			else if (typeName == L"system::Int32")
			{
				result = L"vint32_t";
			}
			else if (typeName == L"system::Int64")
			{
				result = L"vint64_t";
			}
			else if (typeName == L"system::Single")
			{
				result = L"float";
			}
			else if (typeName == L"system::Double")
			{
				result = L"double";
			}
			else if (typeName == L"system::Boolean")
			{
				result = L"bool";
			}
			else if (typeName == L"system::Char")
			{
				result = L"wchar_t";
			}
			else if (typeName == L"system::String")
			{
				result = L"WString";
			}
			else if (typeName == L"system::DateTime")
			{
				result = L"DateTime";
			}
			else if (typeName == L"system::Locale")
			{
				result = L"Locale";
			}
			else if (typeName == L"system::ObservableList")
			{
				result = L"presentation::description::IValueObservableList";
			}
			else if (typeName.Length() >= 11 && typeName.Left(11) == L"system::Xml")
			{
				result = L"parsing::xml::" + typeName.Right(typeName.Length() - 8);
			}
			else if (typeName.Length() >= 12 && typeName.Left(12) == L"system::Json")
			{
				result = L"parsing::json::" + typeName.Right(typeName.Length() - 8);
			}
			else
			{
				result = typeName;
			}
		}
		else
		{
			result = typeName;
		}
	}

	void Visit(WfPredefinedType* node)override
	{
		switch (node->name)
		{
		case WfPredefinedTypeName::Void:
			result = L"void";
			break;
		case WfPredefinedTypeName::Object:
			result = L"description::Value";
			break;
		case WfPredefinedTypeName::Interface:
			result = L"IDescriptable";
			break;
		case WfPredefinedTypeName::Int:
			result = L"vint";
			break;
		case WfPredefinedTypeName::UInt:
			result = L"vuint";
			break;
		case WfPredefinedTypeName::Float:
			result = L"float";
			break;
		case WfPredefinedTypeName::Double:
			result = L"double";
			break;
		case WfPredefinedTypeName::String:
			result = L"WString";
			break;
		case WfPredefinedTypeName::Char:
			result = L"wchar_t";
			break;
		case WfPredefinedTypeName::Bool:
			result = L"bool";
			break;
		}
	}

	void Visit(WfTopQualifiedType* node)override
	{
		VisitReferenceType(node);
	}

	void Visit(WfReferenceType* node)override
	{
		VisitReferenceType(node);
	}

	void Visit(WfRawPointerType* node)override
	{
		auto type = Call(node->element);
		if (type != L"")
		{
			result = type + L"*";
		}
	}

	void Visit(WfSharedPointerType* node)override
	{
		auto type = Call(node->element);
		if (type != L"")
		{
			result = L"Ptr<" + type + L">";
		}
	}

	void Visit(WfNullableType* node)override
	{
		auto type = Call(node->element);
		if (type != L"")
		{
			result = L"Nullable<" + type + L">";
		}
	}

	void Visit(WfEnumerableType* node)override
	{
		auto type = Call(node->element);
		if (type != L"")
		{
			result = L"collections::LazyList<" + type + L">";
		}
	}

	void Visit(WfMapType* node)override
	{
		auto key = node->key ? Call(node->key) : L"";
		auto value = Call(node->value);
		if (value != L"" && (!node->key || key != L""))
		{
			if (node->writability == WfMapWritability::Readonly)
			{
				result = L"const ";
			}

			if (key == L"")
			{
				result += L"collections::List<" + value + L">&";
			}
			else
			{
				result += L"collections::Dictionary<" + key + L", " + value + L">&";
			}
		}
	}

	void Visit(WfFunctionType* node)override
	{
		auto resultType = Call(node->result);
		if (resultType == L"")
		{
			return;
		}

		List<WString> argumentTypes;
		FOREACH(Ptr<WfType>, type, node->arguments)
		{
			auto argumentType = Call(type);
			if (argumentType == L"")
			{
				return;
			}
			argumentTypes.Add(argumentType);
		}

		result = L"Func<" + resultType + L"(";
		FOREACH_INDEXER(WString, type, index, argumentTypes)
		{
			if (index > 0)result += L", ";
			result += type;
		}
		result += L")>";
	}

	void Visit(WfChildType* node)override
	{
		VisitReferenceType(node);
	}
};

WString GetCppTypeNameFromWorkflowType(Ptr<CodegenConfig> config, const WString& workflowType)
{
	if (!config->workflowTable)
	{
		config->workflowTable = WfLoadTable();
	}
	if (!config->workflowManager)
	{
		config->workflowManager = new WfLexicalScopeManager(config->workflowTable);
		const wchar_t* moduleCode = LR"workflow(
module TypeConversion;

using presentation::controls::Gui*;
using presentation::elements::Gui*Element;
using presentation::compositions::Gui*Composition;
using presentation::compositions::Gui*;
using presentation::templates::Gui*;
using system::*;
using system::reflection::*;
using presentation::*;
using presentation::Gui*;
using presentation::controls::*;
using presentation::controls::list::*;
using presentation::controls::tree::*;
using presentation::elements::*;
using presentation::elements::Gui*;
using presentation::elements::text*;
using presentation::compositions::*;
using presentation::templates::*;

)workflow";
		auto module = config->workflowManager->AddModule(moduleCode);
		if (!module)
		{
			PrintErrorMessage(L"Internal error: wrong module code.");
		}
		config->workflowManager->Rebuild(true);
	}

	auto type = WfParseType(workflowType, config->workflowTable);
	if (!type)
	{
		PrintErrorMessage(L"Invalid workflow type: \"" + workflowType + L"\".");
		return L"vint";
	}

	auto module = config->workflowManager->modules[0];
	auto scope = config->workflowManager->moduleScopes[module.Obj()];
	analyzer::ValidateTypeStructure(config->workflowManager.Obj(), type, true);
	if (config->workflowManager->errors.Count() > 0)
	{
		PrintErrorMessage(L"Invalid workflow type: \"" + workflowType + L"\".");
		FOREACH(Ptr<ParsingError>, error, config->workflowManager->errors)
		{
			PrintErrorMessage(error->errorMessage);
		}
		config->workflowManager->errors.Clear();
		return L"vint";
	}

	auto cppType = GetCppTypeNameFromWorkflowTypeVisitor::Call(type.Obj());
	return cppType == L"" ? L"vint" : cppType;
}