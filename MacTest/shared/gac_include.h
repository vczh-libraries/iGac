//
//  gac_include.h
//  GacOSX
//
//  Created by Robert Bu on 12/7/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_gac_include_h
#define GacOSX_gac_include_h

#include "GacUI.h"

using namespace vl;
using namespace vl::collections;
using namespace vl::presentation;
using namespace vl::presentation::elements;
using namespace vl::presentation::compositions;
using namespace vl::presentation::controls;
using namespace vl::presentation::theme;
using namespace vl::presentation::templates;

template<typename T>
void RunGacWindow()
{
    GuiWindow* window = new T();
    GetApplication()->Run(window);
    delete window;
}

#include "Skins/DarkSkin/DarkSkin.h"

namespace osx
{
    class WindowTemplate : public ::vl::presentation::templates::GuiWindowTemplate
    {
    public:
        WindowTemplate()
        {
            this->SetCustomFrameEnabled(false);
        }
    };

    class Theme : public ::vl::presentation::theme::ThemeTemplates
    {
    public:
        Theme()
        {
            this->Window = LAMBDA([](const ::vl::reflection::description::Value& _){
                return new WindowTemplate();
            });
        }
    };
}

class OSXSkinPlugin : public Object, public IGuiPlugin
{
public:

    GUI_PLUGIN_NAME(Custom_OSXSkinPlugin)
    {
        GUI_PLUGIN_DEPEND(GacGen_DarkSkinResourceLoader);
    }

    void Load()override
    {
        RegisterTheme(MakePtr<osx::Theme>());
    }

    void Unload()override
    {
    }
};

class DefaultSkinPlugin : public Object, public IGuiPlugin
{
public:

    GUI_PLUGIN_NAME(Custom_DefaultSkinPlugin)
    {
        GUI_PLUGIN_DEPEND(GacGen_DarkSkinResourceLoader);
    }

    void Load()override
    {
        RegisterTheme(MakePtr<darkskin::Theme>());
    }

    void Unload()override
    {
    }
};
GUI_REGISTER_PLUGIN(DefaultSkinPlugin)
GUI_REGISTER_PLUGIN(OSXSkinPlugin)

#endif
