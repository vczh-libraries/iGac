# Test Matrix Card 2026-11-04T04:02:01-08:00

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS 26.5.2 arm64; Test_TuiControlTest; iGac 51967a6 plus this run’s fixes; CMake Debug |
| Terminal name / version / profile / viewport sizes | Apple Terminal 2.15 Basic first; Kitty 0.48.2 after shortcut failure; 100×30, 80×25, 120×40 |
| Input methods / desktop availability | Kitty-generated keys, raw CSI/SGR replay, native macOS generated shortcuts, ANSI cell captures, pbcopy/pbpaste; physical devices unverified |

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 2026-11-04T12:22:07.990Z (fixed) |
| Unit tests | 2026-11-04T12:11:28.053Z |
| Platform launch and terminal/input capabilities | 2026-11-04T14:02:37.991Z |
| Startup, platform services and teardown | 2026-11-04T13:47:29.462Z |
| Follow-up regression checks | 2026-11-04T13:21:26.879Z |
| List / TextList | 2026-11-04T12:37:42.618Z |
| List / ListView | 2026-11-04T12:39:17.841Z |
| List / TreeView | 2026-11-04T12:39:52.761Z |
| List / BindableDataGrid | 2026-11-04T13:13:35.117Z |
| Refresh List / TextList | 2026-11-04T12:40:42.843Z |
| Refresh List / BindableTextList | 2026-11-04T12:40:47.205Z |
| Refresh List / ListView | 2026-11-04T12:41:47.775Z |
| Refresh List / BindableListView | 2026-11-04T12:41:59.478Z |
| Refresh List / TreeView | 2026-11-04T12:42:33.254Z |
| Refresh List / BindableTreeView | 2026-11-04T12:42:38.517Z |
| Refresh List / BindableDataGrid | 2026-11-04T12:43:14.264Z |
| Layout / Repeat / RepeatStack | 2026-11-04T12:44:02.830Z |
| Layout / Repeat / RepeatFlow | 2026-11-04T12:44:17.987Z |
| Layout / Repeat / SharedSize (RepeatFlow) | 2026-11-04T12:44:33.161Z |
| Layout / Repeat / SharedSize (TextList) | 2026-11-04T12:44:48.343Z |
| Layout / Responsive | 2026-11-04T12:45:43.804Z |
| Control / Document Editor (Toolstrip) | 2026-11-04T13:24:41.790Z |
| Control / TextBox / TextBox | 2026-11-04T12:46:40.554Z |
| Control / TextBox / TextBox (No Tab) | 2026-11-04T12:46:45.840Z |
| Control / TextBox / Document | 2026-11-04T12:46:51.109Z |
| Control / TextBox / Document (No Tab) | 2026-11-04T12:48:06.520Z |
| Control / Embedded Controls | 2026-11-04T12:49:03.244Z |
| Misc / Localization | 2026-11-04T12:50:57.085Z |
| Compact dialog and form layout checks | 2026-11-04T14:02:37.991Z |
| Misc / Dialogs / MessageDialog | 2026-11-04T12:52:28.818Z |
| Misc / Dialogs / ColorDialog | 2026-11-04T12:54:38.041Z |
| Misc / Dialogs / FontDialog | 2026-11-04T12:56:04.734Z |
| Misc / Dialogs / Open/Save FileDialog | 2026-11-04T13:05:14.488Z |
| Misc / DatePicker | 2026-11-04T13:11:36.549Z |
| Window Manager | 2026-11-04T13:47:29.461Z |
| Live palette and clipping regression | 2026-11-04T13:50:04.025Z |
| Exit | 2026-11-04T14:18:56.579Z |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | 2026-11-04T12:34:47.155Z |

## Observations and Limitations

All applicable sample rows above are complete. Blank packaged-tutorial results are an explicit exclusion: that tutorial was not requested. Local ignored evidence is under `<iGac repo>/_OUTPUT_/rpXPlat-20261104/`. Final `./import.sh`, `./syncProj.sh`, and `./build.sh` succeeded in order; the six final shutdown runs used that rebuilt executable.

| Coverage | Observations and evidence |
| --- | --- |
| Unit tests | Fresh GacUI build; `/C /F:TestTuiProvider.cpp /F:TestControls_EasyLayout.cpp` passed 29/29 cases in 2/2 files. Includes startup geometry, hosted/modal interception, cancellation/reentrant close/listener removal, queued teardown, theme refresh with retained menus/date popups/dialogs, title variants, separator colors, tab geometry, inline objects and clipping. Other GacUI unit files were outside this focused run. |
| Startup / services | Fresh 100×30 and 80×25 starts fit the terminal; 120×40 and compact relayouts passed. External `pbcopy`/`pbpaste`, asynchronous file enumeration, ANSI-observed caret blinking, hosted child/dialog repaint and native Carbon global delivery passed. Before-Show painting and notification ordering were covered by provider tests. `fresh-startup-*.txt`, `tui-caret-blink.json`. |
| TextList / ListView / TreeView | Fresh counters, both removal rules, source rotation, check/radio styles, all six requested views and effective Detail behavior, column resizing, keyboard/scroll endpoints, four tree roots, expansion and selection passed at large/compact sizes. |
| BindableDataGrid | Five CJK records; From-only/To-only/both filters (3/4/2 rows), modified date filter, all five headers' sort cycles, edited name/website/gender/category/birthday and source rotation passed. Text editors retained caret/selection; Up/Down did not alter text. Collapsed/expanded combo navigation and commit paths passed. All 25 cell checks preserved separator glyphs/backgrounds, including intersections/trailing space; the first cell after a separator resized the preceding column. `tui-grid-*.json`. |
| Seven Refresh List pages | Independent add/remove/clear/rotate/mutation paths and column refresh cycles passed. Edited file/grid markers and expanded-tree mutations survived recycling and compact/large layouts. `tui-refresh-*-cycles.json`. |
| Four Repeat pages | Independent counters and complete controller sequences, wrapping/shared widths, selection and scroll retention passed. Twelve surrounding-control checks across 120×40 → 80×25 → 120×40 exercised horizontal/vertical ranges; progress followed only the horizontal tracker. `tui-repeat.json`, `tui-repeat-trackers.json`. |
| Responsive | View four levels, Stack seven and Group four, both boundaries/directions, retained editor marker and viewport changes passed. This is explicit level-button behavior, not an automatic ResponsiveContainer test. |
| Toolstrip document | Exact Unicode marker, edit/copy/cut/paste/delete/undo/redo, eight style toggle observations, four alignments, foreground/background accept/cancel, mode behavior, hyperlink cancel/create/edit/activation/remove, image cancel/insert/select/delete/undo, and all four file picker/callback paths passed. Rich clipboard HTML checked formatting, colors and URLs. A second retained TextBox marker and undo/redo history survived page/palette changes. `tui-document-*.json`, `tui-document-image-*.txt`. |
| Four TextBox/Document leaves | Independent upper/lower/right editors where present, Unicode text, editing, clipboard, undo/redo, requested font-size binding, Tab insertion versus No Tab traversal, scrolling and retained state passed. Literal U+0009 copy and visual columns were checked for empty/a/abc/abcd/CJK/supplementary prefixes at interval four; interval eight, wrapping/alignment/cache geometry were covered by provider tests. `tui-textboxes.json`, `tui-tab-geometry.json`, `tui-three-documents-*.txt`. |
| Embedded controls | Complete four-row table, actual inline combo selection of RemoteProtocolTest, palette/resize retention, one RIGHT NOW dialog and subsequent responsiveness passed. Heading selection copied exactly `RemotingTest_Core.exe`; provider tests cover atomic inline-object boundaries. `tui-embedded-selected-remote.txt`, `tui-embedded-after-palette-80.txt`, `tui-embedded-selection-boundaries.txt`. |
| Localization | All twelve localized strings and six literal dollar signs, retained time, and the POSIX en-US numeric/date-format baseline were checked. |
| Compact forms / MessageDialog | All seven button sets/nine outputs, default-button positions and five icon settings passed. Thirty-six large/compact/restored English/Chinese messages covered one/two/three buttons with/without icons. Actions were centered with one explicit blank row above them; CJK/supplementary wrapping remained readable. `tui-compact-messages.json`. The authored single-line message field removes pasted newlines; explicit multiline/blank-line message behavior is covered by provider tests and live multiline file-validation dialogs. |
| Color / Font dialogs | RGB 12/34/56 accept/reopen and change/cancel retention passed. RGB tracker rows were exactly one cell high, with 0/255 endpoints, keyboard steps and drag checks at all three viewport stages. Simple/full font effects, nested color, accept/cancel and Chinese/compact layouts passed. `tui-rgb-trackers.json`, `tui-rgb-tracker-*.txt`. |
| File dialogs | Controlled alpha/beta text, XML and nested-directory fixtures exercised all six form fields, filters/index, single/multiple selection, default extension, navigation and async enumeration. Empty/missing-file/missing-directory validation, Create and Overwrite cancel/accept, outer cancellation, localized multiline prompts and compact scrolling passed. Fixtures were not overwritten by canceled operations. |
| Independent dates | DP1 2024-02-29, DP2 2025-12-31, DC1 2024-02-28 and DC2 2027-01-01 remained independent across navigation, resize and palette changes. Retained date/year popups remained usable. |
| Window Manager / input | Command labels were correct. Kitty-generated Ctrl+Q and Ctrl+Alt+Command+Q produced the exact literal Win-spelled messages. Native generated Command chord also passed. Carbon F8 activated while Finder had focus and native FCT ran concurrently with its distinct Q chord. SGR replay checked left/middle/right down/up across eight Shift/Alt/Ctrl combinations, movement/double-click and both wheel axes; Super remained 0. Main frame options stayed disabled; enabled child Border/SizeBox/IconVisible/TitleBar toggles, child/grandchild ownership, move/resize/overlap/clipping/close passed at both sizes. `tui-window-mouse.json`, `tui-global-f8-concurrent-fct-native.txt`, `tui-children-*.txt`. |
| Live palette / clipping | Thirty-nine mouse and Tab/Enter selections at 120×40 → 80×25 → 120×40 kept one selected radio and restored SkyBlue. ANSI captures confirmed bold/underlined focus and changed palette colors; a desktop screenshot was inspected. Existing children, editor content/styles/history, grid edits/sort/column width/separators, tree state, dates and embedded combo state survived refresh. Subsequent column resize/recycling and single popup/button activation passed. Clipped windows kept their original edges without invented clip-edge corners. `tui-palettes.json`, `tui-palette-overlap.png`. |
| Exit | The long retained session vetoed all four Hide/Close buttons, advancing each invocation/query once with ready=0, then exited normally. Six fresh runs separately tested direct/queued Hide, direct/queued Close and both Stop buttons after opening/dismissing a dialog. Each Hide/Close run canceled once then accepted. All exited 0, restored persistent termios flags (transient macOS PENDIN treated separately), left the alternate screen and accepted a shell command. Accepted notification order/count is established by the provider regression; the terminal UI disappears before those final counters can be read. `tui-exits.json`, `tui-exit-result-*.json`, `tui-shell-restored.png`. |

Input methods are separate: Kitty remote `send-key` generates terminal key sequences; `send-text`/SGR is byte replay; System Events generates native macOS events; Carbon global activation bypasses terminal input. None establishes physical keyboard/mouse hardware, left/right Command release ordering or mobile touch. ANSI cells establish emitted styles/colors; the inspected Kitty screenshots supplement that evidence without claiming arbitrary terminal font/profile support.

The POSIX backend does not report standalone Alt overlays, SGR Super or the native renderer's extra two mouse buttons. Space-based activation did not complete: a separate probe showed both Kitty-generated and native Space delivered byte `20`, while the documented POSIX decoder emits no KeyUp, which button Space activation requires. Tab/Enter activation passed. This is the existing terminal-input contract, not a newly implemented key-release capability. See `KB_VlppOS_TerminalUserInterface.md`, “Key Events and Production Decoders”; probe: `terminal-key-bytes.json`.

Additional baseline limits: the TUI font remains TuiFont/size 1; requested larger/smaller values do not change terminal glyph height. The fake color service has no custom-color palette. ReadOnlyCheckBox, DereferenceLinks, NetworkButton and AddToRecent are inert options. The four document format callbacks show the named format/path and do not persist files. The showcase does not expose live tab-interval configuration, arbitrary short/empty/CJK child-title editing, or externally queued refresh while a modal blocks its radios; the existing provider regressions exercise these cases. No Windows UIA or physical-device result is implied.

## Issues Found and Fix

The initial official build failed because the macOS popup snapshot used unqualified `Pair`. It now uses `collections::Pair`; the final import/sync/build sequence succeeded. Native modal timer, hosted teardown and ellipsized-caption fixes and their negative/positive regressions are detailed in `TestMatrix_NativeRenderer.md`.

Coordinate, focus and observation errors in temporary harnesses were corrected without product changes: locate the current textbox content row and actual popup option, compute Unicode display-cell positions, restore editor focus before shortcuts, wait for state changes, and inspect the inline combo's selected row rather than matching its text elsewhere in the document. These are not marked as product fixes.

## Terminal Comparisons

### Terminal comparison local Alt/Command shortcut delivery

| Field | Required evidence |
| --- | --- |
| Host / build / configuration | 2026-11-04, macOS 26.5.2 arm64, same CMake Debug TUI build for the legacy attempt and Kitty retry; 120×40. |
| Legacy terminal attempted first | Apple Terminal 2.15, Basic profile. The run did not change Option/Meta settings or key bindings; the saved Basic profile contained no Option/Meta override. |
| Operation and expected result | Window Manager local Ctrl+Q and Ctrl+Alt+Command+Q; native generated chords should open their distinct exact messages. Ctrl+Alt+Q was also used to diagnose Alt delivery. Physical modifier release order was not tested. |
| Legacy result | Ctrl+Q opened `You pressed Ctrl+Q!`. Ctrl+Alt+Q also opened that Ctrl+Q dialog, showing lost Alt. Ctrl+Alt+Command+Q did not open its required dialog. Native events were generated through System Events. The failure is retained. |
| Kitty retry after failure | Kitty 0.48.2, owned test window with remote control enabled and the same build. Kitty-generated keys and a native generated Ctrl+Alt+Command+Q both opened exactly `You pressed Ctrl+Alt+Win+Q!`; dismissal restored normal input. |
| Conclusion | Only Kitty established the tested local Command chord. Native Carbon global F8 passed separately and does not establish legacy-terminal local Command support, SGR Super or standalone Alt overlays. Space release remains unavailable under the POSIX decoder contract. |
| Evidence / cleanup | `terminal-ctrl-q.txt`, `terminal-ctrl-alt-q.txt`, `terminal-command-q.txt`, `tui-kitty-command-key.txt`, `tui-kitty-command-native.txt`. The owned Terminal window and Kitty shell closed after normal application exit; unrelated Terminal window 39 was preserved. The key-probe window exited automatically. |
