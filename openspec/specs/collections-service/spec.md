# collections-service Specification

## Purpose
TBD - created by archiving change add-collections-support. Update Purpose after archive.
## Requirements
### Requirement: CollectionsService trait defines the contract for product list access
A `CollectionsService` trait SHALL be defined in `dtrpg-ui/src/services/collections.rs`. It SHALL be `Send + Sync + 'static` and return types from `dtrpg-ui::data::collection`. Error types SHALL follow the same `CollectionsServiceError` / `CollectionsServiceErrorKind` pattern as `LibraryServiceError`.

#### Scenario: list_collections returns collection entries
- **WHEN** `CollectionsService::list_collections()` is called and the API responds successfully
- **THEN** a `Vec<CollectionEntry>` is returned, one entry per product list, each with `id: u64`, `name: Arc<str>`, and `member_ids: Arc<[u64]>` (the `order_product_id` values from `list_product_list_items`)

#### Scenario: list_collections returns session error on 401
- **WHEN** the API returns a 401 response
- **THEN** `CollectionsService::list_collections()` returns `Err` with `CollectionsServiceErrorKind::Session`

### Requirement: SDK-backed implementation fetches product lists and resolves membership
`RustSdkCollectionsService` in `dtrpg-core/src/services/collections_sdk.rs` SHALL implement `CollectionsService` by calling `LibraryClient::list_product_lists()` (paginating until `links.next` is `None`) and then calling `LibraryClient::list_product_list_items(id)` for each list to populate `member_ids`. Membership IDs SHALL be extracted from the `orderProductId` field of each raw `serde_json::Value` item.

#### Scenario: All pages of product lists are fetched
- **WHEN** the user has more product lists than fit on one page
- **THEN** all pages are fetched by following `PaginationLinks.next` and all product lists are included in the result

#### Scenario: Membership extracted from raw items
- **WHEN** `list_product_list_items` returns items containing an `orderProductId` field
- **THEN** each numeric value is included in `member_ids` for that collection

#### Scenario: Missing orderProductId field is skipped with a warning
- **WHEN** a raw item in `list_product_list_items` does not contain a parseable `orderProductId`
- **THEN** that item is skipped; a `tracing::warn!` is emitted; remaining items are still processed

### Requirement: UnavailableCollectionsGateway degrades gracefully
When `RustSdkCollectionsService::from_sdk()` fails to obtain a client, it SHALL fall back to `UnavailableCollectionsGateway`, which returns a stored error on every call. This ensures the app starts even when credentials are missing.

#### Scenario: Gateway unavailable returns stored error
- **WHEN** `CollectionsService::list_collections()` is called on an `UnavailableCollectionsGateway`
- **THEN** `Err(CollectionsServiceError)` is returned with the original initialization error message

### Requirement: CollectionEntry domain type is defined in dtrpg-ui
A `CollectionEntry` struct SHALL be defined in `dtrpg-ui/src/data/collection.rs` with fields: `id: u64` (the `product_list_id`), `name: Arc<str>`, and `member_ids: Arc<[u64]>` (the resolved `order_product_id` values). This type SHALL be `Clone`, `Debug`.

#### Scenario: CollectionEntry is constructible with member ids
- **WHEN** a `CollectionEntry` is created with a non-empty `member_ids` slice
- **THEN** the entry's `id`, `name`, and `member_ids` fields match the provided values

