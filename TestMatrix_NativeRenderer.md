# Test Matrix Card 2026-10-22T00:41:59.196Z

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 2026-10-22T01:29:15.290Z |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-10-22T01:32:08.744Z |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-10-22T01:37:04.479Z |
| [macOS][`/RVMT`][`/MiniHttp`] | 2026-10-22T01:29:15.290Z |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] | 2026-10-22T01:29:15.290Z |
| Import / sync / official build | 2026-10-22T01:25:35.257Z |
| Cocoa raw-element tests, native and hosted | 2026-10-22T01:25:35.257Z (native 4/4; hosted 3 active cases, one remote-only case skipped) |
| Hosted modal event-pump regression | 2026-10-22T01:25:35.257Z (1/1; old implementation times out) |
| Local simple app | 2026-10-22T00:59:28.451Z |
| Local FullControlTest | 2026-10-22T01:07:32.114Z (see coverage notes) |
| Hosted FullControlTest | 2026-10-22T01:15:06.673Z (fixed; see coverage notes) |
| Native Touching acquisition and manipulation | |
| Native TouchingList gestures | |

## Issues Found and Fix

Hosted FullControlTest froze twice after an automation shortcut opened a fake dialog. The nested loop ran inside `CocoaInputService::StartGCDTimer`, preventing the next tick from being scheduled. The Cocoa timer now posts a coalesced application event before running application callbacks. Both shortcut dialogs, subsequent input, Raw Clock and normal shutdown pass. The new `Test_HostedModal` regression times out on the old implementation and passes on the fix. Samples and before/after logs are under `<iGac repo>/build/touch-step4/`.

## Step 4 scope

WASM builds, tests and website deployment are excluded by request. Results belong only to this macOS run.

Native touch rows remain blank because iGac does not support native touch experience. Inherited empty point callbacks satisfy the updated interfaces. Native point automation returns `Unsupported: point input is unavailable on this native window adapter.` Raw Clock and mouse/keyboard checks remain applicable.



- RPT retained the clicked marker through replacement/takeover, passed grid/document and local shortcut/mouse checks, canceled and accepted close, and retained the Core-authored fatal error after No. Native OS global Q was not exercised.

- Remote FCT passed lists, two editors, local shortcuts, mouse/modifier and wheel cases, palettes, responsive modal resize/reopen, Raw Clock pixels, replacement/takeover and normal close. System Events delivered the registered Ctrl+Shift+Alt+Command+Q while Finder was active. Native touch remained unsupported.

## Coverage notes

- Local and hosted FCT passed list add/clear, independent editor markers, local shortcuts, mouse/modifier cases and normal close. Raw Clock changed pixels without input, survived tab/palette changes and restarted correctly. Local responsive-modal client sizes included 240/350/440/680 by 320 and 680 by 220/520. Remote modal resizing was constrained by the host to width 671 and height 490 at the largest requested sizes; the actual bounds are retained in `<iGac repo>/build/touch-step4/remote-modal-sizes.json`.
- All three native RPC configurations passed edited/Unicode greetings, normal shutdown, and idle/blocked host loss. Network receive queues and a pending stdio Controls read established blocked delivery before host termination. Remote renderers retained the exact fatal text after choosing No. Evidence: `<iGac repo>/build/touch-step4/native-rpc-results.json`.
- Physical touch is excluded. Physical mouse/keyboard hardware, every responsive movie/account scrolling combination and title-bar-close variant were not exhaustively checked. The FCT global shortcut used generated System Events input; other native input used renderer/local automation.
