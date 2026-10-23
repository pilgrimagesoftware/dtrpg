## Why

The application has no user-accessible settings surface, which means account management, storage configuration, and file-opening preferences have nowhere to live in the UI. Several already-planned changes (`secure-credential-storage`, `catalog-storage-location`, `open-item-in-default-app`) define backend capabilities that require user controls — this change provides the single unified place those controls are exposed.

## What Changes

- A **Settings view** (modal panel or dedicated window) is added to the Rust app, accessible from the toolbar or application menu.
- The settings view contains three sections:
  1. **Account** — displays the connected DriveThruRPG account, with buttons to log out or reset/reacquire the API key.
  2. **Storage** — displays and allows changing the catalog data storage location, and opens that location in the OS file manager (consumes the `storage-location-preference` and `reveal-in-file-manager` capabilities from `catalog-storage-location`).
  3. **File Openers** — a list of user-defined file-type → application overrides, with controls to add, edit, and remove entries. When an entry is defined for a file type, it takes precedence over the OS default application.
- A gear/settings button is added to the toolbar or a platform-standard menu item opens the settings.
- The Swift app receives an equivalent `Settings` scene using SwiftUI's `Settings` API (macOS system standard).

## Capabilities

### New Capabilities

- `settings-view`: The settings surface itself — entry point, navigation between sections, and platform-appropriate presentation (modal panel for Rust/gpui; SwiftUI `Settings` scene for the Swift app).
- `file-opener-overrides`: User-defined file-type → target application mapping. Stored as a preference list, consulted before the OS default when opening catalog items. Includes UI to add new entries (file extension + application picker), edit existing entries, and remove entries.

### Modified Capabilities

<!-- No existing top-level OpenSpec specs have requirement-level changes from this work. The storage and credential capabilities are defined in their own pending changes and are consumed here as UI sections, not re-specified. -->

## Impact

- **dtrpg-app/rust**: New `settings_view.rs` (and sub-views per section) in `dtrpg-ui/src/ui/views/`. New `SettingsController` or settings state model. Toolbar gains a settings entry point. `file-opener-overrides` preference is a new persisted config key alongside `storage.root_path`.
- **dtrpg-app/swift**: New `SettingsView.swift` with `Settings` scene registration in the `App` struct. Three `Form`-based sections mirroring the Rust layout.
- **Relates to (but does not re-implement)**:
  - `secure-credential-storage`: Account section surfaces credential state and logout/reset actions.
  - `catalog-storage-location`: Storage section exposes the path picker and reveal-in-file-manager button.
  - `open-item-in-default-app`: File Openers section adds user overrides that the open-item action consults before falling back to the OS default.
- **dtrpg-api / dtrpg-sdk**: No changes.
