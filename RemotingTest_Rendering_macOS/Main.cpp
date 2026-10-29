#include <GacUI.h>
#include "../SharedArguments.h"

#include <cstdlib>
#include <cstring>

using namespace vl;

extern int StartMiniHttpClient(const WString& coreHost, vint automationHttpPort);

int main(int argc, char* argv[])
{
	bool miniHttp = false;
	vint automationHttpPort = 8889;
	bool portSpecified = false;
	gacui_test::CoreHostArguments coreHost;
	for (int i = 1; i < argc; i++)
	{
		auto consumed = gacui_test::remoteInjectionArguments.Consume(atow(AString(argv[i])));
		if (consumed < 0) return 1;
		if (consumed > 0) continue;
		consumed = coreHost.Consume(u8tow(U8String(reinterpret_cast<const char8_t*>(argv[i]))));
		if (consumed < 0) return 1;
		if (consumed > 0) continue;
		if (strcmp(argv[i], "/MiniHttp") == 0)
		{
			if (miniHttp)
			{
				return 1;
			}
			miniHttp = true;
		}
		else if (strncmp(argv[i], "/port:", 6) == 0)
		{
			char* end = nullptr;
			auto port = strtol(argv[i] + 6, &end, 10);
			if (portSpecified || end == argv[i] + 6 || *end || port < 1 || port > 65535)
			{
				return 1;
			}
			portSpecified = true;
			automationHttpPort = port;
		}
		else
		{
			return 1;
		}
	}
	return miniHttp ? StartMiniHttpClient(coreHost.host, automationHttpPort) : 1;
}
