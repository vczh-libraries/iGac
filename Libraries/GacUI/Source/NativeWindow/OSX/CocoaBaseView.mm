//
//  CocoaBaseView.cpp
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaBaseView.h"

@implementation CocoaBaseView

- (id)initWithCocoaWindow:(CocoaWindow *)window
{
    if(self = [super init])
    {
        cocoaWindow = window;
        [self updateTrackingAreas];
    }
    
    return self;
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
    
}

- (void)mouseDown:(NSEvent *)event
{
    
}

- (void)mouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)mouseUp:(NSEvent *)event
{
    
}

- (void)mouseMoved:(NSEvent *)event
{
//    if (window->cursorMode == GLFW_CURSOR_DISABLED)
//        _glfwInputCursorMotion(window, [event deltaX], [event deltaY]);
//    else
//    {
//        const NSRect contentRect = [window->ns.view frame];
//        const NSPoint p = [event locationInWindow];
//        
//        _glfwInputCursorMotion(window, p.x, contentRect.size.height - p.y);
//    }
}

- (void)rightMouseDown:(NSEvent *)event
{
   
}

- (void)rightMouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)rightMouseUp:(NSEvent *)event
{
    
}

- (void)otherMouseDown:(NSEvent *)event
{
    
}

- (void)otherMouseDragged:(NSEvent *)event
{
    [self mouseMoved:event];
}

- (void)otherMouseUp:(NSEvent *)event
{
    
}

- (void)mouseExited:(NSEvent *)event
{
    
}

- (void)mouseEntered:(NSEvent *)event
{
    
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
    NSTrackingInVisibleRect;
    
    trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                options:options
                                                  owner:self
                                               userInfo:nil];
    
    [self addTrackingArea:trackingArea];
    [super updateTrackingAreas];
}

- (void)keyDown:(NSEvent *)event
{
    
}

- (void)flagsChanged:(NSEvent *)event
{
//    int action;
//    const unsigned int modifierFlags =
//    [event modifierFlags] & NSDeviceIndependentModifierFlagsMask;
//    const int key = translateKey([event keyCode]);
//    const int mods = translateFlags(modifierFlags);
//    
//    if (modifierFlags == window->ns.modifierFlags)
//    {
//        if (window->keys[key] == GLFW_PRESS)
//            action = GLFW_RELEASE;
//        else
//            action = GLFW_PRESS;
//    }
//    else if (modifierFlags > window->ns.modifierFlags)
//        action = GLFW_PRESS;
//    else
//        action = GLFW_RELEASE;
//    
//    window->ns.modifierFlags = modifierFlags;
//    
//    _glfwInputKey(window, key, [event keyCode], action, mods);
}

- (void)keyUp:(NSEvent *)event
{
//    const int key = translateKey([event keyCode]);
//    const int mods = translateFlags([event modifierFlags]);
//    _glfwInputKey(window, key, [event keyCode], GLFW_RELEASE, mods);
}

- (void)scrollWheel:(NSEvent *)event
{
//    double deltaX, deltaY;
//    
//#if MAC_OS_X_VERSION_MAX_ALLOWED >= 1070
//    if (floor(NSAppKitVersionNumber) > NSAppKitVersionNumber10_6)
//    {
//        deltaX = [event scrollingDeltaX];
//        deltaY = [event scrollingDeltaY];
//        
//        if ([event hasPreciseScrollingDeltas])
//        {
//            deltaX *= 0.1;
//            deltaY *= 0.1;
//        }
//    }
//    else
//#endif /*MAC_OS_X_VERSION_MAX_ALLOWED*/
//    {
//        deltaX = [event deltaX];
//        deltaY = [event deltaY];
//    }
//    
//    if (fabs(deltaX) > 0.0 || fabs(deltaY) > 0.0)
//        _glfwInputScroll(window, deltaX, deltaY);
}

- (void)resetCursorRects
{
//    [self addCursorRect:[self bounds] cursor:getModeCursor(window)];
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

@end