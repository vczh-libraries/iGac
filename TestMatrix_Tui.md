# Test Matrix Card 2026-10-16T01:06:53.035Z

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS arm64 / Test_TuiControlTest / current master plus task changes / CMake default |
| Terminal name / version / profile / viewport sizes | Apple Terminal 2.15 Basic, 120x40 then 80x24; owned xterm-256color PTY at 100x30, 80x25 and 120x40; Kitty 0.48.2 installed but unavailable for comparison |
| Input methods / desktop availability | Initial Quartz mouse checks; later Accessibility -25211. Remaining input went only to an owned PTY master fd. Physical keyboard/IME/global delivery unverified |

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 2026-10-15 17:40 (passed) |
| Unit tests | GacUI: 94 files, 1,837 cases passed |
| Platform launch and terminal/input capabilities | 2026-10-15 (PTY launch/rejected options passed; native input limits below) |
| Startup, platform services and teardown | 2026-10-15 (PTY 100x30/80x25 startup and six shutdown paths passed) |
| Follow-up regression checks | 2026-10-15 (PTY editing/popup/resize subset exercised; limits below) |
| List / TextList | 2026-10-15 (Native Add/Clear; PTY styles, mutations and retention passed) |
| List / ListView | 2026-10-15 (Native six views/source rotation; effective Detail retained) |
| List / TreeView | 2026-10-15 (Native all roots/children and source rotation passed) |
| List / BindableDataGrid | 2026-10-15 (PTY five editors, default filters, sorts, views and retention passed) |
| Refresh List / TextList | 2026-10-15 (Native Check/Uncheck/Read passed) |
| Refresh List / BindableTextList | 2026-10-15 19:01 (PTY mutations passed) |
| Refresh List / ListView | 2026-10-15 19:02 (PTY cycles passed) |
| Refresh List / BindableListView | 2026-10-15 19:02 (PTY cycles passed) |
| Refresh List / TreeView | 2026-10-15 19:01 (PTY mutations passed) |
| Refresh List / BindableTreeView | 2026-10-15 19:01 (PTY mutations passed) |
| Refresh List / BindableDataGrid | 2026-10-15 19:02 (PTY cycles passed) |
| Layout / Repeat / RepeatStack | 2026-10-15 19:01:41 (PTY controller sequence passed) |
| Layout / Repeat / RepeatFlow | 2026-10-15 19:01:41 (PTY controller sequence passed) |
| Layout / Repeat / SharedSize (RepeatFlow) | 2026-10-15 19:01:41 (PTY controller sequence passed) |
| Layout / Repeat / SharedSize (TextList) | 2026-10-15 19:01:41 (PTY controller sequence passed) |
| Layout / Responsive | 2026-10-15 19:03:02 (PTY levels/state/resize passed) |
| Control / Document Editor (Toolstrip) | 2026-10-15 (PTY editing, objects, alignment, modes and format dialogs passed) |
| Control / TextBox / TextBox | 2026-10-15 19:17:44 (PTY editing, Tab behavior and retention) |
| Control / TextBox / TextBox (No Tab) | 2026-10-15 19:17:44 (PTY editing, Tab behavior and retention) |
| Control / TextBox / Document | 2026-10-15 19:17:44 (PTY editing, Tab behavior and retention) |
| Control / TextBox / Document (No Tab) | 2026-10-15 19:17:44 (PTY editing, Tab behavior and retention) |
| Control / Embedded Controls | 2026-10-15 19:17:44 (PTY combo and modal passed) |
| Misc / Localization | 2026-10-15 19:17:44 (PTY translated labels; POSIX format limitation) |
| Compact dialog and form layout checks | 2026-10-15 (PTY compact fields, popups and 80x25/120x40 resize exercised) |
| Misc / Dialogs / MessageDialog | 2026-10-15 19:17:44 (PTY button/output/icon/default cases passed) |
| Misc / Dialogs / ColorDialog | 2026-10-15 19:21:09 (PTY RGB accept/reopen/cancel/resize passed) |
| Misc / Dialogs / FontDialog | 2026-10-15 19:21:09 (PTY simple/effects/nested color/retention/resize passed) |
| Misc / Dialogs / Open/Save FileDialog | 2026-10-15 19:29:22 (PTY selection/filter/path validation/confirmations/resize) |
| Misc / DatePicker | 2026-10-15 19:29:22 (PTY leap day/four independent values/retention/resize) |
| Window Manager | 2026-10-15 (PTY local shortcuts, three buttons, wheels and child windows passed; OS checks unavailable) |
| Live palette and clipping regression | 2026-10-15 (PTY six palettes, resize, retained edits and keyboard radio passed) |
| Exit | 2026-10-15 (All four canceled requests; six fresh normal exits and shell restoration passed) |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | 2026-10-15 (Apple Terminal partial native checks; Kitty/physical keys unavailable) |

## Observations and Limitations

Packaged tutorial verification was not requested; its row remains blank. Wasm is excluded by request. Results distinguish actual terminal mouse input from SGR/CSI/UTF-8 replay and decoded terminal output. They do not establish physical keyboard delivery or displayed font/color fidelity.

Apple Terminal rendered the fresh showcase and delivered a Quartz mouse click that added exact 0–9 to both TextLists, followed by Clear. Native ListView checks requested all six views, retained effective Detail and both datasets, and rotated only the right source away/back. Native TreeView checks expanded/collapsed all four roots in both panes, including all six Blue children, and restored the rotated source. Native Refresh TextList Check/Uncheck/Read returned true/false correctly.

The initial owned Terminal run was stopped after checking its window ID, tty and process ownership. Accessibility subsequently returned -25211. After the user's window-targeting warning, desktop input helpers were disabled; remaining input targeted only the test PTY master fd. No generic desktop typing was used for the remaining checks.

PTY TextList checks covered fresh positional removals (odd-caption leaves 1/3/5/7/9; even-caption leaves 0/2/4/6/8), two additions producing 0–19, all three styles, Dummy checks/radios, source rotation and counter continuation after Clear. Refresh bindable text/tree pages retained changed names/titles and check state. Refresh list/grid pages completed all four DataColumn states, column/subcolumn cycles and requested-view fallback; returning to DataGrid retained an edited File value. Original BindableDataGrid retained all five appropriate editor changes, including CJK/supplementary Name text, Gender, Category, Birthday and Website, through source rotation, six Detail fallbacks, DataGrid restoration and viewport changes. Default From/To/both filters produced 3/4/2 rows, with the expected two names; all five headers completed their three sort states.

All four Repeat pages completed Clear/Reset/Add, both positional-removal sequences, continuing counters and 80x25/120x40 resizing. Responsive View/Stack/Group completed their 4/7/4 levels and boundaries while retaining a unique editor marker through tab changes and resizing.

The Toolstrip editor retained its marker and history through text replacement, cut/copy/paste, undo/redo, four style toggles, color-dialog cancellation, alignment changes and Preview/Selectable/Editable behavior. Hyperlink activation displayed the exact URL; canceling an edit preserved it, and removal completed. Image selection cancellation, insertion of the textual 16x16 image object, cut/delete and undo/redo passed. All four format callbacks displayed their explanatory not-implemented messages with the selected path/format and created no output files. Long explanatory messages required widening to 240 columns to inspect the complete text. Persistence is an existing unimplemented sample behavior.

All four TextBox/Document leaves retained independent markers, CJK/supplementary text, original poem/title content, undo/redo and font-size changes. Tab-enabled pages inserted TAB; No Tab pages traversed focus. Embedded Controls retained its combo selection and displayed/dismissed the exact RIGHT NOW modal. These are terminal-byte tests, not physical IME delivery or exhaustive live tab-stop geometry checks.

Localization switched en-US/zh-CN/en-US labels and all three dollar sentences while retaining the stored time. POSIX date/number formatting remained en-US, matching the existing locale-service limitation. MessageDialog exercised every button set/output, all icons and second/third defaults. ColorDialog accepted/reopened RGB 12/34/56 as #0C2238 and preserved it on Cancel. FontDialog exercised simple/effects forms, all four effects, nested color acceptance, reopen/cancel and resize. The fake color service has no custom-color persistence. ReadOnlyCheckBox, DereferenceLinks, NetworkButton and AddToRecent remain inert fake-file options.

File dialogs selected one and multiple fixture files, changed text/XML filters, navigated a subdirectory, validated a missing file, appended a default extension, and exercised both Cancel/OK create and overwrite confirmations without creating files. Picker Cancel preserved the previous selection. Compact forms and open dialogs were resized to 80x25 and restored. DatePicker selected leap day 2024-02-29 and independent values in all four controls, retaining them across tab changes and resize.

Window Manager delivered exact Ctrl+Q and CSI-u Ctrl+Alt+Super+Q dialogs. SGR replay checked Left/Middle/Right down/up, double-click/movement and both wheel axes across eight Shift/Alt/Ctrl combinations. The POSIX decoder rejects Mouse4/Mouse5 and SGR has no Super bit; these inputs are not passed. Child and grandchild windows were overlapped, moved, resized, clipped at 80x25, restored and closed. Enabled Border/SizeBox/IconVisible/TitleBar options toggled; unavailable options remained unchanged. Local keyboard payloads do not verify Carbon global registration or native left/right Command delivery.

All six palettes and return to SkyBlue were checked with exactly one selected radio at 120x40, 80x25 and restored 120x40. Shift+Tab plus Enter selected the previous radio. Retained document/image content, undo/redo and edited grid data survived palette changes. Full physical color-state comparison, every keyboard-only palette permutation, arbitrary caption editing, queued refresh inside a modal, cross-application clipboard transfer and native global shortcuts remain unverified in this environment.

Exit checks first canceled all four Hide/Close buttons and observed invocation/query counts 1 through 4 with ready=0. Each accepted direct/queued Hide/Close and both Stop buttons then ran on a fresh PTY, after opening/dismissing a hosted dialog and changing pages. All six exited 0. Captures confirmed reset/mouse-disable/alternate-buffer/cursor-restoration sequences, restored persistent termios fields, and a shell read/echo of an exact input marker. Fresh startup at 100x30 and 80x25 was captured before resizing. Accepted notification ordering, reentrancy and listener-removal behavior are additionally covered by the passing GacUI provider regressions; the last notification need not be painted before exit.

## Issues Found and Fix

No new TUI product fix was required. Harness corrections included waiting for rendered state after resize/palette changes, choosing the actual short button caption instead of an underlying title, dismissing a grid editor by selecting another cell, and using Enter for POSIX radio activation. The hyperlink dialog intentionally starts empty on every invocation; retained URLs were checked by activation.

A strict termios comparison initially differed only in macOS's transient PENDIN flag. An independent PTY raw-mode/restore probe reproduced that kernel behavior without GacUI. All persistent termios fields matched; normal shell input and output were verified separately. The comparison excludes only PENDIN.

## Terminal Comparisons

Apple Terminal's native mouse coverage and the owned PTY's decoded-output/input-byte coverage are separate. Accessibility denial prevented a physical Command/global-key retry and the requested legacy-terminal/Kitty comparison. No Kitty or physical keyboard success is claimed. Temporary PTY logs, decoded captures and exit results are retained locally under <iGac repo>/build/task4; they are ignored diagnostic artifacts, not committed source.
