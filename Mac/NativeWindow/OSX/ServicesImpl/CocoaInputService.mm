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
                    vint       keyCode;
                    WString    keyName;
                    
                } KeyMappings[] = {
                    { 0, L"?" },
                    { 1, L"?" },
                    { 2, L"?" },
                    { 3, L"?" },
                    { 4, L"?" },
                    { 5, L"?" },
                    { 6, L"?" },
                    { 7, L"?" },
                    { 8, L"Backspace" },
                    { 9, L"Tab" },
                    { 10, L"?" },
                    { 11, L"?" },
                    { 12, L"?" },
                    { 13, L"Enter" },
                    { 14, L"?" },
                    { 15, L"?" },
                    { 16, L"Shift" },
                    { 17, L"Ctrl" },
                    { 18, L"Alt" },
                    { 19, L"?" },
                    { 20, L"Caps Lock" },
                    { 21, L"?" },
                    { 22, L"?" },
                    { 23, L"?" },
                    { 24, L"?" },
                    { 25, L"?" },
                    { 26, L"?" },
                    { 27, L"Esc" },
                    { 28, L"?" },
                    { 29, L"?" },
                    { 30, L"?" },
                    { 31, L"?" },
                    { 32, L"Space" },
                    { 33, L"Page Up" },
                    { 34, L"Page Down" },
                    { 35, L"End" },
                    { 36, L"Home" },
                    { 37, L"Left" },
                    { 38, L"Up" },
                    { 39, L"Right" },
                    { 40, L"Down" },
                    { 41, L"?" },
                    { 42, L"?" },
                    { 43, L"?" },
                    { 44, L"Sys Req" },
                    { 45, L"Insert" },
                    { 46, L"Delete" },
                    { 47, L"?" },
                    { 48, L"0" },
                    { 49, L"1" },
                    { 50, L"2" },
                    { 51, L"3" },
                    { 52, L"4" },
                    { 53, L"5" },
                    { 54, L"6" },
                    { 55, L"7" },
                    { 56, L"8" },
                    { 57, L"9" },
                    { 58, L"?" },
                    { 59, L"?" },
                    { 60, L"?" },
                    { 61, L"?" },
                    { 62, L"?" },
                    { 63, L"?" },
                    { 64, L"?" },
                    { 65, L"A" },
                    { 66, L"B" },
                    { 67, L"C" },
                    { 68, L"D" },
                    { 69, L"E" },
                    { 70, L"F" },
                    { 71, L"G" },
                    { 72, L"H" },
                    { 73, L"I" },
                    { 74, L"J" },
                    { 75, L"K" },
                    { 76, L"L" },
                    { 77, L"M" },
                    { 78, L"N" },
                    { 79, L"O" },
                    { 80, L"P" },
                    { 81, L"Q" },
                    { 82, L"R" },
                    { 83, L"S" },
                    { 84, L"T" },
                    { 85, L"U" },
                    { 86, L"V" },
                    { 87, L"W" },
                    { 88, L"X" },
                    { 89, L"Y" },
                    { 90, L"Z" },
                    { 91, L"?" },
                    { 92, L"?" },
                    { 93, L"?" },
                    { 94, L"?" },
                    { 95, L"?" },
                    { 96, L"Num 0" },
                    { 97, L"Num 1" },
                    { 98, L"Num 2" },
                    { 99, L"Num 3" },
                    { 100, L"Num 4" },
                    { 101, L"Num 5" },
                    { 102, L"Num 6" },
                    { 103, L"Num 7" },
                    { 104, L"Num 8" },
                    { 105, L"Num 9" },
                    { 106, L"Num *" },
                    { 107, L"Num +" },
                    { 108, L"?" },
                    { 109, L"Num -" },
                    { 110, L"Num Del" },
                    { 111, L"/" },
                    { 112, L"F1" },
                    { 113, L"F2" },
                    { 114, L"F3" },
                    { 115, L"F4" },
                    { 116, L"F5" },
                    { 117, L"F6" },
                    { 118, L"F7" },
                    { 119, L"F8" },
                    { 120, L"F9" },
                    { 121, L"F10" },
                    { 122, L"F11" },
                    { 123, L"F12" },
                    { 124, L"?" },
                    { 125, L"?" },
                    { 126, L"?" },
                    { 127, L"?" },
                    { 128, L"?" },
                    { 129, L"?" },
                    { 130, L"?" },
                    { 131, L"?" },
                    { 132, L"?" },
                    { 133, L"?" },
                    { 134, L"?" },
                    { 135, L"?" },
                    { 136, L"?" },
                    { 137, L"?" },
                    { 138, L"?" },
                    { 139, L"?" },
                    { 140, L"?" },
                    { 141, L"?" },
                    { 142, L"?" },
                    { 143, L"?" },
                    { 144, L"Pause" },
                    { 145, L"Scroll Lock" }
                };
                
                keyNames.Resize(146);
                for(vint i=0; i<146; ++i)
                {
                    keys.Set(KeyMappings[i].keyName, KeyMappings[i].keyCode);
                    keyNames.Set(i, KeyMappings[i].keyName);
                }
                
                memset(asciiLowerMap, 0, sizeof(wchar_t) * 256);
                memset(asciiUpperMap, 0, sizeof(wchar_t) * 256);
                
                asciiLowerMap[VKEY_0] = L'0';
                asciiLowerMap[VKEY_0] = L'1';
                asciiLowerMap[VKEY_2] = L'2';
                asciiLowerMap[VKEY_3] = L'3';
                asciiLowerMap[VKEY_4] = L'4';
                asciiLowerMap[VKEY_5] = L'5';
                asciiLowerMap[VKEY_6] = L'6';
                asciiLowerMap[VKEY_7] = L'7';
                asciiLowerMap[VKEY_8] = L'8';
                asciiLowerMap[VKEY_9] = L'9';
                asciiLowerMap[VKEY_OEM_1] = L';';
                asciiLowerMap[VKEY_OEM_6] = L'[';
                asciiLowerMap[VKEY_OEM_4] = L']';
                asciiLowerMap[VKEY_OEM_7] = L'\'';
                asciiLowerMap[VKEY_OEM_COMMA] = L',';
                asciiLowerMap[VKEY_OEM_PERIOD] = L'.';
                asciiLowerMap[VKEY_OEM_2] = L'/';
                asciiLowerMap[VKEY_OEM_5] = L'\\';
                asciiLowerMap[VKEY_OEM_MINUS] = L'-';
                asciiLowerMap[VKEY_OEM_PLUS] = L'=';
                asciiLowerMap[VKEY_OEM_3] = L'`';
                asciiLowerMap[VKEY_SPACE] = L' ';
                asciiLowerMap[VKEY_RETURN] = VKEY_RETURN;
                asciiLowerMap[VKEY_ESCAPE] = VKEY_ESCAPE;
                asciiLowerMap[VKEY_BACK] = VKEY_BACK;
                for(int i=VKEY_A; i<=VKEY_Z; ++i)
                    asciiLowerMap[i] = L'a' + (i-VKEY_A);
                for(int i=VKEY_NUMPAD0; i<VKEY_NUMPAD9; ++i)
                    asciiLowerMap[i] = L'0' + (i-VKEY_NUMPAD0);
                
                asciiUpperMap[VKEY_0] = L')';
                asciiUpperMap[VKEY_1] = L'!';
                asciiUpperMap[VKEY_2] = L'@';
                asciiUpperMap[VKEY_3] = L'#';
                asciiUpperMap[VKEY_4] = L'$';
                asciiUpperMap[VKEY_5] = L'%';
                asciiUpperMap[VKEY_6] = L'^';
                asciiUpperMap[VKEY_7] = L'&';
                asciiUpperMap[VKEY_8] = L'*';
                asciiUpperMap[VKEY_9] = L'(';
                asciiUpperMap[VKEY_OEM_1] = L':';
                asciiUpperMap[VKEY_OEM_6] = L'{';
                asciiUpperMap[VKEY_OEM_4] = L'}';
                asciiUpperMap[VKEY_OEM_7] = L'\"';
                asciiUpperMap[VKEY_OEM_COMMA] = L'<';
                asciiUpperMap[VKEY_OEM_PERIOD] = L'>';
                asciiUpperMap[VKEY_OEM_2] = L'?';
                asciiUpperMap[VKEY_OEM_5] = L'|';
                asciiUpperMap[VKEY_OEM_MINUS] = L'_';
                asciiUpperMap[VKEY_OEM_PLUS] = L'+';
                asciiUpperMap[VKEY_OEM_3] = L'~';
                asciiUpperMap[VKEY_SPACE] = L' ';
                asciiUpperMap[VKEY_RETURN] = VKEY_RETURN;
                asciiUpperMap[VKEY_ESCAPE] = VKEY_ESCAPE;
                asciiUpperMap[VKEY_BACK] = VKEY_BACK;
                for(int i=VKEY_A; i<=VKEY_Z; ++i)
                    asciiUpperMap[i] = L'A' + (i-VKEY_A);
                for(int i=VKEY_NUMPAD0; i<VKEY_NUMPAD9; ++i)
                    asciiLowerMap[i] = L'0' + (i-VKEY_NUMPAD0);
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
                    CGKeyCode keyCode = (CGKeyCode)CGEventGetIntegerValueField(event, kCGKeyboardEventKeycode);
                    
                    wprintf(L"%s event\n", GetKeyName(NSEventKeyCodeToGacKeyCode(keyCode)).Buffer());
                    
                    if(keyCode < 256)
                        globalKeyStates[keyCode] = keyCode;
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
            
            bool CocoaInputService::IsKeyPressing(vint code)
            {
                if(code < 256)
                    return globalKeyStates[code];
                return false;
            }
            
            bool CocoaInputService::IsKeyToggled(vint code)
            {
                unsigned long modifierFlags = [NSEvent modifierFlags];
                
                switch(code)
                {
                    case VKEY_CAPITAL:
                        return modifierFlags & NSAlphaShiftKeyMask;
                        
                    case VKEY_SHIFT:
                        return modifierFlags & NSShiftKeyMask;
                        
                    case VKEY_CONTROL:
                        return modifierFlags & NSControlKeyMask;
                        
                    case VKEY_LMENU:
                    case VKEY_RMENU:
                        return modifierFlags & NSAlternateKeyMask;
                        
                    case VKEY_LWIN:
                    case VKEY_RWIN:
                        return modifierFlags & NSCommandKeyMask;
                        
                    case VKEY_NUMLOCK:
                        return modifierFlags & NSNumericPadKeyMask;
                        
                    case VKEY_HELP:
                        return modifierFlags & NSHelpKeyMask;
                }
                return false;
            }
            
            WString CocoaInputService::GetKeyName(vint code)
            {
                return keyNames[code];
            }
            
            vint CocoaInputService::GetKey(const WString& name)
            {
                return keys.Get(name);
            }
            
            //
            bool CocoaInputService::ConvertToPrintable(NativeWindowCharInfo& info, NSEvent* event)
            {
                info.ctrl = event.modifierFlags & NSCommandKeyMask;
                info.shift = event.modifierFlags & NSShiftKeyMask;
                info.alt = event.modifierFlags & NSAlternateKeyMask;
                info.capslock = event.modifierFlags & NSAlphaShiftKeyMask;
                
                if(info.ctrl || info.alt)
                    return false;
                
                vint code = NSEventKeyCodeToGacKeyCode(event.keyCode);
                if(code >= 256)
                    return false;
                
                info.code = asciiLowerMap[code];
                if(info.capslock || info.shift) {
                    info.code = asciiUpperMap[code];
                }
                
                if(info.code != 0)
                    return true;
                
                return false;
            }
            
            CocoaInputService* GetCocoaInputService()
            {
                return g_inputService;
            }
            
        }
        
    }
    
}