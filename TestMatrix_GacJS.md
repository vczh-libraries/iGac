# Test Matrix Card 2026-11-14 08:39 PST

## Focused scope and provenance

Execution of `<GacUI repo>/TODO_TASK_iGac.md` on macOS 26.5.2 (25F84), arm64 Debug, Apple clang 21.0.0, `VCZH_DEBUG_NO_REFLECTION`. Upstream GacUI `6c3d81ee1`, iGac baseline `d59347e`, GacJS `9f8a5f8`; fetched and current before synchronization. Selected FCT Window Manager skins, both document editors and fake Open/Save dialogs; corresponding TUI pages only. RPT, RVMT, host modes, Wasm, Raw Clock, touch and unrelated pages are excluded and their rows remain blank. This is a focused subset, not a full SOP pass. Historical cards supply no current passes.

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] |  |
| [macOS][`/FCT`][`/MiniHttp`] | 09:01 selected WebKit behaviors passed; limits below |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] |  |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<command>`] |  |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] |  |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] |  |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over stdio `/Cli:<command>`] |  |

## Issues Found and Fix

### Portable Core link failure

The initial Core build failed with four undefined shared document functions. See `<iGac repo>/TestMatrix_NativeRenderer.md` for the upstream source-inventory correction and revalidation. GacJS import, codegen, build and 235 portable tests passed; the reported Windows-only E2E skip does not count as WebKit coverage. The required WebKit 26.0 engine is installed with Playwright 1.58.2.

## Focused evidence

Node 26.5.0, Yarn 1.22.22, Playwright 1.58.2, WebKit 26.0 (build 2248). `yarn run import`, `yarn codegen`, `yarn build`, `yarn test` succeeded: 235 portable tests across 11 packages. The Windows-only E2E skip was excluded from browser results. Repeated codegen produced a byte-identical diff. Imported upstream snapshots and generated snapshot index are committed separately.

The live browser used the corrected portable Core with `/FCT /MiniHttp` and the entry server on port 8896. Core-local filesystem services were used; Core/browser filesystem, DateTime and Locale injection were disabled. Playwright pointer and keyboard input drove the renderer; Core Controls supplied fresh read-only document/selection evidence. No application/page error occurred during interaction. Intentional Core shutdown logged a lost-network-connection console message in each WebKit session. Core closed normally via the application's Close action.

- All six GUI skins appeared in order, Default initially selected. Pointer and Tab/Enter cycles, Shift+Tab, return to Default, and navigation away/back passed.
- Both editors loaded the original `TestDocument.bin` with Unicode title, styles and two images. Ribbon and Toolstrip edits and exact XML/selection survived skin reconstruction. Ribbon Undo changed the document after refresh and Redo restored its exact XML.
- Private saves, Unicode RTF/HTML exports with embedded images, Open/Save cancellation, and overwrite Cancel/OK were exercised. Cancellation preserved document/file bytes; accepted overwrite produced the expected content. Export selection was captured.
- The interchange fixture added a 123×456 image, hyperlink, alignment and unused style. Browser private output contained all three images and nine styles, then TUI and fresh native GUI processes cross-opened it. TUI resaves were subsequently reopened with the source PNG unavailable.
- English Open and Chinese Save fake dialogs exercised creation, localized validation, cancellation, folder/file collisions, and deletion. Empty, dot, parent, rooted and slash names were rejected. POSIX backslash is a valid name and was accepted. CJK fixture names displayed correctly. Captured multi-selection, independently typed filename preservation, recursive deletion, cancellation, symlink rejection, a verified EACCES descendant with continued sibling deletion, and successful retry all passed; sentinels survived.

## Evidence and limits

Local evidence: `<iGac repo>/build/followup-20261114/webkit-*.json`, `webkit-final.png`, build/test logs and artifact inventory. The card records a focused subset only. Exact queued-action counts, object identity and modified-state timing were not instrumented; all tree enumeration/sorting permutations were not exhausted. Playwright `keyboard.type` omitted CJK characters because this renderer handles keydown text while Playwright uses text insertion for those characters; direct CJK typing is not a pass. Unicode file/document persistence is separately verified. A fresh Core/WebKit pair subsequently reopened the TUI private file with all three images and the unused style while the original PNG was unavailable. Synthetic DOM keydown/keyup events also created a CJK folder; this verifies the renderer event path, not physical IME or Playwright text-insertion support.

## Installed Safari supplementary check

Safari 26.5.2 loaded the live FCT page with a fresh `/FCT /MiniHttp` Core and no injection. The rendered window, selected initial page, labels, controls and layout were visually inspected in `safari.png`; startup Controls were captured in `safari-startup.json`. This is a startup/rendering smoke check only. Safari denied JavaScript from Apple Events because its setting is disabled; generated pointer attempts did not establish delivery, so further interactive Safari results are unverified. The owned Safari window was closed. The supplementary Core did not respond to the subsequent Core-only automation Close request after renderer disconnection and was explicitly terminated during cleanup; normal shutdown for this supplementary run is not claimed. This supplementary observation does not replace the required WebKit run.

## Completion

Upstream Core linkage fix: GacUI `40bd03efb`. Final fetch included documentation-only upstream commits through `edd40756c`; the fix was rebased, and a scoped Git comparison confirmed all tested source, release, resource and build inputs unchanged. Build logs, control/cell captures and output hashes are retained locally in `<iGac repo>/build/followup-20261114/` and are not committed. The verified owned playground was removed after checking all target sentinels, restoring directory permissions and unlinking symlinks without following them. Original `TestDocument.bin` remained unchanged. No temporary test instrumentation was added to tracked application sources.
