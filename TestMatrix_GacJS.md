# Test Matrix Card 2026-09-10 18:50:58 -0700

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-09-10 18:55:28 -0700 |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-09-10 19:04:43 -0700 |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over network] | 2026-09-10 19:09:39 -0700 |
| [macOS][`/RVMT`][`/MiniHttp`][Native `RemotingTest_RvmHost` over stdio `/Cli:<path>`] | 2026-09-11T02:20:12.092Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS browser host `?rvmhost`] | 2026-09-11T02:21:46.864Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node `cli.js` over network] | 2026-09-11T02:20:15.322Z |
| [macOS][`/RVMT`][`/MiniHttp`][GacJS Node SEA over stdio `/Cli:<path>`] | 2026-09-11T02:20:23.526Z |

## Build and synchronization

GacJS import/codegen/build/test and all seven live WebKit rows passed. After restoring audited snapshot noise, two consecutive codegen runs produce no additional diff; GacJS has no lasting source changes.

## Issues Found and Fix

Desktop observation: macOS reports `CGSSessionScreenIsLocked=true`; desktop capture is black. Physical input, native global chord activation and final displayed appearance remain unavailable. Native automation, WebKit and terminal-buffer/replay checks are recorded separately.

WebKit RPT completed: initial UI, button marker, grid add/clear, embedded dialog, both local shortcuts, five buttons/modifiers and both wheel axes, reconnect/takeover with retained marker and repeated input, queued File-menu close with Core exit 0, and a fresh fatal run with exact error mask and one matching page error (Core SIGABRT). Native global registration is unavailable in the locked desktop/headless browser. Captures: `/tmp/rpxplat-20260910/webkit-rpt-*.png`.

WebKit FCT completed: paired lists add/clear, independent search/rich-editor markers and tab/renderer retention, exact brackets/braces with 0xDB/0xDD key payloads, two local shortcuts and full mouse/modifier matrix before/after replacement, then Force Exit and Core exit 0.

Native network RVMT passed: RPC, second-host rejection, renderer replacement and normal exit; separate idle and delivery-acknowledgement host loss both produced the exact Core error and one matching page error. Blocked loss was injected with SIGSTOP, 397 unread response bytes observed via netstat, then SIGKILL before replacement polling; the fatal mask arrived at the five-second deadline.

Native `RemotingTest_RvmHost` over stdio: initial/RPC, renderer replacement and subsequent RPC, normal close, idle host loss and blocked-delivery loss passed with exact Core error and one renderer page error. Exact Core !Exit reaped the stdio child; stopped child plus blocked Controls request established in-flight RPC before EOF.

GacJS Node `cli.js` over network: initial/RPC, second-host rejection, renderer replacement and subsequent RPC, normal close, idle host loss and blocked-delivery loss passed with exact Core error and one renderer page error.

GacJS Node SEA over stdio: initial/RPC, renderer replacement and subsequent RPC, normal close, idle host loss and blocked-delivery loss passed with exact Core error and one renderer page error. Exact Core !Exit reaped the stdio child; stopped child plus blocked Controls request established in-flight RPC before EOF.

GacJS browser host `?rvmhost`: initial/RPC, second-host rejection, renderer replacement and subsequent RPC, normal close, idle host loss and blocked-delivery loss passed with exact Core error and one renderer page error.

After the final GacUI template-stacking fix, import/codegen/build/test passed again and a fresh WebKit RPT run passed button mutation, the local shortcut, queued close and Core exit 0. The expected connection-loss console message occurs after normal Core shutdown; no pre-shutdown page error was observed. GacJS remains unchanged.
