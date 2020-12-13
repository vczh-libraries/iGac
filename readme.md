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

##### TODO
* GuiInnerShadowElementRenderer is not implemented yet
* CMakeLists.txt only covers AddressBook/Animation/CalculatorAndStateMachine/Helloworld/Table
* Code is compiled under VCZH_DEBUG_NO_REFLECTION, if u need Reflection, remember to add remove VCZH_DEBUG_NO_REFLECTION in CMakeLists.txt and add all of Reflection cpp files.
* Crash on Helloworld when setting label size
* MVVM of AddressBook currently not working for 0.9.6.0 on OSX
