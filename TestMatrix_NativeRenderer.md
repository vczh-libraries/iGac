# Test Matrix Card 2026-09-03 01:57:55 -0700

## Test Matrix

| Test Item | 1st |
| --- | --- |
| [macOS][Test_CppTest_Rvm][`/MiniHttp`] | 2026-09-03 02:10:15 -0700 success |
| [macOS][`/RPT`][`/MiniHttp`] | 2026-09-03 02:24:00 -0700 success |
| [macOS][`/FCT`][`/MiniHttp`] | 2026-09-03 02:28:30 -0700 success |
| [macOS][`/RVMT`][`/MiniHttp`] | 2026-09-03 02:34:00 -0700 success |
| [macOS][`/RVMT`][`/MiniHttp /Cli:<path>`] | 2026-09-03 02:40:00 -0700 success |

## Issues Found and Fix

- The first iGac build exposed stale Cocoa callbacks after importing the new GacUI mouse and Super-key APIs. Updated modifier mapping, global shortcut registration, the Command label, and unified five-button dispatch; the rebuild and every matrix row then passed.
