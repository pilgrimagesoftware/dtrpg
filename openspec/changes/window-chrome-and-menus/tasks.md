## 1. Action Declarations

- [x] 1.1 Create `dtrpg-ui/src/ui/actions.rs` and declare app-level actions with the `actions!` macro: `Quit`, `HideApplication`, `HideOthers`, `ShowAll`, `ShowSettings`, `About`
- [x] 1.2 Declare window-level actions in the same file: `Minimize`, `Zoom`, `ToggleFullscreen`
- [x] 1.3 Declare thin no-op text-editing action types for OS routing: `Undo`, `Redo`, `Cut`, `Copy`, `Paste`, `SelectAll`
- [x] 1.4 Add `pub mod actions;` to `dtrpg-ui/src/ui/mod.rs`

## 2. Key Bindings and App-Level Action Handlers

- [x] 2.1 In `setup()` in `dtrpg-ui/src/ui/app/mod.rs`, call `cx.bind_keys()` with: `cmd-q → Quit`, `cmd-, → ShowSettings`, `cmd-h → HideApplication`, `alt-cmd-h → HideOthers`, `cmd-m → Minimize`, `ctrl-cmd-f → ToggleFullscreen`
- [x] 2.2 Register `cx.on_action::<Quit>(|cx| cx.quit())` in `setup()`
- [x] 2.3 Register `cx.on_action::<HideApplication>(|cx| cx.hide())` in `setup()`
- [x] 2.4 Register `cx.on_action::<HideOthers>(|cx| cx.hide_other_apps())` in `setup()`
- [x] 2.5 Register `cx.on_action::<About>(|_cx| { /* no-op: About dialog is a follow-up change */ })` in `setup()`

## 3. Window-Level Action Handlers in LibraryRootView

- [x] 3.1 In `LibraryRootView::new()`, register `cx.on_action::<Minimize>(|window, cx| window.minimize_window())`
- [x] 3.2 Register `cx.on_action::<Zoom>(|window, cx| window.zoom_window())`
- [x] 3.3 Register `cx.on_action::<ToggleFullscreen>(|window, cx| window.toggle_fullscreen())`
- [x] 3.4 Register `cx.on_action::<ShowSettings>(move |_, cx| { settings_clone.update(cx, |ctrl, cx| ctrl.open(cx)); })` — capture a clone of the settings entity before registering

## 4. Menu Bar Registration

- [x] 4.1 In `setup()`, call `cx.set_menus()` with the **Libri** application menu containing: About Libri, separator, Settings… (⌘,), separator, Services (os_submenu), separator, Hide Libri (⌘H), Hide Others (⌥⌘H), Show All, separator, Quit Libri (⌘Q)
- [x] 4.2 Add the **Edit** menu: Undo (os_action + OsAction::Undo), Redo (os_action + OsAction::Redo), separator, Cut (OsAction::Cut), Copy (OsAction::Copy), Paste (OsAction::Paste), Select All (OsAction::SelectAll)
- [x] 4.3 Add the **View** menu: Enter Full Screen (⌃⌘F)
- [x] 4.4 Add the **Window** menu: Minimize (⌘M), Zoom
- [x] 4.5 Add the **Help** menu with a single item: About Libri (mirrors the Libri menu About item)

## 5. Window Drag Region

- [x] 5.1 In `render_toolbar()` in `dtrpg-ui/src/ui/views/toolbar_view.rs`, locate the `div().flex_1()` spacer between the title/count block and the controls cluster
- [x] 5.2 Add `.id("toolbar-drag-region")` and `.on_mouse_down(MouseButton::Left, |_, window, _| window.start_window_move())` to the spacer div
- [x] 5.3 Confirm that the drag region does not overlap the search field, sort selector, group toggle, layout switcher, or settings button (those are siblings, not children, of the spacer)

## 6. Verification

- [ ] 6.1 Build and launch the app; click and drag the empty toolbar area and confirm the window moves
- [x] 6.2 Verify the macOS menu bar shows: Libri | Edit | View | Window | Help
- [x] 6.3 Press ⌘Q and confirm the app quits
- [ ] 6.4 Press ⌘, and confirm the settings panel opens
- [x] 6.5 Press ⌘H and confirm the app windows hide (app remains running in Dock)
- [ ] 6.6 Press ⌘M and confirm the window minimizes to the Dock
- [ ] 6.7 Press ⌃⌘F and confirm the window enters/exits full-screen mode
- [ ] 6.8 Click in the search field, type some text, then use ⌘A / ⌘C / Edit menu Copy and confirm the text is copied to the clipboard
- [x] 6.9 Run `cargo check -p dtrpg-ui` and confirm zero errors
