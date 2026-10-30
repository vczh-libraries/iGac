# Injection verification on macOS — 2026-10-30

Execution of `<GacUI repo>/TODO_Injection_XPlat.md` and the native-Core/browser work recorded in `<wGac repo>/TestMatrix_Injection_XPlat2.md`. Tests used macOS 26.5.2 (25F84), Apple Silicon, system Bash 3.2.57, Node 26.5.0 and Playwright WebKit 26.0. Native processes used `LC_ALL=en_US.UTF-8`; Core used `TZ=UTC`. WebKit used `America/New_York` and `tr-TR` in persistent profiles so OPFS was available.

Starting revisions were iGac `1a8a330eaf5939b57b70e15bfb3ae53b6c31bbda`, GacUI `99a5e5ae7848e18d34aecee0b6fa0c76393dcb24`, VlppOS `bb89b9b06d5eaf9ad6489e50da93d8b1d47ab073`, Workflow `1fc0806d55a61e78383a3a0190a3718ef789b20a`, and GacJS `6e62919aa35fd6072a80c1714d394c2b1facc7c2`. The changes delivered with this report are applied on those revisions.

## Fixes and synchronization

- The Cocoa graphical entry points now initialize `LC_CTYPE` from the environment for Unicode native paths.
- Both launchers avoid expanding an empty injection array under Bash 3.2 `set -u`. Previously, the default disabled-feature launch failed before starting its executable.
- Cocoa image saving now encodes the first frame in PNG, BMP, GIF, JPEG or TIFF, with explicit unsupported-format and incomplete-write failures. Frame creation retains AppKit's actual image instead of assuming RGBA pixels. Animated bitmap frame counts no longer shadow the stored count.
- Reapplying the second inline image in a paragraph incorrectly treated its own existing image as a conflict with the first image. This crashed the native renderer when exporting a document after inserting a JPEG. The comparison now checks the current other range. Reset also removes stale lookup entries and restores the original text before reuse.
- The macOS async-socket amalgamation lacked the internet-address declarations because CodePack deduplicated headers inside the Linux-only branch. Fixed the owning VlppOS sources, regenerated its release, synchronized GacUI and Workflow imports, then imported into iGac.
- Project synchronization brought in the canonical FCT document handlers/resources and the RVM cleanup ordering. No imported or generated implementation was patched directly.

## Builds and focused tests

From `<iGac repo>`, ran `./import.sh`, `./syncProj.sh`, and `./build.sh` in that order. Builds used `LC_ALL=en_US.UTF-8 MAKEFLAGS=-j6`. The initial amalgamation failure was fixed upstream before continuing. Final synchronization/rebuild and unchanged-input comparison are recorded below.

From `<VlppParser2 repo>/Tools/CodePack`, regenerated VlppOS with:

```bash
./Bin/CodePack ../../../VlppOS/Release/CodegenConfig.xml
```

From each upstream unit-test project, used its `.github/Ubuntu/build.sh` wrapper, then ran the built test executable with `/C` and these filters:

| Project | Files | Actual summary |
| --- | --- | --- |
| GacUI | `TestRemote_Startup.cpp`, `TestDocumentConfig.cpp`, `TestControls_Ribbon_Gallery.cpp` | 3/3 files, 167/167 cases |
| VlppOS | `TestInterProcess.cpp`, `TestInterProcess_AsyncSocket.cpp`, `TestInterProcess_AsyncSocket_MiniHttpApi.cpp`, `TestInterProcess_HttpRequest.cpp` | 4/4 files, 110/110 cases |

From `<GacUI repo>/Test/Linux/UnitTest`:

```bash
LC_ALL=en_US.UTF-8 MAKEFLAGS=-j6 ../../../.github/Ubuntu/build.sh
./Bin/UnitTest /C /F:TestRemote_Startup.cpp /F:TestDocumentConfig.cpp /F:TestControls_Ribbon_Gallery.cpp
```

From `<VlppOS repo>/Test/Linux/UnitTest`:

```bash
LC_ALL=en_US.UTF-8 MAKEFLAGS=-j6 ../../../.github/Ubuntu/build.sh
./Bin/UnitTest /C /F:TestInterProcess.cpp /F:TestInterProcess_AsyncSocket.cpp /F:TestInterProcess_AsyncSocket_MiniHttpApi.cpp /F:TestInterProcess_HttpRequest.cpp
```

The GacUI snapshot changes are generated declaration/property-initialization ordering from the current compiler, committed separately from implementation changes.

From `<GacJS repo>/Gaclib`, `yarn install`, `yarn run import`, `yarn codegen` twice, `yarn build`, and `yarn test` passed. The second codegen produced no additional diff. The test summaries total 211 cases, including the 38-case browser entry suite and the Workflow RPC driver integration. The Windows-only native E2E gate did not supply macOS evidence; the live WebKit runs below did. macOS WASM application builds/deployment/runtime verification were excluded as instructed.

The browser entry server ran with `npm run start` from `<GacJS repo>/Gaclib/website/entry`. WebKit opened `http://localhost:8896/index.html?remoteDT&remoteLocale&remoteFS&corehost=localhost`; matrix runs varied the three feature query names independently, and host runs replaced `corehost`. RVMT added `rvmhost`.

Native foreground and background renderer commands, from `<iGac repo>`:

```bash
LC_ALL=en_US.UTF-8 ./test.sh --remoteFS --port:8892 --app:renderer --remoteDT --corehost:127.0.0.1 --remoteLocale
LC_ALL=en_US.UTF-8 ./test.sh --remoteFS --port:8892 --app:renderer --remoteDT --corehost:127.0.0.1 --remoteLocale --unblock
```

Individual provider cases varied the corresponding switches on both ends; the destination matrix used port 8891. Native FCT smokes used `./test.sh --app:fct` with and without `--hosted`; standalone RVMT used `./test.sh --app:rvmt`. The manual host was `<GacUI repo>/Test/Linux/RemotingTest_RvmHost/Bin/RemotingTest_RvmHost /MiniHttp /corehost:127.0.0.1`. Fresh-process matrix and smoke iterations reused `<GacUI repo>/Test/Linux/RemotingTest_Core/Bin/RemotingTest_Core` with `/MiniHttp /FCT`, `/MiniHttp /RPT` or `/MiniHttp /RVMT` and the selected slash switches. The auto-host RVMT run added `/Cli:<absolute path of the rebuilt RemotingTest_RvmHost>`.

Native regression commands:

```bash
./build/MacTest/bin/Test_ImageService /C
./build/MacTest/bin/Test_Paragraph /C
./build/MacTest/bin/Test_RawElement /C
./build/MacTest/bin/Test_RawElement /C --hosted
./build/MacTest/bin/Test_HostedModal /C
```

Image and paragraph tests each passed 1/1 case, including the final production build. The image test checks JPEG-to-PNG pixel equality, every supported encoding, PNG signatures, short writes, unsupported WMP, and two-frame GIF loading. The paragraph regression reuses two inline images, resets/reinserts them, and includes a supplementary Unicode character before their ranges. Raw tests passed 4/4 in each mode on the final build. Hosted modal passed 1/1 in two consecutive final standalone PTY runs. Earlier redirected execution and the first final PTY invocation exited 1 without a passing summary; this intermittent test execution remains a caveat, despite the successful isolated reruns.

## Provider matrix

Each cell was a separate live Core/renderer run, with the other two features disabled. The native renderer used temporary public feature-injection implementations; WebKit used its real providers. Fresh Core API queries and renderer request traces established routing. WebKit runs also performed actual list add/clear operations.

| Feature | Core off / renderer off | Core off / renderer on | Core on / renderer off | Core on / renderer on |
| --- | --- | --- | --- | --- |
| DateTime | Core UTC predecessor | Core UTC predecessor | Core UTC predecessor | Native test timezone / WebKit New York conversions |
| Locale | Core en-US predecessor | Core en-US predecessor | Core en-US predecessor | Native distinguishable defaults/case/name results / WebKit tr-TR |
| Filesystem | Core sentinel | Core sentinel | Empty read-only `/`; sentinel unavailable | Renderer backing directory / origin OPFS sentinel |

All 12 native combinations plus all-enabled passed. All 12 WebKit combinations, all-enabled, and mixed Core DateTime/filesystem versus browser Locale/filesystem passed. The mixed case emitted only filesystem injection requests.

DateTime covered both conversion directions, milliseconds, winter/summer offsets and date/year rollover. Native test conversions used +14 hours in winter and +13 in summer; `2024-12-31 20:59:58.987` became `2025-01-01 10:59:58.987`. WebKit converted the January and July samples across the previous day, including the previous year. Current Core time remained in 2026 despite the test renderer clock returning 2099. Locale checks covered defaults, enumeration, all format lists, day/month names, and four case conversions. Formatting, currency/number conversion, comparison and search retained Core behavior.

Filesystem checks covered distinct Core/renderer storage, Unicode/spaced paths, relative paths, metadata, nested enumeration, create/rename/delete, native copy, unsupported OPFS copy without partial output, missing files, and a 262147-byte binary pattern. Read/peek/seek/position/size, empty files, zero-byte writes, native ReadWrite truncation, OPFS ReadWrite preservation, WriteOnly replacement, read snapshots, close persistence and explicit-close/destruction were checked. Unavailable injection enumerated an empty root and rejected open/mutation operations. Core's sentinel and fixture directory were unchanged throughout the mapped-storage and OPFS matrices.

## Documents and ribbon interactions

Both native and WebKit FCT editors loaded `<GacUI repo>/Test/TestDocument.bin`, typed distinct Unicode markers, saved separate private files, discarded later edits on reload, and cross-loaded the other editor's file. Assertions compared the complete document XML, including text, fonts/colors, paragraph alignment, both image runs and all eight named styles, including unused styles. Private saves cleared modified state after persistence; RTF/HTML export preserved it; canceled saves preserved both the document and output state.

RTF control words and HTML spans were decoded for text checks. Exports contained two embedded images; inserting the JPEG fixture from `<GacUI repo>/Test/Resources/UnitTestResources/cake.jpeg` produced three image runs and three PNG payloads in native RTF. Extracted PNGs decoded at 1250×500, 256×256 and 291×212 pixels. The images were loaded from self-contained private files in isolated fixture storage without their original source paths. WebKit private bytes survived REFRESH and were reloaded with their style catalog intact.

Actual ribbon popup items, rather than inline gallery highlights, applied styles from both groups. Checks included an already-selected item, reopening, resizing, preserved selection and palette/theme refresh. Native and browser wide and collapsed layouts passed; native resize used the public window API through the temporary probe. Selection copy/paste and undo/redo passed; native undo may normalize redundant explicit false bold/italic wrappers while retaining the same formatting.

## Destinations and lifecycle

Native and WebKit runs each verified omitted host, explicit `localhost`, `127.0.0.1`, `Zihans-Mac-mini.ica-home`, LAN address `192.168.1.209`, `::1`, and `[::1]`. Every destination performed Core-side and renderer-side input, actual document load/save/reload, and provider queries. Native runs used a nondefault automation port 8891 while protocol traffic remained on 8888. Browser request origins matched the selected destination; mixed-case query option names worked.

Native and WebKit takeover with capabilities disabled/enabled selected the new provider, retained Core state, and let the detached native renderer exit 0. Fresh queries after observed disconnect returned DateTime/Locale predecessors and the empty filesystem. Closing streams retained from an old native or browser renderer returned the expected original-renderer-unavailable error. Killing the native renderer while filesystem enumeration was deliberately pending completed without a hang or stale provider result, and reconnection worked. Normal Core shutdown ended both native processes with exit 0.

WebKit checkbox changes left the active connection unchanged until REFRESH. Off/on REFRESH changed capabilities, retained the host selection and preserved OPFS bytes. Browser-host RVMT completed Unicode `Translate`, then REFRESH removed the accepted host. A fresh Core input made Core observe that loss and terminate with SIGABRT. Restarting Core restored Unicode RPC and normal shutdown exited 0.

Application smokes passed for standard/hosted Cocoa FCT, native and WebKit RPT, standalone Cocoa RVMT, Core/native RVMT with a manual MiniHTTP host, and Core/native RVMT with an auto-launched CLI host. FCT added/cleared list items. RPT exercised Click Me, grid add/clear, the embedded document button/modal and cancel/confirm close. RVMT returned `Hello, XPlat你好!` through real RPC.

## Launcher and final production verification

Twenty-five invalid cases returned exit 1: duplicate injection switches, empty/malformed/duplicate hosts, duplicate/out-of-range ports, wrong-case switches, Core host options and renderer-only options on other wrapper targets. Native parsing rejects these before transport setup. Reordered valid options and both renderer launch modes are checked using actual process arguments and provider results.

Temporary Core queries and renderer providers were removed from the source. The Core was fully rebuilt through both official launcher modes. Actual process arguments contained all three slash-prefixed injection switches, including reordered wrapper options:

```bash
LC_ALL=en_US.UTF-8 TZ=UTC MAKEFLAGS=-j6 ./test_core.sh --remoteFS --app:fct --remoteDT --protocol:minihttp --remoteLocale
LC_ALL=en_US.UTF-8 TZ=UTC MAKEFLAGS=-j6 ./test_core.sh --unblock --app:fct --remoteLocale --protocol:minihttp --remoteDT --remoteFS
```

The clean Core passed real WebKit document editing, private save/reload, image exports, REFRESH persistence, Core/renderer input and normal shutdown. Its Controls response had no probe field.

After removing instrumentation, the final `./import.sh`, `./syncProj.sh`, `./build.sh` sequence passed. All 46 imported library files and both test-helper files matched the upstream inputs; all seven canonical shared copies matched. Hashes of 172 imported, generated, staging and shared source files were unchanged across that sequence.

The final native binaries passed both all-enabled and disabled-feature runs using real Cocoa providers. Both editors completed load/edit/private save/reload, cross-load, cancellation and RTF/HTML export. JPEG insertion and three-image exports passed with renderer-backed and Core-local output. Disconnect/reconnect retained the document; input through Core and renderer automation worked. Neither run exposed a probe, and both Core processes exited 0. The disabled Core launch also verified the empty injection-array path:

```bash
LC_ALL=en_US.UTF-8 TZ=UTC MAKEFLAGS=-j6 ./test_core.sh --app:fct --protocol:minihttp
LC_ALL=en_US.UTF-8 ./test.sh --app:renderer --port:8889
```

Fresh final native enabled/disabled and WebKit enabled runs also switched the localization UI from English to Chinese and back. The native renderer used `TZ=Asia/Tokyo`, while Core remained UTC; the page retained its cached startup time as documented, so this UI check is not fresh timezone-routing evidence. Both native Core/renderer pairs and the browser Core exited 0 normally.

## Harness corrections and unavailable coverage

The temporary Core probe initially retained a temporary JSON field-name pointer; the probe was corrected. Native trace assertions distinguish requested locale defaults from invariant-locale calls made by ordinary filesystem path handling, and Core time from renderer housekeeping clock calls. The deliberately altered native case-conversion provider was restricted to routing queries; document runs used valid case conversion so resource URLs remained resolvable. Export assertions decode RTF Unicode control words and compare semantic undo results where redundant style wrappers are normalized.

The final localization smoke initially expected a renderer timezone to replace the page's cached startup timestamp. That assertion was corrected to the documented cache behavior; provider routing was already verified using fresh API queries.

This is macOS execution. Another physical computer, separate Safari execution, physical touch/pen, and OS-global-shortcut consent were unavailable or outside the focused injection runs. Same-machine hostname/LAN-address checks do not establish cross-machine access. Browser input and native automation establish application/protocol behavior, not physical-device coverage. Temporary probes, fake providers, fixtures and machine paths are not part of the delivered sources.
