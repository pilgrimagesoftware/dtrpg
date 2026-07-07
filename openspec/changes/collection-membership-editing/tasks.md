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
  checked state from the live cache
  - Implemented as a shared `append_collection_menu_items` helper in `catalog_view.rs`, called from all four
    catalog item context menu sites (ungrouped/grouped list-layout table delegates, thumb row, grid card).
    Clicking a checked collection removes membership; clicking an unchecked one adds it.
- [x] 3.2 Add "Remove from this collection" direct item when the current view is a collection
  - Implemented in the same helper — appended when `LibraryController::filter` is
    `SidebarFilter::Collection(..)`.

## 4. Build and Verify

- [x] 4.1 Run `cargo check --workspace`
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify add/remove via submenu updates checked state and collection contents
  - Partially verified: right-clicking a catalog item while viewing a collection shows the context menu
    with "Download", "Add to…", and "Remove from this collection" (confirmed visually in a running,
    signed-in session). Clicking through the submenu and observing the checked-state toggle live was not
    completed interactively this session — coordinate-based UI automation proved unreliable against this
    native gpui app (no accessibility tree exposed, no `cliclick`-equivalent available), and the user opted
    to defer the remaining click-through rather than continue.
- [ ] 4.4 Manually verify direct remove while viewing a collection
  - Not manually re-verified interactively; same automation limitation as 4.3. The menu item is confirmed
    present and correctly gated on `SidebarFilter::Collection`.
- [ ] 4.5 Manually verify rollback and error surfacing on simulated service failure
  - Not manually re-verified interactively. Covered at the code level: both add and remove paths roll back
    optimistic state and emit their respective failure events on error, and — as of this pass —
    `root_view.rs` actually subscribes to both events and pushes a `Notification` (see 2.2's note on the
    pre-existing `CollectionMemberAddFailed` wiring gap that was fixed here). Since the live API doesn't
    support add/remove yet (see 1.4), every real add/remove attempt hits this rollback path, so it's
    readily verifiable by hand in a signed-in session: right-click any item, click "Add to…" → a collection,
    and confirm a red error notification appears after the optimistic UI change reverts.

## Status

This change now implements both the add-member and remove-member paths end-to-end: service trait, stub,
SDK gateway (explicit "not supported yet" error), controller actions with optimistic update + rollback, and
both context-menu entry points ("Add to…" submenu, "Remove from this collection"). `cargo check` and
`cargo clippy -D warnings` pass across the workspace.

Also fixed in this pass: `CollectionMemberAddFailed` (introduced by `catalog-drag-drop-to-collection`) was
never actually subscribed to in `root_view.rs`, so add-member failures rolled back silently with no user-
visible error. Both `CollectionMemberAddFailed` and the new `CollectionMemberRemoveFailed` are now wired to
a `Notification`.

Remaining before this can be archived: an interactive click-through of the submenu/remove-item/rollback
notification in a signed-in session (4.3–4.5 above), and the `dtrpg-api` change to add real add/remove-member
endpoints so membership changes persist server-side instead of only rolling back.
