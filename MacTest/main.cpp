//
//  main.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include <iostream>

#include "GacUI.h"

#include "label_basic.h"
#include "label_hyperlink.h"
#include "button_enable_disable.h"
#include "button_check_and_radio.h"
#include "tab_textbox_page.h"
#include "textbox_editor.h"
#include "textbox_colorizer.h"
#include "listbox_name_editor.h"
#include "listbox_name_selector.h"
#include "listbox_virtual_mode.h"
#include "listview_viewswitching.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<ViewSwitchingWindow>();
}

