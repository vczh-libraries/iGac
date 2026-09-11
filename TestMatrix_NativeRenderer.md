# Test Matrix Card 2026-09-10 18:50:58 -0700

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 2026-09-11T02:43:05.326Z |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-09-10 19:22:19 -0700 (fixed; fatal prompt inspection unavailable) |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-09-11T02:39:56.791Z |
| [macOS][`/RVMT`][`/MiniHttp`] | 2026-09-11T02:44:27.671Z (fatal prompt inspection unavailable) |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] | 2026-09-11T02:44:42.825Z (fatal prompt inspection unavailable) |

## Build and synchronization

CodePack/import, all four app generations, iGac whole-repo builds after both fixes, and Core/host full builds passed. TUI repeat generation preserved 27 hashes.

## Issues Found and Fix

### Local FullControlTest palette synchronization

The generated radios emitted PaletteSelected, but iGac did not import or subscribe the shared GacUI handler. Aurora selected without changing the existing Default accent. The sync script now copies the owning GacUI helper pair; Main.mm attaches it for both native modes. Standard and hosted runtime verification passed, including all presets and retained list/editor state.

Desktop observation: macOS reports `CGSSessionScreenIsLocked=true`; desktop capture is black. Physical input, native global chord activation and final displayed appearance remain unavailable. Native automation, WebKit and terminal-buffer/replay checks are recorded separately.

## Local app verification

Hosted FullControlTest: fixed. All six presets emit their expected accent colors; independent search/document markers and both lists survive repeated tab visits and palette changes; queued Close exits 0. Standard mode verification also passed.

### Cocoa Command key names

Native renderer automation rejected Ctrl+Alt+Command+Q: CocoaInputService still named both Super VKEYs `?`, preventing key lookup despite correct platform shortcut labels. Both keys now have explicit Command names. Rebuild and runtime verification passed; both local shortcuts work before and after native renderer replacement. A separate RightCommand run produced the exact Ctrl+Alt+Win+Q dialog and normal Core/renderer exit 0. Physical/global activation remains unavailable on the locked desktop.

Native RPT normal path passed: initial/button, three grid rows and clear, document modal, local shortcuts, full mouse/modifier matrix before/after takeover, retained marker and Core/renderer exit 0. The Command lookup fix passes in both replacement renderers. Fresh Fatel Error terminates Core with SIGABRT and enters Cocoa system-alert handling; macOS accessibility denied osascript (-25211) and the locked desktop prevents choosing No. Retained fatal DOM/input rejection could not be observed; the owned renderer was cleaned up.

Local standard FCT passed: paired list add/clear, keyboard-event text with brackets/braces, two retained editors, all six live palettes with retained editor and list state, queued close and exit 0. Physical/global activation and displayed appearance remain unavailable. Repeated successfully after the final GacUI template-stacking fix.

Native remote FCT passed: paired list add/clear, keyboard-event text with brackets/braces, two retained editors, local shortcuts and complete mouse/modifier matrix before/after renderer replacement, queued close and exit 0. Physical/global activation and displayed appearance remain unavailable.

[macOS][Test_CppTest_Rvm][`/MiniHttp`]: successful Translate, second-host rejection, normal UI close and host cleanup; fresh idle-next-call and blocked-delivery host kills terminate the requester nonzero. Direct unhandled requester termination observed.

[macOS][`/RVMT`][`/MiniHttp`]: successful Translate, second-host rejection, renderer replacement and subsequent RPC, normal UI close and host cleanup; fresh idle-next-call and blocked-delivery host kills terminate the requester nonzero. Core reaches native fatal-alert handling; locked-desktop accessibility prevents No/retained-DOM checks. Owned renderer cleaned after each injection.

[macOS][`/RVMT`][`/MiniHttp /Cli:<path>`]: successful Translate, renderer replacement and subsequent RPC, normal UI close and host cleanup; fresh idle-next-call and blocked-delivery host kills terminate the requester nonzero. Core reaches native fatal-alert handling; locked-desktop accessibility prevents No/retained-DOM checks. Owned renderer cleaned after each injection.

Local simple smoke: expected Hello, world! title and Welcome to GacUI Library! label, native close request and process exit 0.
