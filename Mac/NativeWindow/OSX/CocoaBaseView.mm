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

- (id)initWithCocoaWindow:(vl::presentation::osx::CocoaWindow *)window
{
    if(self = [super init])
    {
        cocoaWindow = window;
        [self updateTrackingAreas];
    }
    
    return self;
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
    return YES;
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
    cocoaWindow->HandleEventInternal(event);
    
    [self interpretKeyEvents:@[event]];
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
    if ((NSDragOperationGeneric & [sender draggingSourceOperationMask])
        == NSDragOperationGeneric)
    {
        [self setNeedsDisplay:YES];
        return NSDragOperationGeneric;
    }
    
    return NSDragOperationNone;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    [self setNeedsDisplay:YES];
    return YES;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
//    NSPasteboard* pasteboard = [sender draggingPasteboard];
//    NSArray* files = [pasteboard propertyListForType:NSFilenamesPboardType];
//    
    return YES;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    [self setNeedsDisplay:YES];
}

// text input related

// this can also be archived by interpreting the key events by ourself
// but for compatibility, these are used here

- (void)insertText:(id)string
{
    cocoaWindow->InsertText(vl::presentation::osx::NSStringToWString(string));
}

- (void)deleteBackward:(id)sender
{
    
}

- (void)deleteForward:(id)sender
{
    
}

- (void)deleteToBeginningOfLine:(id)sender
{
    
}

- (void)deleteToEndOfLine:(id)sender
{
    
}

- (void)deleteToBeginningOfParagraph:(id)sender
{
    
}

- (void)deleteToEndOfParagraph:(id)sender
{
    
}

- (void)deleteToMark:(id)sender
{
    
}

- (void)deleteWordBackward:(id)sender
{
    
}

- (void)deleteWordForward:(id)sender
{
    
}

- (void)insertBacktab:(id)sender
{
    
}

- (void)insertContainerBreak:(id)sender
{
    
}

- (void)insertLineBreak:(id)sender
{
    
}

- (void)insertNewline:(id)sender
{
    cocoaWindow->InsertText(L"\n");
}

- (void)insertNewlineIgnoringFieldEditor:(id)sender
{
    
}

- (void)insertDoubleQuoteIgnoringSubstitution:(id)sender
{
    
}

- (void)insertSingleQuoteIgnoringSubstitution:(id)sender
{
    
}

- (void)moveBackward:(id)sender
{
    
}

- (void)moveForward:(id)sender
{
    
}

- (void)moveLeft:(id)sender
{
    
}

- (void)moveRight:(id)sender
{
    
}

- (void)moveToEndOfLine:(id)sender
{
    
}

- (void)moveToRightEndOfLine:(id)sender
{
    
}

- (void)moveForwardAndModifySelection:(id)sender
{
    
}

- (void)moveRightAndModifySelection:(id)sender
{
    
}

- (void)moveLeftAndModifySelection:(id)sender
{
    
}

- (void)moveDownAndModifySelection:(id)sender
{
    
}

- (void)moveToBeginningOfDocument:(id)sender
{
    
}

- (void)moveToEndOfDocument:(id)sender
{
    
}

- (void)moveToBeginningOfParagraphAndModifySelection:(id)sender
{
    
}

- (void)moveToEndOfDocumentAndModifySelection:(id)sender
{
    
}

- (void)moveWordLeft:(id)sender
{
    
}

- (void)moveWordRight:(id)sender
{
    
}

- (void)moveWordRightAndModifySelection:(id)sender
{
    
}

- (void)moveWordLeftAndModifySelection:(id)sender
{
    
}

- (void)pageUp:(id)sender
{
    
}

- (void)pageDown:(id)sender
{
    
}

- (void)pageUpAndModifySelection:(id)sender
{
    
}

- (void)pageDownAndModifySelection:(id)sender
{
    
}

- (void)selectAll:(id)sender
{
    
}

- (void)selectLine:(id)sender
{
    
}

- (void)scrollPageUp:(id)sender
{
    
}

- (void)scrollPageDown:(id)sender
{
    
}

- (void)selectParagraph:(id)sender
{
    
}

- (void)selectToMark:(id)sender
{
    
}

- (void)selectWord:(id)sender
{
    
}

- (void)capitalizeWord:(id)sender
{
    
}

- (void)changeCaseOfLetter:(id)sender
{
    
}

- (void)complete:(id)sender
{
    
}

- (void)yank:(id)sender
{
    
}

- (void)uppercaseWord:(id)sender
{
    
}

- (void)transpose:(id)sender
{
    
}

- (void)transposeWords:(id)sender
{
    
}

@end