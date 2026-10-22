# Test Matrix Card 2026-10-22T00:41:59.196Z

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-10-22T00:58:37.915Z |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-10-22T00:57:35.059Z (WebKit ordinary UI; Chromium CDP touch) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | 2026-10-22T00:53:54.285Z |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<path>`] | 2026-10-22T00:53:56.652Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | 2026-10-22T00:54:04.169Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | 2026-10-22T00:54:11.322Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node SEA over stdio `/Cli:<path>`] | 2026-10-22T00:54:13.462Z |

## Issues Found and Fix

## Step 4 scope

WASM builds, tests and website deployment are excluded by request. Results belong only to this macOS run.

The native iGac touch exclusion does not apply to browser input.

- FCT passed lists, two editor markers, ordinary mouse buttons/modifiers, local shortcuts, layout/palette retention, responsive modal widths 240/350/440/680 and heights 220/320/520, Raw Clock pixels and renderer replacement/takeover. Touching/TouchingList and text selection passed the adapted WebKit PointerEvent fixture with capture simulated; this does not establish browser-native or physical touch acquisition.

- Chromium 145.0.7632.6 subsequently passed all 41 checks in the adapted browser-level CDP touch fixture, including transformed pixels, contact membership, cancellation, swipe deletion, scrolling, text selection and palette replacement. Only viewport preconditions and local evidence paths were adapted. This establishes browser touch acquisition; physical/mobile hardware remains unverified. Evidence: `<iGac repo>/build/touch-step4/chromium-touch-step4-browser.json`.
- All five RPC host modes passed normal RPC/replacement/shutdown and idle/blocked host loss with exact fatal errors. Logs: `<iGac repo>/build/touch-step4/rvm-normal.json` and `<iGac repo>/build/touch-step4/rvm-loss.json`.
- `yarn install --frozen-lockfile`, import, codegen, build and test passed. The Windows-only HTTP E2E suite skipped on macOS as expected. A second codegen left GacJS clean. No WASM command or publication was run.
