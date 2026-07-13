# iGac — macOS Port of GacUI

macOS implementation of [GacUI](http://www.gaclib.net) using Cocoa and CoreGraphics/Quartz2D.

[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/vczh-libraries/iGac)

## License

**Read the [LICENSE](https://github.com/vczh-libraries/iGac/blob/master/LICENSE.md) first.**

## Maintenance Prerequisite

Clone the [Release repository](https://github.com/vczh-libraries/Release) beside this repository as `../Release` before working on iGac. Import refreshes, generated test updates, and framework reference material all use that sibling checkout.

### Install Homebrew and Development Tools

Install Apple's Command Line Tools if they are not already installed:

```bash
xcode-select --install
```

Install Homebrew with the command from the [official Homebrew installation page](https://brew.sh/):

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the installer's **Next steps** to add Homebrew to your shell environment, then install the required formulae:

```bash
brew update
brew install llvm coreutils cmake git node
```

The commands used by this project come from these Homebrew formulae:

| Command or tool | Homebrew formula |
| --- | --- |
| `clang++` | `llvm` |
| `lldb` | `llvm` |
| GNU Coreutils | `coreutils` |
| `cmake` | `cmake` |
| `git` | `git` |
| `node` | `node` |
| `npm` | `node` (npm is included) |

Homebrew's `llvm` formula is keg-only. Add it to the zsh login path to use its `clang++` and `lldb` instead of the versions supplied by macOS:

```bash
echo 'export PATH="$(brew --prefix llvm)/bin:$PATH"' >> ~/.zprofile
exec zsh -l
```

Coreutils commands that conflict with macOS commands are installed with a `g` prefix. To use the GNU commands under their normal names, add the formula's `gnubin` directory to the path:

```bash
echo 'export PATH="$(brew --prefix coreutils)/libexec/gnubin:$PATH"' >> ~/.zprofile
exec zsh -l
```

To update Homebrew and these tools later:

```bash
brew update
brew outdated
brew upgrade llvm coreutils cmake git node
```

See Homebrew's [package update instructions](https://docs.brew.sh/FAQ#how-do-i-update-my-local-packages) for upgrading all installed packages instead.

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
├── Import/                     Amalgamated GacUI source files (Vlpp, GacUI, Workflow, ...)
│
├── doc/                        Documentation
│   ├── OSProvider.md           macOS OS provider: controller, services, entry point
│   ├── OSProvider_Window.md    macOS OS provider: INativeWindow, CocoaWindow, popups
│   ├── OSProvider_Graphics.md  macOS OS provider: CoreGraphics rendering, elements, fonts
│   ├── OSProvider_HostedMode.md macOS hosted mode: virtual windows, render lifecycle
│   └── lldb.md                 Direct LLDB debugging and launch validation
│
├── CMakeLists.txt              Root CMake config (project GacOSX, C++23)
├── import.sh                   Refresh Import/ from the sibling Release repository
├── syncOrg.sh                  Clone and synchronize sibling organization repositories
├── build.sh                    Build script (incremental by default, --rebuild for clean)
├── test.sh                     Run MacTest Hello World app (--unblock for background)
├── testFC.sh                   Run MacFullControlTest app (--unblock for background)
└── testFC_Update.sh            Copy BlackSkin UI sources from ../Release/Tutorial to MacFullControlTest
```

The upstream `Release` repository is expected at `../Release`. This repository commits only its copied `Import/` directory; tutorials and framework knowledge-base documents are read directly from the sibling checkout.

## Synchronizing Organization Repositories

```bash
./syncOrg.sh
```

This synchronizes the sibling `Vlpp`, `VlppOS`, `VlppRegex`, `VlppReflection`, `VlppParser2`, `Workflow`, `GacUI`, `Release`, and `Tools` repositories. Missing repositories are cloned from the `vczh-libraries` GitHub organization. Existing repositories are updated only when they are on `master` with no uncommitted tracked files, untracked files, or unpushed commits. A repository that fails any check is reported in red and skipped while the script continues with the remaining repositories.

## Refreshing GacUI Imports

```bash
./import.sh
```

This removes the existing `Import/` directory, copies the complete `../Release/Import/` directory into this repository, and marks the snapshot read-only. `Import/` is frozen after import: compatibility fixes belong in this repository's CMake or macOS integration code. Review and commit the vendor update together with those integration changes.

## Building

```bash
./build.sh              # Incremental build
./build.sh --rebuild    # Clean build (git clean -xdf + full rebuild)
```

Build output goes to `build/`. The build system requires CMake 3.20 or newer and uses C++23.

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

Copies generated UI source files from `../Release/Tutorial/GacUI_ControlTemplate/BlackSkin/` to `MacFullControlTest/UI/`, excluding reflection files. Also copies `BlackSkin.bin` resource.

## Documentation

- [doc/OSProvider.md](doc/OSProvider.md) — Controller, services, entry point, and overall architecture of the macOS platform layer.
- [doc/OSProvider_Window.md](doc/OSProvider_Window.md) — INativeWindow implementation (CocoaWindow): window lifecycle, Show/Hide, popups, child windows, custom frame, key differences from Windows.
- [doc/OSProvider_Graphics.md](doc/OSProvider_Graphics.md) — CoreGraphics rendering backend: render targets, element renderers, text layout, font management.
- [doc/OSProvider_HostedMode.md](doc/OSProvider_HostedMode.md) — Hosted mode: single-window rendering, hosted controller, virtual windows, render target lifecycle.
- [doc/lldb.md](doc/lldb.md) — Direct LLDB command-line debugging and launch-validation workflow.

## TODO

- `IGuiGraphicsParagraph`
  - Need to test inserting image.
  - Test CocoaClipboardService when image is tested.

## Known Issues

- VKEY mapping is quite big, should be shorter
- Not Implemented:
  - `AsyncService::Semaphore::WaitForTime`
  - `CoreGraphicsResourceManager::CreateRawElement`
  - `CocoaInputService::(R|Unr)egisterGlobalShortcutKey`
  - `CocoaWindow::GetIcon` and `SetIcon`

## Upstream Issues

- `FakeDialogService`
  - File dialog shows empty local disk. The issue is in VlppOS, fix it and test here again.

## Planning

- Replace CGLayer with Metal for rendering
