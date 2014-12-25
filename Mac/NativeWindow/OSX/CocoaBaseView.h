//
//  CocoaBaseView.h
//  GacOSX
//
//  Created by Robert Bu on 12/5/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#ifndef __GAC_OSX_COCOA_BASEVIEW_H__
#define __GAC_OSX_COCOA_BASEVIEW_H__

#include "CocoaHelper.h"

#ifdef GAC_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <Cocoa/Cocoa.h>
#endif

namespace vl { namespace presentation { namespace osx { class CocoaWindow; } } };

#ifndef GAC_OS_IOS

@interface CocoaBaseView: NSView <NSTextInputClient> // todo IME handling via TextInputClient
{
    NSTrackingArea* trackingArea;
    vl::presentation::osx::CocoaWindow* cocoaWindow;
}

- (id)initWithCocoaWindow:(vl::presentation::osx::CocoaWindow*)window;

- (void)updateIMEComposition;

@end

#else

@interface CocoaBaseView: UIView
{
    vl::presentation::osx::CocoaWindow* cocoaWindow;
}

@property (nonatomic) bool enableMouseMoveWindow;

- (id)initWithCocoaWindow:(vl::presentation::osx::CocoaWindow*)window;

@end

#endif


#endif