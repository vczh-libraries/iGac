#include "ServicesImpl/CocoaClipboardService.h"
#import <Cocoa/Cocoa.h>

int SetupRemoteNativeController(vl::presentation::IGuiRemoteProtocol* protocol, const vl::presentation::GuiRemoteControllerConfig& config)
{
    @autoreleasepool
    {
        vl::presentation::osx::CocoaClipboardService clipboard(nullptr, nullptr);
        return SetupRemoteNativeControllerInternal(protocol, config, &clipboard);
    }
}
