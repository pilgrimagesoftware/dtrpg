## 1. Rust App — Dependencies and StorageConfig

- [ ] 1.1 Add `dirs` crate dependency to `dtrpg-app/rust/Cargo.toml`
- [ ] 1.2 Implement `StorageConfig` struct with `root_path() -> PathBuf` that returns the saved preference or the `dirs::data_dir()`-based default
- [ ] 1.3 Implement `StorageConfig::path_for_item(item_id: &str) -> PathBuf` that derives a stable per-item subdirectory under the root
- [ ] 1.4 Implement preference persistence: read/write `storage.root_path` from the app's config file (TOML or equivalent in `dirs::config_dir()`)
- [ ] 1.5 Write unit tests for `StorageConfig` covering: default path resolution on each platform (using cfg), saved override round-trips, and `path_for_item` derivation

## 2. Rust App — Storage Path Validation

- [ ] 2.1 Implement a `validate_writable(path: &Path) -> Result<(), StorageError>` function using a probe write (create and immediately delete a temp file)
- [ ] 2.2 Define `StorageError` enum with variants: `NotWritable`, `VolumeUnavailable`, `PathDoesNotExist`
- [ ] 2.3 Call `validate_writable` before saving any new storage path preference and surface the error to the UI

## 3. Rust App — Storage Path Change Flow

- [ ] 3.1 Identify or create the settings state handler in `dtrpg-app/rust` and add a `change_storage_location()` action
- [ ] 3.2 Invoke the OS-native folder picker dialog (via gpui or `rfd` crate) to let the user select a new directory
- [ ] 3.3 On confirmation, run writability validation; on failure, show an error and abort
- [ ] 3.4 On success, display a warning dialog: "Existing downloaded files will not be moved. Move them manually or re-download." with "Continue" / "Cancel" buttons
- [ ] 3.5 On "Continue", save the new path to `StorageConfig` and refresh all download state (mark previously-downloaded items as not-downloaded at the new location)

## 4. Rust App — Settings UI: Storage Section

- [ ] 4.1 Add a "Storage" section to the settings view in `dtrpg-app/rust` displaying the current `StorageConfig::root_path()` as a read-only text field
- [ ] 4.2 Add a "Change…" button that triggers the folder picker flow (task 3.2–3.5)
- [ ] 4.3 Add a "Show in Finder / Explorer / Files" button that calls the reveal-in-file-manager helper on the storage root (creating the directory first if it does not exist)

## 5. Rust App — Reveal in File Manager Helper

- [ ] 5.1 Implement a `reveal_in_file_manager(path: &Path)` function using `open -R <path>` on macOS, `explorer /select,<path>` on Windows, and DBus `org.freedesktop.FileManager1.ShowItems` (with `xdg-open` on the parent dir as fallback) on Linux
- [ ] 5.2 Use `#[cfg(target_os)]` to select the correct platform implementation at compile time
- [ ] 5.3 Return a `Result` and surface errors as user-facing notifications
- [ ] 5.4 Write integration tests (or manually verify) for reveal on each platform

## 6. Rust App — Catalog and Detail View: Reveal Action

- [ ] 6.1 Add "Show in Finder / Explorer / Files" to the catalog item list row and grid card, visible only when the item is downloaded; call `reveal_in_file_manager` with the item's resolved path
- [ ] 6.2 Add the same action to the catalog item detail view alongside the existing "Open" button
- [ ] 6.3 Handle the missing-file error from `reveal_in_file_manager` by prompting the user to re-download

## 7. Rust App — Startup: Unavailable Storage Root

- [ ] 7.1 On app startup, check that the configured storage root exists and is accessible
- [ ] 7.2 If unavailable, display a persistent banner/alert explaining the storage path is unreachable and disable download/open/reveal actions until the issue is resolved or the path is changed

## 8. Swift App — StorageConfig and Preference

- [ ] 8.1 Implement a `StorageConfig` struct in the Swift app using `UserDefaults` for the override preference and `FileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)` for the default
- [ ] 8.2 Implement `rootURL: URL` (computed, preference or default) and `url(forItemID:) -> URL`
- [ ] 8.3 Implement writability validation using `FileManager` probe write before saving a new preference
- [ ] 8.4 Write XCTest tests for default resolution, round-trip persistence, and `url(forItemID:)`

## 9. Swift App — Storage Path Change Flow

- [ ] 9.1 Use `NSOpenPanel` to present a folder picker when the user clicks "Change…" in settings
- [ ] 9.2 Validate writability; show an `Alert` on failure
- [ ] 9.3 Show confirmation `Alert` explaining files will not be moved; save on "Continue"
- [ ] 9.4 Refresh download state after location change (mark all previously-downloaded items as not-downloaded at the new path)

## 10. Swift App — Settings UI: Storage Section

- [ ] 10.1 Add a "Storage" section to the macOS settings view displaying `StorageConfig.rootURL.path`
- [ ] 10.2 Add a "Change…" button wired to the `NSOpenPanel` flow (tasks 9.1–9.4)
- [ ] 10.3 Add a "Show in Finder" button calling `NSWorkspace.shared.activateFileViewerSelecting([rootURL])`, creating the directory first if needed

## 11. Swift App — Reveal in Finder

- [ ] 11.1 Implement `func revealInFinder(url: URL)` using `NSWorkspace.shared.activateFileViewerSelecting([url])`
- [ ] 11.2 Handle the case where the URL does not exist: create the directory if it is the storage root, or show a re-download prompt for item files
- [ ] 11.3 Add "Show in Finder" to the catalog item row/card and detail view, gated on download state

## 12. Audit and Cleanup

- [ ] 12.1 Audit all existing file path construction in `dtrpg-app/rust` and route any hardcoded or ad hoc paths through `StorageConfig`
- [ ] 12.2 Audit all existing file path construction in `dtrpg-app/swift` and route through `StorageConfig`
- [ ] 12.3 Confirm download state is stored as item-relative paths (not absolute paths) so it remains valid across storage root changes; refactor if needed
- [ ] 12.4 Manual end-to-end test: set custom location → download an item → verify file appears at new location → change location again → verify item shows as not-downloaded → reveal storage root from settings
