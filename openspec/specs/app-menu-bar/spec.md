## ADDED Requirements

### Requirement: App menu (Libri) contains standard macOS application items
The system SHALL register an "Libri" application menu as the first menu in the menu bar, containing: About Libri, separator, Settings (⌘,), separator, Hide Libri (⌘H), Hide Others (⌥⌘H), Show All, separator, Quit Libri (⌘Q).

#### Scenario: Settings menu item opens the settings panel
- **WHEN** the user selects "Settings…" from the Libri menu or presses ⌘,
- **THEN** the settings panel opens to the last-active tab

#### Scenario: Quit menu item exits the app
- **WHEN** the user selects "Quit Libri" or presses ⌘Q
- **THEN** the application exits cleanly

#### Scenario: Hide menu item hides the app
- **WHEN** the user selects "Hide Libri" or presses ⌘H
- **THEN** the app's windows are hidden (standard macOS Hide behavior)

### Requirement: Edit menu contains standard text-editing actions
The system SHALL register an "Edit" menu containing: Undo (⌘Z), Redo (⇧⌘Z), separator, Cut (⌘X), Copy (⌘C), Paste (⌘V), Select All (⌘A).  These SHALL delegate to the platform text-editing system so they work in any focused text input.

#### Scenario: Copy shortcut works in a focused text field
- **WHEN** the user has text selected in the search field and presses ⌘C or selects Edit → Copy
- **THEN** the selected text is copied to the system clipboard

#### Scenario: Undo is available
- **WHEN** the user presses ⌘Z
- **THEN** the last text-editing action in the focused field is undone if the field supports undo

### Requirement: View menu contains presentation and fullscreen controls
The system SHALL register a "View" menu containing: Enter Full Screen (^⌘F), and any view-mode actions the app exposes (e.g., toggle sidebar, switch catalog layout).

#### Scenario: Full Screen shortcut toggles fullscreen
- **WHEN** the user selects "Enter Full Screen" or presses ^⌘F
- **THEN** the main window enters or exits macOS full-screen mode

### Requirement: Window menu contains standard window-management items
The system SHALL register a "Window" menu containing: Minimize (⌘M), Zoom, separator, Bring All to Front.

#### Scenario: Minimize shortcut minimizes the window
- **WHEN** the user presses ⌘M or selects Window → Minimize
- **THEN** the main window is minimized to the Dock

### Requirement: Menu items are disabled when their action is unavailable
The system SHALL disable menu items whose corresponding action cannot execute in the current app state (e.g., Undo when no undo history exists).

#### Scenario: Undo disabled with no history
- **WHEN** no undoable action has been performed in the focused field
- **THEN** the Edit → Undo menu item is grayed out and non-interactive
