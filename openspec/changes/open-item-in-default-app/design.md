## Context

The catalog currently shows purchased items but provides no way to read them. Users expect to click an item and have it open — this is the most fundamental action in a content library. Both the Rust/gpui app (`dtrpg-app/rust`) and the Swift/SwiftUI app (`dtrpg-app/swift`) need this capability, but they reach it through different platform APIs.

The feature is intentionally thin: resolve a local path, hand it to the OS, surface any error. No in-app viewer, no format parsing. The primary complexity is (1) the cross-platform OS integration in the Rust app and (2) UI state management for the "downloaded vs. not downloaded" distinction in both surfaces (catalog view and detail view).

## Goals / Non-Goals

**Goals:**
- Open any downloaded catalog item's file in the OS default application from either the catalog view or the detail view.
- Correctly disable or replace the "Open" action when a file is not locally available.
- Handle multi-file items with a picker when no primary file is designated.
- Report OS-level open failures to the user with an actionable message.
- Cover macOS, Windows, and Linux in the Rust app; macOS only in the Swift app.

**Non-Goals:**
- In-app file viewing of any format (PDF, EPUB, image, etc.).
- Managing or changing the user's default application associations.
- Background download triggering — this change only covers the open action on already-downloaded files (download flow is a separate capability).
- Deep linking into specific pages or sections of a file.

## Decisions

### Decision 1: Use the `open` crate for Rust (all platforms)

**Choice**: The [`open`](https://crates.io/crates/open) crate provides a single `open::that(path)` call that dispatches to `open -a` / `NSWorkspace` on macOS, `ShellExecuteW` on Windows, and `xdg-open` on Linux. It is the standard Rust solution for this use case.

**Alternatives considered**:
- **`std::process::Command::new("open")` / `"xdg-open"` / `"explorer"`**: Works but requires manual platform branching with `#[cfg(target_os)]` and no error normalization.
- **Direct `NSWorkspace` via `objc2` / `windows-sys` / `libdbus`**: Too low-level for a one-call operation; adds FFI complexity without benefit.

**Rationale**: The `open` crate is purpose-built, actively maintained, handles path encoding edge cases, and normalizes the return type. It adds one small dependency with no transitive deps.

### Decision 2: Swift app uses `NSWorkspace.shared.open(_:)` directly

No third-party library is needed on the Swift side. `NSWorkspace.shared.open(_ url: URL)` returns a `Bool` indicating success and is the canonical macOS API. A `URL(fileURLWithPath:)` wraps the local path.

### Decision 3: Open action state is derived from download state, not re-checked on every render

**Choice**: The catalog data model tracks a `downloadState` (or equivalent) per item. The "Open" action is enabled when `downloadState == .downloaded(localPath:)`. The UI binds to this state; no separate file-existence check is performed at render time.

**Rationale**: Checking `FileManager.fileExists` or `std::fs::metadata` on every catalog row render would be expensive for large libraries. The download subsystem is responsible for keeping state accurate. A stale "downloaded" state that no longer has a file on disk is handled as an error at open time (see the missing-file scenario in specs).

**Trade-off**: If a file is deleted externally between app launches, the UI will show "Open" until the user tries — then they see an error with a re-download offer. This is acceptable UX for the common case.

### Decision 4: Multi-file items route to the entry's detail tab instead of a separate picker

**Update (Rust app, implemented):** `dtrpg-api`/`dtrpg-sdk` confirmed there is no "primary file" field on the catalog item model — every multi-file entry is presented as an undifferentiated file list. Rather than build a dedicated sheet/popover to pick a file (the originally proposed approach), `ItemOpener::open_item` returns `OpenError::MultipleFilesRequireSelection` for entries with more than one file, and the caller (`open_item_or_focus_detail_tab` in `catalog_view.rs`) opens/focuses that entry's expanded detail tab instead — which already renders a persistent, selectable per-item list (the `multi-item-catalog-entry-detail` capability). Triggering "Open" from within that same detail tab is a no-op on `MultipleFilesRequireSelection`, since the list is already visible.

Rationale: `multi-item-catalog-entry-detail` was built to solve exactly this browsing problem (which file/item is this?) with per-item metadata and selection state. Building a second, separate popover for the same decision would duplicate UI and diverge from it over time. Routing to the existing surface is simpler and keeps one canonical place to browse a multi-file entry's contents.

The Swift app should follow the same pattern once its own multi-item detail view exists, rather than implement the sheet-based picker described in the original task list (see tasks 8.1-8.3).

### Decision 5: Error handling surfaces to the user, not just to logs

Both apps display an alert/dialog on open failure. The error message names the problem (missing file, no default app, OS error) and, where applicable, offers a recovery action ("Re-download" for missing files, informational text for no-default-app). Errors are also logged via `tracing` (Rust) or `os_log` (Swift) for diagnostics.

## Risks / Trade-offs

**[Risk] `xdg-open` may not be available on all Linux desktop environments** → Mitigation: `xdg-open` is part of `xdg-utils`, present on virtually all modern Linux desktops. If absent, the `open` crate returns an error, which we surface to the user. Document the `xdg-utils` runtime requirement in Linux installation notes.

**[Risk] File path encoding issues on Windows (non-ASCII paths)** → Mitigation: The `open` crate handles `OsStr` / wide-string conversion. Use `PathBuf` (not `String`) throughout the Rust implementation to avoid encoding assumptions.

**[Risk] Stale download state after external file deletion** → Mitigation: On app launch, optionally validate that files marked as "downloaded" still exist on disk. A background sweep on startup is cheap and removes stale state before the user encounters it. This sweep is a nice-to-have; the error path already handles the case if it's not implemented.

**[Risk] gpui may not have a native "open file" hook and requires spawning a process** → Mitigation: The `open` crate spawns the appropriate OS process internally. The Rust app's event loop is not blocked because `open::that` is non-blocking (it fires and returns). No async wrapper is needed.

## Migration Plan

This is a new capability with no prior implementation. Rollout:

1. Add `open` crate dependency to `dtrpg-app/rust`.
2. Implement `ItemOpener` service in the Rust app wrapping `open::that`.
3. Wire "Open" affordance into catalog item view (list and grid) conditioned on download state.
4. Wire "Open" button into item detail view.
5. Implement the same in the Swift app using `NSWorkspace`.
6. Manual test on each platform with a downloaded PDF and with a missing file.

No rollback strategy needed — the feature is additive and can be feature-flagged off if issues arise.

## Open Questions

- **Primary file designation**: Resolved — no such field exists. See Decision 4.
- **Download state model**: What is the current shape of the download state enum/struct in each app? The spec assumes a `localPath` is stored when a file is downloaded — confirm this is the case or adjust accordingly.
- **gpui affordance pattern**: Does gpui have a standard pattern for per-row action buttons in a list, or should the "Open" trigger be a right-click context menu? Defer to whatever pattern the catalog view already uses for other actions.
