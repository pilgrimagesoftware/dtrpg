## 1. Drag Payload

- [x] 1.1 Define a `CatalogItemDrag` payload type carrying the item's identifier
  - Implemented as `DraggedLibraryItem` (`dtrpg-app/rust/crates/dtrpg-ui/src/ui/library/drag.rs`), carrying
    a display `title` and `member_id` (the item's `order_product_id`, falling back to `product_id` — see
    `collection_member_id` in `util/matching.rs`), rather than the full catalog entry, per this change's own
    design decision.
- [x] 1.2 Add `on_drag` to `render_list_row`, `render_thumb_row`, and `render_grid_card` in
  `catalog_view.rs`, reusing the existing row/card element as the drag preview
  - `on_drag` added to `render_grid_card` and `render_thumb_row` only. The list layout's row (rendered
    per-cell via `CatalogListDelegate::render_td`/`render_list_item_cell`, backed by gpui-component's
    `DataTable`/`TableDelegate`) was left out of scope for this pass — attaching drag behavior per-cell
    risked interfering with the table's own column-resize/sort-click handling, and needed more investigation
    than this pass covered. Tracked here as remaining work, not silently dropped.
  - Drag preview is a small dedicated element (`DraggedLibraryItem::render`, a bordered pill with the
    title), not the actual row/card reused dimmed as originally decided in design.md — reusing the live
    row would have needed either cloning the row's full render context (cover cache, colors, density,
    tabs entity, storage path) into the drag payload, or a second lightweight row-rendering path; the
    dedicated small preview was simpler and judged good enough for now. Revisit if the plain preview reads
    as visually inconsistent in practice.

## 2. Drop Targets

- [x] 2.1 Add `on_drop` handling for `CatalogItemDrag` on sidebar collection nav items in `sidebar_view.rs`
  - Required hand-rolling the Collections section (`CollectionsSection`/`CollectionRow` in
    `sidebar_view.rs`) as plain `div`s instead of `gpui-component`'s `SidebarMenuItem`, which exposes no
    `on_drop`/`drag_over` hook on its row. See the `gpui-component-sidebar-droppable` follow-up change,
    which proposes patching `gpui-component` so this hand-rolled duplication can be removed.
- [x] 2.2 Add hover highlight state for valid drop targets while a compatible drag is active
  - `drag_over::<DraggedLibraryItem>` paints `cx.theme().tokens.drop_target` on the row background.
- [x] 2.3 Ensure non-collection sidebar sections do not highlight or accept the drop
  - True by construction: only collection rows are wired to `drag_over`/`on_drop`; the smart-filter menu
    and Publishers section are unaffected.

## 3. Controller Wiring

- [x] 3.1 On drop, check current membership; if already a member, no-op
  - `LibraryController::add_item_to_collection` returns early if `collection.member_ids` already contains
    the dropped item's id.
- [ ] 3.2 On drop, call the same controller action used by the context menu's "Add to…" item
  (`collection-membership-editing`)
  - Partially true: the drop handler does call `LibraryController::add_item_to_collection`, which is the
    shared underlying action — but `collection-membership-editing`'s context-menu "Add to…" entry point
    was never built (see that change's tasks.md), so drag-and-drop is currently the *only* entry point into
    this action, not a second one alongside the context menu as originally envisioned.

## 4. Build and Verify

- [x] 4.1 Run `cargo check --workspace`
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 4.3 Manually verify drag-and-drop add from list, thumb, and grid layouts
  - Verified for thumb and grid layouts only (see 1.2 — list/DataTable row drag source was not
    implemented in this pass).
- [x] 4.4 Manually verify hover highlight appears only over collection targets
- [ ] 4.5 Manually verify dropping onto an existing membership is a no-op
  - Covered by the code path (3.1) but not re-verified interactively in the running app.

## Status

Core interaction (drag from grid/thumb catalog cards onto a sidebar collection, adding membership with
hover feedback and idempotent re-drop) is implemented and working. Known gaps before this can be archived
as fully done: no drag source on the list layout's row (1.2), no context-menu "Add to…" alternate entry
point (blocked on `collection-membership-editing` 3.1), and the sidebar drop target is a hand-rolled
duplicate of `SidebarMenuItem` pending `gpui-component-sidebar-droppable`.
