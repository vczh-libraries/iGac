#include "GacGen.h"

Array<WString>* arguments = 0;

int wmain(int argc, wchar_t* argv[])
{
	Array<WString> _arguments(argc - 1);
	for (vint i = 1; i < argc; i++)
	{
		_arguments[i - 1] = argv[i];
	}
	arguments = &_arguments;
	SetupWindowsDirect2DRenderer();
}

void GuiMain()
{
	Console::WriteLine(L"Vczh GacUI Resource Code Generator for C++");
	if (arguments->Count() != 1)
	{
		PrintErrorMessage(L"GacGen.exe only accept 1 input file.");
		return;
	}

	WString inputPath = arguments->Get(0);
	PrintSuccessMessage(L"gacgen> Making : " + inputPath);
	List<WString> errors;
	auto resource = GuiResource::LoadFromXml(arguments->Get(0), errors);
	if (!resource)
	{
		PrintErrorMessage(L"error> Failed to load resource.");
		return;
	}
	else
	{
		PrintSuccessMessage(L"gacgen> Compiling...");
		resource->Precompile(errors);
	}
	FOREACH(WString, error, errors)
	{
		PrintInformationMessage(error);
	}
	GetInstanceLoaderManager()->SetResource(L"GACGEN", resource);

	auto config = CodegenConfig::LoadConfig(resource);
	if (!config)
	{
		PrintErrorMessage(L"error> Failed to load config.");
		return;
	}

	Regex regexClassName(L"((<namespace>[^:]+)::)*(<type>[^:]+)");
	Ptr<GuiResourcePathResolver> resolver = new GuiResourcePathResolver(resource, resource->GetWorkingDirectory());
	Dictionary<WString, Ptr<InstanceSchema>> typeSchemas;
	List<WString> typeSchemaOrder;
	Dictionary<WString, Ptr<Instance>> instances;
	SearchAllSchemas(regexClassName, resource, typeSchemas, typeSchemaOrder);
	SearchAllInstances(regexClassName, resolver, resource, instances);
		
	FOREACH(Ptr<Instance>, instance, instances.Values())
	{
		Ptr<GuiInstanceEnvironment> env = new GuiInstanceEnvironment(instance->context, resolver);
		SearchAllEventHandlers(config, instances, instance, env, instance->eventHandlers);
	}

	FOREACH(Ptr<Instance>, instance, instances.Values())
	{
		WriteControlClassHeaderFile(config, instance);
		WriteControlClassCppFile(config, instance);
	}
	WritePartialClassHeaderFile(config, typeSchemas, typeSchemaOrder, instances);
	WritePartialClassCppFile(config, typeSchemas, typeSchemaOrder, instances);
	WriteGlobalHeaderFile(config, instances);

	if (config->precompiledOutput != L"")
	{
		WString fileName = config->precompiledOutput;
		auto xml = resource->SaveToXml(true);
		OPEN_FILE(L"Precompiled Resource Xml");
		XmlPrint(xml, writer);
	}
	if (config->precompiledBinary != L"")
	{
		FileStream fileStream(config->resource->GetWorkingDirectory() + config->precompiledBinary, FileStream::WriteOnly);
		resource->SavePrecompiledBinary(fileStream);
	}
	if (config->precompiledCompressed != L"")
	{
		FileStream fileStream(config->resource->GetWorkingDirectory() + config->precompiledCompressed, FileStream::WriteOnly);
		LzwEncoder encoder;
		EncoderStream encoderStream(fileStream, encoder);
		resource->SavePrecompiledBinary(encoderStream);
	}
}