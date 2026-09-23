# Test Matrix Card 2026-09-22T22:41:38-07:00

Scope: remote FCT with the macOS native renderer over MiniHTTP only. All other runtime verifications are excluded by request; their results remain blank.

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`test.sh --app:simple`] |  |
| [macOS][`test.sh --app:fct`] (standard) |  |
| [macOS][`test.sh --app:fct --hosted`] |  |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] |  |
| [macOS][`/RPT`][`/MiniHttp`] |  |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-09-22T22:41:38-07:00 |
| [macOS][`/RVMT`][`/MiniHttp`] |  |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] |  |

## Build and synchronization

2026-09-22T22:41:38-07:00: CodePack, import and sync passed; iGac all-target build passed. Core full rebuild through `test_core.sh --app:fct --protocol:minihttp` passed. Unit tests and all other runtime targets were excluded by request. Evidence: `/tmp/rpxplat-fct-20260922`.

## FCT progress

| Check | Result |
| --- | --- |
| Initial title and tabs | Passed |
| Both lists add 0–9 and clear | Passed; exact 0–9 twice, then absent from Controls and active DOM |
| Search and rich editor text, tab retention, brackets/braces | Passed; MacMiniHTTP922 / NativeMiniHTTP Hello[Ab]{Cd}, exact in both trees after tab round trip |
| Canonical shortcut labels and local dialogs | Passed on all three renderers; canonical Command labels and exact local prompts dismissed |
| Native global shortcut | Passed on all three renderers; native macOS Ctrl+Shift+Alt+Command+Q exact dialog |
| Five mouse buttons and modifier combinations | Passed before and after replacement; all five down/up pairs × eight combinations, matching theme font/color; Mouse4/5 repeated after takeover |
| Movement, double-click, both wheel axes | Passed before and after replacement; eight modifier combinations, all five double-click buttons, both wheel axes/directions; 480 total mouse-event assertions |
| Renderer replacement and takeover, retained state, repeated input | Passed; same Core PID 4421, markers retained in renderers 2/3, renderer 2 exited and port 8889 closed, repeated local shortcuts and Mouse4/Mouse5 on renderer 3 |
| Updated Easy Layout pages | Passed; editor/choice retention, both arrangement rebuilds, all four table splitters, rebuild restores 120×40 editor and retains text |
| Application close and process cleanup | Passed; Exit → self.Close() (InvokeInMainThread), Core and active renderer exit 0; no remaining processes or listeners on 8888/8889/8890 |

## Run details

Completed 2026-09-22T22:56:39-07:00. Core source revision: GacUI `e8be96806`; iGac starting revision: `96acd7c`. All application input used the active native renderer, with System Events keyboard input for the Carbon global shortcut. Core Controls and active renderer DOM were checked after each state change. No functional defects were observed.

`syncProj.sh` imported the current FullControlTest Easy Layout resources and regenerated their C++ snapshot. Framework CodePack output was unchanged apart from line endings; existing line endings were preserved. Generated C++ retains its existing CRLF format; `git -c core.whitespace=cr-at-eol diff --check` passed.

Evidence is retained under `/tmp/rpxplat-fct-20260922`: build/sync/Core/renderer logs, Controls/DOM snapshots, renderer command log, `mouse-before-evidence.json`, `mouse-replacement-evidence.json`, and `takeover-detach.json`. Renderer 1 was deliberately killed to test replacement; renderer 2 exited 0 after takeover; Core and renderer 3 exited 0 through the application close action.

## Issues Found and Fix
