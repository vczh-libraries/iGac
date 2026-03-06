# macOS INativeWindow Implementation

This document describes how `INativeWindow` is implemented on macOS via `CocoaWindow`, including window lifecycle, popup management, and behavioral differences from Windows.

For the overall architecture (entry point, INativeController, services), see [OSProvider.md](OSProvider.md).
For graphics rendering and elements, see [OSProvider_Graphics.md](OSProvider_Graphics.md).

## CocoaWindow

**File:** `Mac/NativeWindow/OSX/CocoaWindow.mm`

`CocoaWindow` implements `INativeWindow`. Each instance wraps an `NSWindow` (specifically the `CocoaNSWindow` subclass), an `NSWindowController`, and a `CocoaWindowDelegate`.

### Window Creation

`CreateWindow()` allocates a `CocoaNSWindow` with:
- Style: `Titled | Closable | Miniaturizable | Resizable`
- Backing: `NSBackingStoreBuffered`, deferred: `YES`
- Initial frame: `(0, 0, 0, 0)` — the window starts hidden and zero-sized

The window is **not shown at creation time**. It only becomes visible when GacUI explicitly calls `Show()` or `ShowDeactivated()`. This is important: GacUI creates multiple native windows during initialization (for popups, tooltips, menus) and controls their visibility via its own lifecycle.

### Show / ShowDeactivated / Hide

**`Show()`** — For the main window (no parent): `[nsWindow makeKeyAndOrderFront:nil]` + `[nsWindow makeMainWindow]`. For child windows with non-borderless style (modal dialogs): `[nsWindow makeKeyAndOrderFront:nil]` + `makeFirstResponder`. For borderless child windows (popups): `[nsWindow orderFront:nil]` + `makeFirstResponder`. On first call, fires `InvokeOpened()`.

**`ShowDeactivated()`** — Used for popups. Calls `[nsWindow orderFront:nil]` + `makeFirstResponder` without making the window key or main. Wrapped in `suppressClosePopups = true/false` to prevent re-entrant popup closing (see below). On first call, fires `InvokeOpened()`.

**`Hide(bool closeWindow)`** — Matches Windows' `PostMessage(WM_CLOSE)` semantics. The `closeWindow` argument is reserved and not used. Calls `InvokeClosing()` first — if cancelled, returns immediately. Otherwise hides the window via `[nsWindow orderOut:nil]`, fires `InvokeClosed()`. For the main window, additionally defers `DestroyNativeWindow` via `dispatch_async` to trigger app exit (the deferral avoids deleting `this` while still inside `Hide()`, matching Windows' async `PostMessage` behavior). The main window check uses `cocoaController` (the native controller stored at construction) rather than `GetCurrentController()`, because in hosted mode `GetCurrentController()` returns the `GuiHostedController` whose `GetMainWindow()` returns a `GuiHostedWindow`, not the native `CocoaWindow`.

### IsVisible

```objc
return [nsWindow isVisible];
```

This is critical for GacUI's render loop. The render loop (`GuiGraphicsHost::Render`) **only runs when `nativeWindow->IsVisible() == true`**. Inside the render loop, `UpdateClientSizeAfterRendering()` computes the correct layout size and resizes the window.

A window that starts at 0×0 (like menu popups) relies on the render loop to compute its content size. If `IsVisible()` returned `false` for 0×0 windows, the render loop would never run, and the window would stay at 0×0 forever — a deadlock. This is why `IsVisible()` must not add extra checks like `frame.size.width > 0`.

### SetBounds / SetClientSize

**`SetBounds()`** — Notifies listeners via `Moving()`, flips coordinates for macOS (Cocoa uses bottom-left origin), calls `[nsWindow setFrame:display:YES]`. Does **not** call `Show()`.

On Windows, `SetBounds` maps to `MoveWindow` / `SetWindowPos`, which repositions and resizes without affecting visibility or activation. The macOS implementation must match this behavior — `SetBounds` should never make a window visible or steal focus. GacUI calls `Show()` / `ShowDeactivated()` explicitly when it wants a window displayed.

**`SetClientSize()`** — Computes the new bounds preserving the top-left position, then calls `SetBounds()`.

### SetParent / Child Windows

`SetParent(parent)` manages the macOS child window relationship:
- Removes from old parent: `[oldParent removeChildWindow:nsWindow]`, removes from `childWindows` list
- Adds to new parent: `[newParent addChildWindow:nsWindow ordered:NSWindowAbove]`, adds to `childWindows` list
- The `addChildWindow:` call is wrapped in `suppressClosePopups = true/false` because it synchronously triggers `windowDidBecomeKey:` → `InvokeGotFocus()` → `ClosePopups()`, which would immediately close the popup being opened.

Popup windows (menus, tooltips, combo dropdowns) are child windows of their logical owner.

### SetTopMost / GetTopMost

On Windows, "TopMost" means `WS_EX_TOPMOST` — a z-order flag that keeps a window above all non-topmost windows. The macOS equivalent is the **window level**:

```objc
void SetTopMost(bool topmost) {
    [nsWindow setLevel: topmost ? NSPopUpMenuWindowLevel : NSNormalWindowLevel];
}
bool GetTopMost() {
    return [nsWindow level] > NSNormalWindowLevel;
}
```

GacUI calls `SetTopMost(controlWindow->GetTopMost())` when opening popups to ensure they appear above their owner.

### Custom Frame Mode

When custom frame mode is enabled, the window uses `NSWindowStyleMaskBorderless` so GacUI can draw its own window chrome. `UpdateStyleMask()` computes the style mask based on `customFrameMode`, `hasBorder`, `hasSizeBox`, and `hasMinimizedBox`.

In custom frame mode, `CocoaWindow` handles hit-testing manually in `HandleEventInternal()` to detect resize edges and title bar drag areas, matching the behavior of `INativeWindowListener::HitTest()`.

Note: `NSWindowStyleMaskBorderless` has value 0. This means XOR-based toggling does not work — the style mask must be rebuilt from the boolean flags each time.

### Popup Auto-Close

Popups must close when the user clicks outside or the app loses focus. This is managed by three mechanisms:

**1. Mouse-down in `HandleEventInternal()`** — When any mouse button is pressed, `ClosePopups(this)` is called before the event is dispatched.

**2. `InvokeGotFocus()`** — When a window gains focus, `ClosePopups(this)` is called (unless `suppressClosePopups` is true).

**3. `applicationDidResignActive:`** — When the app loses focus entirely, `ClosePopupsOnActivation(nullptr, nullptr)` closes all popups.

**`ClosePopups(activatedWindow)`** builds an exception list (the activated window and all its parents up the chain) and calls `ClosePopupsOnActivation()`, which iterates all Normal-mode windows and for each calls `ClosePopupsOf()`.

**`ClosePopupsOf(owner, exceptions)`** is a static recursive method: for each child of `owner`, if the child is non-Normal mode, visible, and not in the exceptions list, it calls `Hide(false)`. Then it recurses into that child's children.

**`suppressClosePopups`** — A file-static boolean flag that prevents re-entrant popup closing. It is set to `true` during:
- `SetParent()` when calling `addChildWindow:` (which synchronously triggers focus callbacks)
- `ShowDeactivated()` when calling `orderFront:` (which can trigger focus callbacks)

Without this guard, opening a popup would immediately trigger its own closing.

### CocoaNSWindow

`CocoaNSWindow` is an `NSWindow` subclass that overrides:

- `canBecomeKeyWindow` — Returns `NO` for disabled windows (prevents modal-owner from stealing key status during modal dialogs). Returns `YES` for top-level windows (no parent). For child windows, returns `YES` only if the window has a non-zero style mask (i.e., it is NOT borderless). This means modal dialog child windows (which have title bars) can become key and receive keyboard input, while borderless popup child windows cannot.
- `canBecomeMainWindow` — Returns `YES` only if there is no parent window.

### CocoaWindowDelegate

An `NSWindowDelegate` that bridges Cocoa window events to GacUI:

- `windowShouldClose:` — Delegates to `Hide(true)` to perform the full close sequence (BeforeClosing/AfterClosing, hide, Closed). Always returns `NO` to prevent Cocoa from releasing the NSWindow — the lifecycle is managed entirely by the C++ side.
- `windowWillClose:` — No-op. Only reached when `[nsWindow close]` is called directly (e.g., from the `~CocoaWindow` destructor cleanup).
- `windowDidResize:` → `InvokeMoved()`
- `windowDidBecomeKey:` → `InvokeGotFocus()`
- `windowDidResignKey:` → `InvokeLostFocus()`
- Tracks `sizeState` (Restored/Minimized/Maximized)

### EnableActivate / DisableActivate

These are currently no-ops on macOS. On Windows, `DisableActivate` sets `WS_EX_NOACTIVATE` to prevent a window from gaining activation when clicked. GacUI calls `SetEnabledActivate(false)` on popup windows, but the macOS implementation relies on `ShowDeactivated()` and `canBecomeKeyWindow` to achieve similar behavior.

### Enable / Disable

On Windows, `EnableWindow(hwnd, FALSE)` prevents user input (mouse clicks, keyboard) without hiding or moving the window. The macOS implementation simply sets the `enabled` flag. The `enabled` flag defaults to `true`, matching Windows where a newly created window is enabled by default (`IsWindowEnabled` returns `TRUE`).

On Windows, `EnableWindow(FALSE)` prevents the window from becoming the active/focus window at the OS level. On macOS, this is handled by `canBecomeKeyWindow` returning `NO` for disabled windows — see the `CocoaNSWindow` section below.

The framework layer (`GuiControlHost::GetEnabled()`) delegates to `native->IsEnabled()`, so when `ShowModal` calls `owner->SetEnabled(false)`, the owner's `GetEnabled()` returns false, and the framework won't process input on it.

**Previous bugs:**
- `enabled` was initialized to `false` (should be `true`), causing `ShowModal`'s `CHECK_ERROR(owner && owner->GetEnabled())` to fail.
- `Disable()` used `[nsWindow orderOut:nil]` which hid the window entirely.
- Later `Disable()` used `[nsWindow setIgnoresMouseEvents:YES]` which made clicks pass through to whatever was behind the window, deactivating the app.

## CocoaBaseView

**File:** `Mac/NativeWindow/OSX/CocoaBaseView.mm`

`CocoaBaseView` is an `NSView` subclass that serves as the content view for every `CocoaNSWindow`. It:

- Forwards all mouse and keyboard events to `CocoaWindow::HandleEventInternal()`
- Implements `NSTextInputClient` for IME composition support
- Uses `NSTrackingArea` for mouse enter/exit tracking
- Handles drag-and-drop via `NSDraggingDestination`
- Manages cursor rects

## Key Differences from Windows

| Aspect | Windows | macOS |
|--------|---------|-------|
| Coordinate system | Top-left origin | Bottom-left origin (Cocoa). All coordinates are flipped via `FlipY()` / `FlipRect()` in `CocoaHelper`. |
| Show without activation | `ShowWindow(SW_SHOWNOACTIVATE)` | `[nsWindow orderFront:nil]` — does not make key or main. |
| TopMost | `WS_EX_TOPMOST` via `SetWindowPos` | `[nsWindow setLevel:NSPopUpMenuWindowLevel]` |
| Disable activation | `WS_EX_NOACTIVATE` | No-op. Handled by `canBecomeKeyWindow` returning NO for child borderless windows. |
| Enable/Disable | `EnableWindow(hwnd, FALSE/TRUE)` — toggles input, no visibility change | `enabled` flag only. `canBecomeKeyWindow` returns `NO` for disabled windows. |
| Hide | `PostMessage(WM_CLOSE)` always | `InvokeClosing()`, `[nsWindow orderOut:nil]`, `InvokeClosed()`. Main window defers `DestroyNativeWindow` via `dispatch_async`. |
| SetBounds | `MoveWindow` / `SetWindowPos` — no visibility side effects | `[nsWindow setFrame:display:YES]` — no visibility side effects. |
| Custom frame | Style flags via `SetWindowLongPtr` | `NSWindowStyleMaskBorderless` + manual hit testing in `HandleEventInternal`. Note: `NSWindowStyleMaskBorderless = 0`, so XOR-based toggling does not work. |
| Window creation | Window starts hidden until `ShowWindow` | Window starts hidden (not ordered). Only becomes visible on `Show()` / `ShowDeactivated()`. |
| Popup close trigger | `WM_ACTIVATEAPP` + mouse messages | `windowDidBecomeKey:` → `InvokeGotFocus()`, mouse-down in `HandleEventInternal`, `applicationDidResignActive:` |
| Render loop gate | `IsWindowVisible(handle)` — true for 0×0 windows | `[nsWindow isVisible]` — true for 0×0 windows (they are ordered on screen). The render loop must be able to run for 0×0 popup windows to compute their content size. |
| Event loop | `GetMessage` / `TranslateMessage` / `DispatchMessage` | `nextEventMatchingMask:` + `sendEvent:` for both main loop and `RunOneCycle`. |
| Modal windows | Framework-level. `RunOneCycle` pumps messages in a loop. | Framework-level. `RunOneCycle` pumps events via `nextEventMatchingMask:`. |

## RunOneCycle and Modal Windows

**File:** `Mac/NativeWindow/OSX/CocoaNativeController.mm`

### Overview

GacUI modal windows (`ShowModal` / `ShowModalAsync`) are entirely framework-level — they do not use native modal APIs. Instead, the framework:

1. Disables the owner window
2. Shows the modal dialog
3. Spins a mini event loop: `while (!exit && app->RunOneCycle())`
4. When the dialog closes, the callback fires, re-enables the owner, and the loop exits

This requires `RunOneCycle()` to process OS events and return, just like a single iteration of the main event loop.

### Windows Implementation (Reference)

```cpp
void Run(INativeWindow* window) override {
    mainWindow = ...;
    mainWindow->Show();
    while (RunOneCycleInternal());  // same function as RunOneCycle()
}

inline bool RunOneCycleInternal() {
    MSG message;
    if (!GetMessage(&message, NULL, 0, 0)) return false;  // blocks until a message arrives
    TranslateMessage(&message);
    DispatchMessage(&message);
    asyncService.ExecuteAsyncTasks();
    return true;
}
```

Key point: `Run()` and `RunOneCycle()` use **the same function** (`RunOneCycleInternal`). The main event loop is just `while (RunOneCycleInternal())`. When a modal dialog calls `RunOneCycle()` in a nested loop, it's the exact same code path — a nested call to the same pump. `GetMessage` **blocks** until a message is available, processes exactly one message, runs async tasks, then returns. Returns `false` on `WM_QUIT`.

### macOS Implementation

```objc
void Run(INativeWindow* window) override {
    mainWindow = window;
    mainWindow->Show();
    while (RunOneCycle());   // same function — matches Windows pattern
}

bool RunOneCycle() override {
    @autoreleasepool {
        NSEvent* event = [NSApp nextEventMatchingMask:NSEventMaskAny
                                            untilDate:[NSDate distantFuture]
                                               inMode:NSDefaultRunLoopMode
                                              dequeue:YES];
        if (event != nil) {
            [NSApp sendEvent:event];
            [NSApp updateWindows];
        }
        asyncService.ExecuteAsyncTasks();
    }
    return mainWindow != nullptr;
}
```

### Why `Run()` Must NOT Use `[NSApp run]`

The previous implementation used `[NSApp run]` for the main loop and `RunOneCycle()` (via `nextEventMatchingMask:`) for framework-level modal sub-loops. This caused crashes because:

1. **Two different event pumps.** `[NSApp run]` is Cocoa's opaque event loop with its own internal state. `RunOneCycle()` is a manual pump using `nextEventMatchingMask:`. When a modal dialog's `RunOneCycle` loop runs *inside* `[NSApp run]`'s dispatch chain, the two mechanisms fight over event queue ownership and run loop state.

2. **`[NSApp stop:nil]` targets the wrong loop.** When the main window is destroyed, `[NSApp stop:nil]` tells `[NSApp run]` to exit. But if we're inside a nested `RunOneCycle` loop (e.g., a framework modal dialog), `[NSApp stop:nil]` doesn't affect our manual pump — it affects the outer `[NSApp run]`, causing it to exit prematurely when the nested loop returns.

3. **`mainWindow` was a dangling pointer.** `DestroyNativeWindow` deleted the window but never set `mainWindow = nullptr`, so `RunOneCycle()` returned `mainWindow != nullptr` → always `true`, never terminating.

The fix: make `Run()` use `while(RunOneCycle())` — identical to Windows. Both the main loop and modal sub-loops use the same `RunOneCycle()` function. Nested calls to `RunOneCycle` are just nested calls to `nextEventMatchingMask:` + `sendEvent:`, which is the standard macOS pattern for nested event loops (same as `NSModalSession`).

### Key Design Decisions

- **`[NSDate distantFuture]`** makes `nextEventMatchingMask:` block until an event arrives, matching Windows' `GetMessage` behavior. No busy-waiting, no CPU cost while idle. `[NSDate distantPast]` would poll without blocking and cause 100% CPU usage.
- **GCD timers still fire** during `nextEventMatchingMask:` because `dispatch_after` on the main queue is processed as a run loop source in `NSDefaultRunLoopMode`. The 16ms timer from `CocoaInputService` continues to work — its callback (`GlobalTimerFunc`) executes *during* the `nextEventMatchingMask:` call, processing rendering and timer events without waiting for an NSEvent.
- **`@autoreleasepool`** wraps each iteration. `[NSApp run]` creates autorelease pools automatically per iteration; our custom loop must do this explicitly to prevent memory buildup from temporary Cocoa objects.
- **`[NSApp updateWindows]`** is called after dispatching the event to ensure window display updates happen synchronously, matching the behavior of `[NSApp run]`'s internal loop.

### App Shutdown Sequence

When the main window is destroyed via `DestroyNativeWindow`:

1. `mainWindow` is set to `nullptr`.
2. A dummy `NSEventTypeApplicationDefined` event is posted to wake `nextEventMatchingMask:` (in case it's blocked waiting for events).
3. `RunOneCycle()` returns `mainWindow != nullptr` → `false`.
4. The `while(RunOneCycle())` loop in `Run()` exits.

The dummy event is necessary because `DestroyNativeWindow` may be called from an async task executed *during* `nextEventMatchingMask:` (via a GCD timer → `GlobalTimerFunc` → `ExecuteAsyncTasks`). In that case, `nextEventMatchingMask:` would continue blocking after the async task returns unless we post an event to wake it.

If `DestroyNativeWindow` is called during `sendEvent:` dispatch (the normal case — user clicks close), we're already past `nextEventMatchingMask:`, so the dummy event is harmless — it's simply ignored on the next iteration.

`CocoaWindowDelegate::windowShouldClose:` delegates to `Hide(true)` and always returns NO. `windowWillClose:` is a no-op. The close button does NOT call `[NSApp stop:nil]` or post events — app termination is handled entirely by `DestroyNativeWindow` setting `mainWindow = nullptr` (deferred via `dispatch_async` from `Hide()`).
