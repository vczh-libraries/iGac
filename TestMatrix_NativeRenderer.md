# Test Matrix Card 2026-11-15 06:09 PST

## Focused scope and provenance

Execution of `<GacUI repo>/TODO_TASK_iGac.md` on macOS 26.5.2 (25F84), arm64 Debug, Apple clang 21.0.0, `VCZH_DEBUG_NO_REFLECTION`. GacUI source/release baseline `ea5e1b330`, iGac baseline `6d2ef8a`. The final GacUI fast-forward to `516112669` changes only release notes; tested source, releases, resources and build inputs are unchanged. Application coverage is limited to Misc / Raw Clock and Misc / Touching, with Window Manager used only to refresh their palette. GacJS, physical touch, unrelated pages, RPT, RVMT and TUI runtime checks were not run.

## Test Matrix

| Test Item | Result |
| --- | --- |
| Import, synchronization and incremental build | Both sequences passed; repeated import/synchronization preserved all 322 input hashes |
| Clean `build.sh --rebuild` | Passed without compiler warnings; all application and fixture targets rebuilt |
| Native `Test_RawElement /C` | Seven cases passed again after the clean build |
| Hosted `Test_RawElement /C --hosted` | Five shared cases passed again after the clean build; two native-window remote cases intentionally return early (runner reports 7/7) |
| Local FCT, native | 06:05 Clock and Touching rendering, Clock updates, resize, tab return, Aurora refresh and normal shutdown passed; fresh binaries repeated startup/ticking/Touching at 06:13 |
| Local FCT, hosted | 06:06 Same focused page checks and normal shutdown passed; fresh binaries repeated startup/ticking/Touching at 06:13 |
| FCT Core with native renderer, MiniHTTP | 05:58–06:04 Clock/Touching, synthetic points, resize, palette, renderer replacement, takeover and normal shutdown passed |

## State and rendering evidence

- Upstream release sources and both full Reflection32/Reflection64 metadata inventories already contain the common registry, reflected `Interpretor`, combined setter and four-field remote descriptor. Resource synchronization preserves the Clock's named selection. No upstream regeneration was needed.
- The shared Clock plugin is present before `GuiMain` in native and hosted setup; registration forwards through the hosted manager. Each consumer directly links the portable base and Cocoa plugin once. No entry point performs explicit Clock registration.
- The focused fixture covers empty/known/missing names, switching factories, atomic name/data visibility, data-only/ID-only/no-op updates, no retry after late registration, independent instances, manual-handler survival and exactly-once finalization with and without targets. Context replacement preserves interpretor ownership. Graphics state, text matrix, path, logical offsets and clipping are checked at 1x and 2x.
- Fixed payloads exercise Clock pixels without a native timer. Actual remote `EndRendering` calls verify interpretor-only repaint with unchanged time, unchanged-frame suppression, data repaint and removal. Touching checks translation, rotation, scale, contact rings and malformed payload rejection; late enumeration, ID changes, replacement, uninstall and adapter teardown preserve the expected pixel hashes without duplicate drawing.
- Local and remote Controls expose `Id="FullControlTest.Clock"`, `Interpretor="FullControlTest::Clock"` and received `HH:mm:ss`. Sixteen native window captures show the white face/ticks and cyan/green/yellow hands. Pixel-derived hand directions agree with the recorded times, including resize, palette refresh and replay; one capture crosses a one-second boundary. Fresh binaries show native time advancing from 06:13:25 to 06:13:28 and hosted time from 06:13:02 to 06:13:04 without input between captures. Controls/IO were used locally; Core Controls/IO and renderer Dom/IO were used remotely.
- Touching keeps an empty `Interpretor`. Core point commands change `180,140,1,0,0` to `240,180,1,0,1,0,240,180`, then `280,140,0,1.5,2,0,280,140,1,280,260`. Captures show the translated rectangle, the 90-degree rotation at 1.5x scale, and both yellow rings. Releasing contacts removes the rings. Controlled local payloads use the bitmap fixture because Cocoa native point acquisition/automation is unsupported.
- Renderer replacement terminates only the renderer while Core remains alive. The replacement receives Touching state and attaches its manual painter; Clock name/data and drawing resume on tab return. A second renderer on port 8890 takes over from port 8889, whose process exits normally. The new renderer draws the replayed Clock, retains the translated Touching state, accepts further point updates and closes normally with Core. Exact handler cleanup and duplicate suppression are asserted separately in the fixture.

## Evidence and limits

Evidence is retained locally under `<iGac repo>/build/raw-interpretor-20261115/` (ignored): build/synchronization logs, fixture output, Controls/Dom captures, native PNGs and screenshot hand/time comparisons. The available display reports backing scale 1; real 2x display migration was unavailable, so 2x coverage is limited to controlled CoreGraphics bitmap transforms. No physical-touch or browser coverage is claimed.

An early fill assertion sampled a partially covered yellow ring; moving it inside the ring removed the antialiasing ambiguity. Review also added rejection of incomplete contact triples. LLDB launch required macOS authorization and was canceled; temporary pixel diagnostics were removed. All owned application/debugger processes and their dialogs were closed after the live checks. Historical ignored evidence is preserved across the clean rebuild.

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
- Both Cocoa editors loaded `<GacUI repo>/Test/TestDocument.bin`; accepted private save and RTF/HTML export produced real files containing Unicode and embedded images. Open/Save cancellation left documents intact. Cocoa overwrite Cancel preserved bytes; Replace wrote the edited document. Accessibility operated actual native panels, including nested overwrite sheets. All repeated commands remained responsive.
- Hosted English and Chinese fake dialogs created CJK/space names; cancellation and invalid empty/dot/parent/rooted/slash names changed nothing; duplicate folder and file collision errors kept the input usable. Captured mixed selection deleted an ordinary CJK file, empty and populated folders, preserving the independently typed save name. Delete cancellation preserved fixtures. Both selected symlinks and directories containing directory symlinks were rejected, with target sentinel intact and unrelated selections deleted. A verified EACCES descendant caused one combined failure; its sibling still deleted, and permission restoration allowed retry.
- Browser-to-TUI-to-hosted/Cocoa/Core document interchange retained three embedded images (1250×500, 256×256, 123×456), Unicode, alignment, hyperlink and nine styles including an unused style. Original document fixture was never overwritten.
- Native remote Core-local run cycled skins by pointer/keyboard, retained ribbon edit/selection through refresh, saved private/HTML, cross-opened the TUI document, and created/deleted a CJK folder plus populated folder through renderer IO. Core and renderer both closed normally.

- Repeated the official full Core build and launched Core/renderer with `--remoteFS` on both. Private save/reload preserved the Cocoa ribbon document. Renderer filesystem injection created and deleted a CJK folder; the unselected sentinel survived. Core and renderer were co-located on this Mac; fixtures were created/inspected on the renderer host under `<GacUI repo>/Test/FileDialogPlayground/renderer-fs`. DateTime/Locale injection remained disabled. Both processes exited normally.

## Evidence and limits

Local evidence is retained under `<iGac repo>/build/followup-20261114/` (ignored): `hosted-*.json`, `cocoa-*.json`, `remote-local-*.json`, `remotefs-*.json`, build logs and artifact inventory. GUI automation used fresh control trees; native panels used macOS accessibility. An initial hosted launch while Core owned the port failed with a bind exception; stopping Core and relaunching succeeded. This was a test scheduling error.

Exact queued-action counts, underlying document pointer identity and modified-state transitions were inspected in source but not instrumented at runtime. No duplicate visible action was observed. Exhaustive pending-enumeration races and every expanded/collapsed/unloaded tree permutation are not claimed. The file-backed image-label branch was not reachable through private-format loading (which materializes stream-backed images); embedded-image persistence was exercised independently.

## Completion

Upstream Core linkage fix: GacUI `40bd03efb`. Final fetch included documentation-only upstream commits through `edd40756c`; the fix was rebased, and a scoped Git comparison confirmed all tested source, release, resource and build inputs unchanged. Build logs, control/cell captures and output hashes are retained locally in `<iGac repo>/build/followup-20261114/` and are not committed. The verified owned playground was removed after checking all target sentinels, restoring directory permissions and unlinking symlinks without following them. Original `<GacUI repo>/Test/TestDocument.bin` remained unchanged. No temporary test instrumentation was added to tracked application sources.
