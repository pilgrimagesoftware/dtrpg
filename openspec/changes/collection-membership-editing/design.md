## Context

`CollectionsService` currently exposes `list_collections`, `create_collection`, and `delete_collection`.
`CollectionEntry` already carries `member_ids: Arc<[u64]>`, so the domain model has a place to store
membership, but nothing mutates it at the item level today. The `catalog-context-menu` change already
established the `.context_menu(...)` pattern (via `gpui_component::menu::ContextMenuExt`) for per-item
right-click menus with conditional items gated on item state — this change extends that same menu.

## Goals / Non-Goals

**Goals:**

- Add/remove a single item to/from a collection from the catalog context menu.
- Reflect the change immediately in the UI (checked state in the submenu, item list of the affected
  collection) without requiring a full collections reload.
- Special-case the "currently viewing this collection" scenario with a direct remove action instead of a
  submenu.

**Non-Goals:**

- Bulk add/remove (selecting multiple items and adding all to a collection) — deferred.
- Drag-and-drop to add (covered by the separate `catalog-drag-drop-to-collection` change).
- Reordering members within a collection.

## Decisions

**Extend `CollectionsService` with `add_member(collection_id, item_id)` and
`remove_member(collection_id, item_id)`.**

Rationale: mirrors the existing verb-per-operation shape of the trait (`create_collection`,
`delete_collection`) rather than a single generic `update_members` call, keeping each operation's error
handling and stub behavior simple and explicit.

**Submenu built from the live collections cache, not a fresh fetch on menu open.**

Rationale: the collections cache is already the source of truth for the sidebar; reusing it for the
context menu avoids a network round-trip just to open a menu, matching the "no disabled items, only
applicable ones" pattern already used in `catalog-context-menu`.

**Optimistic update, reconciled on response.**

Rationale: catalog context menus are expected to feel instant. The controller updates local state (item's
implicit membership, collection's `member_ids`) immediately on click, then reconciles against the actual
service response — rolling back and surfacing an error via the existing alert/notification path if the
call fails.

## Risks / Trade-offs

- If the underlying DriveThruRPG API has no add/remove-member endpoint, this change is blocked pending an
  `dtrpg-api` contract addition — flagged in Impact.
- Optimistic updates that fail need a rollback path; reuse the existing alert/notification mechanism
  (`alert_history_view.rs`) rather than inventing a new error surface.
