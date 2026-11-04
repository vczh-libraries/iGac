#import <Cocoa/Cocoa.h>
#include "GacUI.h"
#include "../Mac/NativeWindow/OSX/CocoaNativeController.h"

using namespace vl;
using namespace vl::presentation;
using namespace vl::presentation::controls;

void VerifyNativeModalTimer()
{
    class Listener : public Object, public INativeControllerListener
    {
    public:
        vint ticks = 0;
        void GlobalTimer() override { ticks++; }
    } listener;
    auto controller = osx::GetOSXNativeController();
    auto callbacks = controller->CallbackService();
    callbacks->InstallListener(&listener);
    for (vint i = 0; i < 2; i++)
    {
        auto before = listener.ticks;
        NSAlert* alert = [[NSAlert alloc] init];
        [alert setMessageText:@"Native modal timer regression"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 150 * NSEC_PER_MSEC), dispatch_get_main_queue(), ^
        {
            [NSApp abortModal];
        });
        [alert runModal];
        [[alert window] orderOut:nil];
        [alert release];
        TEST_ASSERT(listener.ticks > before);
    }
    auto before = listener.ticks;
    bool completed = false;
    GetApplication()->DelayExecuteInMainThread([&]() { completed = true; }, 100);
    while (!completed)
    {
        TEST_ASSERT(controller->WindowService()->RunOneCycle());
    }
    callbacks->UninstallListener(&listener);
    TEST_ASSERT(listener.ticks > before);
}
