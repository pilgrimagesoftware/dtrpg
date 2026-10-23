## Context

The application currently has no settings surface. Three other proposed changes (`secure-credential-storage`, `catalog-storage-location`, `open-item-in-default-app`) define backend capabilities that require user controls, but none of them defines where those controls live in the UI. This change is the presentation layer that unifies them.

The Rust app uses gpui, a retained-mode immediate-rendering UI framework that does not have a built-in settings/preferences window convention. The Swift app targets macOS and can use SwiftUI's `Settings` scene, which integrates with the system `Cmd+,` shortcut and platform toolbar tab navigation automatically.

The most novel section is **File Openers**: it introduces a new preference type (an ordered list of extension → app path pairs) and a new consult-before-OS-default behavior in the open-item action path.

## Goals / Non-Goals

**Goals:**
- A single settings entry point accessible from the main toolbar (Rust) and `Cmd+,` (Swift).
- Three settings sections: Account, Storage, File Openers.
- Account section: display session identity, logout with confirmation, reset/reacquire API key.
- Storage section: delegate to `StorageConfig` for display, path picker, and reveal-in-file-manager.
- File Openers section: full CRUD for extension → application overrides, persisted preference, validation on open.
- The open-item action consults the override list before the OS default.
- Section-level navigation (tab or sidebar), last-visited section remembered.

**Non-Goals:**
- Per-publisher or per-item application overrides (only per-extension).
- A general-purpose settings framework or plugin system.
- Syncing settings across devices.
- Import/export of settings.

## Decisions

### Decision 1: Rust app uses a modal panel (not a second window)

**Choice**: Settings opens as an overlay panel anchored to the main window rather than a separate `gpui::Window`. The panel covers the content area, leaving the sidebar visible, and can be dismissed with Escape or a close button.

**Alternatives considered**:
- **Second window**: Requires managing two window lifecycles; gpui's window management is more complex than a single-window overlay. Second windows also feel heavy for a settings surface that is rarely visited.
- **Inline side panel**: Replaces or overlays the detail panel. Awkward because settings is not a catalog-scoped action; it should feel separate.

**Rationale**: A modal panel is the simplest gpui implementation (a conditionally rendered overlay in `LibraryRootView`) and is a common pattern in single-window apps.

### Decision 2: Section navigation uses a tab strip within the settings panel

The settings panel has a top tab strip with three tabs: Account, Storage, File Openers. The active tab's content is rendered below; inactive tabs are not rendered (not just hidden, avoiding unnecessary work). The last-active tab index is stored in `SettingsController` state and persisted to the preferences file.

**Alternative considered**: A sidebar within the panel (like macOS System Settings). Over-engineered for three sections; a tab strip is lighter and sufficient.

### Decision 3: File-opener overrides stored as a serialized list in the app config file

**Format**: The overrides are stored as an ordered array of `{ extension: String, app_path: String }` objects in the same TOML config file as `storage.root_path` (see `catalog-storage-location` design). Key: `file_openers`.

```toml
[[file_openers]]
extension = "pdf"
app_path = "/Applications/Preview.app"

[[file_openers]]
extension = "epub"
app_path = "/Applications/Calibre.app"
```

**Rationale**: Collocating settings in one config file keeps the persistence model simple and auditable. The override count is small (users configure at most a handful), so a flat TOML array is appropriate.

### Decision 4: Application picker uses an OS-native dialog

- **Rust/macOS**: `Command::new("osascript")` or a gpui file panel configured to show only `.app` bundles. Alternatively use the `rfd` crate's `FileDialog` with an app filter.
- **Rust/Windows**: `rfd` `FileDialog` filtered to `.exe` files.
- **Rust/Linux**: `rfd` `FileDialog` or a text input for the executable path.
- **Swift**: `NSOpenPanel` configured to allow selection of application bundles (`allowedContentTypes = [.application]`).

The `rfd` crate is already under consideration for the storage location picker (see `catalog-storage-location` design). Using it here for consistency avoids a second file-dialog dependency.

### Decision 5: Open-item override lookup is a pure function consulted before the OS dispatch

A `FileOpenerConfig::find_override(extension: &str) -> Option<&Path>` method is called in `ItemOpener::open` before `open::that`. If a matching override is found and the application path exists (`std::fs::metadata` check), `open::with(path, app_path)` (or `Command::new(app_path).arg(file_path)`) is used instead. If the path does not exist, a warning is shown and the call falls through to `open::that`.

This keeps the override logic entirely within the `ItemOpener` layer, invisible to the view model and controller.

### Decision 6: Swift app uses SwiftUI `Settings` scene

```swift
@main struct DTRPGApp: App {
    var body: some Scene {
        WindowGroup { LibraryView() }
        Settings { SettingsView() }
    }
}
```

`SettingsView` uses a `TabView` with `.tabViewStyle(.automatic)` (renders as a toolbar tab bar on macOS). Three tabs: Account, Storage, File Openers. Each tab's content is a SwiftUI `Form`. The last-selected tab index is stored in `@AppStorage`.

## Risks / Trade-offs

**[Risk] gpui does not have a built-in modal/sheet primitive matching the spec's intent** → Mitigation: Implement the settings panel as a full-overlay `div` with a backdrop, rendered at the root level of `LibraryRootView`. This is how modals are typically done in gpui apps. Test that focus/keyboard events are correctly captured by the panel and do not pass through to the library view behind it.

**[Risk] `rfd` file dialog may not support filtering to `.app` bundles on macOS** → Mitigation: On macOS, `NSOpenPanel` via `rfd` can be configured with `add_filter("Application", &["app"])`. If `rfd` filtering is insufficient, fall back to an `osascript` chooser or accept any path and validate post-selection that it is an executable.

**[Risk] Override application paths become stale (apps updated, moved, or uninstalled)** → Mitigation: Validate on settings open (not on every launch) and flag stale entries. Also validate at open time and fall back gracefully with a user-visible warning.

**[Risk] Settings state managed separately from `LibraryController` adds architectural complexity** → Mitigation: `SettingsController` is a separate `gpui::Entity` that owns settings state (active tab, file opener list, storage path). It is constructed at the app level alongside `LibraryController`. The two controllers share no state and communicate only through the persisted config file.

## Migration Plan

New capability, no migration required. Rollout order:

1. Implement `SettingsController` and the settings panel shell with three empty tab sections.
2. Wire the toolbar settings button to open/close the panel.
3. Implement the Account section (depends on `secure-credential-storage` credential store being available; stub with env-var-based state if not yet complete).
4. Implement the Storage section (depends on `StorageConfig` from `catalog-storage-location`; stub with hardcoded default path if not yet complete).
5. Implement `FileOpenerConfig` persistence and `FileOpenerOverridesView`.
6. Update `ItemOpener::open` to consult `FileOpenerConfig` before dispatching to the OS.
7. Implement the Swift equivalent.

Each section can be implemented and shipped independently once the panel shell is in place.

## Open Questions

- **Account identity display**: What account information does the DriveThruRPG API return that can be shown in the Account section (username, email, customer ID)? This determines what the "connected account" display shows. If the current auth flow only stores tokens and not account metadata, the section may initially show only "Signed in" with no identifying detail.
- **gpui focus management in modal**: How does gpui route keyboard events when an overlay is shown? Confirm that Escape closes the settings panel and that Tab/arrow navigation within the panel does not leak to the library view.
- **File Openers section ordering**: Should the override list be ordered (user can drag-reorder) or unordered (sorted by extension)? The spec does not mandate an order. A simple alphabetical-by-extension sort is likely sufficient unless a user has a reason to prioritize one override over another (which they don't, since each extension maps to exactly one app).
