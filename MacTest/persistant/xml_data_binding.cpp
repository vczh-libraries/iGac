//
//  load_from_xml_data_binding.h
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_load_from_xml_data_binding_h
#define GacOSX_load_from_xml_data_binding_h

#include "../shared/gac_include.h"
#include "data_binding/Demo.h"

void RunXmlDataBindingWindow()
{
    List<WString> errors;
    GetInstanceLoaderManager()->SetResource(L"Resource", GuiResource::LoadFromXml(GetApplication()->GetExecutableFolder()+L"/Contents/Resources/XmlWindowResourceDataBinding.xml", errors));
    demos::MainWindow window;
    window.ForceCalculateSizeImmediately();
    window.MoveToScreenCenter();
    GetApplication()->Run(&window);
}

int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunXmlDataBindingWindow();
}

#endif
