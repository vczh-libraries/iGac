//
//  CocoaDialogService.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/9/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaDialogService.h"
#include "../CocoaHelper.h"
#include "../CocoaIntrospection.h"

@interface NSPanelProxy: NSWindow

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen;

- (id)initWithContentRect_Fake:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag;

- (id)initWithContentRect_Fake:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen;


@end

@implementation NSPanelProxy

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    aStyle &= ~NSUtilityWindowMask;
    self = [self initWithContentRect_Fake:contentRect
                                styleMask:aStyle
                                  backing:bufferingType
                                    defer:flag];
    
    return self;
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    aStyle &= ~NSUtilityWindowMask;
    self = [self initWithContentRect_Fake:contentRect
                                styleMask:aStyle
                                  backing:bufferingType
                                    defer:flag
                                   screen:screen];
    
    return self;
}

// will be replaced by original impl

- (id)initWithContentRect_Fake:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag
{
    return nil;
}

- (id)initWithContentRect_Fake:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen
{
    return nil;
}

@end


const CGFloat HackedButtonWidth = 64.0f;
const CGFloat HackedButtonHeight = 24.0f;
const CGFloat HackedButtonBottomMargin = 4.0f;
const CGFloat HackedButtonSideMargin = 9.0f;

// hack system color / font panels since they don't have a OK / Cancel button

@interface WindowCloseDelegate: NSObject<NSWindowDelegate>
{
@protected
    bool closed;
    bool cancelled;
    
    CGFloat buttonTopMargin;
    
    NSButton* okButton;
    NSButton* cancelButton;
    
    NSPanel* parentPanel;
    NSView* originalContentView;
}

- (id)init;
- (id)initWithPanel:(NSPanel*)panel contentView:(NSView*)contentView topMargin:(CGFloat)topMargin;
- (BOOL)windowShouldClose:(id)sender;

- (BOOL)isClosed;
- (BOOL)isCancelled;

@end

@implementation WindowCloseDelegate

- (id)init
{
    if(self = [super init])
    {
        closed = false;
        
        parentPanel = nil;
    }
    
    return self;
}

- (id)initWithPanel:(NSPanel*)panel contentView:(NSView*)contentView topMargin:(CGFloat)topMargin
{
    if(self = [super init])
    {
        closed = false;
        
        parentPanel = panel;
        originalContentView = contentView;
        
        buttonTopMargin = topMargin;
        
        [self relayoutPanel];
    }
    return self;
}

- (NSButton*)createButton:(NSString*)text frame:(NSRect)frame clicked:(SEL)clicked
{
    NSButton* button = [[NSButton alloc] initWithFrame: frame];
    
    [button setButtonType:NSMomentaryLightButton];
    [button setBezelStyle:NSRegularSquareBezelStyle];
    [button setTitle:text];
    
    [button setAction:clicked];
    [button setTarget:self];
    
    return button;
}

- (void)relayoutPanel
{
    [parentPanel setRestorable:NO];
    [parentPanel setContentView:0];
    
    NSRect originalFrame = originalContentView.frame;
    NSRect frameRect = NSMakeRect(0,
                                  0,
                                  originalContentView.frame.size.width,
                                  HackedButtonHeight + originalFrame.size.height + HackedButtonBottomMargin + buttonTopMargin);
    NSView* newView = [[NSView alloc] initWithFrame:frameRect];
    [newView addSubview:originalContentView];
    [originalContentView setFrame:NSMakeRect(0,
                                             HackedButtonBottomMargin + buttonTopMargin + HackedButtonHeight,
                                             originalFrame.size.width,
                                             originalFrame.size.height)];
    
    okButton = [self createButton:@"OK"
                            frame:NSMakeRect(originalFrame.size.width - HackedButtonSideMargin - HackedButtonWidth,
                                             HackedButtonBottomMargin,
                                             HackedButtonWidth,
                                             HackedButtonHeight)
                          clicked:@selector(okClicked)];
    
    cancelButton = [self createButton:@"Cancel"
                                frame:NSMakeRect(originalFrame.size.width - HackedButtonSideMargin - HackedButtonWidth * 2 - 4.0f,
                                                 HackedButtonBottomMargin,
                                                 HackedButtonWidth,
                                                 HackedButtonHeight)
                              clicked:@selector(cancelClicked)];
    
    [newView addSubview:okButton];
    [newView addSubview:cancelButton];

    
    [parentPanel setContentView:newView];
}

- (void)windowDidResize:(NSNotification *)notification
{
    NSRect originalFrame = originalContentView.frame;

    [okButton setFrame:NSMakeRect(originalFrame.size.width - HackedButtonSideMargin - HackedButtonWidth,
                                  HackedButtonBottomMargin,
                                  HackedButtonWidth,
                                  HackedButtonHeight)];
    
    [cancelButton setFrame:NSMakeRect(originalFrame.size.width - HackedButtonSideMargin - HackedButtonWidth * 2 - 4.0f,
                                      HackedButtonBottomMargin,
                                      HackedButtonWidth,
                                      HackedButtonHeight)];
}

- (void)close
{
    closed = true;
    
    [NSApp abortModal];
    [NSApp stopModal];
    
    if(parentPanel)
        [parentPanel setContentView:originalContentView];
}

- (void)okClicked
{
    cancelled = false;
    [self close];
    
    if(parentPanel)
        [parentPanel close];
}

- (void)cancelClicked
{
    cancelled = true;
    [self close];
    
    if(parentPanel)
        [parentPanel close];
}

- (BOOL)windowShouldClose:(id)sender
{
    cancelled = true;
    [self close];
    return YES;
}

- (BOOL)isCancelled
{
    return cancelled;
}

- (BOOL)isClosed
{
    return closed;
}

@end


@interface WindowCloseOpenDelegate: WindowCloseDelegate

- (id)init;
- (id)initWithPanel:(NSPanel*)panel contentView:(NSView*)contentView topMargin:(CGFloat)topMargin;

- (void)windowDidUpdate:(NSNotification *)notification;
- (BOOL)isClosed;
- (BOOL)isOpen;

@end

@implementation WindowCloseOpenDelegate
{
    bool opened;
}

- (id)init
{
    if(self = [super init])
    {
        closed = false;
        opened = false;
    }
    
    return self;
}

- (id)initWithPanel:(NSPanel*)panel contentView:(NSView*)contentView topMargin:(CGFloat)topMargin
{
    if(self = [super initWithPanel:panel contentView:contentView topMargin:topMargin])
    {
        closed = false;
        opened = false;
    }
    
    return self;
}

- (void)close
{
    opened = false;
    [super close];
}

- (void)windowDidUpdate:(NSNotification *)notification
{
    if(!opened)
    {
        closed = false;
        opened = true;
        
        [NSApp abortModal];
        [NSApp stopModal];
    }
}

- (BOOL)isClosed
{
    return closed;
}

- (BOOL)isOpen
{
    return opened;
}

@end

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            void StartInterceptNSPanel()
            {
                ChangeImplementation([NSPanel class],
                                     @selector(initWithContentRect:styleMask:backing:defer:),
                                     [NSPanelProxy class],
                                     @selector(initWithContentRect:styleMask:backing:defer:),
                                     @selector(initWithContentRect_Fake:styleMask:backing:defer:));
                
                ChangeImplementation([NSPanel class],
                                     @selector(initWithContentRect:styleMask:backing:defer:screen:),
                                     [NSPanelProxy class],
                                     @selector(initWithContentRect:styleMask:backing:defer:screen:),
                                     @selector(initWithContentRect_Fake:styleMask:backing:defer:screen:));
            }
            
            void StopInterceptNSPanel()
            {
                ChangeBackImplementation([NSPanel class],
                                         @selector(initWithContentRect:styleMask:backing:defer:),
                                         @selector(initWithContentRect_Fake:styleMask:backing:defer:));
                ChangeBackImplementation([NSPanel class],
                                         @selector(initWithContentRect:styleMask:backing:defer:screen:),
                                         @selector(initWithContentRect_Fake:styleMask:backing:defer:screen:));
            }
            
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
                
                StartInterceptNSPanel();
                NSColorPanel* colorPanel = [NSColorPanel sharedColorPanel];
                StopInterceptNSPanel();
                
                [colorPanel setShowsAlpha:YES];
                
                if(selected)
                {
                    [colorPanel setColor:[NSColor colorWithCalibratedRed:selection.r / 255.0
                                                                   green:selection.g / 255.0
                                                                    blue:selection.b / 255.0
                                                                   alpha:selection.a / 255.0]];
                }
                else
                {
                    [colorPanel setColor:[NSColor blackColor]];
                }
                
#define GAC_COLOR_LIST_NAME @"GAC_COLOR_LIST"
                
                NSColorList* colorList = [NSColorList colorListNamed:GAC_COLOR_LIST_NAME];
                if(!colorList)
                {
                    colorList = [[NSColorList alloc] initWithName:GAC_COLOR_LIST_NAME];
                }
                
                if(customColors)
                {
                    for(vint i=0; i<16; ++i)
                    {
                        [colorList setColor:[NSColor colorWithCalibratedRed:customColors[i].r / 255.0
                                                                       green:customColors[i].g / 255.0
                                                                        blue:customColors[i].b / 255.0
                                                                       alpha:customColors[i].a / 255.0]
                                     forKey:[[NSNumber numberWithLongLong:i] stringValue]];
                    }
                }
                
                if(customColorOptions == CustomColorEnabled)
                {
                    [colorPanel attachColorList:colorList];
                }
                else if(customColorOptions == CustomColorDisabled)
                {
                    [colorPanel detachColorList:colorList];
                }
                
                WindowCloseDelegate* delegate = [[WindowCloseDelegate alloc] initWithPanel:colorPanel
                                                                               contentView:[colorPanel contentView]
                                                                                 topMargin:0];
                [colorPanel setDelegate:delegate];
                
                NSModalSession session = [NSApp beginModalSessionForWindow:colorPanel];
                
                for(;;)
                {
                    [NSApp runModalSession:session];
                    
                    if([delegate isClosed])
                        break;
                }
                
                [NSApp endModalSession:session];
                
                if(![delegate isCancelled])
                {
                    NSColor* color = [[colorPanel color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
                    selection = Color([color redComponent] * 255.0,
                                      [color greenComponent] * 255.0,
                                      [color blueComponent] * 255.0,
                                      [color alphaComponent] * 255.0);
                }
                
                return ![delegate isCancelled];
            }
            
            bool CocoaDialogService::ShowFontDialog(INativeWindow* window,
                                                    FontProperties& selectionFont,
                                                    Color& selectionColor,
                                                    bool selected,
                                                    bool showEffect,
                                                    bool forceFontExist)
            {
                // NSFontDialog
                
                StartInterceptNSPanel();
                NSFontPanel* fontPanel = [NSFontPanel sharedFontPanel];
                NSColorPanel* colorPanel = [NSColorPanel sharedColorPanel];
                StopInterceptNSPanel();
                
                WindowCloseOpenDelegate* cpDelegate = [[WindowCloseOpenDelegate alloc] init];
                WindowCloseDelegate* fpDelegate = [[WindowCloseDelegate alloc] initWithPanel:fontPanel
                                                                                 contentView:[fontPanel contentView]
                                                                                   topMargin:4];
                
                [fontPanel setDelegate:fpDelegate];
                [colorPanel setDelegate:cpDelegate];
                
                if(selected)
                {
                    NSFont* defaultFont = CreateFontWithGacFont(selectionFont);
                    [fontPanel setPanelFont:defaultFont isMultiple:NO];
                }
                
                // from wxWidgets
                
                // force modal dialog
                // here we need both font and color dialog because the font dialog may open a color dialog
            
                // if a color dialog is opened, we exit font modal loop and enter color loop
                // until the color panel is closed
                
                do
                {
                    NSModalSession session = [NSApp beginModalSessionForWindow:fontPanel];
                    
                    for(;;)
                    {
                        [NSApp runModalSession:session];
                        
                        // break if closed or color panel opened
                        if([cpDelegate isOpen] || [fpDelegate isClosed])
                            break;
                    }
                    
                    [NSApp endModalSession:session];
                    
                    // if the color dialog is opened
                    if([cpDelegate isOpen])
                    {
                        NSModalSession session = [NSApp beginModalSessionForWindow:colorPanel];
                        for(;;)
                        {
                            [NSApp runModalSession:session];
                            
                            if([cpDelegate isClosed])
                                break;
                        }
                        
                        [NSApp endModalSession:session];
                    }
                    
                } while(![fpDelegate isClosed]);
                
                if(![fpDelegate isCancelled])
                {
                    NSFont* selectedFont = [fontPanel panelConvertFont:[NSFont userFontOfSize:0]];
                    NSFontTraitMask traits = [[NSFontManager sharedFontManager] traitsOfFont:selectedFont];
                    
                    selectionFont.bold = traits & NSBoldFontMask;
                    selectionFont.italic = traits & NSItalicFontMask;
                    
                    selectionFont.size = [selectedFont pointSize];
                    selectionFont.fontFamily = NSStringToWString([selectedFont familyName]);
                    
                    NSColor* color = [[colorPanel color] colorUsingColorSpaceName:NSCalibratedRGBColorSpace];
                    selectionColor = Color([color redComponent] * 255.0,
                                           [color greenComponent] * 255.0,
                                           [color blueComponent] * 255.0,
                                           [color alphaComponent] * 255.0);
                }
                
                return ![fpDelegate isCancelled];
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
            }
            
        }
        
    }
    
}