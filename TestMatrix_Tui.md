# Test Matrix Card 2026-11-25T10:34:27.920Z

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS 26.5.2 arm64; Test_TuiControlTest built by the official scripts, iGac base bef1d87 with synchronized GacUI 9032411cf; default CMake configuration, VCZH_DEBUG_NO_REFLECTION. |
| Terminal name / version / profile / viewport sizes | Terminal.app 2.15, Basic profile, SFMono-Regular 11; owned windows 115 and 184. Kitty 0.48.2, owned window 158. Main checks at 120×40, 80×25, restored 120×40; fresh startup also at 100×30. |
| Input methods / desktop availability | Interactive foreground PTYs, raw CSI/SGR replay, Kitty send-text, live cell/ANSI capture, and System Events generated OS keys. Unlocked desktop; native screenshots inspected. No human physical-input claim. |

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 2026-11-25T15:34Z (final import → sync → build all exit 0; all 316 generated-file hashes unchanged) |
| Unit tests | 2026-11-25T10:38Z |
| Platform launch and terminal/input capabilities | 2026-11-25T13:46:01.908Z (passed; Terminal.app local Command limitation; Kitty retry passed) |
| Startup, platform services and teardown | 2026-11-25T13:46:01.908Z (passed; unexposed provider cases verified by unit tests) |
| Follow-up regression checks | 2026-11-25T13:32:09.559Z (passed; POSIX input limitations noted) |
| List / TextList | 2026-11-25T11:18Z |
| List / ListView | 2026-11-25T11:33Z |
| List / TreeView | 2026-11-25T11:41Z |
| List / BindableDataGrid | 2026-11-25T13:29:09.158Z (passed) |
| Refresh List / TextList | 2026-11-25T12:08Z |
| Refresh List / BindableTextList | 2026-11-25T12:08Z |
| Refresh List / ListView | 2026-11-25T13:02Z |
| Refresh List / BindableListView | 2026-11-25T13:02Z |
| Refresh List / TreeView | 2026-11-25T11:49:29Z |
| Refresh List / BindableTreeView | 2026-11-25T11:50:12Z |
| Refresh List / BindableDataGrid | 2026-11-25T11:53:35Z |
| Layout / Repeat / RepeatStack | 2026-11-25T12:56:30.123Z (passed) |
| Layout / Repeat / RepeatFlow | 2026-11-25T12:56:30.141Z (passed) |
| Layout / Repeat / SharedSize (RepeatFlow) | 2026-11-25T12:56:30.142Z (passed) |
| Layout / Repeat / SharedSize (TextList) | 2026-11-25T12:56:30.142Z (passed) |
| Layout / Responsive | 2026-11-25T13:12Z (passed) |
| Control / Document Editor (Toolstrip) | 2026-11-25T12:56:30.142Z (passed; native state limitations noted) |
| Control / TextBox / TextBox | 2026-11-25T11:36:48.195Z |
| Control / TextBox / TextBox (No Tab) | 2026-11-25T11:36:48.195Z |
| Control / TextBox / Document | 2026-11-25T11:38:51.981Z |
| Control / TextBox / Document (No Tab) | 2026-11-25T11:41:30.572Z |
| Control / Embedded Controls | 2026-11-25T11:42:36.973Z |
| Misc / Localization | 2026-11-25T11:43:31.604Z |
| Compact dialog and form layout checks | 2026-11-25T13:32:09.560Z (passed) |
| Misc / Dialogs / MessageDialog | 2026-11-25T11:48Z (pass; en-US+zh-CN, 7 sets/16 outputs, 5 icons, 3 defaults, CJK title/multiline, 80x25+120x40 native screenshots) |
| Misc / Dialogs / ColorDialog | 2026-11-25T12:32:27.472Z (passed; typed values and all three tracker drags) |
| Misc / Dialogs / FontDialog | 2026-11-25T11:50Z (pass; en-US+zh-CN accept/reopen/changed-cancel, all four effects with display-cell coordinates, nested color; settled 80x25 screenshot confirms full dialog inside viewport) |
| Misc / Dialogs / Open/Save FileDialog | 2026-11-25T12:40:21.372Z (passed; path selection semantics) |
| Misc / DatePicker | 2026-11-25T11:45:32.560Z |
| Window Manager | 2026-11-25T13:15:12.793Z (passed; terminal input limits noted) |
| Live palette and clipping regression | 2026-11-25T13:46:01.908Z (passed; retained content and undo/redo) |
| Exit | 2026-11-25T13:09:43.898Z (passed) |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | 2026-11-25T13:46:01.908Z (complete; native input limitations preserved) |

## Observations and Limitations

All evidence below is under `<iGac repo>/build/rpXPlat-20261125/`. The full per-action captures remain there; this card consolidates completed checks and supersedes earlier partial progress notes. Timestamps for three Refresh rows were corrected from draft estimates to capture modification times.

- Official import/sync/build passed, including the final ordered run after the native color correction. GacUI UnitTest passed 97/97 files and 2019/2019 cases. After upstream rebase, the targeted TUI provider/showcase/theme regression passed 3/3 files and 35/35 cases. Evidence: `import-resumed.log`, `sync-resumed.log`, `build.log`, `unit-test.log`, `upstream-unit-regression.log`.
- Foreground launch retained terminal input. Unsupported TUI `--hosted`, `--unblock`, and renderer-only `--port` each returned exit 1 with the expected explanation (`tui-invalid-launch-options.json`). Fresh 100×30 and 80×25 first layouts matched the terminal. Hosted windows/dialogs, asynchronous file enumeration, external pbcopy/pbpaste, caret blinking, resizing, clipping and normal restoration passed.
- TextList passed fresh 0–9 and 0–19 datasets, Text/Check/Radio behavior, independent Dummy checks/exclusive radios, exact positional odd/even removal, continuing counter after Clear, two source rotations, selection, scrolling and viewport retention. ListView retained the complete original records in both panes across all six requested views, each intentionally falling back to Detail; source rotation, column resizing, scrolling and compact layout passed. TreeView exercised all four roots and original children in both panes, keyboard/mouse selection, expansion, source rotation and resize. Evidence: `tui-textlist-*`, `tui-listview-*`, `tui-tree*`.
- DataGrid passed five original records, default filter counts 3/4/2/5, changed inclusive date bounds and empty-range behavior, sorting with stable equal-date ties, all five column editors and reopen/retention. Name/Website caret and Shift selection worked; Up/Down left those editors unchanged. Combo boundary/navigation changes did not commit before Enter/mouse. Header drag resized the preceding column, 80-column horizontal scrolling reached Website, and all 25 hovered/selected cells retained complete normal separator backgrounds/intersections. All six fallback views, DataGrid reentry, source rotations and palette refresh retained edits. Evidence: `tui-grid-root-bound-assertions.json`, `tui-grid-editor-keys.json`, `tui-grid-separators.json`, `tui-grid-root-*`, `datagrid-sort-tie-*`.
- All seven Refresh pages passed binding/readback, direct glyph changes, Name/Title mappings and tree mutations. Both ListView variants and BindableDataGrid passed exact DataColumn cycles `[0,1,2] → [1,1,2] → [1,1] → [0,1] → [0,1,2]`, including duplicate projections, and the four header cycles. Main/SubColumn mutations, grid edit persistence, six view requests, scrolling and 120/80/restored geometry passed. Evidence: `refresh-*`, `tui-refresh-*`.
- All four Repeat pages passed 42 fresh-controller assertions: exact odd/even survivors, Clear/Add ten–nineteen, Reset preserving rows, appended zero–nine, 60 long-name items, scrolling to fifty-nine, tab/resize retention. RepeatFlow widths varied; SharedSize widths were equal and shrank back to seven cells after long labels were cleared. SharedSize text labels remained anchored. Horizontal tracker steps 0–10 filled progress 0–99 cells at 120 columns (0–59 at 80); vertical steps 0–5 left progress unchanged. Scroll/tracker drag and Home/End bounds passed at both sizes and after restoration. Evidence: `tui-root-repeat-complete.json`, `tui-root-tracker-steps.json`, `tui-root-repeat-scroll-ranges.json`.
- Responsive View/Stack/Group passed all 4/7/4 levels in both directions with `RESP_AUDIT` retained at 120×40 and 80×25. Evidence: `audit-responsive-*`.
- Toolstrip document coverage included fixture text/two images, command routes for clipboard/selection/undo/redo/modes, all four effects and three alignments, TuiFont sizes, RGB fields/trackers, color cancel/accept, hyperlinks/Preview/removal, image insertion and private/RTF/HTML export. Private overwrite cancel/accept and fresh-process reopen passed. Both browser editors cross-opened the TUI private file with all eight styles and three image payloads unchanged; the inserted 123×456 image decoded to the expected pixels after its original path became unavailable. Evidence: `tui-root-results.json`, `tui-gui-cross-audit.json`, `tui-image-pixel-audit.json`, `tui-root-fresh-process-private-reopen.txt`.
- TextBox, No Tab, Document and Document No Tab preserved all independent originals/Unicode markers through selection replacement, clipboard, undo/redo, scrolling, navigation, font request 1→6→1, and both viewport sizes. Native Terminal-generated Tab inserted one U+0009; pasted tab-X cases with empty/a/abc/abcd/CJK/emoji prefixes reached columns 4/4/4/8/4/4. No Tab pages traversed focus without inserting a tab. A first 65-line wide Unicode paste immediately exposed the final caret without a corrective key/resize. Caret blink at interior/end positions and native display/CJK/emoji clipping were inspected. Evidence: `tui-root-results.json`, `terminal-root-generated-input.jsonl`, `tui-caret-wide-paste.json`, `tui-root-final-native-display.png`.
- Embedded controls retained the four-row table; combo selection changed to RemoteProtocolTest, RIGHT NOW opened the exact Pretend message, and surrounding selection/scroll/wrap passed. Localization en-US→zh-CN→en-US updated all 12 labels and three dollar-containing sentences without changing stored values, and propagated to Dialogs. POSIX date/number formatting intentionally remained en-US. DatePicker retained four independent selections including 2024-02-29 and 2023-12-31→2024-01-01, with year/month navigation, popup dismissal and compact layout. Evidence: `embedded-*`, `localization-*`, `date-*`, `tui-root-results.json`.
- MessageDialog covered seven button sets, 16 exercised results including all nine outputs, five icons and three default positions, English/Chinese title/body, CJK/emoji and multiline content. Color accepted/reopened RGB 12/34/56, reached each tracker endpoint 0/255, and preserved colors on cancel. Font covered four effects, nested color, reopen/cancel and compact full/simple forms. Open/Save covered all six fields/nine options, single/multiple selection, missing/empty/invalid-directory validation, overwrite cancel/accept, PromptCreateFile cancel/accept and zh-CN. A picker returns the selected path; it does not create a file. All dialogs/forms were inspected at 120/80/restored sizes, including repositioning a retained picker by its title bar. Evidence: `native-agent/dialog-*`, `native-agent/file*`, `tui-root-{invalid-directory-validation,create-file-confirmation,create-file-selected-result}.txt`.
- Window Manager child/grandchild move, resize, activation, overlap, clipping, frame toggles and exposed repaint passed. Disabled main frame options stayed unavailable. Raw SGR separately verified delivered Left/Middle/Right down/up, movement/double-click, both wheel axes and modifiers. Mouse4/5 were not delivered, and SGR has no Super bit; these are not passed native-button claims. Local Ctrl+Q and the independent Carbon F8 chord passed through actual OS event delivery; the Terminal/Kitty Command difference is retained below.
- All six palettes passed mouse and Tab/Enter at 120/80/restored sizes with exactly one selected radio and restored SkyBlue. Pink/Emerald/SkyBlue refreshes retained live child/grandchild windows, expanded trees, edited grid state, independent text fields, document text and undo/redo. ANSI cells verified focus bold/underline for buttons, check/radio, combos and tabs, menu hover underline, borderless content/date popups and preserved actual menu borders. Evidence: `tui-palette-mouse-keyboard.json`, `tui-live-palette-retention.json`, `tui-focus-styles.json`, `tui-root-wm-*`.
- All six direct/queued Hide/Close/Stop paths ran in fresh processes after dialog/page interaction and exited 0. Each Hide/Close first canceled with one invocation/query and zero ready notifications, then accepted. Full before/after termios matched; alternate screen, cursor and mouse modes were restored, and a unique shell command succeeded each time. Evidence: `tui-exit-complete.json` and `exit-*` captures.
- Unexposed operations are explicitly covered by provider/showcase unit cases: pre-Show nonpainting, arbitrary SkinItems collection mutation, one-action queued refresh with open popup/dialog, selected identity, explicit tab interval eight, caption variants, main-close interception while a modal is open, reentrant close/listener removal, geometry/cache cases and notification order. These are not claimed as live UI setters. Standalone Alt overlays, key-release-dependent Space activation and SGR Super/extra buttons remain POSIX limitations; Enter activation passed. There is no custom-color palette in the fake color dialog, and TuiFont is the sole TUI family.
- Packaged Win32 tutorial execution was not requested by this macOS job; its row remains blank. Windows/Linux, physical hardware input and a transported native semantic accessibility tree are outside this run.

## Issues Found and Fix

- No TUI application-source defect was established. Initial SGR failures came from stale layout coordinates, counting CJK/supplementary text as one cell, or clicking dialog padding instead of the handle. Fresh display-cell coordinates resolved RGB tracker dragging, filter bounds, grid editing and the child Close hit target.
- A retained file picker appeared clipped after shrinking. Moving the existing dialog into the smaller viewport exposed the complete picker/footer; this was retained position, not minimum-size failure (`native-agent/file3-80-moved.png`).
- Terminal.app AppleScript capture retains stale off-viewport columns after a shrink. Physical-width trimming and native screenshots resolved the capture ambiguity; the Kitty retry remains recorded below.
- An earlier interrupted TUI run and stale shell result were rejected as exit evidence. All six final paths use unique fresh-process exit tags, before/after termios and usable-shell assertions. No forced shutdown is counted as a normal exit.

## Terminal Comparisons

### Terminal comparison local Command shortcut

| Field | Required evidence |
| --- | --- |
| Host / build / configuration | macOS 26.5.2 arm64, same current Test_TuiControlTest build, 120×40. |
| Legacy terminal attempted first | Terminal.app 2.15, Basic, SFMono-Regular 11; current Option/Command profile bindings retained. |
| Operation and expected result | Window Manager; System Events Ctrl+Q and Ctrl+Option+Command+Q; require exact local shortcut dialogs. |
| Legacy result | Ctrl+Q passed. Ctrl+Option+Q delivered the same 0x11 byte as Ctrl+Q; Ctrl+Option+Command+Q delivered no TUI bytes and no requested dialog. |
| Kitty retry after failure | Kitty 0.48.2 with backend-requested keyboard disambiguation; the same OS Ctrl+Option+Command+Q opened exactly You pressed Ctrl+Alt+Win+Q!; dismissal and ordinary input passed. |
| Conclusion | The local Command chord works in the tested Kitty session only. Separately, actual Ctrl+Shift+Option+Command+F8 while hosted FCT had focus reached both background TUIs, proving Carbon delivery independently of terminal bytes. |
| Evidence / cleanup | `<iGac repo>/build/rpXPlat-20261125/tui-root-native-*`, `tui-grid-root-native-*`, and `terminal-root-generated-input.jsonl`. Generated OS events, not human physical input. Owned sessions are closed during final cleanup. |

### Terminal comparison compact cell capture

| Field | Required evidence |
| --- | --- |
| Host / build / configuration | Same macOS build and application; 120×40→80×25→120×40. |
| Legacy terminal attempted first | Terminal.app 2.15, owned window 115, then independent window 184. |
| Operation and expected result | Shrink while viewing list/grid/dialog content; capture exactly the current viewport and inspect complete glyphs/usable controls. |
| Legacy result | AppleScript contents retained old columns beyond 80, making the untrimmed capture unreliable. This was a capture limitation; native screenshots and display-cell trimming later showed usable content. |
| Kitty retry after failure | Kitty 0.48.2 remote screen/ANSI capture and cell-size resize produced bounded 80-column content; list/grid/editor and retained-state checks passed. |
| Conclusion | Both terminal displays were usable for the inspected checks. Kitty supplied reliable bounded captures; Terminal.app's untrimmed AppleScript output must not be used as physical viewport evidence. |
| Evidence / cleanup | `<iGac repo>/build/rpXPlat-20261125/tui-terminal-80.txt`, `tui-listview-kitty-*`, `tui-grid-root-*`, `tui-root-final-native-display.png`, and compact dialog PNGs. Only owned sessions are closed. |
