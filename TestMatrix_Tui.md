# Test Matrix Card 2026-11-14 08:39 PST

## Focused scope and provenance

Execution of `<GacUI repo>/TODO_TASK_iGac.md` on macOS 26.5.2 (25F84), arm64 Debug, Apple clang 21.0.0, `VCZH_DEBUG_NO_REFLECTION`. Upstream GacUI `6c3d81ee1`, iGac baseline `d59347e`, GacJS `9f8a5f8`; fetched and current before synchronization. Selected FCT Window Manager skins, both document editors and fake Open/Save dialogs; corresponding TUI pages only. RPT, RVMT, host modes, Wasm, Raw Clock, touch and unrelated pages are excluded and their rows remain blank. This is a focused subset, not a full SOP pass. Historical cards supply no current passes.

## Environment

| Field | Value |
| --- | --- |
| Platform / application / commit / build configuration | macOS 26.5.2 arm64 Debug; iGac d59347e plus regenerated resources; GacUI 6c3d81ee1 |
| Terminal name / version / profile / viewport sizes | Apple Terminal 2.15 / Basic / SFMono-Regular 11; Kitty 0.48.2 default profile; 120×40 → 80×25 → 120×40 |
| Input methods / desktop availability | Desktop and accessibility available. OS-generated Tab/Enter, Kitty key commands, injected SGR mouse/UTF-8, cell capture and screenshots; no physical input claim |

## Test Matrix

| Test Item | 1st |
| --- | --- |
| Build / resource generation / import / sync | 08:44 passed: Codepack, import, sync, Debug arm64 build; x32/x64 generation |
| Unit tests |  |
| Platform launch and terminal/input capabilities | 09:19 passed interactive stdin/stdout; input distinctions below |
| Startup, platform services and teardown | 09:19 normal exits and usable shells; termios notes below |
| Follow-up regression checks | 09:20 focused persistence and mutation checks; limits below |
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
| Control / Document Editor (Toolstrip) | 09:20 private/RTF/HTML, interchange and fresh-process reopen passed |
| Control / TextBox / TextBox |  |
| Control / TextBox / TextBox (No Tab) |  |
| Control / TextBox / Document |  |
| Control / TextBox / Document (No Tab) |  |
| Control / Embedded Controls |  |
| Misc / Localization |  |
| Compact dialog and form layout checks | 09:14 120×40, 80×25, restored; open-dialog placement limitation below |
| Misc / Dialogs / MessageDialog |  |
| Misc / Dialogs / ColorDialog |  |
| Misc / Dialogs / FontDialog |  |
| Misc / Dialogs / Open/Save FileDialog | 09:14 focused mutation/localization checks passed |
| Misc / DatePicker |  |
| Window Manager | 09:20 six-item selector, pointer replay and Tab/Enter passed |
| Live palette and clipping regression | 09:14 selected pages only; screenshot/cell evidence |
| Exit | 09:20 normal close; Terminal and Kitty shells restored |
| Packaged tutorial checks (when requested) |  |
| Linux/macOS legacy-terminal and Kitty comparison (when applicable) | 09:20 see comparison below |

## Observations and Limitations

- Terminal.app was attempted first. It launched at 120×40 with inherited interactive descriptors; injected terminal bytes cycled all six skins at 120×40, 80×25 and restored 120×40. OS-generated Tab/Enter subsequently selected Orange, Grass, Emerald, SkyBlue and Purple. Two normal closes returned exit 0. Its before/after `stty -g` values matched exactly.
- Kitty used the same executable/build and independently ran the selected editor and dialog checks. Six-item order and initial SkyBlue were correct, with one selected radio after reconstruction. All pointer-replay choices and Tab/Enter choices worked. OS-generated Tab/Enter selected Orange. Cell captures and screenshots showed the styled Unicode document, hyperlink and image labels.
- Original fixture loading displayed `GacUI Remote Document — 中文 π` and both images. Browser-to-TUI private interchange retained Unicode, alignment, hyperlink, all nine styles including an unused style, and image labels `[Image, 1250 x 500]`, `[Image, 256 x 256]`, `[Image, 123 x 456]`. Private resaves contained actual image data, not serialized label text; GUI cross-open rendered all three images. RTF and UTF-8 HTML contained embedded image output.
- Edited content/selection survived navigation and skin refresh. After restoring editor focus, Undo removed the final inserted character after refresh and Redo restored it; both states were captured. Open/Save cancellation wrote nothing and did not replace the document. Overwrite cancellation preserved bytes; accepted repeat save matched prior bytes. A fresh TUI process reopened/resaved with the original PNG renamed away; all images and unused styles remained. Three Kitty normal exits returned 0 and shell input worked.
- English and Chinese Open and Save fake dialogs displayed action captions, nested new-folder input and localized errors. Creation cancel/title-close changed nothing; valid CJK/space names appeared without navigation. Empty/dot/parent/rooted/slash names, folder collision and file collision retained a correctable input. Mixed recursive deletion used selected rows despite an independent typed filename. Cancellation preserved fixtures. Symlink/subtree-link rejection preserved target sentinels and continued other deletions. A verified permission-denied directory produced a combined failure while its sibling deleted; restored permissions allowed retry.
- At 80×25, an already-open dialog retained its old position and clipped beyond the viewport. Dragging its title into view exposed all controls; nested Chinese input/error dialogs then remained operable. Selected page content and palettes also survived restoration to 120×40. Automatic repositioning of an existing modal on terminal resize is not claimed.
- Kitty's before/after terminal settings matched except Darwin's `PENDIN` pending-input state bit (0x20000000); canonical mode, echo, control characters, speeds and other flags matched. Shell input and alternate-screen restoration were observed. Exact byte-for-byte Kitty termios restoration is not claimed.
- Raw SGR events verify decoding/application behavior, not host mouse delivery. Generated desktop pointer attempts did not activate the intended tab in either host; physical mouse delivery is unverified. No standalone Alt overlays, Space key-release requirement, unrelated shortcuts or excluded pages were added.
- Runtime action counters, document pointer identity, modified-state timing, every tree/pending-enumeration permutation, and the path-bearing `[Image: path, width x height]` branch are not claimed. Private-format image loading yields stream-backed images. Evidence is retained under `<iGac repo>/build/followup-20261114/`: `terminal-*.txt`, `tui-*.txt`, screenshots and terminal settings.

## Issues Found and Fix

The portable Core link correction is described in `<iGac repo>/TestMatrix_NativeRenderer.md`; independent TUI did not require a provider/framework change. Test-input mistakes (substring matches hitting titles/messages and localized field names) were corrected in the temporary driver and rerun; they are not application failures.

## Terminal Comparisons

### Selector input

| Item | Observation |
| --- | --- |
| Legacy terminal attempted first | Terminal.app 2.15 Basic/SFMono-Regular 11. Generated pointer attempts did not activate Window Manager. Injected SGR selected all themes at all three sizes; OS-generated Tab/Enter cycle subsequently succeeded. |
| Kitty retry after failure | Kitty 0.48.2, same Debug arm64 executable. Generated pointer attempt likewise did not establish delivery. SGR replay and Kitty key commands passed; OS-generated Tab/Enter also selected Orange. |
| Conclusion | Keyboard delivery verified through generated native events in both hosts. Application mouse behavior verified through replay; physical/native pointer delivery remains unverified. Detailed editor/dialog checks ran in Kitty and must not be attributed to Terminal.app. |

## Completion

Upstream Core linkage fix: GacUI `40bd03efb`. Final fetch included documentation-only upstream commits through `edd40756c`; the fix was rebased, and a scoped Git comparison confirmed all tested source, release, resource and build inputs unchanged. Build logs, control/cell captures and output hashes are retained locally in `<iGac repo>/build/followup-20261114/` and are not committed. The verified owned playground was removed after checking all target sentinels, restoring directory permissions and unlinking symlinks without following them. Original `TestDocument.bin` remained unchanged. No temporary test instrumentation was added to tracked application sources.
