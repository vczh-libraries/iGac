//
//  rendering_rawapi.h
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef GacOSX_rendering_rawapi_h
#define GacOSX_rendering_rawapi_h

#include "GacUI.h"
#include "../../Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.h"


class CGWindow : public vl::presentation::controls::GuiWindow
{
protected:
    static const int        Radius=200;
    static const int        LongScale=10;
    static const int        ShortScale=5;
    static const int        SecondLength=180;
    static const int        MinuteLength=150;
    static const int        HourLength=120;
    
    double GetAngle(double second)
    {
        return (second-15)*3.1416/30;
    }
    
    void DrawLine(CGContextRef context, vl::presentation::Color color, double angle, vl::vint startLength, vl::vint endLength, vl::vint x, vl::vint y);
    
    // arguments.dc is WinDC, which is an encapsulation for HDC.
    void element_Rendering(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments);
    
public:
    CGWindow();
    
};


#endif
