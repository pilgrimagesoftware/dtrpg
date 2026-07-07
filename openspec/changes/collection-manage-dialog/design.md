## Context

`collection-membership-editing` added an "Add to…" submenu and a "Remove from this collection" item to
every catalog item context menu, built via `gpui-component`'s `PopupMenu`/`PopupMenuItem::submenu`. Manual
testing surfaced two problems:

1. **Dismiss bug**: `PopupMenu`'s dismiss cascade depends on a submenu's `parent_menu` weak reference to its
   root menu (see `crates/ui/src/menu/popup_menu.rs`'s `dismiss`/`handle_dismiss`). Setting that reference
   requires `cx: &mut Context<PopupMenu>` at the point the submenu is built. Two of this app's four catalog
   context-menu sites are `TableDelegate::context_menu(&mut self, row_ix, menu, window, cx: &mut
   Context<TableState<Self>>)` — a different context type — so `append_collection_menu_items` (in
   `catalog_view.rs`) builds the submenu via a raw `PopupMenu::build` call with no way to wire
   `parent_menu`. Result: clicking outside the menu while the submenu is open dismisses only the submenu,
   never cascades to the root `ContextMenu`, which stays on screen indefinitely.
2. **Illegible removal**: `HttpSdkCollectionsGateway::remove_product_list_item` (and
   `::add_product_list_item`) fail immediately — the live DriveThruRPG API has no endpoint for either
   operation yet (`collection-membership-editing` design.md). Every real add/remove optimistically updates,
   then rolls back on the next tick. In a transient popup this reads as "nothing happened"; a modal dialog
   that stays open and can show inline error state makes the same limitation legible.

Rather than patch the submenu's dismiss wiring (which would need restructuring the two `TableDelegate`
call sites to obtain the right context type, for a UI pattern that will always be one interaction away
from this class of bug), this change replaces the submenu approach entirely with a modal dialog.

## Goals / Non-Goals

**Goals:**
- Replace the "Add to…"/"Remove from this collection" context-menu items with one "Manage collections…"
  item opening a modal dialog, at all four catalog context-menu sites.
- Let the dialog create a new collection inline and immediately add the target item to it.
- Show inline, persistent error state in the dialog when add/remove/create fails — not just a toast.
- Add a "Collections" summary + "Manage…" button to the catalog entry detail view.

**Non-Goals:**
- No changes to `CollectionsService`, `LibraryController::add_item_to_collection`/
  `::remove_item_from_collection`, or the SDK gateway — those are reused as-is.
- No `dtrpg-api`/`dtrpg-sdk` changes. Add/remove still don't persist server-side; that remains a tracked
  follow-up (`collection-membership-editing` task 1.4), unaffected by this change.
- No change to the sidebar drag-and-drop collection drop target (`catalog-drag-drop-to-collection`,
  `gpui-component-sidebar-droppable`) — this change is scoped to the context menu and detail view only.

## Decisions

**Use `gpui-component`'s `Dialog` + `Window::open_dialog`, not a hand-rolled overlay.** `crates/ui/src/
dialog/dialog.rs` provides `Dialog::new(cx).title(..).content(|window, cx| ..).footer(..)`, opened
imperatively via `window.open_dialog(cx, move |dialog, window, cx| { .. })` — exactly the shape needed for
opening from a menu-item `on_click` or a detail-view button `on_click`, with no submenu/`parent_menu`
dismiss chain involved. `Dialog` owns its own outside-click/Escape dismissal, sidestepping the bug in
Context. This also matches the "always prefer `gpui-component` components" project convention.

**Add `LibraryController::create_collection_and_add_member(name, item_id, cx)` rather than have the
dialog orchestrate two separate fire-and-forget calls.** `create_collection` is fire-and-forget
(`cx.spawn` + `CollectionCreateFailed` event on failure, push-to-`collections` + `LibraryChanged` on
success) with no return value the caller can chain on. The dialog's "New collection…" affordance needs
"create, then add this item to the new collection" as one user-visible action. A dedicated controller
method awaits the create call itself and, only on success, immediately calls the existing
`add_item_to_collection` logic with the newly created collection's id — reusing that method's own
optimistic-update/rollback/event behavior rather than duplicating it. On create failure, only
`CollectionCreateFailed` fires; no add is attempted.

**Dialog subscribes to the existing failure events directly; `root_view.rs`'s toast subscriptions are
unchanged.** `CollectionMemberAddFailed`, `CollectionMemberRemoveFailed`, and `CollectionCreateFailed` are
already `EventEmitter`s on `LibraryController`. GPUI event emitters support multiple simultaneous
subscribers, so the dialog entity adds its own subscription (active only while open) to drive inline error
state, alongside — not instead of — `root_view.rs`'s existing toast subscriptions. This keeps the toast
behavior correct for any future entry point into these actions while giving the dialog the persistent,
visible-while-open feedback the spec requires.

**Dialog is scoped to a single item, not a bulk-edit surface.** Matches the proposal: it's opened either
from a specific catalog item's context menu or from the detail view of a specific entry, always with one
target item in mind. A collection-centric "which items are in this collection" view is out of scope here.

**Detail view summary re-reads `LibraryController::collections` on dialog close, not via a live
subscription while the dialog is open.** The detail view already re-renders on `LibraryChanged` (emitted
by every add/remove/create path), so no new plumbing is needed beyond ensuring the summary section reads
current membership from `collections`/`collection_member_id` each render, same as the context menu's
existing membership check.

## Risks / Trade-offs

- [Dialog and the existing per-row context-menu membership check now both compute membership the same
  way but in two places] → Both already share `collection_member_id`/`CollectionEntry::member_ids`
  directly; no new derivation logic, just two call sites reading the same data.
- [Every real add/remove/create still fails against the live API] → Unchanged limitation, now made
  legible via inline dialog error state instead of a barely-visible toast; the underlying `dtrpg-api` gap
  remains open and out of scope here.
- [Removing the submenu changes previously-shipped context-menu structure] → Not a published spec
  (`collection-membership-editing` is still an open change), so no migration/deprecation needed — its
  `tasks.md` 3.1/3.2 should simply be marked superseded by this change.

## Open Questions

- Exact dialog layout (checkbox list styling, "New collection…" as an inline text input vs. a nested
  small dialog) is left to implementation; no existing app pattern strongly dictates one over the other.
