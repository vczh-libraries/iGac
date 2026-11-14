# Test Matrix Card 2026-11-14 08:39 PST

## Focused scope and provenance

Execution of `<GacUI repo>/TODO_TASK_iGac.md` on macOS 26.5.2 (25F84), arm64 Debug, Apple clang 21.0.0, `VCZH_DEBUG_NO_REFLECTION`. Upstream GacUI `6c3d81ee1`, iGac baseline `d59347e`, GacJS `9f8a5f8`; fetched and current before synchronization. Selected FCT Window Manager skins, both document editors and fake Open/Save dialogs; corresponding TUI pages only. RPT, RVMT, host modes, Wasm, Raw Clock, touch and unrelated pages are excluded and their rows remain blank. This is a focused subset, not a full SOP pass. Historical cards supply no current passes.

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] |  |
| [macOS][`/RPT`][`/MiniHttp`] |  |
| [macOS][`/FCT`][`/MiniHttp`] | 09:29 Core-local and remoteFS focused subsets passed |
| [macOS][`/RVMT`][`/MiniHttp`] |  |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<command>`] |  |
| [macOS][Local FullControlTest][hosted] | 09:06 selected behaviors passed; limits below |
| [macOS][Local FullControlTest][Cocoa panels] | 09:18 selected behaviors passed |
| Build / release / import / sync | 08:44 passed: Codepack, import, sync, Debug arm64 build; x32/x64 generation |

## Issues Found and Fix

### Portable Core link failure

At 08:44, `<iGac repo>/test_core.sh --app:fct --protocol:minihttp` failed to link on arm64 with undefined `gacui_demo::LoadDocument`, `SaveDocument`, `ExportDocumentRtf` and `ExportDocumentHtml`. The portable Core's authored `vmake` inventory included the FCT event handlers but omitted `<GacUI repo>/Test/GacUISrc/SharedDocumentEditor.cpp`. Added that implementation once in `<GacUI repo>/Test/Linux/RemotingTest_Core/vmake`, regenerated through the normal wrapper and repeated full builds and the WebKit/native-renderer runtime checks successfully. No framework/provider change is needed; the test-app-only unit-test exemption applies.

## Focused evidence

- `Codepack` exited 0. Release content matched HEAD after Git line-ending normalization. Official `import.sh`, `syncProj.sh`, `build.sh` each exited 0. All four applications generated both x32 and x64 staging outputs and eight deployment manifests; no resource error files. Only arm64 executables were run. The two regenerated resource buffers differ solely in six CRLF-to-LF text separators and corresponding lengths. The CppMerge build also regenerated `<Workflow repo>/Tools/CppMerge/makefile` with spacing-only changes. Shared persistence compiled once per executable; no TUI DarkSkin or reflection addition.
- Hosted and standard FCT started and closed normally. Both six-item GUI selectors retained one selection through pointer, Tab/Enter, reconstruction and navigation. Ribbon Unicode edits and selection survived skin changes; the standard Toolstrip editor also retained edited content/selection.
- Both Cocoa editors loaded `TestDocument.bin`; accepted private save and RTF/HTML export produced real files containing Unicode and embedded images. Open/Save cancellation left documents intact. Cocoa overwrite Cancel preserved bytes; Replace wrote the edited document. Accessibility operated actual native panels, including nested overwrite sheets. All repeated commands remained responsive.
- Hosted English and Chinese fake dialogs created CJK/space names; cancellation and invalid empty/dot/parent/rooted/slash names changed nothing; duplicate folder and file collision errors kept the input usable. Captured mixed selection deleted an ordinary CJK file, empty and populated folders, preserving the independently typed save name. Delete cancellation preserved fixtures. Both selected symlinks and directories containing directory symlinks were rejected, with target sentinel intact and unrelated selections deleted. A verified EACCES descendant caused one combined failure; its sibling still deleted, and permission restoration allowed retry.
- Browser-to-TUI-to-hosted/Cocoa/Core document interchange retained three embedded images (1250×500, 256×256, 123×456), Unicode, alignment, hyperlink and nine styles including an unused style. Original document fixture was never overwritten.
- Native remote Core-local run cycled skins by pointer/keyboard, retained ribbon edit/selection through refresh, saved private/HTML, cross-opened the TUI document, and created/deleted a CJK folder plus populated folder through renderer IO. Core and renderer both closed normally.

- Repeated the official full Core build and launched Core/renderer with `--remoteFS` on both. Private save/reload preserved the Cocoa ribbon document. Renderer filesystem injection created and deleted a CJK folder; the unselected sentinel survived. Core and renderer were co-located on this Mac; fixtures were created/inspected on the renderer host under `<GacUI repo>/Test/FileDialogPlayground/renderer-fs`. DateTime/Locale injection remained disabled. Both processes exited normally.

## Evidence and limits

Local evidence is retained under `<iGac repo>/build/followup-20261114/` (ignored): `hosted-*.json`, `cocoa-*.json`, `remote-local-*.json`, `remotefs-*.json`, build logs and artifact inventory. GUI automation used fresh control trees; native panels used macOS accessibility. An initial hosted launch while Core owned the port failed with a bind exception; stopping Core and relaunching succeeded. This was a test scheduling error.

Exact queued-action counts, underlying document pointer identity and modified-state transitions were inspected in source but not instrumented at runtime. No duplicate visible action was observed. Exhaustive pending-enumeration races and every expanded/collapsed/unloaded tree permutation are not claimed. The file-backed image-label branch was not reachable through private-format loading (which materializes stream-backed images); embedded-image persistence was exercised independently.

## Completion

Upstream Core linkage fix: GacUI `40bd03efb`. Final fetch included documentation-only upstream commits through `edd40756c`; the fix was rebased, and a scoped Git comparison confirmed all tested source, release, resource and build inputs unchanged. Build logs, control/cell captures and output hashes are retained locally in `<iGac repo>/build/followup-20261114/` and are not committed. The verified owned playground was removed after checking all target sentinels, restoring directory permissions and unlinking symlinks without following them. Original `TestDocument.bin` remained unchanged. No temporary test instrumentation was added to tracked application sources.
