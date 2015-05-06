//
//  datagrid_chemical_elements_renderer.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/15/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "datagrid_chemical_elements.h"
#include "datagrid_chemical_elements_cg_renderer.h"

const wchar_t* ElementElectron::RegexEec = L"(<level>/d+)(<type>[spdf])(<count>/d+)";

ElementElectronDataVisualizer::ElementElectronDataVisualizer()
{
    renderer = new ElementElectronDataRenderer;
}

void ElementElectronDataVisualizer::BeforeVisualizerCell(list::IDataProvider* dataProvider, vint row, vint column)
{
    renderer->electronCounts.Clear();
}

void ElementElectronDataVisualizer::ShowGraph(list::StrongTypedDataProvider<ElementData>* dataProvider, vint row)
{
    Array<vint> counts;
    CopyFrom(counts, Range((vint)0, (vint)1).Repeat(10));
    
    ElementData data;
    vint order=row+1;
    while(order>0)
    {
        dataProvider->GetRowData(order-1, data);
        FOREACH(ElementElectron, ec, data.ecs->electrons)
        {
            counts[ec.level-1]+=ec.count;
        }
        order=data.ecs->nobleGasNotationOrder;
    }
    
    CopyFrom(renderer->electronCounts, From(counts).Take(counts.IndexOf(0)));
    

}

GuiBoundsComposition* ElementElectronDataVisualizer::CreateBoundsCompositionInternal(GuiBoundsComposition* decoratedComposition)
{
    GuiCoreGraphicsElement* graphElement = GuiCoreGraphicsElement::Create();
    graphElement->BeforeRenderTargetChanged.AttachMethod(renderer, &ElementElectronDataRenderer::OnBeforeRenderTargetChanged);
    graphElement->AfterRenderTargetChanged.AttachMethod(renderer, &ElementElectronDataRenderer::OnAfterRenderTargetChanged);
    graphElement->Rendering.AttachMethod(renderer, &ElementElectronDataRenderer::OnRendering);
    //
    composition = new GuiBoundsComposition;
    composition->SetPreferredMinSize(vl::presentation::Size(0, 64));
    composition->SetOwnedElement(graphElement);
    return composition;
}


int main(int argc, const char * argv[])
{
    SetupOSXCoreGraphicsRenderer();
    
    return 0;
}

void GuiMain()
{
    RunGacWindow<ChemicalElementWindow>();
}