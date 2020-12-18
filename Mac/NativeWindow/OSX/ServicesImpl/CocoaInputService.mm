//
//  CocoaInputService.cpp
//  GacTest
//
//  Created by Robert Bu on 12/2/14.
//  Copyright (c) 2014 Robert Bu. All rights reserved.
//

#include "CocoaInputService.h"
#include "../CocoaHelper.h"

#import <AppKit/AppKit.h>

namespace vl {
    
    namespace presentation {
        
        namespace osx {
            
            namespace
            {
                CocoaInputService* g_inputService;
            }
            
            CGEventRef InputTapFunc(CGEventTapProxy proxy, CGEventType type, CGEventRef event, void *refcon)
            {
                CocoaInputService* inputService = (CocoaInputService*)refcon;
                inputService->InvokeInputHook(type, event);
                return event;
            }
            
            
            CocoaInputService::CocoaInputService(MouseTapFunc mouseTap, TimerFunc timer):
                eventSource(0),
                isTimerEnabled(false),
                isHookingMouse(false),
                mouseTapFunc(mouseTap),
                timerFunc(timer),
                inputTapPort(0),
                inputTapRunLoopSource(0)
            {
                g_inputService = this;
                
                InitKeyMapping();
                
                eventSource = CGEventSourceCreate(kCGEventSourceStateHIDSystemState);
                // default is 0.25s
                CGEventSourceSetLocalEventsSuppressionInterval(eventSource, 0.0);
                
                memset(globalKeyStates, 0, sizeof(vint8_t) * 256);
                
                HookInput();
            }
            
            CocoaInputService::~CocoaInputService()
            {
                CFRunLoopRemoveSource(CFRunLoopGetCurrent(), inputTapRunLoopSource, kCFRunLoopDefaultMode);
                CFMachPortInvalidate(inputTapPort);
                
            }
            
            void CocoaInputService::InitKeyMapping()
            {
                // todo
                // just build the map...
                // need some copy-pasta here
                
                static struct {
                    VKEY       keyCode;
                    WString    keyName;
                } KeyMappings[] = {
                    { (VKEY)0, L"?" },
                    { (VKEY)1, L"?" },
                    { (VKEY)2, L"?" },
                    { (VKEY)3, L"?" },
                    { (VKEY)4, L"?" },
                    { (VKEY)5, L"?" },
                    { (VKEY)6, L"?" },
                    { (VKEY)7, L"?" },
                    { (VKEY)8, L"Backspace" },
                    { (VKEY)9, L"Tab" },
                    { (VKEY)10, L"?" },
                    { (VKEY)11, L"?" },
                    { (VKEY)12, L"?" },
                    { (VKEY)13, L"Enter" },
                    { (VKEY)14, L"?" },
                    { (VKEY)15, L"?" },
                    { (VKEY)16, L"Shift" },
                    { (VKEY)17, L"Ctrl" },
                    { (VKEY)18, L"Alt" },
                    { (VKEY)19, L"?" },
                    { (VKEY)20, L"Caps Lock" },
                    { (VKEY)21, L"?" },
                    { (VKEY)22, L"?" },
                    { (VKEY)23, L"?" },
                    { (VKEY)24, L"?" },
                    { (VKEY)25, L"?" },
                    { (VKEY)26, L"?" },
                    { (VKEY)27, L"Esc" },
                    { (VKEY)28, L"?" },
                    { (VKEY)29, L"?" },
                    { (VKEY)30, L"?" },
                    { (VKEY)31, L"?" },
                    { (VKEY)32, L"Space" },
                    { (VKEY)33, L"Page Up" },
                    { (VKEY)34, L"Page Down" },
                    { (VKEY)35, L"End" },
                    { (VKEY)36, L"Home" },
                    { (VKEY)37, L"Left" },
                    { (VKEY)38, L"Up" },
                    { (VKEY)39, L"Right" },
                    { (VKEY)40, L"Down" },
                    { (VKEY)41, L"?" },
                    { (VKEY)42, L"?" },
                    { (VKEY)43, L"?" },
                    { (VKEY)44, L"Sys Req" },
                    { (VKEY)45, L"Insert" },
                    { (VKEY)46, L"Delete" },
                    { (VKEY)47, L"?" },
                    { (VKEY)48, L"0" },
                    { (VKEY)49, L"1" },
                    { (VKEY)50, L"2" },
                    { (VKEY)51, L"3" },
                    { (VKEY)52, L"4" },
                    { (VKEY)53, L"5" },
                    { (VKEY)54, L"6" },
                    { (VKEY)55, L"7" },
                    { (VKEY)56, L"8" },
                    { (VKEY)57, L"9" },
                    { (VKEY)58, L"?" },
                    { (VKEY)59, L"?" },
                    { (VKEY)60, L"?" },
                    { (VKEY)61, L"?" },
                    { (VKEY)62, L"?" },
                    { (VKEY)63, L"?" },
                    { (VKEY)64, L"?" },
                    { (VKEY)65, L"A" },
                    { (VKEY)66, L"B" },
                    { (VKEY)67, L"C" },
                    { (VKEY)68, L"D" },
                    { (VKEY)69, L"E" },
                    { (VKEY)70, L"F" },
                    { (VKEY)71, L"G" },
                    { (VKEY)72, L"H" },
                    { (VKEY)73, L"I" },
                    { (VKEY)74, L"J" },
                    { (VKEY)75, L"K" },
                    { (VKEY)76, L"L" },
                    { (VKEY)77, L"M" },
                    { (VKEY)78, L"N" },
                    { (VKEY)79, L"O" },
                    { (VKEY)80, L"P" },
                    { (VKEY)81, L"Q" },
                    { (VKEY)82, L"R" },
                    { (VKEY)83, L"S" },
                    { (VKEY)84, L"T" },
                    { (VKEY)85, L"U" },
                    { (VKEY)86, L"V" },
                    { (VKEY)87, L"W" },
                    { (VKEY)88, L"X" },
                    { (VKEY)89, L"Y" },
                    { (VKEY)90, L"Z" },
                    { (VKEY)91, L"?" },
                    { (VKEY)92, L"?" },
                    { (VKEY)93, L"?" },
                    { (VKEY)94, L"?" },
                    { (VKEY)95, L"?" },
                    { (VKEY)96, L"Num 0" },
                    { (VKEY)97, L"Num 1" },
                    { (VKEY)98, L"Num 2" },
                    { (VKEY)99, L"Num 3" },
                    { (VKEY)100, L"Num 4" },
                    { (VKEY)101, L"Num 5" },
                    { (VKEY)102, L"Num 6" },
                    { (VKEY)103, L"Num 7" },
                    { (VKEY)104, L"Num 8" },
                    { (VKEY)105, L"Num 9" },
                    { (VKEY)106, L"Num *" },
                    { (VKEY)107, L"Num +" },
                    { (VKEY)108, L"?" },
                    { (VKEY)109, L"Num -" },
                    { (VKEY)110, L"Num Del" },
                    { (VKEY)111, L"/" },
                    { (VKEY)112, L"F1" },
                    { (VKEY)113, L"F2" },
                    { (VKEY)114, L"F3" },
                    { (VKEY)115, L"F4" },
                    { (VKEY)116, L"F5" },
                    { (VKEY)117, L"F6" },
                    { (VKEY)118, L"F7" },
                    { (VKEY)119, L"F8" },
                    { (VKEY)120, L"F9" },
                    { (VKEY)121, L"F10" },
                    { (VKEY)122, L"F11" },
                    { (VKEY)123, L"F12" },
                    { (VKEY)124, L"?" },
                    { (VKEY)125, L"?" },
                    { (VKEY)126, L"?" },
                    { (VKEY)127, L"?" },
                    { (VKEY)128, L"?" },
                    { (VKEY)129, L"?" },
                    { (VKEY)130, L"?" },
                    { (VKEY)131, L"?" },
                    { (VKEY)132, L"?" },
                    { (VKEY)133, L"?" },
                    { (VKEY)134, L"?" },
                    { (VKEY)135, L"?" },
                    { (VKEY)136, L"?" },
                    { (VKEY)137, L"?" },
                    { (VKEY)138, L"?" },
                    { (VKEY)139, L"?" },
                    { (VKEY)140, L"?" },
                    { (VKEY)141, L"?" },
                    { (VKEY)142, L"?" },
                    { (VKEY)143, L"?" },
                    { (VKEY)144, L"Pause" },
                    { (VKEY)145, L"Scroll Lock" }
                };
                
                keyNames.Resize(146);
                for(vint i=0; i<146; ++i)
                {
                    keys.Set(KeyMappings[i].keyName, KeyMappings[i].keyCode);
                    keyNames.Set(i, KeyMappings[i].keyName);
                }
                
                memset(asciiLowerMap, 0, sizeof(wchar_t) * 256);
                memset(asciiUpperMap, 0, sizeof(wchar_t) * 256);
                
                asciiLowerMap[(int)VKEY::_0] = L'0';
                asciiLowerMap[(int)VKEY::_1] = L'1';
                asciiLowerMap[(int)VKEY::_2] = L'2';
                asciiLowerMap[(int)VKEY::_3] = L'3';
                asciiLowerMap[(int)VKEY::_4] = L'4';
                asciiLowerMap[(int)VKEY::_5] = L'5';
                asciiLowerMap[(int)VKEY::_6] = L'6';
                asciiLowerMap[(int)VKEY::_7] = L'7';
                asciiLowerMap[(int)VKEY::_8] = L'8';
                asciiLowerMap[(int)VKEY::_9] = L'9';
                asciiLowerMap[(int)VKEY::_OEM_1] = L';';
                asciiLowerMap[(int)VKEY::_OEM_6] = L'[';
                asciiLowerMap[(int)VKEY::_OEM_4] = L']';
                asciiLowerMap[(int)VKEY::_OEM_7] = L'\'';
                asciiLowerMap[(int)VKEY::_OEM_COMMA] = L',';
                asciiLowerMap[(int)VKEY::_OEM_PERIOD] = L'.';
                asciiLowerMap[(int)VKEY::_OEM_2] = L'/';
                asciiLowerMap[(int)VKEY::_OEM_5] = L'\\';
                asciiLowerMap[(int)VKEY::_OEM_MINUS] = L'-';
                asciiLowerMap[(int)VKEY::_OEM_PLUS] = L'=';
                asciiLowerMap[(int)VKEY::_OEM_3] = L'`';
                asciiLowerMap[(int)VKEY::_SPACE] = L' ';
                asciiLowerMap[(int)VKEY::_RETURN] = (int)VKEY::_RETURN;
                asciiLowerMap[(int)VKEY::_ESCAPE] = (int)VKEY::_ESCAPE;
                asciiLowerMap[(int)VKEY::_BACK] = (int)VKEY::_BACK;
                for(int i=(int)VKEY::_A; i<=(int)VKEY::_Z; ++i)
                    asciiLowerMap[i] = L'a' + (i-(int)VKEY::_A);
                for(int i=(int)VKEY::_NUMPAD0; i<(int)VKEY::_NUMPAD9; ++i)
                    asciiLowerMap[i] = L'0' + (i-(int)VKEY::_NUMPAD0);
                
                asciiUpperMap[(int)VKEY::_0] = L')';
                asciiUpperMap[(int)VKEY::_1] = L'!';
                asciiUpperMap[(int)VKEY::_2] = L'@';
                asciiUpperMap[(int)VKEY::_3] = L'#';
                asciiUpperMap[(int)VKEY::_4] = L'$';
                asciiUpperMap[(int)VKEY::_5] = L'%';
                asciiUpperMap[(int)VKEY::_6] = L'^';
                asciiUpperMap[(int)VKEY::_7] = L'&';
                asciiUpperMap[(int)VKEY::_8] = L'*';
                asciiUpperMap[(int)VKEY::_9] = L'(';
                asciiUpperMap[(int)VKEY::_OEM_1] = L':';
                asciiUpperMap[(int)VKEY::_OEM_6] = L'{';
                asciiUpperMap[(int)VKEY::_OEM_4] = L'}';
                asciiUpperMap[(int)VKEY::_OEM_7] = L'\"';
                asciiUpperMap[(int)VKEY::_OEM_COMMA] = L'<';
                asciiUpperMap[(int)VKEY::_OEM_PERIOD] = L'>';
                asciiUpperMap[(int)VKEY::_OEM_2] = L'?';
                asciiUpperMap[(int)VKEY::_OEM_5] = L'|';
                asciiUpperMap[(int)VKEY::_OEM_MINUS] = L'_';
                asciiUpperMap[(int)VKEY::_OEM_PLUS] = L'+';
                asciiUpperMap[(int)VKEY::_OEM_3] = L'~';
                asciiUpperMap[(int)VKEY::_SPACE] = L' ';
                asciiUpperMap[(int)VKEY::_RETURN] = (int)VKEY::_RETURN;
                asciiUpperMap[(int)VKEY::_ESCAPE] = (int)VKEY::_ESCAPE;
                asciiUpperMap[(int)VKEY::_BACK] = (int)VKEY::_BACK;
                for(int i=(int)VKEY::_A; i<=(int)VKEY::_Z; ++i)
                    asciiUpperMap[i] = L'A' + (i-(int)VKEY::_A);
                for(int i=(int)VKEY::_NUMPAD0; i<(int)VKEY::_NUMPAD9; ++i)
                    asciiLowerMap[i] = L'0' + (i-(int)VKEY::_NUMPAD0);
            }
            
            void CocoaInputService::HookInput()
            {
                int eventMask = (CGEventMaskBit(kCGEventMouseMoved)) |
                                (CGEventMaskBit(kCGEventLeftMouseDown)) |
                                (CGEventMaskBit(kCGEventLeftMouseUp)) |
                                (CGEventMaskBit(kCGEventRightMouseDown)) |
                                (CGEventMaskBit(kCGEventRightMouseUp)) |
                                (CGEventMaskBit(kCGEventKeyDown)) |
                                (CGEventMaskBit(kCGEventKeyUp));
                inputTapPort =  CGEventTapCreate(kCGSessionEventTap,
                                                 kCGHeadInsertEventTap,
                                                 kCGEventTapOptionDefault,
                                                 eventMask,
                                                 &InputTapFunc,
                                                 this);
                if (inputTapPort == NULL)
                {
                    throw EventTapException(L"Failed to create CGEventTap");
                }
                else
                {
                    inputTapRunLoopSource = CFMachPortCreateRunLoopSource(NULL, inputTapPort, 0);
                    if (inputTapRunLoopSource == 0)
                    {
                        throw EventTapException(L"Failed to create run loop for the mouse even tap");
                    }
                    else
                    {
                        CFRunLoopRef runLoop =  CFRunLoopGetCurrent();
                        CFRunLoopAddSource(runLoop, inputTapRunLoopSource, kCFRunLoopCommonModes);
                        
                        CGEventTapEnable(inputTapPort, true);
                    }
                }

            }
            
            void CocoaInputService::InvokeInputHook(CGEventType type, CGEventRef event)
            {
                if(type == kCGEventKeyDown ||
                   type == kCGEventKeyUp)
                {
                    // this won't work is OSX Accessibility is turned on for our app (think about the case of Steam)
                    // so maybe a better way is just hooking window level events and send to InputService
                    // however that won't be global key states...
                    auto keyCode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);

                    wprintf(L"%s event\n", GetKeyName(NSEventKeyCodeToGacKeyCode(keyCode)).Buffer());

                    if(keyCode < 256)
                        globalKeyStates[keyCode] = static_cast<vint8_t>(keyCode);
                }
                else
                {
                    if(isHookingMouse)
                    {
                        mouseTapFunc(type, event);
                    }
                }
            }
            
            void CocoaInputService::StartHookMouse()
            {
                isHookingMouse = true;
            }
            
            void CocoaInputService::StopHookMouse()
            {
                isHookingMouse = false;
                
            }
            
            bool CocoaInputService::IsHookingMouse()
            {
                return isHookingMouse;
            }
            
            void CocoaInputService::StartGCDTimer()
            {
                double delayInMilliseconds = 16;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInMilliseconds * NSEC_PER_MSEC));
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void)
                {
                    if(IsTimerEnabled())
                    {
                        timerFunc();
                        StartGCDTimer();
                    }
                });
            }
            
            void CocoaInputService::StartTimer()
            {
                StartGCDTimer();
                isTimerEnabled = true;
            }
            
            void CocoaInputService::StopTimer()
            {
                isTimerEnabled = false;
            }
            
            bool CocoaInputService::IsTimerEnabled()
            {
                 return isTimerEnabled;
            }
            
            bool CocoaInputService::IsKeyPressing(VKEY code)
            {
                if((int)code < 256)
                    return globalKeyStates[(int)code];
                return false;
            }
            
            bool CocoaInputService::IsKeyToggled(VKEY code)
            {
                NSEventModifierFlags modifierFlags = [NSEvent modifierFlags];
                
                switch(code)
                {
                    case VKEY::_CAPITAL:
                        return modifierFlags & NSEventModifierFlagCapsLock;
                        
                    case VKEY::_SHIFT:
                        return modifierFlags & NSEventModifierFlagShift;
                        
                    case VKEY::_CONTROL:
                        return modifierFlags & NSEventModifierFlagControl;
                        
                    case VKEY::_LMENU:
                    case VKEY::_RMENU:
                        return modifierFlags & NSEventModifierFlagOption;
                        
                    case VKEY::_LWIN:
                    case VKEY::_RWIN:
                        return modifierFlags & NSEventModifierFlagCommand;
                        
                    case VKEY::_NUMLOCK:
                        return modifierFlags & NSEventModifierFlagNumericPad;
                        
                    case VKEY::_HELP:
                        return modifierFlags & NSEventModifierFlagHelp;
                }
                return false;
            }
            
            WString CocoaInputService::GetKeyName(VKEY code)
            {
                return keyNames[(int)code];
            }

            VKEY CocoaInputService::GetKey(const WString& name)
            {
                return keys.Get(name);
            }
            
            //
            bool CocoaInputService::ConvertToPrintable(NativeWindowCharInfo& info, NSEvent* event)
            {
                info.ctrl = event.modifierFlags & NSEventModifierFlagCommand;
                info.shift = event.modifierFlags & NSEventModifierFlagShift;
                info.alt = event.modifierFlags & NSEventModifierFlagOption;
                info.capslock = event.modifierFlags & NSEventModifierFlagCapsLock;
                
                if(info.ctrl || info.alt)
                    return false;
                
                int code = (int)NSEventKeyCodeToGacKeyCode(event.keyCode);
                if(code >= 256)
                    return false;
                
                info.code = asciiLowerMap[code];
                if(info.capslock || info.shift)
                {
                    info.code = asciiUpperMap[code];
                }

                return info.code != 0;
            }
            
            CocoaInputService* GetCocoaInputService()
            {
                return g_inputService;
            }
            
        }
        
    }
    
}