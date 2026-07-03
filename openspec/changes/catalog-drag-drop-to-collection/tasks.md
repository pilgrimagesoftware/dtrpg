## 1. Drag Payload

- [ ] 1.1 Define a `CatalogItemDrag` payload type carrying the item's identifier
- [ ] 1.2 Add `on_drag` to `render_list_row`, `render_thumb_row`, and `render_grid_card` in
  `catalog_view.rs`, reusing the existing row/card element as the drag preview

## 2. Drop Targets

- [ ] 2.1 Add `on_drop` handling for `CatalogItemDrag` on sidebar collection nav items in
  `sidebar_view.rs`
- [ ] 2.2 Add hover highlight state for valid drop targets while a compatible drag is active
- [ ] 2.3 Ensure non-collection sidebar sections do not highlight or accept the drop

## 3. Controller Wiring

- [ ] 3.1 On drop, check current membership; if already a member, no-op
- [ ] 3.2 On drop, call the same controller action used by the context menu's "Add to…" item
  (`collection-membership-editing`)

## 4. Build and Verify

- [ ] 4.1 Run `cargo check --workspace`
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify drag-and-drop add from list, thumb, and grid layouts
- [ ] 4.4 Manually verify hover highlight appears only over collection targets
- [ ] 4.5 Manually verify dropping onto an existing membership is a no-op
