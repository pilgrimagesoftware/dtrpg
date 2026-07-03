## Why

The context-menu path for adding an item to a collection (see `collection-membership-editing`) requires
several clicks through a submenu. Drag-and-drop from the catalog onto a collection in the sidebar is the
native desktop interaction users expect for this action and is faster for repeated use.

## What Changes

- Catalog items (list row, thumb row, grid card) become drag sources carrying the item's identifier.
- Sidebar collection entries become drop targets; dropping a dragged item onto a collection adds that item
  as a member of the collection, using the same underlying operation added in
  `collection-membership-editing`.
- Visual feedback: the collection entry highlights while a compatible drag is hovering over it; an invalid
  drop (e.g. dropping onto a non-collection sidebar section) is a no-op with no highlight.

## Capabilities

### New Capabilities

- `catalog-drag-drop-to-collection`: Catalog items can be dragged onto a sidebar collection to add them as
  members.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: drag source setup on list row, thumb
  row, grid card (`gpui`'s drag-and-drop API, e.g. `on_drag` / `Draggable`).
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/sidebar_view.rs`: drop target setup on collection nav
  items (`on_drop` / `Droppable` / hover highlight state).
- `dtrpg-app/rust/crates/dtrpg-ui/src/controllers/library.rs`: reuses the `add_member` controller action
  from `collection-membership-editing`.
- Depends on `collection-membership-editing` landing first (or in parallel) for the underlying
  `add_member` operation.
