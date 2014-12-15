//
//  CocoaDialogService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaDialogService.h"
#include "../CocoaHelper.h"

#import <Cocoa/Cocoa.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            INativeDialogService::MessageBoxButtonsOutput CocoaDialogService::ShowMessageBox(INativeWindow* window,
                                                                                             const WString& text,
                                                                                             const WString& title,
                                                                                             MessageBoxButtonsInput buttons,
                                                                                             MessageBoxDefaultButton defaultButton,
                                                                                             MessageBoxIcons icon,
                                                                                             MessageBoxModalOptions modal)
            {
                CFStringRef button1 = CFSTR("OK"), button2 = nil, button3 = nil;
                switch(buttons)
                {
                    case DisplayOK: break;
                    case DisplayOKCancel: button2 = CFSTR("Cancel"); break;
                    case DisplayAbortRetryIgnore: button1 = CFSTR("Abort"); button2 = CFSTR("Retry"); button3 = CFSTR("Ignore"); break;
                    case DisplayCancelTryAgainContinue: button1 = CFSTR("Cancel"); button2 = CFSTR("Try Again"); button3 = CFSTR("Continue"); break;
                    case DisplayRetryCancel: button1 = CFSTR("Retry"); button2 = CFSTR("Cancel"); break;
                    case DisplayYesNo: button1 = CFSTR("Yes"); button2 = CFSTR("No"); break;
                    case DisplayYesNoCancel: button1 = CFSTR("Yes"); button2 = CFSTR("No"); button3 = CFSTR("Cancel"); break;
                }
                
                CFOptionFlags level;
                switch(icon)
                {
                    case INativeDialogService::IconError:
                        level = kCFUserNotificationStopAlertLevel;
                        break;
                        
                    case INativeDialogService::IconWarning:
                        level = kCFUserNotificationNoteAlertLevel;
                        break;
                        
                        // todo these icons, can pack into resource
                    case INativeDialogService::IconNone:
                        level = kCFUserNotificationPlainAlertLevel;
                        break;
                        
                    case INativeDialogService::IconQuestion:
                        level = kCFUserNotificationPlainAlertLevel;
                        break;
                        
                    case INativeDialogService::IconInformation:
                        level = kCFUserNotificationPlainAlertLevel;
                        break;
                }
                
                NSString* nsTitle = WStringToNSString(title);
                NSString* nsText = WStringToNSString(text);
                
                CFStringRef cfTitle = (__bridge CFStringRef)nsTitle;
                CFStringRef cfText = (__bridge CFStringRef)nsText;
                
                CFOptionFlags result;
                CFUserNotificationDisplayAlert(0,
                                               level,
                                               NULL,
                                               NULL,
                                               NULL,
                                               cfTitle,
                                               cfText,
                                               button1, // default "ok"
                                               button2, // alternate button
                                               button3, //other button title
                                               &result);
                switch(result)
                {
                    case kCFUserNotificationDefaultResponse:
                    {
                        switch(buttons)
                        {
                            case DisplayOK:
                            case DisplayOKCancel:
                                return SelectOK;
                            case DisplayAbortRetryIgnore:
                                return SelectAbort;
                            case DisplayCancelTryAgainContinue:
                                return SelectCancel;
                            case DisplayRetryCancel:
                                return SelectRetry;
                            case DisplayYesNo:
                            case DisplayYesNoCancel:
                                return SelectYes;
                        }
                        break;
                    }
                    case kCFUserNotificationAlternateResponse:
                    {
                        switch(buttons)
                        {
                            case DisplayOK:
                            case DisplayOKCancel:
                                return SelectCancel;
                            case DisplayAbortRetryIgnore:
                                return SelectRetry;
                            case DisplayCancelTryAgainContinue:
                                return SelectTryAgain;
                            case DisplayRetryCancel:
                                return SelectCancel;
                            case DisplayYesNo:
                            case DisplayYesNoCancel:
                                return SelectNo;
                        }
                        break;
                    }
                    case kCFUserNotificationOtherResponse:
                    {
                        switch(buttons)
                        {
                            case DisplayOK:
                            case DisplayOKCancel:
                                return SelectOK;
                            case DisplayAbortRetryIgnore:
                                return SelectAbort;
                            case DisplayCancelTryAgainContinue:
                                return SelectCancel;
                            case DisplayRetryCancel:
                                return SelectRetry;
                            case DisplayYesNo:
                            case DisplayYesNoCancel:
                                return SelectYes;
                        }
                        break;
                    }
                    case kCFUserNotificationCancelResponse:
                    {
                        switch(buttons)
                        {
                            case DisplayAbortRetryIgnore:
                                return SelectIgnore;
                            case DisplayCancelTryAgainContinue:
                                return SelectContinue;
                            case DisplayYesNoCancel:
                                return SelectCancel;
                            default:
                                break;
                        }
                        break;
                    }
                }
                return SelectCancel;
            }
            
            bool CocoaDialogService::ShowColorDialog(INativeWindow* window,
                                                     Color& selection,
                                                     bool selected,
                                                     ColorDialogCustomColorOptions customColorOptions,
                                                     Color* customColors)
            {
                // NSColorPanel
                return false;
            }
            
            bool CocoaDialogService::ShowFontDialog(INativeWindow* window,
                                                    FontProperties& selectionFont,
                                                    Color& selectionColor,
                                                    bool selected,
                                                    bool showEffect,
                                                    bool forceFontExist)
            {
                // NSFontDialog
                return false;
            }
            
            
            bool CocoaDialogService::ShowFileDialog(INativeWindow* window,
                                                    collections::List<WString>& selectionFileNames,
                                                    vint& selectionFilterIndex,
                                                    FileDialogTypes dialogType,
                                                    const WString& title,
                                                    const WString& initialFileName,
                                                    const WString& initialDirectory,
                                                    const WString& defaultExtension,
                                                    const WString& filter,
                                                    FileDialogOptions options)
            {
                if(dialogType == FileDialogTypes::FileDialogOpen ||
                   dialogType == FileDialogTypes::FileDialogOpenPreview)
                {
                    NSOpenPanel* op = [NSOpenPanel openPanel];
                    
                    NSMutableArray* filters = [[NSMutableArray alloc] init];

                    vint prevIndex = 0;
                    for(vint i=0;i<filter.Length();i++)
                    {
                        if(filter[i]==L'|')
                        {
                            [filters addObject:WStringToNSString(filter.Sub(prevIndex, i-prevIndex))];
                            prevIndex = i+1;
                        }
                    }
                    if(prevIndex != filter.Length())
                    {
                        [filters addObject:WStringToNSString(filter.Sub(prevIndex, filter.Length()-prevIndex))];

                    }
                    
                    [op setAllowedFileTypes:filters];
                    [op setDirectoryURL: [NSURL fileURLWithPath:WStringToNSString(initialDirectory)]];
                    [op setTitle:WStringToNSString(title)];
                    [op setNameFieldStringValue:WStringToNSString(initialFileName)];
                    
                    [op setCanChooseFiles:YES];
                    [op setCanChooseDirectories:YES];
                    if(options & FileDialogAllowMultipleSelection)
                    {
                        [op setAllowsMultipleSelection:YES];
                    }
                    if(options & FileDialogDereferenceLinks)
                    {
                        [op setResolvesAliases:YES];
                    }
                    
                    if([op runModal] == NSFileHandlingPanelOKButton)
                    {
                        selectionFileNames.Clear();
                        
                        NSArray* urls = [op URLs];
                        for(NSURL* url in urls)
                        {
                            selectionFileNames.Add(NSStringToWString([url absoluteString]));
                        }
                        
                        return true;
                    }
                    return false;
                }
                else
                {
                    NSSavePanel* op = [NSSavePanel savePanel];
                    
                    NSMutableArray* filters = [[NSMutableArray alloc] init];
                    
                    vint prevIndex = 0;
                    for(vint i=0;i<filter.Length();i++)
                    {
                        if(filter[i]==L'|')
                        {
                            [filters addObject:WStringToNSString(filter.Sub(prevIndex, i-prevIndex))];
                            prevIndex = i+1;
                        }
                    }
                    if(prevIndex != filter.Length())
                    {
                        [filters addObject:WStringToNSString(filter.Sub(prevIndex, filter.Length()-prevIndex))];
                        
                    }
                    
                    [op setAllowedFileTypes:filters];
                    [op setDirectoryURL: [NSURL fileURLWithPath:WStringToNSString(initialDirectory)]];
                    [op setTitle:WStringToNSString(title)];
                    [op setNameFieldStringValue:WStringToNSString(initialFileName)];
                    
                    
                    if([op runModal] == NSFileHandlingPanelOKButton)
                    {
                        selectionFileNames.Clear();
                        selectionFileNames.Add(NSStringToWString([[op URL] absoluteString]));
                        
                        return true;
                    }
                    return false;
                }
            }
            
        }
        
    }
    
}