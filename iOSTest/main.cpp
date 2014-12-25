//
//  main.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include <iostream>

#include "GacUI.h"

#include "controls/label_basic.h"
#include "controls/label_hyperlink.h"
#include "controls/button_enable_disable.h"
#include "controls/button_check_and_radio.h"
#include "controls/tab_textbox_page.h"
#include "controls/textbox_editor.h"
#include "controls/textbox_colorizer.h"
#include "controls/listbox_name_editor.h"
#include "controls/listbox_name_selector.h"
#include "controls/template_customized_border.h"
#include "controls/scroll_colorpicker.h"
#include "controls/datagrid_date_picker.h"
#include "controls/tooltip_richtext.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<DatePickerWindow>();
}

