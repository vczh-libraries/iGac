//
//  CocoaBaseView.h
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_BASEVIEW_H__
#define __GAC_OSX_COCOA_BASEVIEW_H__

#import <Cocoa/Cocoa.h>

class CocoaWindow;

@interface CocoaBaseView: NSView
{
    NSTrackingArea* trackingArea;
    CocoaWindow* cocoaWindow;
}

- (id)initWithCocoaWindow:(CocoaWindow*)window;

@end


#endif