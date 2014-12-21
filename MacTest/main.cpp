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
#include "controls/listbox_virtual_mode.h"
#include "controls/listview_viewswitching.h"
#include "controls/listview_sorting_and_filtering.h"
#include "controls/listview_virtual_mode.h"
#include "controls/template_customized_border.h"
#include "controls/treeview_file_explorer.h"
#include "controls/scroll_colorpicker.h"
#include "controls/datagrid_chemical_elements.h"
#include "controls/datagrid_file_browser.h"
#include "controls/datagrid_date_picker.h"
#include "controls/datagrid_table_editor.h"
#include "controls/tooltip_richtext.h"

#include "rendering/rendering_rawapi.h"

#include "persistant/directcode_simplewindow.h"
#include "persistant/directcode_scripting.h"

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<TooltipWindow>();
}

