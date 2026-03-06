# iGac — macOS Port of GacUI

macOS implementation of [GacUI](http://www.gaclib.net) using Cocoa and CoreGraphics/Quartz2D.

## License

**Read the [LICENSE](https://github.com/vczh-libraries/iGac/blob/master/LICENSE.md) first.**

## Project Structure

```
iGac/
├── Mac/                        macOS platform implementation
│   ├── NativeWindow/OSX/       Cocoa windowing (controller, window, view, input)
│   │   ├── ServicesImpl/       Service implementations (screen, clipboard, dialog, ...)
│   │   └── CoreGraphics/       CoreGraphics app entry point
│   └── GraphicsElement/
│       └── CoreGraphics/       CoreGraphics rendering engine (renderers, layout, resource manager)
│
├── MacShared/                  Shared static libraries and test utilities
│   ├── CMakeLists.txt          Builds GacUI, GacOSX, GacOSXShared static libraries
│   ├── gac_include.h           Convenience header: includes GacUI, registers DarkSkin theme
│   ├── osx_shared.h/mm         OS X helpers (string conversion, file utils, resource folder)
│   └── UnixFileSystemInfo.*    Cross-platform file system utilities
│
├── MacTest/                    Simple test app (Hello World)
│   ├── CMakeLists.txt
│   └── HelloWorlds/Cpp/Main.cpp
│
├── MacFullControlTest/         Full-featured test app using BlackSkin control template
│   ├── CMakeLists.txt
│   ├── Main.mm
│   └── UI/FullControlTest/     Generated UI source files (copied by testFC_Update.sh)
│
├── Release/                    Git submodule: GacUI release imports, tools, tutorials
│   ├── Import/                 Amalgamated GacUI source files (Vlpp, GacUI, Workflow, ...)
│   ├── Tutorial/               Tutorial projects and resources
│   └── Tools/                  Build tools and scripts
│
├── doc/                        Documentation
│   ├── OSProvider.md           macOS OS provider: controller, services, entry point
│   ├── OSProvider_Window.md    macOS OS provider: INativeWindow, CocoaWindow, popups
│   ├── OSProvider_Graphics.md  macOS OS provider: CoreGraphics rendering, elements, fonts
│   └── lldb.md                 LLDB MCP server setup, debugging workflow
│
├── CMakeLists.txt              Root CMake config (project GacOSX, C++23)
├── build.sh                    Build script (incremental by default, --rebuild for clean)
├── test.sh                     Run MacTest Hello World app (--unblock for background)
├── testFC.sh                   Run MacFullControlTest app (--unblock for background)
└── testFC_Update.sh            Copy BlackSkin UI sources from Release/Tutorial to MacFullControlTest
```

## Building

```bash
./build.sh              # Incremental build
./build.sh --rebuild    # Clean build (git clean -xdf + full rebuild)
```

Build output goes to `build/`. The build system uses CMake with C++23.

### Static Libraries (built by MacShared/CMakeLists.txt)

- **GacUI** — Core GacUI amalgamated sources (Vlpp, VlppOS, VlppRegex, VlppReflection, VlppGlrParser, VlppWorkflowLibrary, GacUI, DarkSkin)
- **GacOSX** — All macOS platform code (Cocoa windowing, CoreGraphics rendering, services)
- **GacOSXShared** — Shared test helpers (osx_shared, UnixFileSystemInfo)

Code is compiled with `VCZH_DEBUG_NO_REFLECTION`. If reflection is needed, remove this define from `MacShared/CMakeLists.txt` and add all reflection `.cpp` files.

## Running

```bash
./test.sh               # Run Hello World test
./test.sh --unblock     # Run in background, prints PID

./testFC.sh             # Run Full Control Test (BlackSkin)
./testFC.sh --hosted    # Run Full Control Test in hosted mode (single window)
./testFC.sh --unblock   # Run in background, prints PID
```

### Updating MacFullControlTest Sources

```bash
./testFC_Update.sh
```

Copies generated UI source files from `Release/Tutorial/GacUI_ControlTemplate/BlackSkin/` to `MacFullControlTest/UI/`, excluding reflection files. Also copies `BlackSkin.bin` resource.

## Documentation

- [doc/OSProvider.md](doc/OSProvider.md) — Controller, services, entry point, and overall architecture of the macOS platform layer.
- [doc/OSProvider_Window.md](doc/OSProvider_Window.md) — INativeWindow implementation (CocoaWindow): window lifecycle, Show/Hide, popups, child windows, custom frame, key differences from Windows.
- [doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md) — CoreGraphics rendering backend: render targets, element renderers, text layout, font management.
- [doc/lldb.md](doc/lldb.md) — LLDB MCP server setup, debugging workflow, graceful app termination.
- [doc/Plan_HostedMode.md](doc/Plan_HostedMode.md) — Implementation plan for macOS hosted mode (single-window rendering).

## Known Issues / Limitations

- `IGuiGraphicsParagraph`
  - Removing hyperlink should cancel any overlapped complete hyperlinks
    - It works on Windows
    - On macos a complete hyperlink needs to precisely selected
    - When removed the style is gone but the underline remains, editing styles won't remove the underline except editing text.
  - In `Preview` mode hyperlink won't react to cursor or clicking.
  - Need to test inserting image
- `FakeDialogService`
  - File dialog shows empty local disk. The issue is in VlppOS, fix it and test here again.
- VKEY mapping is quite big, should be shorter
- Replace CGLayer with Metal for rendering
- Not Implemented:
  - `AsyncService::Semaphore::WaitForTime`
  - `GuiInnerShadowElementRenderer`
  - `GuiFocusRectangleElementRenderer`
  - `GuiGradientBackgroundElement` does not work with round-rect.
  - `CoreGraphicsResourceManager::CreateRawElement`
  - `CocoaInputService::(R|Unr)egisterGlobalShortcutKey`
  - `CocoaClipboardWriter` and `CocoaClipboardReader`
  - `CocoaWindow::GetIcon` and `SetIcon`
