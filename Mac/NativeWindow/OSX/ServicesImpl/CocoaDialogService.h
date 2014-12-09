//
//  CocoaDialogService.h
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_DIALOG_SERVICE_H__
#define __GAC_OSX_COCOA_DIALOG_SERVICE_H__


#include "GacUI.h"

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            class CocoaDialogService: public Object, public INativeDialogService
            {
            public:
                MessageBoxButtonsOutput ShowMessageBox(INativeWindow* window,
                                                       const WString& text,
                                                       const WString& title = L"",
                                                       MessageBoxButtonsInput buttons = DisplayOK,
                                                       MessageBoxDefaultButton defaultButton = DefaultFirst,
                                                       MessageBoxIcons icon = IconNone,
                                                       MessageBoxModalOptions modal = ModalWindow)  override;
                
                bool ShowColorDialog(INativeWindow* window,
                                     Color& selection,
                                     bool selected = false,
                                     ColorDialogCustomColorOptions customColorOptions = CustomColorEnabled,
                                     Color* customColors = 0) override;
                
                bool ShowFontDialog(INativeWindow* window,
                                    FontProperties& selectionFont,
                                    Color& selectionColor,
                                    bool selected = false,
                                    bool showEffect = true,
                                    bool forceFontExist = true) override;
                
                
                bool ShowFileDialog(INativeWindow* window,
                                    collections::List<WString>& selectionFileNames,
                                    vint& selectionFilterIndex,
                                    FileDialogTypes dialogType,
                                    const WString& title,
                                    const WString& initialFileName,
                                    const WString& initialDirectory,
                                    const WString& defaultExtension,
                                    const WString& filter,
                                    FileDialogOptions options) override;
            };
            
            
        }
    }
}


#endif
