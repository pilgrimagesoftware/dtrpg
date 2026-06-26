## Why

The application window currently has no drag region and no OS-native menu bar. On macOS, users expect to drag a window by clicking on the title bar area and to access standard app functions through the menu bar. The absence of these makes the app feel unfinished and breaks standard platform conventions for moving windows, keyboard shortcuts, and accessibility.

## What Changes

- The toolbar row (and/or the transparent title bar area above it) becomes draggable — clicking and dragging initiates a window move without requiring the native OS title bar chrome.
- An OS-native menu bar is registered with `cx.set_menus()` containing the standard macOS menu groups: App (Libri), Edit, View, Window, and Help.
- Standard keyboard shortcuts are wired through gpui actions so they are available from both the menu and keyboard: ⌘Q Quit, ⌘, Settings, ⌘H Hide, ⌘M Minimize, ⌘F search focus, ⌘W Close Window, ⌘Z/⇧⌘Z Undo/Redo.
- The Edit menu items (Cut, Copy, Paste, Select All) delegate to system text-editing actions so they work correctly in any focused text field.

## Capabilities

### New Capabilities

- `window-drag-region`: A draggable region in the main window that lets users reposition the window by clicking and dragging on the toolbar or title bar area.
- `app-menu-bar`: OS-native menu bar registered at app startup with standard macOS menus and keyboard shortcuts wired to gpui actions.

### Modified Capabilities

- None.

## Impact

- **`dtrpg-ui/src/ui/app/mod.rs`**: Add `cx.set_menus()` call and define gpui `actions!` for app-level commands (Quit, Settings, Hide, About).
- **`dtrpg-ui/src/ui/views/toolbar_view.rs`**: Add a drag-region `div` or `on_mouse_down` handler in the toolbar that calls the gpui window-move API.
- **New file** `dtrpg-ui/src/ui/actions.rs`: Centralizes gpui `actions!` macro declarations for all menu-bound actions.
- No SDK or API changes required.
- macOS-only for the initial implementation; the gpui menu API is cross-platform (Windows/Linux menus are no-ops on those targets).
