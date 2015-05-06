#include "../shared/gac_include.h"
#include "rendering_rawapi.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<CGWindow>();
}