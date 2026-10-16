# Test Matrix Card 2026-10-16T01:06:53.035Z

Wasm is excluded by request. Results below belong to this run.

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-10-15 18:24 (browser SOP passed; OS global key separate) |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-10-15 19:26:54 (browser SOP exercised; OS global key unavailable) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | 2026-10-15 18:27 |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<path>`] | 2026-10-15 18:33 |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | 2026-10-15 18:36 (fixed) |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | 2026-10-15 18:44 |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node SEA over stdio `/Cli:<path>`] | 2026-10-15 18:48 |

## Issues Found and Fix

## Build and supporting tests

- GacJS import, codegen, build and unit tests passed. Windows-only E2E suites report their expected macOS skip; the live WebKit results are recorded below.
- Initial build lacked workspace dependency links. `yarn install --frozen-lockfile` restored them; build and tests then passed without source changes.

## Live WebKit evidence

- FCT: both lists add exact 0–9 and clear; two editor markers including brackets survive navigation; local Ctrl+Q and Ctrl+Alt+Command+Q dialogs; five mouse buttons/down/up/double-click and both wheel axes under eight modifier combinations through browser events; Raw Clock pixels tick without input, survive hide/show on the same canvas, viewport and palette changes, replacement and live takeover; detached renderer input is ignored; queued Close followed by Force Exit shuts Core down cleanly.
- Responsive dialog: 240/350/440/680 widths in two cycles, 220/520 heights, modal OK/Cancel, initial dimensions on reopen. Detailed layout and state checks were completed in the follow-up below.
- Screenshots: `<iGac repo>/build/task4/webkit-clock.png`, `<iGac repo>/build/task4/webkit-responsive-large.png`.
- Browser mouse replay is distinct from physical Cocoa input and browser-global OS hotkeys.

- RPT: exact initial title/tabs, changed Home button, 3x3 populated grid then Clear, embedded RIGHT NOW modal, both local shortcuts, five-button/modifier/wheel sequence before and after replacement and takeover, marker retained, clean confirmed queued Close/Force Exit. Fresh fatal injection produced the exact error mask and one matching page error, with nonzero Core termination.

- Native network RVMT: exact greeting and printable RPC marker, rejected extra hosts exited 1 while the accepted host continued; renderer replacement preserved state and later RPC calls, normal browser Exit terminated Core with code 0. The harness was corrected to wait for listener readiness before starting a manual host, and to accept rejected-host exit without waiting for buffered output.

- Native network RVMT host-loss variants passed: idle-next-call and blocked delivery. The blocked run observed 380 bytes in the stopped host socket receive queue before killing that host; Core reported the exact disconnect and terminated after about 5.3 seconds. Both pages had the exact fatal mask and one matching page error.
- Native stdio normal run passed RPC, renderer replacement, normal Exit and automatic host reaping.

- Native stdio host-loss variants passed with exact fatal masks and one matching page error, in 335 ms idle-next-call and 438 ms blocked-call; the latter retained a pending Controls read while the host was stopped.

### Browser-host takeover stops its accepted service

Reproduced three times in WebKit: RPC succeeds in the host page, but creating an ordinary replacement renderer stops the accepted host and its next RPC reports `RemotingTest_RvmHost disconnected.`. The HTML page unconditionally called `session.stop()` in its completion cleanup. The fix retains the host for renderer disconnection, disposes renderer/clock state, and keeps full session cleanup on host completion, page teardown and fatal error. Added built-page regression coverage for all three outcomes; full build/tests and live retries passed.

The browser-host fix also handles `RequestControllerConnectionStopped`, which is used for takeover as well as normal renderer stopping. Host completion performs remaining session cleanup. All 28 built-page/session tests passed. Live normal startup/RPC/replacement, second-host rejection, normal Exit, idle host loss and blocked delivery loss passed. The blocked variant retained both the real replacement Request and RPC Response, confirmed a queued Controls read, then stopped only the host; the exact error arrived in 5.0 seconds.

- Node network host: normal RPC, second-host rejection, renderer replacement and normal Exit passed; idle-next-call loss passed in 354 ms and blocked delivery loss in 5.4 seconds after confirming a positive receive queue.

- Node SEA stdio: RPC and renderer replacement passed. Exact Core automation `!Exit` ended Core with code 0 and reaped the SEA child. Idle and blocked host-loss variants passed in 272 ms and 446 ms with the exact fatal mask and one matching page error.

FCT completion: Easy Layout editor/choice state survived four palette switches. Automation header/button bounds confirmed an exact five-pixel gap. The responsive modal exposed eight accounts, retained selected movie/account through repeated 240/350/440/680 widths and 220/520 heights, kept equal-width OK/Cancel labels and reachable footer, and reopened under Aurora. Account-menu selection screenshots were retained. Native FCT separately scrolled and verified all 24 film titles.

The changed-account screenshot was visually inspected: the green selection arrow moved to HarperCollins, with all eight account labels and the modal footer visible.

Unicode RPC: all five live RVMT host modes returned the exact appended Chinese/Japanese marker from DOM keyboard events on the real renderer input surface, then Force Exit ended Core cleanly. This is browser-event replay, distinct from physical IME delivery.
