# Test Matrix Card 2026-11-04T04:02:01-08:00

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-11-04T12:05:27.052Z |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-11-04T12:11:50.614Z (fixed) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | 2026-11-04T12:08:17.848Z |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<path>`] | 2026-11-04T12:09:14.882Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | 2026-11-04T12:09:27.925Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | 2026-11-04T12:09:49.419Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over stdio `/Cli:<command>`] | Pending: replacement command not verified on this platform |
| Import / codegen / build / tests | 2026-11-04T12:08:17.848Z |

## Observations and Limitations

The replacement Node command has not been verified on macOS. Platform
verification was explicitly skipped during the Windows maintenance task. The
retired packaged-host row previously passed at 2026-11-04T12:10:10.436Z;
the observations below describe that historical run, not the replacement command.

Playwright WebKit on macOS 26.5.2 arm64, with a fresh `/MiniHttp` Core for each topology. Initial GacJS commit `5531c26`, plus the capture fix below. Local ignored evidence is under `<iGac repo>/_OUTPUT_/rpXPlat-20261104/`.

| Coverage | Observed result / evidence |
| --- | --- |
| Build and portable tests | `yarn run import`, code generation twice with identical generated output, build and test passed: 236 tests in 30 files. Windows-only native-browser suites are intentionally skipped on macOS. |
| RPT | Initial UI/Home, shortcuts, mouse input, add/clear grid, document dialog, renderer replacement/takeover and retained state, normal exit and Core-authored fatal overlay passed. `webkit-rpt-*.json`. |
| FCT | Lists, two editor markers and OEM brackets, keyboard/mouse input, layout tabs and palette retention, four responsive appearances and nine sizes, scrolling, account selection, OK/Cancel/title-close and normal exit passed. A final browser-driven scroll sweep verified all 24 movie titles and their directors in Core controls and rendered DOM (`webkit-all-films.json`). Raw Clock pixels/state survived palette and renderer lifecycle changes. `webkit-fct-editors.json`, `webkit-responsive-sizes.json`, `webkit-modal-scroll.json`, `webkit-clock.png`. |
| Five historical RVM host topologies | Initial/Unicode RPC and renderer replacement, normal exit, idle-next-call host loss and blocked-delivery host loss passed for native network, native stdio, browser host, Node network and the retired packaged Node stdio host. Manual network/browser modes rejected a second host. Stdio children terminated after normal Core shutdown. Fifteen results in `webkit-rvm-results.json`. |
| Browser touch | Shared Touching, TouchingList and ordinary/document gesture helpers passed through DOM-synthetic PointerEvents, including transforms, cancellation, fallback, row identities, selection and momentum checks. `webkit-touching.json`, `webkit-touching-list.json`, `webkit-ordinary-touch.json`. |
| Mouse capture regression | Three outside-release resize repetitions and two title-drag repetitions passed after observing Core's capture request. Returning without a pressed button left bounds unchanged. `webkit-outside-release-after.json`, `webkit-title-capture.json`. |

The WebKit adapter's synthetic PointerEvents establish gesture dispatch and rendered behavior; they do not establish physical touch acquisition, actual pointer-capture acquisition, outside-surface touch retention, mobile hardware or installed Safari coverage. Native OS global shortcuts are outside browser JavaScript's delivery path. The rebuilt Windows `CppTest`/UIA-only document scenarios in shared sections 3.1/3.2 were not claimed; the applicable browser gesture scenarios were exercised separately. Wasm was not requested by this job. No Chromium, Firefox, Linux or Windows runtime result is implied.

## Issues Found and Fix

### FCT: releasing a captured mouse drag outside the renderer

Reproduced twice: releasing a modal resize outside `#gacui-screen`, then returning without a pressed button, continued resizing (945×320 became 181×181). `RequestIORequireCapture` and `RequestIOReleaseCapture` were ignored, so the outside release did not reach Core. Before-fix evidence: `webkit-outside-release-before.json`.

The renderer now tracks Core capture and forwards outside document mouse events through its existing handlers. Events already handled inside the surface are not duplicated. Release and disposal clear capture and remove listeners. The browser regression checks the outside-up coordinates, exactly-once inside delivery, release, and disposal; the full portable suite and live resize/title retests passed. DOM/protocol documentation and the reusable shared SOP now describe this behavior.
