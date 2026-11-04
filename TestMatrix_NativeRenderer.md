# Test Matrix Card 2026-11-04T04:02:01-08:00

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 2026-11-04T12:31:37.713Z |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-11-04T12:34:57.063Z |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-11-04T13:15:07.265Z |
| [macOS][`/RVMT`][`/MiniHttp`] | 2026-11-04T12:31:47.124Z |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] | 2026-11-04T12:32:49.422Z |
| Build / CodePack / import / sync | 2026-11-04T12:22:07.990Z (fixed) |
| Local Hello World | 2026-11-04T12:34:45.353Z |
| Local FullControlTest | 2026-11-04T12:38:01.214Z (fixed) |
| Local FullControlTest --hosted | 2026-11-04T13:25:39.521Z (fixed) |
| Native regression tests | 2026-11-04T12:31:37.711Z (fixed) |
| Native Touching gestures (excluded: native touch unsupported) |  |
| Native TouchingList gestures (excluded: native touch unsupported) |  |

## Observations and Limitations

macOS 26.5.2 arm64, CMake Debug; initial iGac commit `51967a6`, GacUI `7dbf1bc8e`, plus the fixes below. Final `./import.sh`, `./syncProj.sh`, and `./build.sh` succeeded in that order. CodePack, the portable Core/host builds, and generated resources were refreshed. Evidence is local and ignored under `<iGac repo>/_OUTPUT_/rpXPlat-20261104/`.

| Coverage | Observed result / evidence |
| --- | --- |
| RPT | Initial UI, Home, shortcuts, all five mouse buttons and modifiers, grid add/clear, document dialog, replacement and takeover retained state. Normal Exit and Core-authored fatal error paths passed. `native-rpt-*.json`, `native-rpt-fatal.png`. |
| RVM standalone and both remote host modes | Initial and Unicode RPC, second-host rejection for manual network hosts, replacement/takeover where applicable, normal shutdown, idle-next-call host loss and blocked-delivery host loss passed. Nine scenario results in `native-rvm-results.json`; stdio children exited with Core. |
| Local FCT | Lists, independent editor markers, shortcuts/mouse, four vertical layout pages, palette retention, responsive modal size cycle, account/movie content and modal close paths passed. Open cancellation and private fixture loading retained timer/automation activity. Private-format save/reload retained serialized XML; RTF and HTML exports contained the document/images. `native-document-exports.json`, `native-local-modal-sizes.json`. |
| Hosted FCT | Initial lists/input, retained editor text and layouts, palette changes and exact responsive dimensions passed after the ellipsis fix. Initial size is 240×320; the cycle covers widths 240/350/440/680 and heights 220/320/520. Title close and queued main Close exited normally. `native-Native-Hosted-Fixed-responsive.json`. |
| Remote FCT | Initial, replacement and takeover retained state and input. Responsive sizes matched the requested dimensions after placing the modal within the host viewport. All 24 movie titles/directors and all eight accounts were checked; Oxford selection followed by Harper moved the green selection arrow. OK, Cancel and title close worked. `native-remote-films.json`, `native-remote-modal-exact.json`, `native-remote-account-harper.png`. |
| Global shortcuts | Native generated Command+Control+Option+Shift+Q activated the hosted FCT dialog while Finder was focused. Concurrent FCT Q and TUI F8 both activated independently. Remote FCT Q passed initially, after replacement, and after takeover. `native-global-rounds.json`. These are OS registration/delivery checks, not physical-keyboard checks. |
| Raw Clock | Local, hosted, remote and takeover screenshots showed changing clock/hand pixels, and palette changes retained the painter. Compared frames had thousands of changed clock pixels, including hand pixels. `native-*-clock-*.png`. |
| Focused regressions | Raw elements: 4/4 native and 4/4 hosted; image service: 1/1; paragraph/ellipsis: 2/2. The combined hosted/AppKit modal and earlier-native-teardown regression passed five consecutive runs. `native-modal-combined-*.log`, `label-fixed.log`. |

Native `wGac`/`iGac` touch is explicitly excluded by the job; the two touch rows remain blank. Synthetic Core input is not native touch evidence. Windows-only `/Pipe`, `/Http`, UIA and rebuilt `CppTest` sections 3.1/3.2 are outside this macOS matrix; native point-input document checks are expressly excluded by the shared SOP. Mouse/keyboard automation and native generated global chords do not establish physical-device coverage. No Linux or Windows runtime coverage is claimed.

## Issues Found and Fix

### Initial build: popup snapshot type

The first official build failed at `CocoaWindow.mm:1427`: `Pair` belongs to `vl::collections`. Qualifying it as `collections::Pair` repaired the macOS integration build. Imported framework files were regenerated only through import.

### Native modal panels stopped subsequent timer delivery

Open-panel acceptance and cancellation both reproduced an unresponsive renderer/automation endpoint. AppKit consumed the coalesced timer event without clearing its pending flag, so no later timer event was posted. `CocoaApplication::sendEvent:` now dispatches that event in both the provider loop and AppKit modal loops. `NativeModal.mm` checks two AppKit modal loops and subsequent queued/timer work; live open, cancel, save and reload retests passed.

The same open-panel investigation found that directories could be returned to the file loader, causing a serialization short read. Open panels now allow navigation but return files only. A selected test fixture subsequently loaded successfully.

### Queued hosted-window deletion used an already-destroyed native window

An intermittent SIGSEGV occurred twice across the targeted repeats; a deterministic regression reproduced earlier native-child destruction before queued deletion on the old snapshot. GacUI now checks the control-host disposal flag and its current native-window association before destroying the captured native window. The normal destruction notification still performs control-host deletion. Five combined modal/teardown runs passed, with exactly one deletion callback.

### Ellipsized captions forced hosted windows wider than requested

Hosted FCT's responsive modal opened at 291×320 and could not shrink to 240px because CoreGraphics counted the full ellipsized caption as minimum width. Windows label renderers contribute zero width in this mode. CoreGraphics now does likewise while retaining measured height. The new composition regression failed before the fix and passes afterward; live initial 240×320 sizing and all nine grow/shrink checks passed.
