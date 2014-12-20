//
//  xml_control_template.h
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_xml_control_template_h
#define GacOSX_xml_control_template_h

#include "../gac_include.h"
#include "control_template/HelloWorld.h"

using namespace vl::collections;
using namespace vl::reflection::description;

void RunControlTemplateWindow()
{
    List<WString> errors;
    GetInstanceLoaderManager()->SetResource(L"Resource", GuiResource::LoadFromXml(GetApplication()->GetExecutableFolder()+L"/Contents/Resources/XmlWindowResourceControlTemplate.precompiled.xml", errors));
    demos::MainWindow window;
    window.ForceCalculateSizeImmediately();
    window.MoveToScreenCenter();
    GetApplication()->Run(&window);
}

#endif
