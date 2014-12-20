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
        
        _enableMouseMoveWindow = NO;
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
    if(cocoaWindow->GetParent())
    {
        NSPoint mouseLoc = [NSEvent mouseLocation];
        NSPoint windowLocation = [[self window] convertRectFromScreen: NSMakeRect(mouseLoc.x, mouseLoc.y, 0, 0)].origin;
        NSPoint viewLocation = [self convertPoint:windowLocation fromView:nil];
        return NSPointInRect(viewLocation, [self bounds]);
    }
    return [super acceptsFirstResponder];
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
    cocoaWindow->HandleEventInternal(event);
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

- (BOOL)needsDisplay
{
    return YES;
}


@end