## Why

DriveThruRPG lets customers organize their purchased items into named groups called "product lists" (surfaced in the UI as "collections"). Libri currently shows only the flat all-purchases view; users who have organized their libraries into collections have no way to browse by those groupings. Surfacing collections in the sidebar alongside the existing smart sections makes Libri match the browsing model customers already use on the DTRPG website.

## What Changes

- Fetch the authenticated user's product lists from `GET /product_lists` using the existing `LibraryClient`
- Surface each product list as a "Collections" section in the left sidebar, beneath the existing smart sections
- Clicking a collection filters the catalog to show only the items belonging to that collection, resolved against the already-loaded library
- A `CollectionsService` trait (analogous to `LibraryService`) and `CollectionsViewModel` are added to `dtrpg-ui`; the SDK-backed implementation lives in `dtrpg-core`
- The `LibraryController` gains a collections field so the sidebar can render collection entries alongside publisher and section counts

## Capabilities

### New Capabilities

- `collections-sidebar`: Sidebar section listing the user's named collections; selecting one filters the catalog to that collection's items
- `collections-service`: Service trait, error types, and SDK-backed gateway for fetching product lists and resolving membership against the loaded library

### Modified Capabilities

- `library-sidebar`: The sidebar now has a Collections section beneath the existing smart sections; sidebar rendering and filter state must accommodate the new `SidebarFilter::Collection(id)` variant

## Impact

- `dtrpg-ui`: New `services/collections.rs` (trait + errors); new `view_models/collections.rs`; new `data/collection.rs` (collection domain type); `SidebarFilter` gains `Collection(u64)` variant; `LibraryController` gains a collections field; sidebar view updated to render collection entries
- `dtrpg-core`: New `services/collections_sdk.rs` implementing the collections service via `LibraryClient::list_product_lists()`; `app/mod.rs` creates and passes `CollectionsService` alongside `LibraryService`
- `dtrpg-sdk`: No changes — both endpoints (`list_product_lists`, `list_product_list_items`) are already implemented
- The `ProductListItemsResponse` items are raw `serde_json::Value`; resolving collection membership is done by matching `order_product_id` values against the already-loaded library, so the raw schema gap is worked around without blocking this change
