# Test Matrix Card 2026-10-16T01:06:53.035Z

Wasm is excluded by request. Results below belong to this run.

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Import / sync / full build | 2026-10-15 17:40 (fixed) |
| GacUI unit tests | Passed: 94 files, 1,837 cases |
| Cocoa raw-element tests, native and hosted | 2026-10-15 18:44 (fixed) |
| Local simple app | 2026-10-15 18:53 (passed) |
| Local FullControlTest | 2026-10-15 18:57 (automation passed; native dialog/resize limits below) |
| Hosted FullControlTest | 2026-10-15 19:03:03 (automation passed; native-alert limitation) |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 2026-10-15 19:20:40 (normal/Unicode/rejected host/both loss variants passed) |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-10-15 19:08:47 (normal/replacement/takeover passed; global key unavailable) |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-10-15 19:16:45 (clock/UI/replacement/takeover passed; global key unavailable) |
| [macOS][`/RVMT`][`/MiniHttp`] | 2026-10-15 19:23:54 (normal/Unicode/replacement/both loss terminations; native No unavailable) |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] | 2026-10-15 19:23:54 (normal/Unicode/replacement/both loss terminations; native No unavailable) |

## Issues Found and Fix

### Stable imported line endings

The first import produced unrelated CRLF/LF rewrites. `import.sh` now normalizes snapshots to their existing conventions. Re-importing leaves only semantic framework updates (11 files), and the second synchronization is preserving the local Cocoa helper sources and target references.

- CodePack, import, both complete synchronizations and the full native build passed. Apple legacy `Ptr`, `Rect`, and `Size` typedef collisions in new test/demo code were fixed by qualifying GacUI types. Local Cocoa helpers and CMake references survived the second sync.

- Focused Cocoa tests: native 4/4 passed; hosted factory, offscreen state isolation and fixed-data clock tests passed (the real native-window remote case is intentionally native-only). The offscreen fixture needed the same flipped coordinate transform as the native view. LLDB launch required Developer Tools Access authentication; that probe was canceled and its processes stopped. The supported test runner then completed successfully.

Native local FCT: both exact list sequences, Clear, and two keyboard-entered editor markers survived navigation. Ctrl+Q displayed the exact native alert (screenshot captured). Accessibility subsequently returned -25211, preventing native-dialog dismissal and desktop input verification; the remaining checks used isolated application/PTY automation. The blocked local run was terminated before a fresh run.

Local FCT: real Cocoa clock screenshots show successive hand positions without input, including Ember refresh. Vertical layout pages, retained editor/choice state across Default/Ember/Aurora/Default, responsive 240x320 modal, eight account choices, list-end navigation, OK/Cancel/reopen and queued Close passed. Physical resize and native-dialog dismissal remain unavailable with Accessibility denied.

Hosted FCT: list/editor continuity, real clock data and two screenshots across an input-free tick, palette refresh, 40 button/double-click combinations and 32 wheel combinations passed. Responsive hosted frame widths 291/366/456/685 exercised compact/details/menu/list layouts repeatedly, with OK/Cancel and clean queued Close. Local and hosted shortcut message boxes both use Cocoa native dialogs; Ctrl+Q was visible, but dismissal and OS global chords are unverified after Accessibility denial.

Unexpected Core termination closed the configured native renderer cleanly (its GuiRemoteRendererSingle uses exit-on-disconnect). Retained raw-picture lifetime is covered by the focused renderer test; interactive fatal retention still needs the native No button, unavailable with Accessibility denied.

Native RVMT network and stdio: Unicode RPC, replacement, normal Exit, manual second-host rejection and stdio child reaping passed. Both idle-next-call and blocked-call host losses terminated Core nonzero. The blocked stdio proof must be taken after input reaches Core; an immediate Controls read can overtake renderer input. Once Controls remained pending, killing the stopped child released Core promptly. Exact fatal prompts were captured, but Accessibility prevents No/retained-DOM/ordinary-input-rejection verification. Standalone RVMT also passed both unhandled host-loss terminations; its blocked network receive queue contained 389 bytes before termination, released in 4.99 s.

A fresh ordinary local FCT also passed the full 40 button/double-click and 32 wheel modifier combinations, followed by queued Close with exit 0.

Final native FCT replacement/takeover captures waited for fresh Raw data and a painted frame. All three renderers showed the actual clock; the takeover renderer's dial and three hands were visually inspected. The old renderer exited 0 on takeover, and queued Close ended the final Core and renderer with exit 0. An earlier immediate black capture was taken before first paint and was not used as rendering evidence.
