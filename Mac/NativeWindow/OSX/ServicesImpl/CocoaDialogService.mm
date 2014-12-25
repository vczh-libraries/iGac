//
//  CocoaDialogService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaDialogService.h"
#include "../CocoaHelper.h"

#ifdef GAC_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

#ifdef GAC_OS_IOS

@interface AlertDelegate: NSObject<UIAlertViewDelegate>

@property (nonatomic) NSInteger buttonIndex;

@end

@implementation AlertDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    _buttonIndex = buttonIndex;
}

@end

#endif

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
                
#ifdef GAC_OS_OSX
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
                
#else
                NSString* button1 = @"OK", *button2 = nil, *button3 = nil;
                switch(buttons)
                {
                    case DisplayOK: break;
                    case DisplayOKCancel: button2 = @("Cancel"); break;
                    case DisplayAbortRetryIgnore: button1 = @("Abort"); button2 = @("Retry"); button3 = @("Ignore"); break;
                    case DisplayCancelTryAgainContinue: button1 = @("Cancel"); button2 = @("Try Again"); button3 = @("Continue"); break;
                    case DisplayRetryCancel: button1 = @("Retry"); button2 = @("Cancel"); break;
                    case DisplayYesNo: button1 = @("Yes"); button2 = @("No"); break;
                    case DisplayYesNoCancel: button1 = @("Yes"); button2 = @("No"); button3 = @("Cancel"); break;
                }
                
                AlertDelegate* delegate = [[AlertDelegate alloc] init];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:WStringToNSString(title)
                                                                message:WStringToNSString(text)
                                                               delegate:delegate
                                                      cancelButtonTitle:button2
                                                      otherButtonTitles:button3, nil];
                
                [alert show];
                
                switch(delegate.buttonIndex)
                {
                    case 0:
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
                    case 1:
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
                    case 2:
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
                }
#endif
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
             
#ifdef GAC_OS_OSX
                NSMutableArray* filters = [[NSMutableArray alloc] init];
                
                vint prevIndex = 0;
                vint k = 0;
                bool allowAnyTypes = false;
                for(vint i=0;i<filter.Length();i++)
                {
                    if(filter[i]==L'|')
                    {
                        if(k == 1)
                        {
                            NSString* filterStr = WStringToNSString(filter.Sub(prevIndex, i-prevIndex));
                            NSUInteger dotIndex = [filterStr rangeOfString:@"."].location;
                            
                            if([filterStr compare:@"*.*"] == NSOrderedSame)
                                allowAnyTypes = true;
                            [filters addObject:[filterStr substringFromIndex:dotIndex+1]];
                        }
                        prevIndex = i+1;
                        k = (k+1) % 2;
                    }
                }
                if(prevIndex != filter.Length())
                {
                    NSString* filterStr = WStringToNSString(filter.Sub(prevIndex, filter.Length()-prevIndex));
                    NSUInteger dotIndex = [filterStr rangeOfString:@"."].location;
                    
                    [filters addObject:[filterStr substringFromIndex:dotIndex+1]];
                }
                
                if(dialogType == FileDialogTypes::FileDialogOpen ||
                   dialogType == FileDialogTypes::FileDialogOpenPreview)
                {
                    NSOpenPanel* op = [NSOpenPanel openPanel];
                    
                    [op setAllowedFileTypes:filters];
                    [op setDirectoryURL: [NSURL fileURLWithPath:WStringToNSString(initialDirectory)]];
                    [op setTitle:WStringToNSString(title)];
                    [op setNameFieldStringValue:WStringToNSString(initialFileName)];
                    
                    [op setCanChooseFiles:YES];
                    [op setCanChooseDirectories:YES];
                    [op setAllowsOtherFileTypes:allowAnyTypes];
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
                            selectionFileNames.Add(NSStringToWString(url.path));
                        }
                        
                        return true;
                    }
                    return false;
                }
                else
                {
                    NSSavePanel* op = [NSSavePanel savePanel];
                    
                    [op setAllowedFileTypes:filters];
                    [op setDirectoryURL: [NSURL fileURLWithPath:WStringToNSString(initialDirectory)]];
                    [op setTitle:WStringToNSString(title)];
                    [op setNameFieldStringValue:WStringToNSString(initialFileName)];
                    [op setAllowsOtherFileTypes:allowAnyTypes];
                    
                    if([op runModal] == NSFileHandlingPanelOKButton)
                    {
                        selectionFileNames.Clear();
                        selectionFileNames.Add(NSStringToWString([op URL].path));
                        
                        return true;
                    }
                    return false;
                }
                
#else
                
                return false;
                
#endif
            }
            
        }
        
    }
    
}