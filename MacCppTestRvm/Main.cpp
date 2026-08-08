#include <GacUI.h>

#include <cstring>

extern int StartMiniHttpServer();

int main(int argc, char* argv[])
{
	if (argc == 2 && strcmp(argv[1], "/MiniHttp") == 0)
	{
		return StartMiniHttpServer();
	}
	return 1;
}
