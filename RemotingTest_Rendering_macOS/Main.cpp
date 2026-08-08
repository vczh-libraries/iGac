#include <GacUI.h>

#include <cstdlib>
#include <cstring>

using namespace vl;

extern int StartMiniHttpClient(vint automationHttpPort);

int main(int argc, char* argv[])
{
	bool miniHttp = false;
	vint automationHttpPort = 8889;
	bool portSpecified = false;
	for (int i = 1; i < argc; i++)
	{
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
	return miniHttp ? StartMiniHttpClient(automationHttpPort) : 1;
}
