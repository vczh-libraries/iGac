//
//  CocoaBaseView.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaBaseView.h"

#include "CocoaWindow.h"
#include "CocoaHelper.h"
#include "ServicesImpl/CocoaResourceService.h"

@implementation CocoaBaseView
{
    NSString* textToInsert;
    BOOL hasMarkedText;
    NSRange markedRange;
    NSString* markedText;
}

- (id)initWithCocoaWindow:(vl::presentation::osx::CocoaWindow *)window
{
    if(self = [super init])
    {
        cocoaWindow = window;
        [self updateTrackingAreas];
        
        _enableMouseMoveWindow = NO;
        
        textToInsert = nil;
        markedText = nil;
    }
    
    return self;
}

- (BOOL)mouseDownCanMoveWindow
{
    return _enableMouseMoveWindow;
}

- (id)init
{
    assert(false);
    return nil;
}

- (BOOL)isOpaque
{
    return YES;
}

- (BOOL)canBecomeKeyView
{
    return YES;
}

- (BOOL)acceptsFirstResponder
{
    // as borderless window will not be included in the responder chain by default
    return [cocoaWindow->GetNativeWindow() styleMask] & NSBorderlessWindowMask ? YES : [super acceptsFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    cocoaWindow->InvokeGotFocus();
    return [super becomeFirstResponder];
}

- (BOOL)resignFirstResponder
{
    cocoaWindow->InvokeLostFocus();
    return [super resignFirstResponder];
}

- (void)cursorUpdate:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)mouseDown:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)mouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)mouseUp:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)mouseMoved:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)rightMouseDown:(NSEvent *)event
{
   cocoaWindow->HandleEventInternal(event);
}

- (void)rightMouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)rightMouseUp:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)otherMouseDown:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)otherMouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)otherMouseUp:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)mouseExited:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)mouseEntered:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)viewDidChangeBackingProperties
{
    
}

- (void)updateTrackingAreas
{
    if (trackingArea != nil)
    {
        [self removeTrackingArea:trackingArea];
    }
    
    NSTrackingAreaOptions options = NSTrackingMouseEnteredAndExited |
                                    NSTrackingActiveInKeyWindow |
                                    NSTrackingCursorUpdate |
                                    NSTrackingInVisibleRect |
                                    NSTrackingMouseMoved;
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:options
                                                  owner:self
                                               userInfo:nil];
    
    [self addTrackingArea:trackingArea];
    [super updateTrackingAreas];
}

- (void)keyDown:(NSEvent *)event
{
    BOOL oldHasMarkedText = hasMarkedText;
    
    textToInsert = @"";
    markedText = @"";
    
    [self interpretKeyEvents:@[event]];
    
    // only send single key event to the generic key handle
    // when we are not composing text with an IME
    if(!oldHasMarkedText && !hasMarkedText && textToInsert.length <= 1)
        cocoaWindow->HandleEventInternal(event);
    else
    {
        if(textToInsert.length >= 1)
        {
            cocoaWindow->InsertText(vl::presentation::osx::NSStringToWString(textToInsert));
        }
    }
}

- (void)flagsChanged:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)keyUp:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)scrollWheel:(NSEvent *)event
{
    cocoaWindow->HandleEventInternal(event);
}

- (void)resetCursorRects
{
    vl::presentation::osx::CocoaCursor* cursor = dynamic_cast<vl::presentation::osx::CocoaCursor*>(cocoaWindow->GetWindowCursor());
    
    [self addCursorRect:[self bounds] cursor:cursor->GetNativeCursor()];
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask]) == NSDragOperationGeneric)
    {
        [self setNeedsDisplay:YES];
        
        cocoaWindow->DragEntered();
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    cocoaWindow->PrepareDrag();
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    NSPasteboard* pasteboard = [sender draggingPasteboard];
    NSArray* files = [pasteboard propertyListForType:NSFilenamesPboardType];
    
    vl::collections::List<vl::WString> vlFiles;
    for(NSString* fn in files)
    {
        vlFiles.Add(vl::presentation::osx::NSStringToWString(fn));
    }
    cocoaWindow->PerformFileDrag(vlFiles);
    
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    cocoaWindow->ConcludeDrag();
    [self setNeedsDisplay:YES];
}

- (void)updateIMEComposition
{
    [[NSTextInputContext currentInputContext] invalidateCharacterCoordinates];
}

// NSTextInputClient

- (void)insertText:(id)aString replacementRange:(NSRange)replacementRange
{
    if([aString isKindOfClass:[NSAttributedString class]])
        textToInsert = [aString string];
    else
        textToInsert = [aString copy];
}

- (void)doCommandBySelector:(SEL)aSelector
{
    
}

- (void)setMarkedText:(id)aString selectedRange:(NSRange)selectedRange replacementRange:(NSRange)replacementRange
{
    hasMarkedText = YES;
    markedRange = selectedRange;
    if([aString isKindOfClass:[NSAttributedString class]])
    {
        markedText = [aString string];
    }
    else
        markedText = aString;
}

- (void)unmarkText
{
    hasMarkedText = NO;
    markedRange = NSMakeRange(NSNotFound, 0);
}

- (NSRange)selectedRange
{
    return NSMakeRange(NSNotFound, 0);
}

- (NSRange)markedRange
{
    return markedRange;
}

- (BOOL)hasMarkedText
{
    return hasMarkedText;
}

- (NSAttributedString *)attributedSubstringForProposedRange:(NSRange)aRange actualRange:(NSRangePointer)actualRange
{
    return nil;
}

- (NSArray*)validAttributesForMarkedText
{
    return nil;
}

- (NSRect)firstRectForCharacterRange:(NSRange)aRange actualRange:(NSRangePointer)actualRange
{
    vl::presentation::Point caretPoint = cocoaWindow->GetCaretPoint();
    vl::presentation::Rect bounds = cocoaWindow->GetBounds();
    
    NSWindow* wnd = cocoaWindow->GetNativeWindow();
    NSScreen* screen = vl::presentation::osx::GetWindowScreen(wnd);
    
    return NSMakeRect(caretPoint.x + bounds.Left(),
                      screen.frame.size.height - (caretPoint.y + bounds.Top() + 30),
                      16, 16);
}

- (NSUInteger)characterIndexForPoint:(NSPoint)aPoint
{
    return 0;
}

@end