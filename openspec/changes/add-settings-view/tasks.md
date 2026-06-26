## 1. Rust App — SettingsController and Panel Shell

- [x] 1.1 Create `dtrpg-ui/src/controllers/settings.rs` with `SettingsController` struct owning: active tab index, file-opener override list, and open/closed state
- [x] 1.2 Add `SettingsTab` enum with variants `Account`, `Storage`, `FileOpeners`
- [x] 1.3 Persist the last-active tab to the app config file on change; restore it on `SettingsController::new()`
- [x] 1.4 Create `dtrpg-ui/src/ui/views/settings_view.rs` with an overlay panel that renders a tab strip and the active section content
- [ ] 1.5 Implement the panel backdrop and dismiss-on-Escape keyboard handling; confirm focus does not leak to `LibraryRootView` behind the panel
- [x] 1.6 Add `SettingsController` as a second `gpui::Entity` in `LibraryRootView`; conditionally render the settings panel overlay when `SettingsController::is_open()` is true
- [x] 1.7 Add a settings/gear button to the toolbar that toggles `SettingsController::is_open`

## 2. Rust App — Account Section

- [x] 2.1 Create `settings_account_view.rs` rendering account identity (from credential store or a stub "Signed in" label if account metadata is not yet available)
- [x] 2.2 Implement "Log Out" button with a confirmation dialog; on confirm, call the credential store `delete()` and reset app session state
- [x] 2.3 Implement "Reset API Key" button: clear the API key credential from the store and present the API key entry flow
- [ ] 2.4 Render an unauthenticated state ("Not signed in" + authenticate prompt) when no valid session is present
- [x] 2.5 Wire account section to `SettingsController::Account` tab

## 3. Rust App — Storage Section

- [x] 3.1 Create `settings_storage_view.rs` rendering the current `StorageConfig::root_path()` as a read-only path label
- [ ] 3.2 Add "Change…" button that invokes the `rfd` folder picker; on confirmation, run writability validation and show the "files will not be moved" warning dialog before saving
- [ ] 3.3 Add "Show in Finder / Explorer / Files" button that calls `reveal_in_file_manager` on the storage root (creating the directory first if it does not exist)
- [x] 3.4 Wire storage section to `SettingsController::Storage` tab

## 4. Rust App — FileOpenerConfig Persistence

- [x] 4.1 Define `FileOpenerEntry { extension: String, app_path: PathBuf }` and `FileOpenerConfig { entries: Vec<FileOpenerEntry> }` in `dtrpg-core` or `dtrpg-ui`
- [x] 4.2 Implement `FileOpenerConfig::load()` and `save()` reading/writing the `[[file_openers]]` TOML array in the app config file
- [x] 4.3 Implement `FileOpenerConfig::find_override(extension: &str) -> Option<&Path>` with case-insensitive, leading-dot-tolerant extension lookup
- [x] 4.4 Implement `FileOpenerConfig::add(entry)` with duplicate-extension detection (replace after confirmation or reject)
- [x] 4.5 Implement `FileOpenerConfig::remove(extension: &str)` and `update_app_path(extension: &str, new_path: PathBuf)`
- [x] 4.6 Implement `FileOpenerConfig::validate_all() -> Vec<&FileOpenerEntry>` returning entries whose `app_path` does not exist on disk
- [x] 4.7 Write unit tests for `find_override` (exact match, case-insensitive, no match, dot-prefixed input), `add` (new, duplicate), and `validate_all`

## 5. Rust App — File Openers Section UI

- [x] 5.1 Create `settings_file_openers_view.rs` rendering the override list; show an empty-state message when no overrides are configured
- [x] 5.2 Render each override as a row: extension badge, application name (derived from path), edit button, remove button
- [x] 5.3 Flag invalid (stale) override rows with a warning indicator; call `FileOpenerConfig::validate_all()` when the section is first rendered
- [x] 5.4 Implement "Add" control: present an inline row or dialog for extension input + application picker via `rfd::FileDialog` (filter to `.app` on macOS, executable on Windows/Linux)
- [x] 5.5 Normalize the entered extension to lowercase with no leading dot before saving
- [ ] 5.6 Implement edit: re-open the application picker pre-filled with the current path; update the entry on confirmation
- [x] 5.7 Implement remove: delete the entry from `FileOpenerConfig` and refresh the list
- [x] 5.8 Wire File Openers section to `SettingsController::FileOpeners` tab

## 6. Rust App — Update ItemOpener to Consult Overrides

> **BLOCKED**: `ItemOpener` does not yet exist. These tasks depend on the `open-item-in-default-app` change.

- [ ] 6.1 Load `FileOpenerConfig` in `ItemOpener` (or accept it as a constructor argument) so it is available at open time
- [ ] 6.2 In `ItemOpener::open(path)`, call `FileOpenerConfig::find_override(extension)` before dispatching to `open::that`
- [ ] 6.3 If an override is found and its `app_path` exists, use `open::with(file_path, app_path)` or `Command::new(app_path).arg(file_path)`
- [ ] 6.4 If an override is found but `app_path` does not exist, show a user warning ("Configured opener not found") and fall back to `open::that`
- [ ] 6.5 Write unit tests for the override-lookup path using a `FileOpenerConfig` with a known entry

## 7. Swift App — Settings Scene Shell

> **BLOCKED**: The Swift package (`DTRPGClient`) is a library target with no `@main` App struct.  
> Tasks 7–10 require a macOS app target to exist first.

- [ ] 7.1 Register a `Settings` scene in the `DTRPGApp` `@main` struct alongside the main `WindowGroup`
- [ ] 7.2 Create `SettingsView.swift` as a `TabView` with `.tabViewStyle(.automatic)` and three tabs: Account, Storage, File Openers
- [ ] 7.3 Persist the selected tab index with `@AppStorage("settings.activeTab")`

## 8. Swift App — Account Section

- [ ] 8.1 Create `AccountSettingsView.swift` as a `Form` section displaying session identity (or "Not signed in")
- [ ] 8.2 Add "Log Out" button with a confirmation `Alert`; on confirm, call the `KeychainCredentialStore` `delete()` and update app session state
- [ ] 8.3 Add "Reset API Key" button clearing only the API key keychain entry and routing to the key-entry flow

## 9. Swift App — Storage Section

- [ ] 9.1 Create `StorageSettingsView.swift` as a `Form` section displaying `StorageConfig.rootURL.path`
- [ ] 9.2 Add "Change…" button opening `NSOpenPanel`; validate writability and show a confirmation sheet before saving
- [ ] 9.3 Add "Show in Finder" button calling `NSWorkspace.shared.activateFileViewerSelecting([rootURL])`

## 10. Swift App — File Openers Section

- [ ] 10.1 Create `FileOpenersSettingsView.swift` as a `Form` section with a `List` of overrides and an "Add" button
- [ ] 10.2 Implement `FileOpenerStore` (ObservableObject) wrapping `UserDefaults` persistence of the override list as a `[String: String]` dictionary (extension → app path)
- [ ] 10.3 Render each override row with extension, app name, and a delete button; flag stale (missing app) entries with a warning icon
- [ ] 10.4 Implement "Add" using `NSOpenPanel` filtered to `.application` content type; normalize extension on save
- [ ] 10.5 Update the Swift app's file-open action to consult `FileOpenerStore` before `NSWorkspace.shared.open(_:)`

## 11. Verification

- [ ] 11.1 Open settings from the toolbar gear button; verify all three tabs are accessible and the last-viewed tab is remembered across open/close cycles
- [ ] 11.2 Log out via Account section; verify credentials are cleared and the app returns to unauthenticated state
- [ ] 11.3 Change storage location via Storage section; verify the path updates and the "files will not be moved" warning appears
- [ ] 11.4 Add a `.pdf` → Preview.app override; open a PDF catalog item; verify Preview opens instead of the OS default
- [ ] 11.5 Delete the override; open a PDF catalog item again; verify the OS default is used
- [ ] 11.6 Simulate a stale override (move the target app); open File Openers settings; verify the stale entry is flagged
- [ ] 11.7 Run `cargo test --workspace` and confirm all tests pass
