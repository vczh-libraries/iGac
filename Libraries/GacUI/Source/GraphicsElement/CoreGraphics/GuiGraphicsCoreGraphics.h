//
//  GuiGraphicsCoreGraphics.h
//  GacOSX
//
//  Created by Robert Bu on 12/4/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_GUIGRAPHICS_COREGRAPHICS_H__
#define __GAC_OSX_GUIGRAPHICS_COREGRAPHICS_H__

#include "../GuiGraphicsElement.h"
#include "../../GraphicsComposition/GuiGraphicsComposition.h"

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            using namespace elements;
            
            class ICoreGraphicsRenderTarget : public elements::IGuiGraphicsRenderTarget
            {
            public:
                virtual void* GetCGContext() const = 0;
            };
            
            
            class ICoreGrpahicsObjectProvider : public Interface
            {
            public:
                virtual void								RecreateRenderTarget(INativeWindow* window)=0;
                virtual ICoreGraphicsRenderTarget*			GetNativeCoreGraphicsRenderTarget(INativeWindow* window)=0;
                virtual ICoreGraphicsRenderTarget*          GetBindedRenderTarget(INativeWindow* window)=0;
                virtual void								SetBindedRenderTarget(INativeWindow* window, ICoreGraphicsRenderTarget* renderTarget)=0;
            };
            
            extern ICoreGrpahicsObjectProvider*			GetCoreGraphicsObjectProvider();
            extern void									SetCoreGraphicsObjectProvider(ICoreGrpahicsObjectProvider* provider);
            
            extern void                                 SetCurrentRenderTarget(ICoreGraphicsRenderTarget* renderTarget);
            extern ICoreGraphicsRenderTarget*           GetCurrentRenderTarget();
            
        }
        
    }
    
}

#endif
