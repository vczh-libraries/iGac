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

namespace vl { namespace presentation { namespace osx { class CocoaWindow; } } };

@interface CocoaBaseView: NSView <NSTextInputClient> // todo IME handling via TextInputClient
{
    NSTrackingArea* trackingArea;
    vl::presentation::osx::CocoaWindow* cocoaWindow;
}

@property (nonatomic) bool enableMouseMoveWindow;

- (id)initWithCocoaWindow:(vl::presentation::osx::CocoaWindow*)window;

- (void)updateIMEComposition;

@end


#endif