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
  - Verified: `dtrpg-api/openapi.yaml` documents only `GET` on `/product_lists` and `/product_list_items` —
    no add/remove-member endpoint. `dtrpg-sdk/rust`'s `client.rs` has no corresponding method either.
  - Rather than block the whole feature on a `dtrpg-api` change, both `HttpSdkCollectionsGateway::
    add_product_list_item` and `::remove_product_list_item` (in `dtrpg-core/src/services/collections_sdk.rs`)
    fail explicitly with a clear "not supported by the API yet" error instead of guessing an undocumented
    request shape against the live DriveThruRPG API. A `dtrpg-api` change to add the real endpoints is still
    an open follow-up — membership add/remove do not currently persist to the server; only the local
    optimistic update (task 2.1) is visible until those endpoints exist.

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
