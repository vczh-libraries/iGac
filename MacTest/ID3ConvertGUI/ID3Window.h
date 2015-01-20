//
//  ID3Window.h
//  GacOSX
//
//  Created by Robert Bu on 1/20/15.
//  Copyright (c) 2015 Robert Bu. All rights reserved.
//

#ifndef __ID3_CONVERT_ID3WINDOW__
#define __ID3_CONVERT_ID3WINDOW__

#include "GacUI.h"
#include "../osx_shared.h"
#include "../gac_include.h"

#include "../../Mac/NativeWindow/OSX/CocoaPredef.h"

namespace id3c
{
    
    class ID3ConvertWindow : public GuiWindow, public vl::presentation::osx::IDraggingListener
    {
    public:
        ID3ConvertWindow();
        ~ID3ConvertWindow();
        
    public:
        // IDraggingListener
        void PerformFileDrag(const List<WString>& files);
        
    public:
        
    };

}


#endif
