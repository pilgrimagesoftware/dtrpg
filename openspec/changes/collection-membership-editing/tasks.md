## 1. Service Layer

- [x] 1.1 Add `add_member(&self, collection_id: u64, item_id: u64) -> Result<(), CollectionsServiceError>`
  to `CollectionsService`
- [ ] 1.2 Add `remove_member(&self, collection_id: u64, item_id: u64) -> Result<(),
  CollectionsServiceError>` to `CollectionsService`
  - Not implemented. Only `add_member` was needed to unblock `catalog-drag-drop-to-collection` (drag only
    adds membership); `remove_member` still has no trait method, no stub, no SDK gateway method, and no
    controller action.
- [x] 1.3 Implement both in `CollectionsStubService` for all stub modes
  - Only `add_member` implemented in the stub (`CollectionsStubService`), for all three modes
    (Seeded/Empty/Error). `remove_member` is not implemented since it doesn't exist on the trait yet.
- [x] 1.4 Verify the underlying DriveThruRPG API/SDK exposes an equivalent endpoint; if not, open a
  `dtrpg-api` change to add it and block on that first
  - Verified: `dtrpg-api/openapi.yaml` documents only `GET` on `/product_lists` and `/product_list_items` —
    no add/remove-member endpoint. `dtrpg-sdk/rust`'s `client.rs` has no corresponding method either.
  - Rather than block the whole feature on a `dtrpg-api` change, `HttpSdkCollectionsGateway::
    add_product_list_item` (in `dtrpg-core/src/services/collections_sdk.rs`) was implemented to fail
    explicitly with a clear "not supported by the API yet" error instead of guessing an undocumented
    request shape against the live DriveThruRPG API. A `dtrpg-api` change to add the real endpoint is still
    an open follow-up — membership additions do not currently persist to the server; only the local
    optimistic update (task 2.1) is visible until that endpoint exists.

## 2. Controller Actions

- [x] 2.1 Add `LibraryController` actions to invoke add/remove member with optimistic local update
  - `LibraryController::add_item_to_collection` implemented (optimistic add + confirm via service). No
    corresponding remove action exists yet (see 1.2).
- [x] 2.2 Wire rollback-and-alert behavior on service failure
  - `add_item_to_collection` rolls back the optimistic `member_ids`/`collection_members` update and emits
    `CollectionMemberAddFailed` on service failure; `root_view.rs` subscribes to it and pushes an error
    `Notification`, mirroring the existing `CollectionCreateFailed` pattern.

## 3. Context Menu

- [ ] 3.1 Add "Add to…" submenu construction to the catalog item context menu, listing collections with
  checked state from the live cache
  - Not implemented. The only entry point into `add_item_to_collection` today is drag-and-drop (see
    `catalog-drag-drop-to-collection`); there is no context-menu path.
- [ ] 3.2 Add "Remove from this collection" direct item when the current view is a collection
  - Not implemented — blocked on 1.2 (`remove_member`) as well.

## 4. Build and Verify

- [x] 4.1 Run `cargo check --workspace`
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify add/remove via submenu updates checked state and collection contents
  - N/A — submenu (task 3.1) not built.
- [ ] 4.4 Manually verify direct remove while viewing a collection
  - N/A — remove path (task 1.2/3.2) not built.
- [ ] 4.5 Manually verify rollback and error surfacing on simulated service failure
  - Not manually re-verified interactively; covered at the code level (rollback + event emission logic
    exists and compiles/type-checks) but the running app hasn't been driven through a simulated failure by
    hand.

## Status

This change is **partially implemented** — only the add-member path exists, driven solely by drag-and-drop
(`catalog-drag-drop-to-collection`). Do not archive this change yet. Remaining work (`remove_member`, the
context-menu "Add to…"/"Remove from this collection" entries, and the `dtrpg-api` endpoint for real
persistence) is still open and tracked here.
