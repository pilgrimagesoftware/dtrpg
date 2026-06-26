## 1. Selection State Model

- [ ] 1.1 Replace the `Selection` enum in `data/selection.rs` with a struct: `pub struct Selection { pub entry_id: Option<Arc<str>>, pub item_id: Option<Arc<str>> }` with a `Default` impl returning both as `None`
- [ ] 1.2 Add `Selection::has_entry() -> bool`, `Selection::has_item() -> bool`, and `Selection::is_none() -> bool` convenience methods
- [ ] 1.3 Run `cargo check -p dtrpg-ui` and fix all `Selection::None` / `Selection::Item(_)` pattern-match and construction sites; the compiler will enumerate them all
- [ ] 1.4 Add a `file_count: u32` field to `LibraryItem` in `data/library.rs`, defaulting to `1` in all stub constructions, so the single-item vs multi-item branch is testable before SDK data is wired

## 2. Controller Selection Actions

- [ ] 2.1 Rename the existing `select_item(id, cx)` method in `LibraryController` to `select_entry(entry_id, cx)`; update the method to set `selection.entry_id = Some(entry_id)` and clear `selection.item_id = None`
- [ ] 2.2 Add `select_entry_item(item_id: Arc<str>, cx)` — sets `selection.item_id = Some(item_id)`; is a no-op if `selection.entry_id` is `None`
- [ ] 2.3 Add `dismiss_entry_item(cx)` — clears `selection.item_id` only; leaves `selection.entry_id` intact
- [ ] 2.4 Update `clear_selection(cx)` to clear both `entry_id` and `item_id`
- [ ] 2.5 Update `selected_item()` helper to read from `selection.entry_id`; add `selected_entry_item() -> Option<&LibraryItem>` that looks up by `selection.item_id`
- [ ] 2.6 Update `LibrarySnapshot` to expose both `selected_entry: Option<LibraryItem>` and `selected_entry_item: Option<LibraryItem>`; update `snapshot()` accordingly
- [ ] 2.7 Write unit tests: `select_entry` clears `item_id`; `dismiss_entry_item` leaves `entry_id`; `clear_selection` clears both; `select_entry_item` is no-op with no entry

## 3. Detail Panel View — Render Branch

- [ ] 3.1 Update `render_detail_panel` signature to accept `selected_entry: Option<&LibraryItem>`, `selected_entry_item: Option<&LibraryItem>`, and the controller entity
- [ ] 3.2 If `selected_entry` is `None`, return an empty `div` (unchanged behavior)
- [ ] 3.3 If `selected_entry` has `file_count == 1` (single-item), render the existing item detail view unchanged (full panel width, close button calls `clear_selection`)
- [ ] 3.4 If `selected_entry` has `file_count > 1` (multi-item), render the multi-item base layer (entry metadata + scrollable item list) with a stable `ElementId` for the scroll container
- [ ] 3.5 If `selected_entry_item` is `Some` and the entry is multi-item, render the item detail overlay `div` positioned absolutely within the panel column (`right_0`, `w(px(260.0))`, full height)
- [ ] 3.6 Update `root_view.rs` to pass both `selected_entry` and `selected_entry_item` from the snapshot into `render_detail_panel`

## 4. Multi-Item Base Layer View

- [ ] 4.1 Create `multi_item_detail_view.rs` (or add a function to `detail_panel_view.rs`) that renders: entry cover, entry title/publisher/description, scrollable item list, and a close button that calls `clear_selection`
- [ ] 4.2 Assign a stable `ElementId` to the item list scroll container using the catalog entry ID (e.g., `ElementId::from(format!("item-list-{}", entry_id))`)
- [ ] 4.3 Render each item row in the list with: item name, item type/format, and a click handler calling `select_entry_item(item_id, cx)`
- [ ] 4.4 When `selected_entry_item` is `Some`, visually highlight the selected item row in the base layer list
- [ ] 4.5 For non-item-row areas of the base layer (cover, title, empty space), add a click handler calling `dismiss_entry_item(cx)` so tapping these areas dismisses the overlay

## 5. Item Detail Overlay View

- [ ] 5.1 Create `item_detail_overlay_view.rs` (or a function) rendering the item detail: item name, format, size, download state, action buttons, and a close button calling `dismiss_entry_item(cx)`
- [ ] 5.2 Position the overlay with `div().absolute().right_0().top_0().bottom_0().w(px(260.0))` within a `position: relative` panel column container
- [ ] 5.3 Give the overlay a left border and background (`surface`) to visually separate it from the base layer strip
- [ ] 5.4 Confirm the overlay does not consume pointer events outside its bounds (the left ~60 px strip should remain fully interactive beneath it)

## 6. Panel Column Container

- [ ] 6.1 Wrap the base layer and optional overlay in a single panel column `div` with `position: relative`, `w(px(320.0))`, and `overflow_hidden`
- [ ] 6.2 Ensure the base layer is never unmounted when the overlay is shown (keep it in the render tree as the first child of the panel column at all times while an entry is selected)
- [ ] 6.3 Ensure the panel column container itself has no `on_click` handler (so clicks that reach it are not silently swallowed)

## 7. Catalog View Click Isolation

- [ ] 7.1 Audit `catalog_view.rs`, `sidebar_view.rs`, and `toolbar_view.rs` for any `on_click` handlers that call `clear_selection` or `dismiss_entry_item` — remove any such calls; these surfaces must not dismiss the detail panel
- [ ] 7.2 Confirm that clicking a catalog item row calls `select_entry(id, cx)` — which naturally replaces any current selection — rather than first calling `clear_selection`
- [ ] 7.3 Confirm that clicking the same catalog item row that is already selected does not re-trigger a state change (guard with an equality check in `select_entry`)

## 8. Verification

- [ ] 8.1 Set `file_count = 1` on a stub item; select it; verify the single-item detail fills the full panel with no item list
- [ ] 8.2 Set `file_count = 3` on a stub item; select it; verify the multi-item base layer shows with no item pre-selected
- [ ] 8.3 Click an item row in the base layer list; verify the item detail overlay appears, leaving a ~60 px strip of the base layer visible on the left
- [ ] 8.4 Click the visible strip of the base layer while the overlay is open; verify the overlay dismisses and the base layer is fully visible again
- [ ] 8.5 Click a different item row in the visible strip; verify the overlay updates to the new item in a single interaction
- [ ] 8.6 Click the overlay's close button; verify only the overlay dismisses; the base layer remains
- [ ] 8.7 Click the base layer's close button; verify both layers dismiss and the panel is hidden
- [ ] 8.8 While the overlay is open, click a catalog item row; verify both layers are replaced by the detail for the newly selected item
- [ ] 8.9 While the overlay is open, click in the catalog list area between items; verify no layer is dismissed
- [ ] 8.10 Scroll the item list in the base layer; open and close the overlay; verify the scroll position is preserved
- [ ] 8.11 Run `cargo test --workspace`; confirm all tests pass
