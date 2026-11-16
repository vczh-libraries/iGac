# Test Matrix Card 2026-11-16 08:19:48 PST

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS 26.5.2 arm64; Test_TuiControlTest, current master with this run’s fixes; official build.sh defaults, CMAKE_BUILD_TYPE unset. |
| Terminal name / version / profile / viewport sizes | Terminal.app 2.15 Basic, 120×40/80×25; isolated Kitty 0.48.2, 120×40/80×25 and restored 120×40. |
| Input methods / desktop availability | Locked desktop; live terminal capture, PTY byte replay and Kitty-generated keys. Physical keyboard/mouse, IME, global OS delivery and displayed profile colors are unavailable. |

## Test Matrix

Current execution of `<GacUI repo>/.github/Jobs/job.rpXPlat.prompt.md`; historical results are not current passes. Evidence is retained in `<iGac repo>/build/rpXPlat-20261116/`.

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 11:42:46 PST |
| Unit tests | 10:03:47 PST (fixed) |
| Platform launch and terminal/input capabilities | Pass with physical-input limitations |
| Startup, platform services and teardown | 10:29:55 PST |
| Follow-up regression checks | Pass: terminal capture and provider regressions |
| List / TextList | 08:40:55 PST |
| List / ListView | 08:46:26 PST |
| List / TreeView | 08:45:23 PST |
| List / BindableDataGrid | 08:51:31 PST |
| Refresh List / TextList | 08:52:21 PST |
| Refresh List / BindableTextList | 08:52:36 PST |
| Refresh List / ListView | 08:53:29 PST |
| Refresh List / BindableListView | 08:53:49 PST |
| Refresh List / TreeView | 08:55:11 PST |
| Refresh List / BindableTreeView | 08:55:25 PST |
| Refresh List / BindableDataGrid | 08:55:05 PST |
| Layout / Repeat / RepeatStack | 08:56:56 PST |
| Layout / Repeat / RepeatFlow | 08:57:16 PST |
| Layout / Repeat / SharedSize (RepeatFlow) | 08:57:36 PST |
| Layout / Repeat / SharedSize (TextList) | 08:57:56 PST |
| Layout / Responsive | 08:59:54 PST |
| Control / Document Editor (Toolstrip) | 10:26:56 PST (fixed) |
| Control / TextBox / TextBox | 09:20:57 PST |
| Control / TextBox / TextBox (No Tab) | 09:21:43 PST |
| Control / TextBox / Document | 09:24:09 PST |
| Control / TextBox / Document (No Tab) | 09:25:09 PST |
| Control / Embedded Controls | 09:27:24 PST |
| Misc / Localization | 09:27:51 PST |
| Compact dialog and form layout checks | 10:29:55 PST |
| Misc / Dialogs / MessageDialog | 09:33:30 PST |
| Misc / Dialogs / ColorDialog | 09:39:48 PST |
| Misc / Dialogs / FontDialog | 09:41:37 PST |
| Misc / Dialogs / Open/Save FileDialog | 09:49:15 PST |
| Misc / DatePicker | 09:52:47 PST |
| Window Manager | 10:04:56 PST |
| Live palette and clipping regression | 10:12:37 PST |
| Exit | 10:29:55 PST |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | Completed; compact capture only reliable in Kitty |

## Observations and Limitations

Packaged Win32 tutorial is outside this macOS job. Native input, terminal-generated keys, byte replay and displayed appearance are recorded separately.

- The initial GacUI unit suite passed 97/97 files and 2008/2008 cases, including portable TUI provider regressions; log: `<iGac repo>/build/rpXPlat-20261116/unit-test.log`. The final suite after all fixes passed 2012/2012 cases as recorded below.

- Apple Terminal.app Basic profile is the initial terminal (owned window 125, 120×40). The host session is locked. Native physical chord delivery, IME and displayed profile appearance cannot be established; live Terminal cell contents and PTY byte replay are recorded separately.

- Terminal.app resizing from 120×40 to 80×25 reports the new dimensions and relayouts the app, but its AppleScript visible-content capture retains old right-hand columns (120 cells on 24 of the 25 rows). This prevents reliable compact-layout inspection through that capture. Evidence: terminal-terminal-resize-stale-cells.txt. Retry the same build in Kitty, preserving this legacy capture limitation.

- Terminal.app 2.15 completed TextList and TreeView replay, all six ListView requests resolved to Detail, source rotation/scrolling worked, and queued Close returned 0 with exact termios restoration and usable shell input. Compact capture is retried in Kitty 0.48.2.

- Kitty 0.48.2 correctly captures the same ListView at 80×25 and after restoring 120×40. This resolves compact inspection for subsequent replay without replacing the recorded Terminal.app capture limitation. Kitty remote-control generated keys remain separate from physical input.

- Initial RTF export of TUI20261116中😀 produced \u128512; macOS textutil decoded the supplementary character as U+F600. Private and HTML exports preserved it. Reproduction files: tui-document.rtf and tui-document-rtf-decoded.txt. The upstream fix and final successful round-trip are recorded below.

- After the RTF fix, GacUI passed 97/97 files and 2009/2009 cases. The focused document regression first failed on the old exporter and then passed (136/136 document cases). Logs: rtf-before-fix.log, rtf-after-fix.log, unit-test-after-rtf.log. The shared exporter now emits signed UTF-16 units rather than platform wchar_t values.

- Cross-opened tui-image-document.bin in the GUI ribbon editor. Its decoded 123×456 image and text/styles survived the missing source path. Initial serialized inspection exposed nested old/new hyperlinks after repeated edits over per-character runs; Preview activated the old URL. Evidence: tui-hyperlink-nesting.xml. The upstream fix and final live verification are recorded below.

- Initial Preview mode also allowed Edit Hyperlink and exported the new readonly-mutation URL. Evidence: tui-preview-mutation.html and kitty-document-preview-mutation captures. TUI lacked the editable-mode guard already present in the GUI showcase; the fix adds that guard and a focused resource regression.

- Color dialog accepted RGB 12,34,56, reopened with those values, and preserved them on cancel in both locales. Red tracker changed 12→13 by keyboard, reached 0/255 with Home/End and 255 by drag. Compact dialogs opened at 80×25 fit; a dialog retained its position when the terminal shrank and was moved into view. TUI exposes RGB controls, without the native custom-color grid. ANSI captures retain color information; physical appearance is unverified.

- Open/Save pickers passed all six configured fields, Text/Binary filters, multiple selection, subfolder navigation, empty/missing/invalid paths, create and overwrite cancel/accept, default extension and outer cancellation. Returned paths matched exactly; no file-content write is implied. All nine option switches were exercised; ReadOnly/Network/Dereference/AddToRecent expose no additional hosted TUI controls. At 80×25 the form scrolls to its actions and both pickers plus Chinese multiline validation prompts fit.

- The regenerated TUI read-only regression passed (1/1 showcase case). An intermediate full run reported 2009/2010: Overlap_Remove_DoesNotLeaveStaleActive expected an old enclosing hyperlink after replacement. The final model preserves unselected fragments and removes selected links; the hover expectation and six resulting snapshot files were updated to match that behavior.

- After preserving unselected hyperlink fragments and clearing nested links from existing documents, focused document/hover tests passed 157/157 and the full suite passed 97/97 files, 2012/2012 cases. Logs: hyperlink-complete-after-fix.log and unit-test-final-retry.log.

- Window Manager passed Ctrl+Q and Ctrl+Alt+Win+Q through byte replay; Kitty-generated Ctrl+Alt+Super+Q also reached its exact dialog. Three-button SGR replay covered 24 modifier combinations and 32 two-axis wheel cases; mouse Alt readout agreed. SGR supplies no Super modifier or verified extra-button acquisition. Child/grandchild move, overlap, resize, clipping, close and enabled frame options passed; disabled frame options remained unchanged. Carbon-backed shortcut labels were valid during concurrent native FCT/TUI startup, but physical/global OS delivery remains unverified. Separate registration probes cannot establish another process's registration ownership.

- All six palettes passed mouse and Tab/Enter selection at 120×40, 80×25 and restored 120×40 with one selected radio. Queued refresh plus Ctrl+Q kept the dialog usable. Independent text/document undo and redo survived refresh; edited/sorted/resized grid state and expanded tree persisted. Child/grandchild clipping and repaint passed. Arbitrary SkinItems/action-count and provider shutdown checks are covered by the 2012-case suite; terminal ANSI capture is distinct from physical displayed colors.

- Final rebuilt live checks passed: repeated hyperlink edits keep only the latest URL; Preview and Selectable reject hyperlink mutation and export identical content; removal preserves text. FinalTUI中😀 exports as signed UTF-16 and round-trips through textutil. Existing nested links were cleared; GUI ribbon/toolstrip private files reopened with the embedded 123×456 image despite its missing original path. Load/save cancellation preserved content.

- Final build started fresh at 100×30 and 80×25 with matching live geometry/title. All four direct/queued Hide/Close paths passed cancellation then acceptance on fresh runs; cancellation advanced invocation/query once with ready zero. Both Stop paths also exited 0 after dialog/page/palette activity. All six runs restored exact termios and accepted shell input. Accepted-request notification counts, before-Show behavior, caption variants and interval-eight TAB geometry have deterministic provider coverage; synchronous final close readouts are not separately visible after loop exit. Evidence: tui-final-exits.json and termios-*-before/after.txt.

- A final fresh-run follow-up passed private-document overwrite cancellation/acceptance and literal TAB typing/copy. With interval four, X appeared at columns 4,4,4,8 for tab-X/a-tab-X/abc-tab-X/abcd-tab-X and column 4 after both 中 and 😀. The queued Stop restored termios and shell input again.

## Issues Found and Fix

- RTF Unicode export used platform `wchar_t` values. On macOS, supplementary characters became a single value above 16 bits; `textutil` decoded the wrong character. `<GacUI repo>/Source/Resources/GuiDocumentClipboard_RichTextFormat.cpp` now writes signed UTF-16 code units. A regression covers BMP boundaries and a surrogate pair.
- Replacing or removing a hyperlink across separately formatted runs could leave nested old links. `<GacUI repo>/Source/Resources/GuiDocument_Edit.cpp` now splits intersecting links and removes the selected range, preserving links outside it. The removal visitor also clears nested links from existing documents. Three model regressions and the existing hover scenario cover these cases.
- The TUI editor enabled hyperlink commands in Preview/Selectable. `<GacUI repo>/Test/Resources/App/TuiControlTest/DocumentEditorBase.xml` now uses the existing editable-cursor guard; the generated showcase regression checks both commands in all three modes at both terminal sizes.
- The hyperlink and read-only defects are shared model/showcase behavior. The RTF failure depends on the platform character width. Final live rechecks and normal exits passed as recorded above.

## Terminal Comparisons

### Terminal comparison: compact viewport capture

| Field | Required evidence |
| --- | --- |
| Host / build / configuration | macOS 26.5.2 arm64, initial native build from current master; identical executable/configuration for both attempts. Resize 120×40 → 80×25 → 120×40. |
| Legacy terminal attempted first | Terminal.app 2.15, Basic profile, owned window 125. Physical Option/Meta and shortcut delivery were unavailable in the locked desktop. |
| Operation and expected result | Inspect ListView after viewport resizing; require 80-cell rows at 80×25 and correct relayout after restoration. Input used the owned PTY. |
| Legacy result | The terminal reported 80×25 and the app relaid out, but AppleScript visible-content capture retained 120 cells on 24 rows. This prevented reliable compact inspection. It does not establish that displayed Terminal pixels were wrong. |
| Kitty retry after failure | Kitty 0.48.2, isolated owned window, same build/configuration and resize sequence. Remote-control cell captures correctly contained 80 columns, then 120 after restoration. |
| Conclusion | Only Kitty supplied reliable compact cell capture in this session. Both apps remained usable and exited normally. Physical appearance, IME and global OS shortcut delivery remain unverified. |
| Evidence / cleanup | `<iGac repo>/build/rpXPlat-20261116/terminal-terminal-resize-stale-cells.txt`, Kitty compact captures and termios before/after files. Terminal.app and every final Kitty app run exited 0 with restored input modes; owned terminal cleanup is recorded at completion. |

POSIX disambiguation does not expose a standalone Alt key, so access-key overlays cannot be established from that input path. Translated strings changed with locale while native date/number formatting remained en-US. Interval-eight TAB geometry and short/long/empty/CJK caption variants are provider-regression coverage; the showcase does not expose controls for changing these settings. Physical cursor/color/font appearance is unverified.

Owned terminal cleanup completed: all showcase runs had already exited normally; the legacy broker and both owned shells exited, and the isolated Kitty app was terminated. Terminal window 125 is hidden with zero tabs (Terminal still enumerates its closed window object); unrelated window 39 was preserved. Evidence: `terminal-final-cleanup.json`.

Final required `import.sh`, `syncProj.sh` and `build.sh` repetition succeeded. All ten changed imported/generated files are byte-for-byte identical to the versions used in live checks; no additional source changes appeared. Evidence: `import-at-finish.log`, `sync-at-finish.log`, `build-at-finish.log` and `final-sync-audit.json`.
