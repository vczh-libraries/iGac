# Test Matrix Card 2026-11-16 08:19:48 PST

## Test Matrix

Current execution of `<GacUI repo>/.github/Jobs/job.rpXPlat.prompt.md`; historical results are not current passes. Evidence is retained in `<iGac repo>/build/rpXPlat-20261116/`.

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 08:41:04 PST |
| [macOS][`/RPT`][`/MiniHttp`] | Pass with fatal-dialog limitation |
| [macOS][`/FCT`][`/MiniHttp`] | Pass (fixed; desktop limitations) |
| [macOS][`/RVMT`][`/MiniHttp`] | Pass with fatal-dialog limitation |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<command>`] | Pass with fatal-dialog limitation |
| Build / resource generation / import / sync | 11:42:46 PST |
| [macOS][Hello World][native] | 08:49:47 PST |
| [macOS][Local FullControlTest][native] | Pass with desktop limitations |
| [macOS][Local FullControlTest][hosted] | 11:05:09 PST (fixed) |
| Native provider regression tests | 08:38:37 PST |
| Native touch acquisition / Touching / TouchingList |  |
| Native Toolstrip point-input scenario |  |

## Observations and Limitations

Verification used macOS 26.5.2 arm64 and the official native build defaults (`CMAKE_BUILD_TYPE` unset). Native touch acquisition, Touching/TouchingList and the Toolstrip point-input scenario are excluded because iGac does not support native touch; their results remain blank.

- Hello World opened its expected welcome UI and exited normally. Provider fixtures passed: Test_RawElement native and hosted, Test_HostedModal, Test_ImageService and Test_Paragraph. Hosted RawElement has two source-defined early returns; its reported 7/7 is not seven hosted painting scenarios.
- Standalone CppTest_Rvm and network/stdio remote RVMT passed normal RPC and applicable replacement/takeover, second-host rejection and shutdown checks. Idle and confirmed blocked host losses terminated the requester/Core as expected. Stdio blocked EOF released Core in 851 ms. Native fatal prompts reached `CocoaDialogService::ShowMessageBox` / `CFUserNotificationDisplayAlert`, but the locked session exposed no accessible notification window. Fatal-prompt pixels and retained-UI inspection remain unavailable; owned fatal-test renderers were stopped after collecting process/thread evidence.
- RPT passed normal controls, exact local shortcuts, grid add/clear, document modal, renderer replacement/takeover and queued close. Each connection passed 40 button/double-click combinations and 32 wheel cases. Fatal Core termination was confirmed; native fatal-dialog accessibility remained unavailable. Evidence: `native-rpt-fatal.json` and process logs.
- Local hosted FCT passed document clipboard/formatting/font/color/alignment/styles/link/read-only/persistence operations, layout and palette retention, input checks, modal handling and Raw Clock data. Its initial responsive-height failure reproduced twice. The final rebuilt app passed nine grow/shrink samples with 27-pixel compact and 106-pixel detailed rows, then OK/Cancel and queued close returned 0. The modal was moved left within the native surface before testing width 680. Evidence: `hosted-final-responsive.json`.
- Local non-hosted FCT passed lists/editor markers, clipboard Undo/Redo, eight styles and reapplication, format toggles, all hyperlink command paths, read-only mutation rejection, alignment, palette state, mouse/wheel checks, modal OK/Cancel and Raw Clock data. The final rebuilt app repeated hyperlink edits across separately typed runs: only the latest URL remained, removal preserved `LocalFinal中😀`, and queued close returned 0. Native system panels, system-frame title actions and desktop resize were unavailable in this locked session. Evidence: `local-final-link-regression.json`.
- Final remote FCT passed the complete applicable Ribbon walkthrough: fixture loading, exact context groups/five separators and release-only opening, context/ribbon/shortcut clipboard actions, format toggles, alignment, installed font/size changes and colors through both dialog paths, images with cancellation/Undo/Redo, hyperlink edit/activation/all removal paths, read-only commands and shortcuts, all eight styles/reapplication, sample entries, group expansion, private persistence, RTF/HTML and palette retention. The selected range was (0,0)–(0,5); Select All reached (5,29) in the original fixture. Exports retained four images, the final URL, Deleted style and `NativeExport中😀`; RTF also round-tripped through `textutil`. Evidence: `native-remote-doc-checks.json` and `native-remote-final.*`.
- Native synthetic Escape did not dismiss the document's nonactivating context popup; clicking the main-window corner did, preserving the range. The scrolled viewport-edge popup stayed within the renderer. Current native width exposed the inline gallery and collapsed Edit/Alignment groups. Main-window wide/narrow desktop resizing remained unavailable; GacJS separately exercised both gallery presentations.
- Remote Layout passed all four vertical pages, Up/Down selection, five-pixel header/button spacing and Default/Ember/Aurora/Default refresh. `NativeEasy中😀`, Right check and Second choice survived every palette. Twelve Alt access labels appeared in the native renderer DOM and disappeared after release/Escape. This is generated input and renderer-data evidence, not physical keyboard delivery.
- Remote responsive layout passed nine transitions through 240/350/440/680-pixel widths, retaining Vertigo selection and returning rows from 106 to 27 pixels. All 24 films/directors were collected in each appearance. Eight independent accounts, selected-menu arrow movement, icon-only scrolling, 680×220/520 height changes and independent movie/account scrolling passed. Native renderer data showed eight centered, unstretched account images; the corresponding assets are 32×32. OK, Cancel, title close and a changed-palette opening restored owner input without accumulating windows. Evidence: `native-remote-responsive-*.json`.
- Remote initial, replacement and takeover renderers each passed both local shortcuts plus 40 button/double-click and 32 wheel cases. Shortcut and mouse-result labels used the same font/color. Replacement/takeover retained Search, document and Layout state. The displaced takeover renderer exited 0; final queued close ended Core and the current renderer with exit 0.
- Raw Clock had one visible renderer element and changing Core-authored HH:mm:ss data before/after tab changes, palette, replacement and takeover. Native screenshot capture failed with `could not create image from window`; hand pixels and desktop resizing remain unverified. Browser pixel/canvas tests and native provider fixtures are separate evidence.
- A fresh System Events query found the owned native renderer with zero accessible windows. Physical keyboard/mouse, native IME and OS-global hotkey delivery remain unverified. Generated renderer IO does not establish those paths. Evidence: `native-remote-desktop-access.txt`.

## Issues Found and Fix

- Responsive movie rows retained detailed measured heights after shrinking. `<GacUI repo>/Test/Resources/App/FullControlTest/EasyLayoutResponsiveWindow.xml` now replaces the arranger on level changes, resetting measurements while retaining selection. KnowledgeBase guidance distinguishes this from palette refresh, which intentionally preserves measurements. Rebuilt local hosted and remote apps passed repeated grow/shrink cycles.
- Hyperlink replacement/removal across separately formatted runs could retain nested old links. The shared document model now removes the selected links, preserves unselected fragments and clears nested links in existing documents. Rebuilt local and remote editor checks passed; model/hover regressions passed.
- RTF Unicode export now writes signed UTF-16 units instead of platform `wchar_t` values. The native remote export retained supplementary Unicode through macOS `textutil`.

All owned native test applications and Core/host processes were exited or stopped after their checks. The TUI matrix records its independent terminal verification and cleanup.

Final required `import.sh`, `syncProj.sh` and `build.sh` repetition succeeded. All ten changed imported/generated files are byte-for-byte identical to the versions used in live checks; no additional source changes appeared. Evidence: `import-at-finish.log`, `sync-at-finish.log`, `build-at-finish.log` and `final-sync-audit.json`.
