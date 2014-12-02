#include "GacGen.h"

/***********************************************************************
Codegen::ControlClassContent
***********************************************************************/

void WriteControlClassHeaderFileContent(Ptr<CodegenConfig> config, Ptr<Instance> instance, StreamWriter& writer)
{
	WString prefix = WriteNamespaceBegin(instance->namespaces, writer);
	WString instanceClassName;
	FOREACH(WString, ns, instance->namespaces)
	{
		instanceClassName += ns + L"::";
	}
	instanceClassName += instance->typeName;

	writer.WriteLine(prefix + L"class " + instance->typeName + L" : public " + instanceClassName + L"_<" + instanceClassName + L">");
	writer.WriteLine(prefix + L"{");
	writer.WriteLine(prefix + L"\tfriend class " + instanceClassName + L"_<" + instanceClassName + L">;");
	writer.WriteLine(prefix + L"\tfriend struct vl::reflection::description::CustomTypeDescriptorSelector<" + instanceClassName + L">;");
	writer.WriteLine(prefix + L"protected:");
	writer.WriteLine(L"");
	WriteControlClassHeaderFileEventHandlers(config, instance, prefix, writer);
	writer.WriteLine(prefix + L"public:");
	writer.WriteString(prefix + L"\t" + instance->typeName + L"(");
	FOREACH_INDEXER(Ptr<GuiInstanceParameter>, parameter, index, instance->context->parameters)
	{
		if (index > 0)
		{
			writer.WriteString(L", ");
		}
		writer.WriteString(L"Ptr<");
		writer.WriteString(parameter->className.ToString());
		writer.WriteString(L"> ");
		writer.WriteString(parameter->name.ToString());
	}
	writer.WriteLine(L");");
	writer.WriteLine(prefix + L"};");
	WriteNamespaceEnd(instance->namespaces, writer);
	writer.WriteLine(L"");
}

void WriteControlClassCppFileContent(Ptr<CodegenConfig> config, Ptr<Instance> instance, StreamWriter& writer)
{
	Group<WString, WString> existingEventHandlers;
	List<WString> additionalLines;
	WString prefix = WriteNamespaceBegin(instance->namespaces, writer);
	WriteControlClassCppFileEventHandlers(config, instance, prefix, existingEventHandlers, additionalLines, writer);
	writer.WriteLine(L"");
	writer.WriteString(prefix + instance->typeName + L"::" + instance->typeName + L"(");
	FOREACH_INDEXER(Ptr<GuiInstanceParameter>, parameter, index, instance->context->parameters)
	{
		if (index > 0)
		{
			writer.WriteString(L", ");
		}
		writer.WriteString(L"Ptr<");
		writer.WriteString(parameter->className.ToString());
		writer.WriteString(L"> ");
		writer.WriteString(parameter->name.ToString());
	}
	writer.WriteLine(L")");
	writer.WriteLine(prefix + L"{");
	writer.WriteString(prefix + L"\tInitializeComponents(");
	FOREACH_INDEXER(Ptr<GuiInstanceParameter>, parameter, index, instance->context->parameters)
	{
		if (index > 0)
		{
			writer.WriteString(L", ");
		}
		writer.WriteString(parameter->name.ToString());
	}
	writer.WriteLine(L");");
	writer.WriteLine(prefix + L"}");
	WriteNamespaceEnd(instance->namespaces, writer);
	writer.WriteLine(L"");
}