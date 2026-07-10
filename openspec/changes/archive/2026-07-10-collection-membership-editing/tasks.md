## 1. Service Layer

- [x] 1.1 Add `add_member(&self, collection_id: u64, item_id: u64) -> Result<(), CollectionsServiceError>`
  to `CollectionsService`
- [x] 1.2 Add `remove_member(&self, collection_id: u64, item_id: u64) -> Result<(),
  CollectionsServiceError>` to `CollectionsService`
  - Implemented on the trait, `CollectionsStubService` (all three stub modes), `RustSdkCollectionsService`,
    and `HttpSdkCollectionsGateway::remove_product_list_item` (fails explicitly with a "not supported by the
    API yet" error, mirroring `add_product_list_item` — see 1.4).
- [x] 1.3 Implement both in `CollectionsStubService` for all stub modes
  - `add_member` and `remove_member` both implemented for Seeded/Empty/Error modes.
- [x] 1.4 Verify the underlying DriveThruRPG API/SDK exposes an equivalent endpoint; if not, open a
  `dtrpg-api` change to add it and block on that first
  - Verified at the time: `dtrpg-api/openapi.yaml` documented only `GET` on `/product_lists` and
    `/product_list_items` — no add/remove-member endpoint, and `dtrpg-sdk/rust`'s `client.rs` had no
    corresponding method. Both `HttpSdkCollectionsGateway::add_product_list_item` and
    `::remove_product_list_item` failed explicitly with a "not supported by the API yet" error rather than
    guess at an undocumented request shape.
  - Resolved: `dtrpg-api`'s `collections-crud-contract` change (archived
    `2026-07-06-define-collections-crud-contract`) documented `POST`/`DELETE` on `/product_lists` and
    `/product_list_items`, and `dtrpg-sdk` 0.1.0 (published to crates.io, already the version
    `dtrpg-app` depends on) implements `LibraryClient::add_product_list_item`/`delete_product_list_item`
    against that contract. `HttpSdkCollectionsGateway::add_product_list_item`/`::remove_product_list_item`
    now call those SDK methods instead of failing explicitly. Because `DELETE /product_list_items/{id}`
    takes the item's own id (not the product's id), `remove_product_list_item` first paginates
    `list_product_list_items` to resolve `order_product_id`/`product_id` to its `productListItemId`.
    Membership add/remove now persist server-side; the optimistic update (task 2.1) is reconciled against
    a real response instead of always rolling back.
  - Separately, `dtrpg-sdk/rust`'s own nested `API` submodule pointer had regressed from the
    `collections-crud-contract` commit back to an older one during an unrelated merge-conflict resolution,
    orphaning its SDK methods against a spec that no longer documented them. Fixed on a
    `fix/restore-collections-api-submodule` branch in `dtrpg-sdk/rust`. This didn't block the `dtrpg-app`
    fix above, since `dtrpg-app` depends on the already-published crates.io 0.1.0 release, not the git
    submodule.

## 2. Controller Actions

- [x] 2.1 Add `LibraryController` actions to invoke add/remove member with optimistic local update
  - `LibraryController::add_item_to_collection` and `::remove_item_from_collection` both implemented
    (optimistic update + confirm via service, mirrored logic in each direction).
- [x] 2.2 Wire rollback-and-alert behavior on service failure
  - Both actions roll back the optimistic `member_ids`/`collection_members` update and emit
    `CollectionMemberAddFailed`/`CollectionMemberRemoveFailed` on service failure. `root_view.rs` subscribes
    to both and pushes an error `Notification`, mirroring the existing `CollectionCreateFailed` pattern.
    (`CollectionMemberAddFailed` had been defined and emitted since `catalog-drag-drop-to-collection`, but
    `root_view.rs` was never actually subscribed to it — add-member failures silently rolled back with no
    visible notification. Fixed as part of this pass, alongside wiring the new remove-failure event.)

## 3. Context Menu

- [x] 3.1 Add "Add to…" submenu construction to the catalog item context menu, listing collections with
  checked state from the live cache — **superseded, see below**
  - Originally implemented as a shared `append_collection_menu_items` helper in `catalog_view.rs`. Manual
    testing surfaced a real bug: two of the four context-menu call sites (`TableDelegate::context_menu`)
    only expose a `Context<TableState<Self>>`, not the `Context<PopupMenu>` that `PopupMenu`'s submenu
    `parent_menu` back-reference requires to wire dismissal — so the submenu never cascaded a dismiss to
    the root context menu, and clicking outside it (after hovering "Add to…") left the whole menu stuck on
    screen. `collection-manage-dialog` replaces this submenu entirely with a modal dialog instead of
    patching the wiring; see that change for the fix and its design.md for the root-cause writeup.
- [x] 3.2 Add "Remove from this collection" direct item when the current view is a collection —
  **superseded, see below**
  - Also replaced by `collection-manage-dialog`'s modal (checkbox-per-collection), for the same reason:
    removing against the live API always rolls back near-instantly (see 1.4), which read as "nothing
    happened" in a transient popup with no persistent feedback surface.

## 4. Build and Verify

- [x] 4.1 Run `cargo check --workspace`
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 4.3 Manually verify add/remove via submenu updates checked state and collection contents —
  **N/A, superseded**
  - The submenu this task referred to no longer exists (see 3.1). Its replacement is verified via
    `collection-manage-dialog`'s own tasks.md (6.3–6.6).
- [x] 4.4 Manually verify direct remove while viewing a collection — **N/A, superseded**
  - The "Remove from this collection" item this task referred to no longer exists (see 3.2). Replaced by
    unchecking a collection's checkbox in the Manage Collections dialog; verified via
    `collection-manage-dialog`'s tasks.md (6.3).
- [x] 4.5 Manually verify rollback and error surfacing on simulated service failure
  - Covered at the code level: both add and remove paths roll back optimistic state and emit their
    respective failure events on error, and `root_view.rs` subscribes to both and pushes a `Notification`
    (see 2.2's note on the pre-existing `CollectionMemberAddFailed` wiring gap that was fixed here).
    `collection-manage-dialog` additionally subscribes to these events itself for inline dialog error state
    — see that change's tasks.md 6.3 for the interactive verification.

## Status

This change implements the add-member and remove-member paths end-to-end: service trait, stub, SDK gateway
(explicit "not supported yet" error), and controller actions with optimistic update + rollback. `cargo
check` and `cargo clippy -D warnings` pass across the workspace.

Also fixed in this pass: `CollectionMemberAddFailed` (introduced by `catalog-drag-drop-to-collection`) was
never actually subscribed to in `root_view.rs`, so add-member failures rolled back silently with no user-
visible error. Both `CollectionMemberAddFailed` and the new `CollectionMemberRemoveFailed` are now wired to
a `Notification`.

This change's own context-menu UI (tasks 3.1/3.2) has been superseded by `collection-manage-dialog`, which
replaces the "Add to…" submenu / "Remove from this collection" item with a single "Manage collections…"
dialog — see that change for why (a structural `PopupMenu` dismiss bug, and illegible rollback feedback)
and for the remaining interactive verification. This change is otherwise ready to archive once
`collection-manage-dialog` lands; the still-open `dtrpg-api` work to add real add/remove-member endpoints
(so membership changes persist server-side instead of only rolling back) remains a separate follow-up.
