## Context

The current detail panel (`detail_panel_view.rs`) is a 320 px absolute-positioned `div` that renders a single item detail when `Selection::Item(id)` is set. It has a close button that calls `clear_selection`. Clicking anywhere in the catalog fires `select_item` (which replaces the selection), not `clear_selection` — so the existing behavior already avoids accidental dismissal from catalog clicks. The gap this change closes is:

1. No concept of a catalog entry having multiple items; the selection model is flat.
2. No overlay layer within the panel for the item-within-entry detail.
3. The visible-strip-of-base-layer interaction (click to dismiss overlay) doesn't exist.

The `multi-item-catalog-entry-detail` change specifies what the content of each layer looks like. This change specifies the state machine that governs which layers are shown and how they dismiss.

## Goals / Non-Goals

**Goals:**
- Extend `Selection` to two levels: `CatalogEntry(id)` and optionally `EntryItem(id)` within it.
- Render the correct detail layer(s) based on selection state and item count.
- Implement the overlay layout: item detail covers ~80% of the panel column right-aligned; ~60 px base layer strip is left exposed and receives clicks.
- Implement the dismissal contract: overlay closes on close-button or base-layer-strip click; catalog/sidebar clicks do not dismiss.
- Preserve base layer scroll position across overlay transitions.

**Non-Goals:**
- Animated transitions for the overlay (slide/fade) — correct layout and state management first; animation is additive.
- Persisting item-within-entry selection across navigation (already specified as ephemeral in `catalog-entry-detail-view`).
- Keyboard navigation between levels (a follow-up accessibility concern).

## Decisions

### Decision 1: Extend Selection to carry two optional IDs

Replace the current `Selection` enum:

```rust
pub enum Selection {
    None,
    Item(Arc<str>),
}
```

With a struct that decouples the two levels:

```rust
pub struct Selection {
    pub entry_id: Option<Arc<str>>,
    pub item_id: Option<Arc<str>>,   // only meaningful when entry_id is Some
}
```

`item_id` is automatically cleared whenever `entry_id` changes. Controller methods become:
- `select_entry(entry_id)` — sets `entry_id`, clears `item_id`
- `select_entry_item(item_id)` — sets `item_id` within the current `entry_id`; no-op if `entry_id` is `None`
- `dismiss_entry_item()` — clears `item_id` only
- `clear_selection()` — clears both

**Alternative considered**: Keep the enum, add `EntryWithItem(Arc<str>, Arc<str>)` variant. Rejected because matching on the enum everywhere becomes verbose, and the struct naturally enforces the invariant that `item_id` requires `entry_id`.

### Decision 2: Item count drives the render branch, not a separate flag

The detail panel rendering function reads `LibraryItem::files.len()` (or equivalent field once the SDK model is wired) to branch between single-item and multi-item layouts. There is no explicit "is_multi_item" flag stored separately. This keeps the rendering function pure and testable given only the selected `LibraryItem`.

For the stub catalog (where `LibraryItem` does not yet carry file lists), default to treating all entries as single-item. Adjust when the SDK data model is connected.

### Decision 3: Overlay is a second absolute-positioned div within the detail panel column

The detail panel column container is a `div` with `position: relative` and a fixed width (320 px). The base layer fills this container normally. The item detail overlay is:

```
div()
    .absolute()
    .right_0()
    .top_0()
    .bottom_0()
    .w(px(260.0))   // ~81% of 320 px; leaves ~60 px strip
    .bg(surface)
    .border_l_1()
    ...
```

This approach keeps both layers in the same DOM subtree, avoids any global z-index management, and means the visible strip (the leftmost ~60 px of the panel) naturally receives click events because the overlay does not cover it.

**Alternative considered**: Two adjacent panels (base panel shrinks when overlay opens). Rejected — resizing the base layer triggers a layout reflow of the item list, violating the scroll-preservation requirement.

### Decision 4: Click-on-visible-strip is handled by the base layer, not the overlay

The base layer's item rows and non-interactive areas fire their own click handlers normally. Because the overlay only covers the right ~260 px of the 320 px column, clicks on the left ~60 px reach the base layer view directly. No special "dismiss overlay on outside click" handler is needed — the base layer's `on_click` handlers call `select_entry_item(new_id)` (which replaces the overlay) or `dismiss_entry_item()` (on non-item areas), and that is sufficient.

This means: **there is no global click listener**. The catalog view, sidebar, and toolbar render no "dismiss detail" click handler. The detail panel is the only place dismissal can be triggered.

**Alternative considered**: A transparent full-screen click-capture backdrop behind the overlay. Rejected — this would intercept catalog clicks and create the exact "click outside to dismiss" behavior the spec explicitly forbids.

### Decision 5: Scroll position preservation via gpui scroll state

gpui renders the base layer's scrollable item list inside a scroll container with a stable `ElementId`. As long as the scroll container's `ElementId` does not change between renders, gpui preserves the scroll offset across re-renders. The overlay is added to a sibling element, not to the scroll container. Provided the `ElementId` for the base layer scroll region is stable and the base layer is not unmounted when the overlay appears, scroll position is preserved automatically.

The base layer must NOT be conditionally unmounted when the overlay is shown — it must remain in the render tree at all times while a multi-item entry is selected.

## Risks / Trade-offs

**[Risk] gpui may not preserve scroll position across renders if the element tree structure changes** → Mitigation: Use a stable, unique `ElementId` for the base layer scroll container (e.g., tied to the catalog entry ID). Verify empirically during implementation. If scroll is not preserved, store the offset in `LibraryController` state and restore it explicitly on re-render.

**[Risk] The ~60 px visible strip may be too narrow for the item list to be meaningfully interactive** → Mitigation: The strip's primary function is to signal "click here to go back" and to allow item re-selection. Even at 60 px, item rows can show a truncated title with an arrow indicator. The exact width is a design tuning parameter — the spec requires a minimum 60 px, and the implementation can offer more.

**[Risk] The current `Selection::Item(Arc<str>)` is used throughout the controller and views; changing to a struct is a broad refactor** → Mitigation: The change is mechanical — `Selection::Item(id)` → `Selection { entry_id: Some(id), item_id: None }` everywhere. Compiler errors will identify all call sites. No logic changes at the call sites, only construction and pattern-matching syntax.

**[Risk] Stub catalog items all have zero files, so all entries will be treated as single-item** → Mitigation: Acceptable for now. Once `connect-sdk-to-rust-app` is live, real data will have multi-file entries. Test the multi-item path manually by temporarily setting a stub item to have `files.len() > 1` or by adding a flag field.

## Migration Plan

1. Change `Selection` from enum to struct; update all construction and match sites in the controller and views.
2. Add `select_entry`, `select_entry_item`, `dismiss_entry_item` to `LibraryController`; rename existing `select_item` to `select_entry`.
3. Update `detail_panel_view.rs` to branch on item count: single-item path (existing rendering) or multi-item path (base layer + optional overlay).
4. Implement the overlay `div` within the panel column container.
5. Verify that catalog clicks and sidebar clicks do not call any dismissal action.
6. Test: select multi-item entry → overlay appears on item select → clicking strip dismisses overlay → close button dismisses overlay → selecting new entry replaces all state.

## Open Questions

- **Item count source**: Until the SDK is wired, `LibraryItem` does not carry a file list. Should a `file_count: u32` field be added to `LibraryItem` now (defaulting to 1 in the stub) so the branch works before the SDK is connected?
- **Overlay width tuning**: Is 260 px (leaving a 60 px strip) the right split, or should the strip be wider (e.g., 80 px) to make it more obviously tappable? This is a UI judgment call to be made during implementation.
- **Entry ID vs item ID namespacing**: The `Arc<str>` item IDs in the stub are strings like `"b1"`. Will catalog entry IDs and item-within-entry IDs ever collide in the real data model? If so, the `Selection` struct should use typed newtypes to prevent mixing them up.
