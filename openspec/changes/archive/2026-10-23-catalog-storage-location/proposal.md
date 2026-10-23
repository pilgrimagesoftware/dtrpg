## Why

Users have different preferences and constraints for where large content libraries live — external drives, NAS mounts, specific volumes with more space — and the application should not silently hard-code a location they cannot control. Equally, once files are downloaded, users need to be able to find them in the OS file explorer without hunting for a buried app-specific folder.

## What Changes

- A storage location preference is added to application settings, allowing the user to choose the root directory where catalog data (downloaded files, metadata cache) is stored.
- The application ships with a sensible default (platform-appropriate user data directory) and uses it until the user overrides it.
- A "Show in Finder / Explorer / Files" action is added to catalog items, opening the OS file manager at the item's containing folder.
- A "Show storage folder" action is added to settings, opening the configured root storage directory in the OS file manager.
- **BREAKING** (runtime, not API): if a user changes the storage location, existing downloaded files are not automatically moved; the application treats the old location's files as absent until the user manually moves them or re-downloads.

## Capabilities

### New Capabilities

- `storage-location-preference`: User-configurable root directory for catalog data storage, with a default, a picker to change it, and validation that the chosen path is writable.
- `reveal-in-file-manager`: Action to open the OS file manager (Finder on macOS, Explorer on Windows, the default file manager on Linux) at a specific path — either an item's containing folder or the storage root.

### Modified Capabilities

<!-- No existing specs have requirement-level changes from this work. -->

## Impact

- **dtrpg-app/rust**: Reads and writes the storage path preference; all file I/O paths are derived from the configured root. Uses `open` crate (already planned in `open-item-in-default-app`) or platform-specific reveal APIs for "show in file manager."
- **dtrpg-app/swift**: Same preference binding; uses `NSWorkspace.shared.activateFileViewerSelecting(_:)` for Finder reveal.
- **Settings UI** (both apps): New "Storage" section with current path display, "Change…" button, and "Show in Finder/Explorer" button.
- **Catalog UI** (both apps): Per-item "Show in Finder/Explorer" action added alongside the existing (planned) "Open" action, visible only for downloaded items.
- **dtrpg-sdk**: No changes; file path resolution stays in the app layer.
- **dtrpg-api**: No changes.
