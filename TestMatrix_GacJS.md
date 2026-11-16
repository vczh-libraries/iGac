# Test Matrix Card 2026-11-16 08:19:48 PST

## Test Matrix

Current execution of `<GacUI repo>/.github/Jobs/job.rpXPlat.prompt.md`; historical results are not current passes. Evidence is retained in `<iGac repo>/build/rpXPlat-20261116/`.

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | 08:29:16 PST |
| [macOS][`/FCT`][`/MiniHttp`] | 11:03:42 PST (fixed) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | 08:29:38 PST |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<command>`] | 08:30:34 PST |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | 08:31:00 PST |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | 08:31:23 PST |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over stdio `/Cli:<command>`] | 08:31:56 PST |
| Build / resource generation / import / sync | 10:53:21 PST |
| Portable unit tests | 10:53:50 PST; 279 passed |

## Observations and Limitations

Verification used Playwright WebKit 26.0 on macOS 26.5.2 arm64. Windows-only E2E skips do not establish live browser coverage. No Windows, Linux or Wasm application run is claimed.

- RPT passed normal controls, exact shortcut labels and local dialogs, grid add/clear, document modal, renderer replacement/takeover, detached-page input rejection, queued close and the exact Core-authored fatal overlay. Each renderer passed 100 button/movement/wheel cases, including modifier payloads, double-clicks and Mouse4/Mouse5 history suppression.
- All five RVM host modes passed RPC, replacement/takeover, applicable second-host rejection, normal shutdown, idle-next-call loss and blocked-delivery loss. Both stdio commands used paths containing spaces; the Node command included `--no-warnings`. Core-authored fatal errors arrived once. Blocked network loss completed around five seconds; stdio around 55 ms. Evidence: `rvm-*.json` in the run directory.
- Final import, code generation and build succeeded. Root `yarn test --concurrency 1` passed 279 tests in 11 packages, including the new mouse-capture regression. The initial missing pinned Firefox prerequisite was installed using Node 22 after the Node 26 installer stalled; the actual suite used the normal Node 26 environment. Logs: `gacjs-test-mouse-capture.log` and `gacjs-build-mouse-capture.log`.
- Live FCT supplemental editor/clock/replacement tests passed 47/47. WebKit DOM pointer tests passed Touching, TouchingList and ordinary/document touch, including momentum; Chromium additionally passed real browser capture loss and outside-surface touch movement. The imported observer required an explicit End-event barrier when reused over HTTP. Logs: `webkit-portable-supplement.log`, `webkit-touch.log`, `chromium-touch.log` and `chromium-touch-retry.log`.
- Ribbon passed fixture loading, context/ribbon/shortcut clipboard actions, formatting, colors, alignment, hyperlink edit/activation/all removal paths, read-only commands and mode shortcuts, eight styles at wide/narrow sizes, sample items, group expansion, private persistence, RTF/HTML exports and palette retention. The browser font picker exposes only its configured Segoe UI family; size changes and cancellation passed, while unsupported-family typing was correctly rejected.
- Toolstrip repeated applicable commands with DOM point input: short/long presses, reversed/end-point selection, blank-space equivalence to mouse clicks, scrolling with unchanged range, and context menus retained through Down/Cancel/scroll. Six endpoint cases and phase-by-phase popup evidence are retained. Toolbar and Object image/link commands, cancellation, Undo/Redo, read-only modes, private persistence and exports passed. Physical touch remains distinct from this injection.
- Responsive layout passed 240/350/440/680-pixel widths and reverse cycles: rows returned from 106 to 27 pixels and Vertigo remained selected. All 24 films/directors were collected in each appearance; all eight accounts, selection-arrow movement, independent scrolling, 680×220/520 layouts and natural 32×32 account images passed. Equal-width footer buttons remained reachable. OK, Cancel, title close and a changed-palette opening passed.
- Five rapid outside-release attempts passed after the fix, with release preceding Core's capture request. Outside title drag, subsequent ordinary resize and close also passed. Evidence: `browser-fast-capture-fixed.json` and `browser-final-modal-capture-closes.json`.
- FCT initial and replacement renderers each passed both local shortcuts and 100 mouse cases. Raw Clock had one canvas, changing Core data and corresponding changing pixels before/after tab changes, resize, palette and replacement; backing dimensions matched bounds/DPR. The old painter stopped after replacement. Force Exit ended Core normally with exit 0.
- An owned headful WebKit window was attempted for interactive IME/UIA coverage. A final System Events query found the Playwright process but zero accessible windows. Actual candidate selection/cancellation, physical software-keyboard appearance, physical input and OS-global hotkeys remain unavailable. Direct Unicode, automated composition and DOM touch are separate coverage. Evidence: `browser-interactive-ime-access-final.json`. The owned headful browser was closed.

## Issues Found and Fix

- Rapid outside mouse release could arrive before `IORequireCapture`, leaving a modal resize active. It reproduced twice. `<GacJS repo>/Gaclib/gaclib/renderer/src/GacUIRendererImpl.ts` now acquires browser pointer capture on mouse press and releases owned capture during disposal. The new real-browser test failed on the old implementation and passed after the fix; five live WebKit attempts also passed. The shared SOP now includes this rapid-release case.
- Responsive rows retained their detailed height after shrinking. `<GacUI repo>/Test/Resources/App/FullControlTest/EasyLayoutResponsiveWindow.xml` now replaces the arranger on level changes. Selection is retained and measurements reset; repeated live grow/shrink cycles passed.
- Repeated hyperlink edits over separately formatted runs left nested old links. The shared document model now removes the selected links while preserving unselected fragments and clears pre-existing nested links. Final GUI edits retained only the chosen URL, Preview activated it, and all removal paths preserved text.
- RTF exported platform `wchar_t` values instead of signed UTF-16 units. The shared exporter now writes signed units, including surrogate pairs. The final browser export round-tripped `BrowserExport中😀` through `textutil`, with formatting and embedded images retained.

All observed product failures above were fixed. Desktop and physical-input limitations remain explicitly unverified.

A final RPT smoke run on the fixed renderer repeated both local shortcuts and 100 mouse cases, then Force Exit returned 0 without page errors. Evidence: `browser-final-rpt-smoke.json`.

Rebased GacUI onto concurrent Linux verification commits. Their release refresh was already present in the tested CodePack output; production source/release text stayed unchanged. Their touch expectation now matches the short/long-press behavior verified live above. Evidence: `rebase-audit.json`.
