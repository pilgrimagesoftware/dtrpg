## Why

Catalog items currently expose actions (download, reveal in file manager) only through the detail panel, which requires selecting an item first. A right-click context menu makes these actions discoverable and reachable without changing the selection, matching the interaction model users expect from native desktop catalog apps.

## What Changes

- Add right-click (secondary click) context menus to catalog item list rows, thumb rows, and grid cards in the Rust app.
- Initial menu items:
  - **Show in Finder / Explorer / Files** — calls `reveal_in_file_manager` on the item's resolved storage path; enabled only when the item is downloaded.
  - **Download** — triggers the download action; shown when the item is not yet downloaded.
  - **Remove Download** — removes the local file and marks item as cloud-only; shown when the item is downloaded.
- Context menu appearance and dismissal follow platform conventions (no custom chrome).

## Capabilities

### New Capabilities

- `catalog-context-menu`: Right-click context menu on catalog items exposing reveal, download, and remove-download actions gated on item download state.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust`: `catalog_view.rs` (list row, thumb row, grid card), `controllers/library.rs` (remove-download action), `util/reveal.rs` (already exists).
- gpui context menu API must be verified; gpui does not ship a built-in `ContextMenu` widget — a custom popover or the `right_button_down` / `on_secondary_mouse_down` event will be used.
- No new dependencies expected.
