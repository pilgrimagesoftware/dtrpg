## Why

The current detail panel renders a single flat view for any selected catalog item, ignoring whether that item is a single-file entry or a bundle with multiple files. Now that `multi-item-catalog-entry-detail` specifies distinct content for each case, the detail panel needs a layering interaction model: the multi-item list is a persistent base layer, and the individual item detail slides in as an overlay on top of it — without the standard "click outside to dismiss" behavior that would disrupt the browsing flow.

## What Changes

- The `Selection` state model is extended to two levels: a selected **catalog entry** (first level) and an optionally selected **item within that entry** (second level, only meaningful for multi-item entries).
- Selecting a catalog entry with a single file shows the item detail view directly in the right sidebar — no overlay, no list.
- Selecting a catalog entry with multiple files shows the multi-item detail view (file list + entry metadata) as the base layer in the right sidebar.
- Selecting an individual item from the multi-item detail view slides the item detail in as an overlay on top of the right portion of the multi-item detail, with part of the multi-item detail remaining visible beneath.
- The item detail overlay is dismissed **only** by: (a) the user clicking in the visible portion of the multi-item detail, or (b) the user clicking the item detail's close control. Clicking anywhere in the catalog/sidebar area outside the right panel does **not** dismiss either layer.
- Selecting a different catalog entry replaces both layers with the appropriate detail for the new entry.

## Capabilities

### New Capabilities

- `detail-panel-layering`: The two-level interaction model for the right sidebar detail panel — selection state machine (entry → optional item), overlay layout rules, and the dismissal contract (explicit only, no click-outside-to-close).

### Modified Capabilities

- `catalog-entry-detail-view`: The existing spec (from `multi-item-catalog-entry-detail`) defines content requirements for single-item and multi-item entries. This change adds requirements for the item detail overlay within multi-item entries and the dismissal interaction — both are spec-level behavioral changes.

## Impact

- **dtrpg-app/rust**: `data/selection.rs` — `Selection` enum gains a second level (`CatalogEntry` + optional `SelectedItem`). `controllers/library.rs` — new selection actions: `select_entry`, `select_entry_item`, `dismiss_entry_item`. `ui/views/detail_panel_view.rs` — split into base layer (multi-item) and overlay layer (item detail); rendered in a column container that owns both. `ui/views/root_view.rs` — click handling in the catalog area must not trigger selection clearing.
- **dtrpg-app/swift**: Equivalent selection state and view layering in SwiftUI; dismissal driven by `ZStack` with tap gesture on the visible portion of the base layer.
- **No API or SDK changes.**
