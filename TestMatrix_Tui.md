# Test Matrix Card 2026-10-22T00:41:59.196Z

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS 26.5.2 arm64; Test_TuiControlTest; iGac 5eee7d0 plus this change; official build.sh |
| Terminal name / version / profile / viewport sizes | Apple Terminal 2.15, 120×40; Kitty 0.48.2, default configuration, 120×40 and 80×25 |
| Input methods / desktop availability | Desktop available; generated Quartz/System Events input, Kitty test-key commands, SGR mouse replay, cell-buffer captures and macOS clipboard |

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 2026-10-22T01:25:35.257Z |
| Unit tests |  |
| Platform launch and terminal/input capabilities |  |
| Startup, platform services and teardown |  |
| Follow-up regression checks |  |
| List / TextList |  |
| List / ListView |  |
| List / TreeView |  |
| List / BindableDataGrid |  |
| Refresh List / TextList |  |
| Refresh List / BindableTextList |  |
| Refresh List / ListView |  |
| Refresh List / BindableListView |  |
| Refresh List / TreeView |  |
| Refresh List / BindableTreeView |  |
| Refresh List / BindableDataGrid |  |
| Layout / Repeat / RepeatStack |  |
| Layout / Repeat / RepeatFlow |  |
| Layout / Repeat / SharedSize (RepeatFlow) |  |
| Layout / Repeat / SharedSize (TextList) |  |
| Layout / Responsive |  |
| Control / Document Editor (Toolstrip) |  |
| Control / TextBox / TextBox |  |
| Control / TextBox / TextBox (No Tab) |  |
| Control / TextBox / Document |  |
| Control / TextBox / Document (No Tab) |  |
| Control / Embedded Controls |  |
| Misc / Localization |  |
| Compact dialog and form layout checks |  |
| Misc / Dialogs / MessageDialog |  |
| Misc / Dialogs / ColorDialog |  |
| Misc / Dialogs / FontDialog |  |
| Misc / Dialogs / Open/Save FileDialog |  |
| Misc / DatePicker |  |
| Window Manager |  |
| Live palette and clipping regression |  |
| Exit |  |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | 2026-10-22T01:30:58.213Z |

## Observations and Limitations

This run has broad page coverage but does not claim the complete TUI SOP. Behavior rows remain blank where some operations were not observed. Evidence is in `<iGac repo>/build/touch-step4/tui-*.txt`, with terminal color runs in `<iGac repo>/build/touch-step4/tui-palette-*.ansi`.

| Area | Observed in this run |
| --- | --- |
| Lists | Two-pane additions/removals, continuing counter, check/radio styles, source rotation, six ListView requests with effective Detail, four tree roots in both panes, all five grid editors with source-rotation retention, grid sort and default date filters |
| Refresh lists | All seven pages: check/read agreement, name/title mappings, targeted mutations, four-step data/header collection cycles and requested views; tree parent/child mutation |
| Repeat / responsive layout | All four Repeat models ran clear/reset/add/removal/counter sequences; responsive View/Stack/Group reached both boundaries and retained an edited marker |
| Documents / text | Clipboard copy/paste with pbpaste, undo/redo, independent markers in all four TextBox leaves, CJK/supplementary input, Tab behavior and font-size requests; embedded combo and exact RIGHT NOW dialog |
| Localization / dialogs | English/Chinese resource strings; all message button sets, outputs, default positions and icons; RGB 12/34/56 accept/reopen/cancel; font effects and nested color accept/reopen/cancel |
| Files / dates | Real fixture enumeration and selection, missing-file validation, default extension, overwrite cancel/accept without file mutation; independent DP/DC dates, leap February and 80×25 resizing |
| Windows / palette | Child/grandchild overlap, movement and close; all six palette choices at 120×40, 80×25 and restored size; local shortcuts and generated OS Carbon F8 |
| Shutdown | Four canceled Hide/Close paths, then all six normal Hide/Close/Stop paths on fresh runs; initial 100×30 and 80×25 layouts, exit status 0 and usable shell after each |

Uncompleted SOP operations include exhaustive grid filter bounds, selection/recycling combinations, rich-document format/link/image commands, all localized and compact dialog variants, full file-option validation, frame-option combinations, live-popup palette refresh, and physical input/displayed-font checks. The shutdown results do not replace the portable provider reentrant-close/listener-removal unit regressions.

Portable TUI unit tests and packaged tutorial runs are outside this port change. The TUI resources regenerate unchanged. Physical keyboard/mouse hardware was not tested. POSIX standalone Alt overlays and SGR Super mouse modifiers remain unavailable. Locale resource strings switch to Chinese; POSIX date/number formatting remains en-US. Custom color palettes and the documented inert file-picker options are not implemented by the shared fake dialog service.

## Issues Found and Fix

## Terminal Comparisons

### Local Alt/Command shortcut

| Field | Observed evidence |
| --- | --- |
| Host / build | macOS 26.5.2, this official build, 120×40 |
| Legacy terminal attempted first | Apple Terminal 2.15, existing default profile |
| Expected result | Ctrl+Alt+Command+Q opens exactly `You pressed Ctrl+Alt+Win+Q!` |
| Legacy result | Generated native Ctrl+Q worked. Ctrl+Alt+Q delivered the Ctrl+Q behavior; Ctrl+Alt+Command+Q produced no application dialog. |
| Kitty retry | Kitty 0.48.2 `send-key ctrl+alt+super+q` and the same System Events generated OS chord both opened the exact intended dialog. Physical hardware input remains unverified. |
| Global registration | System Events generated Ctrl+Shift+Alt+Command+F8 while Finder was active; the TUI displayed exactly `You pressed Ctrl+Shift+Alt+Win+F8!`. |
| Evidence | `<iGac repo>/build/touch-step4/terminal-ctrl-alt-q.txt`, `<iGac repo>/build/touch-step4/terminal-command-q.txt`, `<iGac repo>/build/touch-step4/tui-kitty-command-q.txt`, `<iGac repo>/build/touch-step4/tui-global-f8-native.txt` |


## Step 4 scope

WASM builds, tests and website deployment are excluded by request. Results belong only to this macOS run.

Additional evidence: Kitty delivered the OS-generated local Command chord in `<iGac repo>/build/touch-step4/tui-kitty-command-native.txt`; 24 left/middle/right SGR button/modifier combinations passed in `<iGac repo>/build/touch-step4/tui-mouse.json`. Window captures confirmed the SkyBlue/Purple selection accents in `<iGac repo>/build/touch-step4/kitty-palette-skyblue.png` and `<iGac repo>/build/touch-step4/kitty-palette-purple.png`. Six fresh normal exit paths returned 0 and restored usable shell input, recorded in `<iGac repo>/build/touch-step4/tui-exits.json`.

All owned test apps exited. The owned Apple Terminal window, Kitty window, browser driver and static server were closed; unrelated terminal windows were preserved.
