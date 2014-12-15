//
//  datagrid_chemical_elements_cg_renderer.h
//  GacOSX
//
//  Created by Robert Bu on 12/15/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GacOSX__datagrid_chemical_elements_cg_renderer__
#define __GacOSX__datagrid_chemical_elements_cg_renderer__

#include "GacUI.h"
#include "../Mac/GraphicsElement/CoreGraphics/GuiGraphicsCoreGraphics.h"


struct ElementElectronDataRenderer
{
    vl::collections::List<vl::vint>     electronCounts;
    
    static const vl::vint   GraphHeight     =64;
    static const vl::vint   GraphWidth      =8;
    static const vl::vint   GraphHole       =16;
    static const vl::vint   GraphStep       =20;
    static const vl::vint   ArcLeft         =0;
    static const vl::vint   ArcTop          =12;
    static const vl::vint   ArcRadius       =32;
    
    void OnBeforeRenderTargetChanged(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments);
    
    void OnAfterRenderTargetChanged(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments);
    
    void OnRendering(vl::presentation::compositions::GuiGraphicsComposition* sender, vl::presentation::elements::GuiCoreGraphicsElementEventArgs& arguments);

};


#endif /* defined(__GacOSX__datagrid_chemical_elements_cg_renderer__) */
