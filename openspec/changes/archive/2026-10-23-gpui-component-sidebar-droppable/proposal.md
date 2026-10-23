## Why

`catalog-drag-drop-to-collection` needed sidebar collection rows to act as drop targets. `gpui-component`'s
`SidebarMenuItem` — used for every sidebar row (smart filters, publishers, collections) — has no
`on_drop`/`drag_over` hooks: it is a closed builder that renders its own `div` internally with no way to
wrap or extend it from outside. As a stopgap, the Collections section in `sidebar_view.rs` was hand-rolled
as plain `gpui` `div`s, duplicating `SidebarMenuItem`'s visual styling (hover/active colors, spacing,
submenu indentation) purely so it could support drag-and-drop. This change replaces that duplication with
first-class support in `gpui-component` itself, so the Collections section can go back to using
`SidebarMenu`/`SidebarMenuItem` like every other sidebar section.

## What Changes

- Fork `github.com/longbridge/gpui-component` and add drop-target support to `SidebarMenuItem` — a
  `droppable::<T>(style_fn, on_drop_fn)` builder method (or equivalent), mirroring the
  `on_drag`/`drag_over`/`on_drop` pattern `gpui-component` already uses elsewhere (e.g. `DragPanel` in
  `crates/ui/src/dock/tab_panel.rs`).
- Point `dtrpg-app/rust`'s `Cargo.toml` `gpui-component` git dependency at the fork/branch containing this
  addition.
- Replace the hand-rolled `CollectionsSection`/`CollectionRow` types in `sidebar_view.rs` with
  `SidebarMenu`/`SidebarMenuItem` again, now using `.droppable::<DraggedLibraryItem>(...)` instead of the
  duplicated row-rendering code.
- Open an upstream PR to `longbridge/gpui-component` proposing the same addition, so this doesn't need to
  live in a private fork indefinitely.

## Capabilities

### New Capabilities

- `sidebar-menu-item-droppable`: `gpui-component`'s `SidebarMenuItem` supports first-class drop-target
  behavior, and `dtrpg-app/rust`'s Collections section uses it instead of a hand-rolled duplicate. No
  user-facing behavior change — this is a codebase/dependency-level capability, not a new feature.

### Modified Capabilities

(none — `catalog-drag-drop-to-collection` has not yet been archived to `openspec/specs/`, so there is no
canonical requirement baseline to delta against here; this change alters only how its sidebar drop target
is implemented; catalog-drag-drop-to-collection's own change should be updated/archived separately to
reflect this once it lands)

## Impact

- New dependency: a fork of `github.com/longbridge/gpui-component` (owner/location TBD — see design.md's
  open question).
- `dtrpg-app/rust/Cargo.toml`: `gpui-component` git dependency URL/rev changes to the fork/branch.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/sidebar_view.rs`: `CollectionsSection`, `CollectionRow`,
  `CollectionsSuffixFn`, `CollectionsToggleFn`, and `render_collection_row` are removed; the Collections
  section is rebuilt using `SidebarMenu`/`SidebarMenuItem` plus the new `.droppable(...)` hook, matching how
  the Publishers section and smart-filter menu are already built.
- No change to `dtrpg-app/rust/crates/dtrpg-ui/src/ui/library/drag.rs` (`DraggedLibraryItem` payload) or to
  `LibraryController::add_item_to_collection` — both are reused unchanged.
- Depends on `catalog-drag-drop-to-collection` and `collection-membership-editing` having already landed
  (they have, in `dtrpg-app/rust`); this is a pure refactor of their sidebar drop-target implementation.
