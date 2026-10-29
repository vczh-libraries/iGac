# General Instructions

At the end of every request, run the following scripts in order:
- `./import.sh`
- `./syncProj.sh`
- `./build.sh`
and they must all succeed.

When missing any dependencies to libraries, cmake and build scripts must be updated properly, and treat `./build.sh` as the only official verification.

All build scripts and makefiles, including CMake files, must remain usable on a fresh computer with a fresh clone after installing the documented prerequisites. They must not depend on temporary folders, machine-specific paths, or artifacts left over from previous builds. Any required generated inputs must be reproducible through the documented build process.

## Before You Start

**You MUST read these files before doing any work:**

1. **[readme.md](readme.md)** — Project structure, build commands, script descriptions.
2. **[doc/OSProvider.md](doc/OSProvider.md)** — Controller, services, entry point, overall architecture.
3. **[doc/OSProvider_Window.md](doc/OSProvider_Window.md)** — INativeWindow (CocoaWindow): window lifecycle, popup management, coordinate systems, differences from Windows.
4. **[doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md)** — CoreGraphics rendering: render targets, element renderers, text layout, font management.
5. **[doc/OSProvider_HostedMode.md](doc/OSProvider_HostedMode.md)** — Hosted mode: single-window rendering, hosted controller, virtual windows, render target lifecycle.

Read them thoroughly. Most macOS porting bugs come from behavioral differences between Win32 and Cocoa that are documented there.

**Debugging reference:**

6. **[doc/lldb.md](doc/lldb.md)** — Direct LLDB command-line debugging, launch validation, and process cleanup.

**Critical reference — GacUI Knowledge Base:**

7. **[../GacUI/.github/KnowledgeBase/Index.md](../GacUI/.github/KnowledgeBase/Index.md)** — The master index in the sibling `GacUI` repository for all GacUI framework knowledge: preferred data types, API guidance for every library (Vlpp, VlppOS, VlppRegex, VlppReflection, GacUI, Workflow), and design explanations covering platform initialization, window management, element rendering, layout, focus, and more. **You MUST consult the relevant Knowledge Base articles before implementing or modifying any feature that touches GacUI framework interfaces.** Key design docs include:
   - `KB_GacUI_Design_PlatformInitialization.md` — Entry points, hosted/raw/standard modes, renderer setup, service registration.
   - `KB_GacUI_Design_MainWindowModalWindow.md` — Modal windows, hosted mode considerations, event loop architecture.
   - `KB_GacUI_Design_ImplementingIGuiGraphicsElement.md` — Element lifecycle, renderer registration, render target abstraction.
   - `KB_GacUI_Design_LayoutAndGuiGraphicsComposition.md` — Layout system, composition hierarchy, invalidation chain.

## Key Facts

- This is the **macOS port** of GacUI. The framework snapshot under `Import/` and test-only remoting helpers under `Import-Test/` are assembled from the sibling `../GacUI/Import/` and `../GacUI/Release/` directories by `./import.sh`.
- **`Import/` and `Import-Test/` are frozen after `./import.sh` completes. Never modify anything under either directory to fix a build break.** Fix compatibility in this repository's CMake files or macOS integration code. Framework changes belong in their upstream repository and are re-imported through `GacUI`.
- All macOS-specific code is under `Mac/`. Shared test utilities are in `MacShared/`.
- Build with `./build.sh` (incremental) or `./build.sh --rebuild` (clean).
- Test native apps with `./test.sh --app:simple`, `./test.sh --app:fct`, `./test.sh --app:fct --hosted`, `./test.sh --app:rvmt`, `./test.sh --app:tui`, or `./test.sh --app:renderer`; use `./test_core.sh --app:fct|rpt|rvmt --protocol:minihttp` for the sibling GacUI Core-side launcher.
- Run `<iGac repo>/syncProj.sh` to incrementally build Workflow's `CppMerge` and GacUI's `GacGen` and `GacBuild`, copy Full Control Test, Remote Protocol Test, Remote View Model Test, and Tui Control Test resources from `<GacUI repo>/Test/Resources/App/`, and call `<iGac repo>/GacBuild.sh -mode:GacGen` to merge their x32/x64 C++ sources under `<iGac repo>/Apps/`.
- The native remote renderer uses automation port 8889 by default; use `--port:<port>` for a concurrent takeover renderer.
- Generated embedded-resource `.cpp` files remove the need to load test resource binaries from disk.
- Every test target compiles with `VCZH_DEBUG_NO_REFLECTION`; generated reflection source files under `Apps/*/Source` are not added to the targets.

`<iGac repo>/GacBuild.sh` owns upstream executable discovery, explicit absolute GacGen and CppMerge paths, and the temporary full-metadata entry point. It defaults to GacBuild driver-XML mode; put `-mode:GacGen` first for one resource. Preserve the caller's working directory, argument boundaries, native exit status and cleanup on failure. Keep the temporary GacGen symlink unresolved: its adjacent `Metadata.txt` selects full `Reflection32.bin` and `Reflection64.bin` from `<GacUI repo>/Test/Resources/Metadata/`, including generated dialog types absent from the normal core-only metadata.

GacBuild runs `/P32` and `/P64`, validates both staging trees, and merges matching files with CppMerge while preserving upstream seed `USER_CONTENT`, embedded resources and `RemoteViewModelTestRpc.h/.cpp`. Keep generated reflection files and the existing target exclusions. Retain `<iGac repo>/Apps/*/Resources/GacBuild.log` and `<iGac repo>/Apps/*/Resources/Resource.xml.log/{x32,x64}/` for diagnostics, including compiler logs, staged C++/RPC files and `Deploy.xml`. These artifacts are ignored by Git. A compiler, artifact, merge or deployment failure must stop synchronization with nonzero status.

## When You Make Changes

**You MUST update the documentation if your changes affect anything documented:**

- If you modify window behavior (Show, Hide, SetBounds, SetParent, popups, focus, etc.) → update [doc/OSProvider_Window.md](doc/OSProvider_Window.md).
- If you modify rendering, element renderers, text layout, or font management → update [doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md).
- If you modify hosted mode behavior (entry point, render target lifecycle, virtual windows) → update [doc/OSProvider_HostedMode.md](doc/OSProvider_HostedMode.md).
- If you modify the controller, services, or entry point → update [doc/OSProvider.md](doc/OSProvider.md).
- If you add/remove/rename files, directories, scripts, or CMake targets → update [readme.md](readme.md).
- If you add new documentation files → add them to the Documentation section in [readme.md](readme.md).
- If you change build steps or script behavior → update [readme.md](readme.md).

Documentation must stay in sync with the code. If you fix a bug or implement a feature, check whether the relevant doc section needs updating.

## Architecture Notes

- `Import/GacUI.h` defines the platform abstraction interfaces (`INativeController`, `INativeWindow`, `INativeWindowListener`, etc.). Read the interface comments to understand the contract before implementing.
- `Import/GacUI.Windows.cpp` is the Windows implementation. When the macOS behavior is unclear, check how Windows does it — the macOS port should match Windows semantics.
- The render loop only runs when `INativeWindow::IsVisible()` returns true. Never add extra conditions to `IsVisible()` that would prevent 0×0 windows from being "visible" — popup windows start at 0×0 and rely on the render loop to compute their size.
- `SetBounds()` must not call `Show()`. On Windows, `MoveWindow`/`SetWindowPos` repositions without showing. GacUI calls `Show()`/`ShowDeactivated()` explicitly.
- macOS Cocoa uses bottom-left origin coordinates. All coordinate conversions go through `FlipY()`/`FlipRect()` in `CocoaHelper`.
- `NSWindowStyleMaskBorderless = 0`. Bitwise XOR/AND operations on style masks do not work as expected with this value. Use explicit flag-based reconstruction (see `UpdateStyleMask()`).
- **Never use `GetCurrentController()` in OS provider code** (`Mac/`). In hosted mode, `GetCurrentController()` returns `GuiHostedController`, not the native `CocoaController`. The hosted controller has its own `CallbackService`, `WindowService`, etc. that manage virtual windows — calling them from the OS provider (which deals with real Cocoa objects) causes bugs. Use `GetOSXNativeController()` (declared in `CocoaNativeController.h`) instead. Test/app code (`MacShared/`, `MacTest/`, `MacFullControlTest/`) should continue using `GetCurrentController()`, as application-level code is meant to go through whichever controller is active.

## Testing Rules

- After launching a test app (via `./test.sh`, `./test_core.sh`, or directly), you **MUST** ensure the process is killed or properly exited when done. Never leave test processes running.
- When LLDB or a test app is no longer needed, just kill the processes directly — do not rely on `lldb_terminate` or graceful shutdown, as those may hang or be unavailable.
- Use `--unblock` to launch GUI apps in background and get the PID for later cleanup. TUI requires foreground inherited stdin/stdout and rejects this flag. Follow `../GacUI/.github/Jobs/DebugTuiControlTestSop.md` and maintain `TestMatrix_Tui.md`.
- Verify `--app:rvmt` with `GacUI/Test/Linux/RemotingTest_RvmHost /MiniHttp`.
- When testing the native remote renderer, follow `../GacUI/.github/Jobs/DebugRemoteProtocolWithNativeRenderer.md` and verify `/RPT`, `/FCT`, renderer replacement, takeover, and clean shutdown.
- Use the following to find and kill test/debugger processes:

```bash
# Find all running test processes
pgrep -fl 'Test_TuiControlTest|Test_FullControlTest|Test_HellWorld|Test_CppTest_Rvm|RemotingTest_Rendering_macOS|RemotingTest_Core|RemotingTest_RvmHost|lldb'

# Kill all test and debugger processes
pkill -f 'Test_TuiControlTest|Test_FullControlTest|Test_HellWorld|Test_CppTest_Rvm|RemotingTest_Rendering_macOS|RemotingTest_Core|RemotingTest_RvmHost|lldb'
```

## Files You Should Never Modify

- Anything under `Import/` — these files are assembled from `../GacUI/Import/` and `../GacUI/Release/` by `import.sh` and should be changed upstream, then re-imported.
- Anything under `Import-Test/` — these test-only remoting helpers are assembled from `../GacUI/Release/` by `import.sh` and should be changed upstream, then re-imported.
- Anything under `Apps/*/Resources/` or `Apps/*/Source/` — these are synchronized/generated by `syncProj.sh`.
- Anything under sibling upstream source repositories unless the task explicitly includes that repository.
- `build/` — generated build artifacts.

## Remote feature injection

Native renderer executables accept `/remoteDT`, `/remoteLocale` and `/remoteFS`.
All three demo options default to false. The corresponding `test.sh --app:renderer`
and `test_core.sh --app:fct --protocol:minihttp` shell options are `-remoteDT`,
`-remoteLocale` and `-remoteFS`; scripts translate them to slash switches in both
foreground and `--unblock` modes. Enable each desired feature independently on
both core and renderer. Keep the canonical renderer GuiMain and SharedArguments
synchronized from GacUI. Reconnection reevaluates capabilities; DateTime/Locale
fall back to the predecessor, while an unavailable injected filesystem is empty.

FullControlTest's authored shared helper is `FullControlTestEventHandlers.h/.cpp`.
Synchronize it with the XML/generated event definitions. Native entry points call
`demo::AttachFctEvents<demo::DocumentEditorBase>` once per main window, attaching
four document events per editor plus the palette event to their correct owners.

## Choosing the remote Core host

`./test.sh --app:renderer --corehost:core.example.com` selects the destination; omitting `--corehost` defaults to localhost. The option is renderer-only, case-sensitive, nonempty and allowed once. Both foreground and `--unblock` branches forward one quoted `/corehost:<host>` argument. The native entry point uses the canonical GacUI parser and accepts DNS hostnames, IPv4 and IPv6 addresses (optionally bracketed), without a URL, path or separate port. Invalid or duplicate native arguments are rejected before transports start.

```bash
./test.sh --app:renderer --corehost:core.example.com --port:8889
./test.sh --app:renderer --corehost:::1 --port:8890 --unblock
```

Native renderers here use `/MiniHttp`; `/Pipe` and `/Http` are Windows transports. Protocol TCP port is always 8888. `--port` changes only local renderer automation, default 8889, and can be combined with destination and injection options. The local Core/requester launchers need no destination option. A manually launched `RemotingTest_RvmHost /MiniHttp /corehost:core.example.com` connects to Core `/RVMT` or a requester server; its local `/Cli` mode rejects an explicit host.

Keep SharedArguments and renderer GuiMain synchronized from GacUI, and maintain the platform Main.cpp separately. Socket destinations are unbracketed IPv6; HTTP authorities add brackets. Native listeners use wildcard interfaces; network reachability still depends on the host environment. Same-machine hostname checks do not verify another computer.
