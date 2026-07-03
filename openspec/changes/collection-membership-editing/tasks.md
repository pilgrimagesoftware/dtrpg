## 1. Service Layer

- [ ] 1.1 Add `add_member(&self, collection_id: u64, item_id: u64) -> Result<(), CollectionsServiceError>`
  to `CollectionsService`
- [ ] 1.2 Add `remove_member(&self, collection_id: u64, item_id: u64) -> Result<(),
  CollectionsServiceError>` to `CollectionsService`
- [ ] 1.3 Implement both in `CollectionsStubService` for all stub modes
- [ ] 1.4 Verify the underlying DriveThruRPG API/SDK exposes an equivalent endpoint; if not, open a
  `dtrpg-api` change to add it and block on that first

## 2. Controller Actions

- [ ] 2.1 Add `LibraryController` actions to invoke add/remove member with optimistic local update
- [ ] 2.2 Wire rollback-and-alert behavior on service failure

## 3. Context Menu

- [ ] 3.1 Add "Add to…" submenu construction to the catalog item context menu, listing collections with
  checked state from the live cache
- [ ] 3.2 Add "Remove from this collection" direct item when the current view is a collection

## 4. Build and Verify

- [ ] 4.1 Run `cargo check --workspace`
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify add/remove via submenu updates checked state and collection contents
- [ ] 4.4 Manually verify direct remove while viewing a collection
- [ ] 4.5 Manually verify rollback and error surfacing on simulated service failure
