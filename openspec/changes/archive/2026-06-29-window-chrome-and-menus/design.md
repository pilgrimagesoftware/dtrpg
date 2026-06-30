## Context

The app opens a single window with `appears_transparent: true` on the titlebar, which extends the content area under the native macOS traffic lights. The toolbar row (`render_toolbar`) fills the 53 px strip below the native title bar. Neither the title bar nor the toolbar strip calls `window.start_window_move()`, so the window is currently immovable except by clicking the very thin native OS title bar area above the traffic lights.

The app also has no registered menus. Without `cx.set_menus()`, macOS produces a minimal default menu with only Quit, which breaks standard shortcuts like ⌘H, ⌘M, and ⌘,.

The gpui version in use (Zed rev `1d217ee`) provides:
- `Window::start_window_move()` — initiates a drag-to-move from a mouse-down event
- `Window::minimize_window()`, `Window::zoom_window()`, `Window::toggle_fullscreen()` — window management
- `App::quit()`, `App::hide()`, `App::hide_other_apps()` — app-level platform calls
- `App::set_menus(impl IntoIterator<Item = Menu>)` — registers the OS menu bar
- `MenuItem::action(name, action)` and `MenuItem::os_action(name, action, OsAction)` — menu items wired to gpui actions
- `OsAction` variants: `Cut`, `Copy`, `Paste`, `SelectAll`, `Undo`, `Redo` — delegate to the system text-editing stack
- `MenuItem::os_submenu("Services", SystemMenuType::Services)` — OS-managed Services menu

## Goals / Non-Goals

**Goals:**
- The toolbar's empty space (the flex spacer between title and controls) calls `window.start_window_move()` on left-mouse-down, making the window draggable from the toolbar.
- A central `actions.rs` file defines all app-level gpui actions with the `actions!` macro.
- `cx.set_menus()` is called in `setup()` with five menus: Libri, Edit, View, Window, Help.
- App-level actions (Quit, Hide, ShowSettings, About) are handled in `setup()` via `cx.on_action()`.
- Window-level actions (Minimize, Zoom, ToggleFullscreen) are handled in `LibraryRootView` via `cx.on_action()` inside `new()`.
- The `ShowSettings` action opens `SettingsController` to the Account tab and is both menu-accessible (⌘,) and keyboard-accessible.

**Non-Goals:**
- Animated window dragging or custom resize handles.
- A custom About dialog (⌘? / About Libri can be a no-op initially; a real dialog is a separate change).
- Per-item context menus (right-click menus on catalog items).
- Windows or Linux menu customization (gpui menu calls are no-ops on non-macOS in the current build target).

## Decisions

### Decision 1: Drag region is the toolbar flex spacer, not a dedicated overlay div

The toolbar row already has a `div().flex_1()` spacer between the section title/count and the controls cluster. Adding `.on_mouse_down(MouseButton::Left, |_, window, _| window.start_window_move())` to this spacer is the minimal change: it makes the large empty center of the toolbar draggable without interfering with any interactive controls.

The native macOS title bar strip (above the toolbar, where the traffic lights sit) is already draggable by default — no changes needed there.

**Alternative considered**: A transparent absolute-positioned div spanning the full toolbar width. Rejected — it would sit on top of interactive controls and eat their mouse events.

### Decision 2: All gpui actions centralized in `dtrpg-ui/src/ui/actions.rs`

Declaring all app-level actions in one file (via a single `actions!` macro call) makes key bindings and menu wiring easy to audit and extend. The file is imported by both `app/mod.rs` (for handler registration and menu wiring) and `ui/views/root_view.rs` (for the `ShowSettings` handler).

### Decision 3: App-level action handlers registered in `setup()`, window-level in `LibraryRootView::new()`

gpui dispatches menu-triggered actions through `cx.dispatch_action()`, which walks the focused view tree. App-level actions (Quit, Hide, About) can be handled directly in `setup()` with `cx.on_action()`. Window-level actions (Minimize, Zoom, ToggleFullscreen) need access to `Window`, so they are registered in `LibraryRootView::new()` using `cx.on_action()` there.

`ShowSettings` is a special case: it needs to mutate `SettingsController`, which is owned by `LibraryRootView`. It is registered in `LibraryRootView::new()` so it can capture the settings entity:
```rust
let settings_for_action = settings.clone();
cx.on_action::<ShowSettings>(move |cx| {
    settings_for_action.update(cx, |ctrl, cx| {
        ctrl.open(cx);
    });
});
```

### Decision 4: Edit menu items use `MenuItem::os_action` with `OsAction` variants

The gpui `OsAction` enum (`Cut`, `Copy`, `Paste`, `SelectAll`, `Undo`, `Redo`) instructs the macOS platform layer to route these items through the responder chain, which means they work correctly in any focused text field without the app needing its own undo stack. Each item still requires a paired gpui `Action` type (so the menu item has a type-erased action); thin no-op action structs (`Cut`, `Copy`, etc.) are declared in `actions.rs` for this purpose. The OS routing takes precedence when `OsAction` is present.

### Decision 5: Key bindings registered via `cx.bind_keys()` to map shortcuts to actions

Registering key bindings with `cx.bind_keys()` in `setup()` ensures the shortcuts work whether the user presses the key directly or uses the menu. The menu item's display of the shortcut character is derived from the bound key binding automatically by gpui.

```rust
cx.bind_keys([
    KeyBinding::new("cmd-q", Quit, None),
    KeyBinding::new("cmd-,", ShowSettings, None),
    KeyBinding::new("cmd-h", HideApplication, None),
    KeyBinding::new("cmd-m", Minimize, None),
    KeyBinding::new("ctrl-cmd-f", ToggleFullscreen, None),
]);
```

## Risks / Trade-offs

**[Risk] `window.start_window_move()` may interfere with drag-and-drop operations if the app later adds draggable catalog items** → Mitigation: The drag region is limited to the toolbar spacer, not the catalog area. Catalog items will have their own drag handlers in separate divs.

**[Risk] The `ShowSettings` action is registered in `LibraryRootView::new()` rather than at the app level, so if focus moves out of that view the action may not be reachable** → Mitigation: In a single-window app, `LibraryRootView` is always the root of the focus tree and receives all unhandled actions via bubbling. This is an acceptable constraint until a multi-window architecture is introduced.

**[Risk] `OsAction` Edit items rely on the macOS responder chain, which gpui may not expose fully** → Mitigation: The `init_app_menus` function in gpui (called automatically by the platform) hooks `on_validate_app_menu_command` and `on_app_menu_action`, which means the platform layer handles the menu item enabling/disabling correctly. The app does not need to implement undo/redo itself.

## Migration Plan

1. Create `dtrpg-ui/src/ui/actions.rs` with all action declarations.
2. Export it from `dtrpg-ui/src/ui/mod.rs`.
3. Register app-level action handlers and key bindings in `setup()`.
4. Register window-level and `ShowSettings` handlers in `LibraryRootView::new()`.
5. Call `cx.set_menus()` in `setup()` with all five menus.
6. Add `on_mouse_down` to the toolbar flex spacer in `render_toolbar`.
7. Manual smoke test: drag window, verify all shortcuts, verify Edit menu items work in search field.

## Open Questions

- **About dialog**: Should "About Libri" show a dialog or be a no-op? A real About dialog requires either a second gpui window or an overlay view. Suggested: register the action, handle it as a no-op for now, and implement the dialog as a follow-up change.
- **`BringAllToFront`**: gpui does not expose a `bring_all_to_front()` API in this revision. Should the "Bring All to Front" Window menu item be omitted, or implemented as a platform call via `cocoa`/`objc`?
- **Services submenu**: `MenuItem::os_submenu("Services", SystemMenuType::Services)` requires no additional app code — the OS populates it. Confirm this is the desired behavior or if it should be omitted to keep the menu clean.
