# Remote Protocol Catch-Up Notes

These are the issues encountered while bringing wGac to the state described by `GacUI/DebugRemoteProtocolCrossPlatform.md`, and how they were resolved. They are intended as a checklist for the equivalent iGac work; no iGac implementation was inspected while writing this note.

## Import and shared sources

- Run `import.sh` before changing project files. The old local `Mini*.cpp` responsibilities are now supplied by the imported GacUI framework and `Import-Test/Test.RemotingHelpers.*`. Delete the stale shared-project `Mini*.cpp` copies, compile the imported test-helper implementation in the shared test target, and add `Import-Test` to its include paths.
- Treat `Import/` and `Import-Test/` as generated snapshots. The wGac refresh produced a large line-ending-only diff in addition to real upstream changes; review with `git diff --ignore-space-at-eol`, but commit the exact imported output instead of hand-normalizing it.

## Project synchronization

- Add `RemoteViewModelTest` to `syncProj.sh`. Its resource tree has a `Source/` directory containing seed RPC files that GacGen does not recreate. Copy those files into `Apps/RemoteViewModelTest/Source/` before removing `Resources/Source`, then run GacGen and copy `RemoteViewModelTestInitialize.{h,cpp}` from GacUI.
- Copy the shared `CppTest_Rvm/GuiMain.cpp` and native-renderer `GuiMain.cpp` from GacUI rather than maintaining platform forks. On GCC, the RVM entry point includes `RemoteViewModelTest.h`; `RemoteViewModelTestIncludes.h` is a Visual Studio generated convenience header and is not produced by the portable GacGen run.
- Clang requires `template Cast<...>()` for `RequestService(...).Cast<...>()` inside templated server functions. This was fixed upstream in both `CppTest_Rvm` and `RemotingTest_Core`; synchronize those versions before compiling.

## Platform entry points

- Rename the native-renderer project folder and target from `RemotingTest_Renderer_macOS` to `RemotingTest_Rendering_macOS`, matching `RemotingTest_Rendering_Win32` and `RemotingTest_Rendering_Wayland`; update its CMake, launcher, synchronization script, and documentation references together.
- The shared renderer entry point must substitute the platform renderer automation service (`CocoaAutomationServiceRenderer` on macOS), not the neutral `AutomationServiceRenderer`; the neutral implementation cannot execute native IO commands.
- Add the local RVM executable target and `test.sh --app:rvmt` path. It accepts `/MiniHttp`, uses the hosted macOS setup, and waits for `GacUI/Test/Linux/RemotingTest_RvmHost/Bin/RemotingTest_RvmHost /MiniHttp`.
- The shared renderer uses the automation prefix `/Automation/RemotingTest_Rendering_Native`. Do not retain the old platform-specific prefix.
- Support `/port:<port>` in `RemotingTest_Rendering_macOS` and expose it through `test.sh --app:renderer --port:<port>`. Replacement can reuse the default 8889 after the old renderer stops, but takeover needs the old renderer on 8889 and the new renderer on another port such as 8890. This option changes only the renderer automation listener; Core still uses `/MiniHttp` on 8888.

## Verification lessons

- Build and run the standard and hosted Full Control Test, the local RVM client with its host, and `RemotingTest_Core` with the native renderer for `/RPT`, `/FCT`, and `/RVMT`.
- For renderer DOM checks, `Elements` is a cache and retains historical or hidden text. Collect element IDs reachable from the current `Dom` tree and validate only matching `Elements`; otherwise a closed dialog can look present.
- Verify RPT replacement and takeover with separate automation ports, preserved `You have clicked!` state, clean detachment of the old renderer, and a status-0 UI-driven shutdown of Core and the active renderer.
