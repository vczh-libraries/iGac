//
//  GuiGraphicsLayoutProviderCoreText.h
//  GacOSX
//
//  Created by Robert Bu on 12/18/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_GUI_GRAPHICS_LAYOUT_PROVIDER_CORE_TEXT_H__
#define __GAC_OSX_GUI_GRAPHICS_LAYOUT_PROVIDER_CORE_TEXT_H__

#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace elements_coregraphics {
            
            class CoreTextLayoutProvider: public Object, public elements::IGuiGraphicsLayoutProvider
            {
            public:
                Ptr<elements::IGuiGraphicsParagraph> CreateParagraph(const WString& text, elements::IGuiGraphicsRenderTarget* renderTarget, elements::IGuiGraphicsParagraphCallback* callback) override;
            };
            
        }
        
    }
    
}

#endif
