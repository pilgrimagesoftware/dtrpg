## 1. CollectionEntry Domain Type and CollectionsService Trait

- [ ] 1.1 Create `dtrpg-ui/src/data/collection.rs` with `CollectionEntry { id: u64, name: Arc<str>, member_ids: Arc<[u64]> }` deriving `Clone, Debug`
- [ ] 1.2 Add `pub mod collection;` to `dtrpg-ui/src/data/mod.rs`
- [ ] 1.3 Create `dtrpg-ui/src/services/collections.rs` with `CollectionsServiceErrorKind` (Network, Session), `CollectionsServiceError`, and `CollectionsService` trait with `list_collections(&self) -> Result<Vec<CollectionEntry>, CollectionsServiceError>`
- [ ] 1.4 Add `pub mod collections;` to `dtrpg-ui/src/services/mod.rs`
- [ ] 1.5 Add test stub `CollectionsStubService` in `dtrpg-ui/src/services/collections.rs` gated behind `#[cfg(test)]`, with `Seeded`, `Empty`, and `Error` modes
- [ ] 1.6 Run `cargo check -p dtrpg-ui` and fix any errors

## 2. SidebarFilter Collection Variant

- [ ] 2.1 Add `Collection(u64)` variant to `SidebarFilter` in `dtrpg-ui/src/data/enums.rs`
- [ ] 2.2 Update `item_matches_filter` in `dtrpg-ui/src/util/filter.rs` to accept an additional `collection_members: &HashSet<u64>` parameter; return `true` for `Collection(_)` if `item.numeric_id` is in the set; thread the parameter through all call sites in `LibraryController::visible_items()`
- [ ] 2.3 Add `collection_members: HashSet<u64>` field to `LibraryController`; initialize to empty
- [ ] 2.4 In `LibraryController::set_filter`, when the new filter is `Collection(id)`, look up the matching `CollectionEntry` from `self.collections` and populate `self.collection_members` from `entry.member_ids`; clear `collection_members` when switching to any non-collection filter
- [ ] 2.5 Run `cargo check -p dtrpg-ui` and confirm compilation is clean

## 3. SDK-Backed CollectionsService Implementation

- [ ] 3.1 Create `dtrpg-core/src/services/collections_sdk.rs` with `SdkCollectionsGateway` trait, `RustSdkCollectionsService`, `HttpSdkCollectionsGateway`, and `UnavailableCollectionsGateway`, following the same structure as `sdk.rs`
- [ ] 3.2 Implement `HttpSdkCollectionsGateway::list_product_lists()`: loop with `PageParams` following `links.next` until `None`, accumulating all `ProductListItem` values
- [ ] 3.3 Implement `HttpSdkCollectionsGateway::list_product_list_items(id)`: loop following `links.next`, extracting the `orderProductId` field (as `u64`) from each raw `serde_json::Value` item; emit `tracing::warn!` and skip items where the field is absent or non-numeric
- [ ] 3.4 Implement `RustSdkCollectionsService::list_collections()`: call gateway for all product lists, then call `list_product_list_items` for each, build `CollectionEntry` per list with the resolved `member_ids`
- [ ] 3.5 Add `pub mod collections_sdk;` to `dtrpg-core/src/services/mod.rs`
- [ ] 3.6 Write unit tests in `collections_sdk.rs` using a `FakeCollectionsGateway`: (a) seeded data produces correct `CollectionEntry` values; (b) session error propagates; (c) items with missing `orderProductId` are skipped without error
- [ ] 3.7 Run `cargo test -p dtrpg-core` and confirm tests pass

## 4. Wire LibraryController to CollectionsService

- [ ] 4.1 Add `collections: Vec<CollectionEntry>` field to `LibraryController`; initialize from a new `collections_service` parameter in `new()`
- [ ] 4.2 Update `LibraryController::new(library_service, collections_service)` to load collections synchronously (call `collections_service.list_collections()`, default to empty `Vec` on error, log a warning)
- [ ] 4.3 Add `pub fn collections(&self) -> &[CollectionEntry]` accessor to `LibraryController`
- [ ] 4.4 Update `LibraryRootView::new` and `ui/app/mod.rs::setup` to accept and forward `Box<dyn CollectionsService>` alongside `Box<dyn LibraryService>`
- [ ] 4.5 Update `dtrpg-core/src/app/mod.rs::run()` to create both `RustSdkLibraryService` and `RustSdkCollectionsService` from the same initialized SDK; pass both to `setup`
- [ ] 4.6 Run `cargo check --workspace` and fix any errors

## 5. Sidebar Collections Section

- [ ] 5.1 Add `CollectionEntry` to the `LibrarySnapshot` fields (or expose via a separate accessor); update `LibraryController::snapshot()` to include `collections: Vec<CollectionEntry>`
- [ ] 5.2 Add a `render_collections_section` function in `dtrpg-ui/src/ui/views/sidebar_view.rs` (or a new `collections_section_view.rs`) that renders the "Collections" header and a list entry per `CollectionEntry`; header and entries are hidden when the slice is empty
- [ ] 5.3 Each collection entry shows the collection name and the count of `member_ids` that are present in the full catalog (compute at render time: `entry.member_ids.iter().filter(|id| catalog_ids.contains(id)).count()`)
- [ ] 5.4 Wire selection: clicking a collection entry calls `controller.set_filter(SidebarFilter::Collection(entry.id), cx)`
- [ ] 5.5 Apply the active selection style to the clicked entry (consistent with how publisher entries are highlighted)
- [ ] 5.6 Add the collections section to the sidebar render call in `root_view.rs`, passing the `LibraryController` entity and the collections slice

## 6. Verification

- [ ] 6.1 Run `cargo test --workspace` and confirm all tests pass
- [ ] 6.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and resolve any new warnings introduced by this change
- [ ] 6.3 Launch the app with valid credentials; confirm the Collections section appears in the sidebar if the user has product lists, and is absent if they have none
- [ ] 6.4 Click a collection entry and confirm the catalog filters to only items in that collection
- [ ] 6.5 Confirm the item count next to each collection name reflects items present in the loaded library, not the server count
- [ ] 6.6 Switch from a collection filter back to "All" and confirm all library items are shown again
- [ ] 6.7 Launch the app with credentials that cause the collections fetch to fail (e.g., revoked token for that endpoint); confirm the library still opens and the Collections section is absent
