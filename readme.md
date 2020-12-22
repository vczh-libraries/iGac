#### OSX implementation w CoreGraphics/Quartz2D for [GacLib](http://www.gaclib.net)

[![Build Status](https://travis-ci.org/vczh-libraries/iGac.svg?branch=master)](https://travis-ci.org/vczh-libraries/iGac)

![GacOSX](https://darkfall.me/resource/gac_osx.jpg)

##### License

**Read the [LICENSE](https://github.com/vczh-libraries/iGac/blob/master/LICENSE.md) first.**

##### Current Progress:
* Finalizing & Bug fixes

##### iOS
* iOS proof of concept implementation is in iOS branch, which may not be updated / synced with the main branch as its just something for fun.

##### Known Issues/Limiations:
* Global keyboard hook requires Accessibility priviledge
* AsyncService::Semaphore::WaitForTime
* Code is compiled under VCZH_DEBUG_NO_REFLECTION, if u need Reflection, remember to remove VCZH_DEBUG_NO_REFLECTION in CMakeLists.txt and add all of Reflection cpp files.

##### TODO
* GuiInnerShadowElementRenderer is not implemented yet
* GuiFocusRectangleElementRenderer is not implemented yet
* CocoaClipboardWriter and CocoaClipboardReader is not implemented yet
* CocoaWindow's GetIcon and SetIcon is not implemented yet
* VKEYS mapping is quite big, should be shotter
* Replace cglayer with metal
