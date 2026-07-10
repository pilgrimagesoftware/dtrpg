## Why

The context-menu-based "Add to…" submenu and "Remove from this collection" item added by
`collection-membership-editing` have real problems surfaced during manual testing: (1) two of the four
catalog item context-menu render sites build the submenu without `gpui-component`'s `PopupMenu.parent_menu`
back-reference wired (their call site only exposes a `Context<TableState<Self>>`, not the
`Context<PopupMenu>` the wiring needs), so dismissing the submenu never cascades to dismiss the root
context menu — right-clicking a catalog entry, hovering "Add to…", then clicking elsewhere leaves the menu
stuck on screen; (2) removing an item from a collection always rolls back near-instantly (the live
DriveThruRPG API doesn't persist membership changes yet), which reads as "nothing happened" in a transient
popup with no lasting feedback. A dedicated modal dialog replaces the fragile nested-popup interaction with
a stable, inspectable surface, and is also the natural place to let a user create a new collection on the
fly while adding an item — something the context-menu approach had no room for.

## What Changes

- Remove the "Add to…" submenu and standalone "Remove from this collection" context-menu item introduced by
  `collection-membership-editing` (all four catalog item context-menu sites: list ungrouped/grouped,
  thumb row, grid card).
- Add a single "Manage collections…" context-menu item in their place, at all four sites.
- New "Manage Collections" modal dialog, opened from that menu item (and from the detail view, see below):
  - Lists every collection with a checkbox reflecting the current item's membership.
  - Toggling a checkbox calls the existing `LibraryController::add_item_to_collection` /
    `::remove_item_from_collection` actions (unchanged from `collection-membership-editing`).
  - Includes an inline "New collection…" affordance: creates the collection via the existing
    `LibraryController::create_collection` action and immediately adds the current item as a member.
  - Surfaces add/remove/create failures as inline dialog state (not a transient toast that can be missed),
    since the live API's lack of persistence (see `collection-membership-editing` design.md) means every
    real add/remove attempt currently fails and rolls back.
- Catalog entry detail view gains a "Collections" summary: the names of collections the entry currently
  belongs to (or an empty-state message), plus a "Manage…" button that opens the same dialog scoped to that
  entry.

## Capabilities

### New Capabilities

- `collection-manage-dialog`: A modal dialog for viewing and changing which collections a single catalog
  item belongs to, including creating a new collection inline. Reachable from the catalog item context menu
  and from the entry detail view.
- `detail-view-collection-membership`: The catalog entry detail view displays a summary of the entry's
  current collection memberships and provides a button into `collection-manage-dialog`.

### Modified Capabilities

(none — `collection-membership-editing` has not been archived to `openspec/specs/` yet, so there is no
published spec to delta against. This change instead supersedes that change's still-open context-menu tasks
(3.1 "Add to…" submenu, 3.2 "Remove from this collection" item); `collection-membership-editing`'s
`tasks.md` should be updated to point here once this change lands, rather than carrying a duplicate
requirement.)

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: `append_collection_menu_items` (added by
  `collection-membership-editing`) is replaced with a single menu item that opens the new dialog; the
  four context-menu call sites are updated accordingly.
- New dialog view (exact module path TBD in design.md) under `dtrpg-app/rust/crates/dtrpg-ui/src/ui/`,
  reusing `LibraryController::add_item_to_collection`, `::remove_item_from_collection`, and
  `::create_collection` unchanged.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/detail_panel_view.rs` (or wherever the entry detail tab is
  rendered): new "Collections" summary section and "Manage…" button.
- No service-layer, controller-action, or SDK/API changes beyond what `collection-membership-editing`
  already introduced — this change is UI-surface only. The known API limitation (add/remove don't persist
  server-side yet) is unchanged and must be reflected in the dialog's failure messaging.
