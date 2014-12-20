//
//  datagrid_chemical_elements_cg_renderer.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/15/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "datagrid_chemical_elements_cg_renderer.h"

#import <Cocoa/Cocoa.h>


void ElementElectronDataRenderer::OnBeforeRenderTargetChanged(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments)
{
    
}

void ElementElectronDataRenderer::OnAfterRenderTargetChanged(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments)
{
    
}

#define TO_RADIUS(d) (d / 180.f * 3.1415926)

void ElementElectronDataRenderer::OnRendering(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments)
{
    CGContextRef context = arguments.context;
    
    CGContextSaveGState(context);
    for(vl::vint i=0; i<electronCounts.Count(); ++i)
    {

        NSString* s = [@(electronCounts[i]) stringValue];
        [s drawAtPoint:NSMakePoint(arguments.bounds.x1 + ArcLeft + i * GraphStep + ArcRadius - 4,
                                   arguments.bounds.y1 + (GraphHeight - GraphHole) / 2) withAttributes:nil];

        CGContextSetRGBStrokeColor(context, 0.5f, 0.5f, 0.5f, 1.0f);

        CGContextAddArc(context,
                        arguments.bounds.x1 + ArcLeft + i * GraphStep,
                        arguments.bounds.y1 + GraphHeight / 2,
                        ArcRadius,
                        TO_RADIUS(50),
                        TO_RADIUS(15),
                        1);
        
        CGContextStrokePath(context);
        
        CGContextAddArc(context,
                        arguments.bounds.x1 + ArcLeft + i * GraphStep,
                        arguments.bounds.y1 + GraphHeight / 2,
                        ArcRadius,
                        TO_RADIUS(-15),
                        TO_RADIUS(-50),
                        1);
        CGContextStrokePath(context);
        
    }
    CGContextRestoreGState(context);
}

