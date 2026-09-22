# Test Matrix Card 2026-09-22 00:03:15 -0700

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | Normal PASS 23:46–23:52; exit probe PASS 00:03; fresh fatal included (`/tmp/rpxplat-20260921/browser-normal`, `browser-exit-probes`) |
| [macOS][`/FCT`][`/MiniHttp`] | Normal PASS 23:53–23:59; exit probe PASS 00:03 (`/tmp/rpxplat-20260921/browser-retry-normal`, `browser-exit-probes`) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | Normal PASS 23:51; fresh idle PASS 00:00; fresh blocked PASS 00:00 (`/tmp/rpxplat-20260921/browser-blocked`) |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<path>`] | Normal PASS 23:51; fresh idle PASS 00:00; blocked retry PASS 00:01 (`/tmp/rpxplat-20260921/browser-blocked-stdio-retry`) |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | Normal PASS 23:59; fresh idle PASS 00:00; fresh blocked PASS 00:00 (`/tmp/rpxplat-20260921/browser-blocked`) |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | Normal PASS 23:52; fresh idle PASS 00:00; fresh blocked PASS 00:00 (`/tmp/rpxplat-20260921/browser-blocked`) |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node SEA over stdio `/Cli:<path>`] | Normal PASS 23:52; fresh idle PASS 00:00; blocked retry PASS 00:01 (`/tmp/rpxplat-20260921/browser-blocked-stdio-retry`) |

## Build and synchronization

GacJS import/codegen/build/test passed: 159 tests across 10 packages. GacUI Core and
native RVM host builds also passed. The tested GacUI baseline is revision
`83fc7100b`; the temporary WebKit harness is
`/tmp/rpxplat-20260921/browser-matrix.mjs`.

## Issues Found and Fix

RPT covered initial UI, button/grid/document actions, local shortcuts, the full
left/middle/right mouse and modifier matrix with both wheel axes, renderer
replacement and concurrent takeover, detached-renderer input isolation, the
required File → `self.Close()` confirmation path, and a fresh fatal run with
the exact error mask, one page error, and nonzero Core termination. The short
exit probe also verified code 0 and no signal for the normal close path.

FCT covered paired list add/clear, independent search and rich-editor markers,
0xDB/0xDD key-code payloads including explicit shifted brace chords,
shortcut and mouse matrices before and after replacement, and Force Exit with
Core exit code 0. Easy Layout checks covered five outer control bounds, shared
track proportions, both directions, edited marker retention through rebuild,
900×700 resize and restoration, choice retention, all six palettes, checkbox
state, and inert buttons.

All five RVMT topologies passed normal initial/RPC, renderer replacement,
normal close, and second-host rejection where applicable. Each topology also
passed fresh idle-loss and blocked-delivery loss with the exact Core error mask,
one matching page error, nonzero Core termination, and bounded acknowledgement.
The browser-host rejection path retained the original host while the rejected
page displayed its error mask. WebKit cannot synthesize native Mouse4/Mouse5
input; those buttons were covered separately with cancelable browser-boundary
events and protocol payload/history assertions. All owned listeners, hosts,
browsers, and dialogs were cleaned after each batch.
