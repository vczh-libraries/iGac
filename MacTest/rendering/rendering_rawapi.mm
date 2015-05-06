//
//  rendering_rawapi.mm
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "rendering_rawapi.h"

#include <CoreGraphics/CoreGraphics.h>

CGWindow::CGWindow():
GuiWindow(vl::presentation::theme::GetCurrentTheme()->CreateWindowStyle())
{
    SetText(L"Rendering.RawAPI.CoreGraphics");
    SetClientSize(vl::presentation::Size(640, 480));
    GetBoundsComposition()->SetPreferredMinSize(vl::presentation::Size(640, 480));
    MoveToScreenCenter();
    {
        vl::presentation::elements::GuiCoreGraphicsElement* element = vl::presentation::elements::GuiCoreGraphicsElement::Create();
        element->Rendering.AttachMethod(this, &CGWindow::element_Rendering);
        
        vl::presentation::compositions::GuiBoundsComposition* composition=new vl::presentation::compositions::GuiBoundsComposition;
        composition->SetAlignmentToParent(vl::presentation::Margin(0, 0, 0, 0));
        composition->SetOwnedElement(element);
        GetContainerComposition()->AddChild(composition);
    }
}

void CGWindow::DrawLine(CGContextRef context, vl::presentation::Color color, double angle, vl::vint startLength, vl::vint endLength, vl::vint x, vl::vint y)
{
    double s = sin(angle);
    double c = cos(angle);
    vl::vint x1 = (int)(c*startLength)+x+Radius;
    vl::vint y1 = (int)(s*startLength)+y+Radius;
    vl::vint x2 = (int)(c*endLength)+x+Radius;
    vl::vint y2 = (int)(s*endLength)+y+Radius;
    
    CGPoint points[] = {
        {(CGFloat)x1, (CGFloat)y1},
        {(CGFloat)x2, (CGFloat)y2}
    };
    CGContextSetRGBStrokeColor(context, color.r/255.0, color.g/255.0, color.b/255.0, color.a/255.0);
    CGContextStrokeLineSegments(context, points, 2);
}

void CGWindow::element_Rendering(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments)
{
    vl::vint w = arguments.bounds.Width();
    vl::vint h = arguments.bounds.Height();
    vl::vint x = arguments.bounds.Left()+(w-Radius*2)/2;
    vl::vint y = arguments.bounds.Left()+(h-Radius*2)/2;
    
    CGContextRef context = arguments.context;
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
    CGContextStrokeEllipseInRect(context, CGRectMake(x, y, Radius*2, Radius*2));
    
    for(int i=0;i<60;i++)
    {
        int scale=i%5==0?LongScale:ShortScale;
        double angle=GetAngle(i);
        
        DrawLine(context, vl::presentation::Color(0, 0, 0), angle, Radius-scale, Radius, x, y);
    }
    
    vl::DateTime dt=vl::DateTime::LocalTime();
    {
        double angle=GetAngle(dt.hour*5+dt.minute/12.0+dt.second/720.0);
        DrawLine(context, vl::presentation::Color(255, 0, 0), angle, 0, HourLength, x, y);
    }
    {
        double angle=GetAngle(dt.minute+dt.second/60.0);
        DrawLine(context, vl::presentation::Color(0, 255, 0), angle, 0, MinuteLength, x, y);
    }
    {
        double angle=GetAngle(dt.second);
        DrawLine(context, vl::presentation::Color(0, 0, 255), angle, 0, SecondLength, x, y);
    }
}
