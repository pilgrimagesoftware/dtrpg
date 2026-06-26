## Context

The application currently has no configurable storage layer — file paths are either hardcoded or not yet implemented. Two related capabilities land together: (1) letting the user pick where catalog data lives, and (2) letting the user navigate to that location (or an item's location) in their OS file manager. These are naturally paired because both depend on knowing the resolved storage path.

The Rust/gpui app (`dtrpg-app/rust`) runs on macOS, Windows, and Linux. The Swift/SwiftUI app (`dtrpg-app/swift`) runs on macOS only. Both need the preference stored and the reveal-in-file-manager action available. The `open-item-in-default-app` change (already proposed) adds the `open` crate; this change reuses it and adds a reveal-specific approach where the OS supports it.

## Goals / Non-Goals

**Goals:**
- Persist a user-configurable storage root path and derive all catalog file paths from it.
- Default to the platform-appropriate user data directory on first run.
- Validate the chosen path for writability before saving.
- Reveal an item's file (selected/highlighted) in the OS file manager from both the catalog view and detail view.
- Reveal the storage root directory from settings.
- Display a clear warning when the user changes the storage location that existing files will not be moved.

**Non-Goals:**
- Automatically migrating or copying files when the storage location changes.
- Supporting multiple storage roots (e.g., one per account or library).
- Syncing the storage location preference across devices.
- Monitoring the storage directory for external changes (e.g., files deleted by the user in Finder).

## Decisions

### Decision 1: Storage preference stored in the app's existing config/preference mechanism

The storage path is a single string preference key (`storage.root_path`) persisted wherever the rest of the app's user preferences live (a platform-appropriate config file, not the Keychain). It is distinct from credential storage (covered by `secure-credential-storage`).

On Rust: use the `dirs` crate to resolve the platform default (`dirs::data_dir()`) and a config file (TOML or similar) in `dirs::config_dir()` to persist the override. On Swift: `UserDefaults` for the preference key; `FileManager.urls(for:in:)` for the default.

**Alternative considered**: Environment variable override — useful for advanced users, but adds complexity to the resolution chain. Defer until there's a concrete request.

### Decision 2: Reveal-in-file-manager uses platform-specific APIs, not `xdg-open` alone

Revealing a file *selected* (highlighted) in the file manager is meaningfully better UX than just opening the containing folder — it saves the user from hunting for the file in a directory that may contain many items.

- **macOS (Swift)**: `NSWorkspace.shared.activateFileViewerSelecting([url])` — selects the file in Finder.
- **macOS (Rust)**: Same via the `open` crate's `open::with` targeting `Finder`, or a direct `NSWorkspace` call via `objc2`. Simpler: use `Command::new("open").args(["-R", path])` which invokes Finder's reveal-selection mode.
- **Windows**: `Command::new("explorer").args(["/select,", path])` — selects the file in Explorer.
- **Linux**: Try `dbus` `org.freedesktop.FileManager1.ShowItems` first (supported by Nautilus, Dolphin, Thunar); fall back to `xdg-open` on the parent directory if the DBus interface is unavailable. The `open` crate does not support file-selection on Linux, so this requires a small custom helper.

**Rationale**: The macOS and Windows approaches are one-line command invocations. The Linux fallback degrades gracefully to opening the parent folder, which is acceptable.

### Decision 3: Storage path resolution is centralized in a `StorageConfig` type

Both apps expose a `StorageConfig` struct/type that owns:
- `root_path(): PathBuf / URL` — the resolved storage root (preference override or platform default)
- `path_for_item(id:) -> PathBuf / URL` — derives a per-item subdirectory under the root

All download, open, and reveal operations derive paths through `StorageConfig`, never by constructing paths ad hoc. This ensures the user's preference change propagates everywhere without a search-and-replace.

### Decision 4: Writability check uses a probe write, not permission bits

Before saving a new storage path, the application attempts to create a temporary file in the chosen directory and immediately deletes it. This catches permission issues, read-only mounts, and full volumes in one step, rather than interrogating `fs::metadata` and permission bits (which are unreliable across platforms).

### Decision 5: "Files will not be moved" warning is a one-time confirmation dialog

When the user confirms a new storage location, a modal dialog states: "Existing downloaded files will not be moved to the new location. You will need to move them manually or re-download them." The user must click "Continue" to proceed or "Cancel" to abort. This warning appears every time the storage location is changed, not just the first time.

## Risks / Trade-offs

**[Risk] User picks a path on an external drive that is later unmounted** → Mitigation: On app startup, if the configured storage root is unreachable, the application displays a prominent banner explaining the storage path is unavailable and offers to either wait (drive will be mounted) or revert to the default. Downloads and open actions are disabled while the path is unavailable.

**[Risk] `dirs` crate defaults may not match user expectations on all Linux distributions** → Mitigation: The XDG spec is widely followed; `dirs::data_dir()` returns `$XDG_DATA_HOME` with the correct fallback. Document the default path in settings so the user is never surprised.

**[Risk] Linux DBus `ShowItems` interface may not be available in minimal environments** → Mitigation: The `xdg-open` fallback (open parent directory) is always available. The reveal action degrades gracefully — the file manager opens at the folder even if the specific file is not selected.

**[Risk] Changing the storage root invalidates all "downloaded" state** → Mitigation: The download state is stored relative to the storage root (item ID → relative path), not as absolute paths. When the root changes, the relative-path lookup simply finds nothing at the new root. This is correct behavior, communicated clearly by the warning dialog.

## Migration Plan

This is new capability; no prior storage configuration exists.

1. Add `dirs` crate to `dtrpg-app/rust`.
2. Implement `StorageConfig` in Rust and Swift with default resolution and persistence.
3. Audit all existing file path construction in both apps and route through `StorageConfig`.
4. Implement `reveal_in_file_manager(path)` helper for each platform.
5. Add Settings UI: storage section with current path, "Change…", and "Show in …" button.
6. Add "Show in …" to catalog item row/card and detail view (download-state-gated).
7. Test path change flow end-to-end, including the warning dialog and the "treat old files as absent" behavior.

## Open Questions

- **Config file format**: Does the Rust app already have a config/settings persistence layer? If so, the `storage.root_path` key should join it rather than introduce a second file.
- **Download state storage**: Is download state (which items have been downloaded and where) stored as absolute paths or relative paths currently? The design assumes relative; this needs verification before implementation.
- **Linux file manager DBus**: Is there an existing Rust crate for `org.freedesktop.FileManager1`? `zbus` can be used for the DBus call; assess whether pulling it in is worth the improved UX over `xdg-open` on the parent folder.
