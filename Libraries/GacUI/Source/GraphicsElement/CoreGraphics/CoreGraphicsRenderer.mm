//
//  CoreGraphicsRenderer.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CoreGraphicsRenderer.h"
#include "../../Controls/GuiApplication.h"

using namespace vl::presentation;

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
                
            CGResourceManager::CGResourceManager()
            {
                //                        layoutProvider=new WindowsDirect2DLayoutProvider;
            }
            
            IGuiGraphicsRenderTarget* CGResourceManager::GetRenderTarget(INativeWindow* window) override
            {
            //                        return GetWindowsDirect2DObjectProvider()->GetBindedRenderTarget(window);
                return 0;
            }
            
            void CGResourceManager::RecreateRenderTarget(INativeWindow* window) override
            {
                NativeWindowDestroying(window);
            //                GetWindowsDirect2DObjectProvider()->RecreateRenderTarget(window);
                NativeWindowCreated(window);
            }
            
        
            IGuiGraphicsLayoutProvider* CGResourceManager::GetLayoutProvider() override
            {
                //            return layoutProvider.Obj();
                return 0;
            }
    
            void CGResourceManager::NativeWindowCreated(INativeWindow* window) override
            {
                //                        WindowsDirect2DRenderTarget* renderTarget=new WindowsDirect2DRenderTarget(window);
                //                        renderTargets.Add(renderTarget);
                //                        GetWindowsDirect2DObjectProvider()->SetBindedRenderTarget(window, renderTarget);
            }

            void CGResourceManager::NativeWindowDestroying(INativeWindow* window) override
            {
                //                    WindowsDirect2DRenderTarget* renderTarget=dynamic_cast<WindowsDirect2DRenderTarget*>(GetWindowsDirect2DObjectProvider()->GetBindedRenderTarget(window));
                //                    GetWindowsDirect2DObjectProvider()->SetBindedRenderTarget(window, 0);
                //                    renderTargets.Remove(renderTarget);
            }
    
            
#define IMPLEMENT_ELEMENT_RENDERER(TRENDERER)\
    TRENDERER::TRENDERER()\
    {\
    }\
    void TRENDERER::InitializeInternal()\
    {\
    }\
    void TRENDERER::FinalizeInternal()\
    {\
    }\
    void TRENDERER::RenderTargetChangedInternal(ICoreGraphicsRenderTarget* oldRenderTarget, ICoreGraphicsRenderTarget* newRenderTarget)\
    {\
    }\
    void TRENDERER::OnElementStateChanged()\
    {\
    }\
    void TRENDERER::Render(Rect bounds)\


            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBackgroundElementRenderer)
            {
                
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiSolidBorderElementRenderer)
            {
                
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiRoundBorderElementRenderer)
            {
                
            }
            
            IMPLEMENT_ELEMENT_RENDERER(GuiGradientBackgroundElementRenderer)
            {
                
            }
            
         
            
        }
    }
    
}



void CoreGraphicsMain()
{
    vl::presentation::elements_coregraphics::CGResourceManager resourceManager;
    SetGuiGraphicsResourceManager(&resourceManager);
    GetCurrentController()->CallbackService()->InstallListener(&resourceManager);
    
    elements_coregraphics::GuiSolidBorderElementRenderer::Register();
    elements_coregraphics::GuiRoundBorderElementRenderer::Register();
    //    elements_coregraphics::Gui3DBorderElementRenderer::Register();
    //    elements_coregraphics::Gui3DSplitterElementRenderer::Register();
    elements_coregraphics::GuiSolidBackgroundElementRenderer::Register();
    elements_coregraphics::GuiGradientBackgroundElementRenderer::Register();
    //    elements_coregraphics::GuiSolidLabelElementRenderer::Register();
    //    elements_coregraphics::GuiImageFrameElementRenderer::Register();
    //    elements_coregraphics::GuiPolygonElementRenderer::Register();
    //    elements_coregraphics::GuiColorizedTextElementRenderer::Register();
    //    elements_coregraphics::GuiDirect2DElementRenderer::Register();
    elements::GuiDocumentElement::GuiDocumentElementRenderer::Register();
    
    GuiApplicationMain();
}

