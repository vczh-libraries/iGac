//
//  directcode_scripting.h
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_directcode_scripting_h
#define GacOSX_directcode_scripting_h

#include "../gac_include.h"

using namespace vl::collections;
using namespace vl::reflection::description;
using namespace vl::parsing;
using namespace vl::workflow;
using namespace vl::workflow::analyzer;
using namespace vl::workflow::runtime;

void RunSimpleWindowByScripting()
{
    List<Ptr<ParsingError>> errors;
    List<WString> codes;
    codes.Add(LR"workflow(
              module helloworld;
              using system::*;
              using system::reflection::*;
              using presentation::*;
              using presentation::controls::*;
              using presentation::compositions::*;
              using presentation::theme::*;
              
              var window : GuiWindow* = null;
              
              func button_Clicked(sender : GuiGraphicsComposition*, arguments : GuiEventArgs*) : void
              {
                  var button = cast GuiButton* (sender.RelatedControl);
                  button.Text = "Well done!";
              }
              
              func CreateWindow() : GuiWindow*
              {
                  window = new GuiWindow*(ITheme::GetCurrentTheme().CreateWindowStyle());
                  window.Text = "Scriptable GacUI!";
                  window.ContainerComposition.PreferredMinSize = cast Size "x:300 y:200";
                  
                  var button = new GuiButton*(ITheme::GetCurrentTheme().CreateButtonStyle());
                  button.Text = "Click Me!";
                  button.BoundsComposition.AlignmentToParent = cast Margin "left:50 top:50 right:50 bottom:50";
                  attach(button.Clicked, button_Clicked);
                  window.AddChild(button);
                  
                  window.ForceCalculateSizeImmediately();
                  window.MoveToScreenCenter();
                  return window;
              }
              
              )workflow");
    
    WfLoadTypes();
    auto table = WfLoadTable();
    auto assembly = Compile(table, codes, errors);
    if(errors.Count() != 0)
    {
        for(int i=0; i<errors.Count(); ++i)
        {
            wprintf(L"%ls\n", errors[i]->errorMessage.Buffer());
        }
    }
    auto globalContext = MakePtr<WfRuntimeGlobalContext>(assembly);
    auto threadContext = MakePtr<WfRuntimeThreadContext>(globalContext);
    
    auto initializeFunction = LoadFunction<void()>(globalContext, L"<initialize>");
    auto createWindowFunction = LoadFunction<GuiWindow*()>(globalContext, L"CreateWindow");
    initializeFunction();
    Ptr<GuiWindow> window = createWindowFunction();
    GetApplication()->Run(window.Obj());
}

#endif
