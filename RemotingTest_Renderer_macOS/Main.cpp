#include <GacUI.h>

#include <cstring>

extern int StartMiniHttpClient();

int main(int argc, char* argv[])
{
	if (argc == 2 && strcmp(argv[1], "/MiniHttp") == 0)
	{
		return StartMiniHttpClient();
	}
	return 1;
}
