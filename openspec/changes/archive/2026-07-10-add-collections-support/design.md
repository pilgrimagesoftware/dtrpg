## Context

The SDK already exposes two product-list endpoints via `LibraryClient`: `list_product_lists` (all user collections) and `list_product_list_items` (items in one collection). The `ProductListItemsResponse` items are untyped `serde_json::Value` because the API contract for that schema is not yet finalized. The `LibraryController` currently holds a flat catalog of all library items and drives the sidebar via `SectionCounts` and `Vec<PublisherEntry>`. The sidebar filter is a `SidebarFilter` enum that routes what the catalog renders.

`connect-sdk-to-rust-app` just landed the `LibraryService` trait and wired `LibraryController` to it. This change follows the same pattern for collections.

## Goals / Non-Goals

**Goals:**
- List the user's named collections in the sidebar beneath the existing smart sections
- Filter the catalog to items belonging to a selected collection
- Add a `CollectionsService` trait in `dtrpg-ui` and SDK-backed implementation in `dtrpg-core` that follows the pattern established by `LibraryService`

**Non-Goals:**
- Creating, renaming, or deleting collections (read-only for now)
- Displaying collection item counts that differ from the resolved count (server count vs. matched items in local library may diverge; display the resolved count)
- Implementing `list_product_list_items` detail fetching (membership is resolved by matching `order_product_id` from the raw JSON against `LibraryItem.numeric_id`)

## Decisions

### D1: Resolve collection membership locally rather than calling `list_product_list_items`

The `ProductListItemsResponse` items are raw `serde_json::Value`. The only stable field we need is `orderProductId` to match against `LibraryItem.numeric_id`. Rather than building a typed schema now (which would need updating when the API firms up), we deserialize just that field from the raw value and intersect with the loaded library. This avoids an extra network round-trip per collection selection and skips the schema maintenance burden.

**Alternative considered**: Fetch collection items on demand from `list_product_list_items`. Rejected: adds latency on every collection click, and the raw schema requires fragile `serde_json` navigation.

### D2: Fetch all collections at startup, not on-demand

Collections are fetched once during `LibraryController` initialization, alongside the library load. The result is a `Vec<CollectionEntry>` (id, name, resolved item count) stored in the controller. This matches the existing pattern where `publishers` is built upfront and kept in sync.

**Alternative considered**: Lazy-load collections on first sidebar interaction. Rejected: adds a loading state to the sidebar that complicates rendering for what is expected to be a small, fast call.

### D3: Add `SidebarFilter::Collection(u64)` variant

The `SidebarFilter` enum in `dtrpg-ui/src/data/enums.rs` gains a `Collection(u64)` variant holding the `product_list_id`. The `item_matches_filter` predicate in `util/filter.rs` gains a branch that accepts an item only if its `numeric_id` is in the membership set for that collection. The membership set is built when the filter is set and stored in `LibraryController`.

**Alternative considered**: Store the full membership set in the filter variant itself. Rejected: would make `SidebarFilter` non-`Copy` and require cloning large sets on every render.

### D4: Membership set stored separately from the filter

`LibraryController` adds a `collection_members: HashSet<u64>` field that is populated whenever `SidebarFilter::Collection(_)` is set. The `visible_items()` method checks this set. This keeps `SidebarFilter` copyable and the hot render path allocation-free.

### D5: CollectionsService trait in dtrpg-ui, SDK implementation in dtrpg-core

Following the same layering as `LibraryService`: the trait and error types live in `dtrpg-ui/src/services/collections.rs`; the SDK-backed `RustSdkCollectionsService` and `HttpSdkCollectionsGateway` live in `dtrpg-core/src/services/collections_sdk.rs`. The `UnavailableSdkGateway` pattern (returning a stored error on every call) is reused.

### D6: Collections and library share one LibraryClient instance

`RustSdkLibraryService` and `RustSdkCollectionsService` both need a `LibraryClient`. To avoid duplicating SDK initialization, both are created in `dtrpg-core/src/app/mod.rs` from the same `DriveThruRpgSdk` instance before it is consumed. The two services are passed independently to `setup`.

## Risks / Trade-offs

- **Raw JSON parsing of `order_product_id`**: If the API field name changes, membership resolution silently produces empty collections. Mitigation: log a warning when the field cannot be extracted; surface this as an empty result, not a crash.
- **Startup latency**: Adding a second blocking SDK call at startup increases the time before the window opens. Mitigation: both library and collections loads are synchronous today (deferred async in a later change). Collections load is expected to be fast (small payload, no pagination in typical use).
- **Server item count vs. resolved count**: `ProductListAttributes.item_count` may include items the user no longer owns or that are archived. The sidebar should show the resolved count (items present in the local library), not the server count, to avoid confusing discrepancies.

## Open Questions

- Should collections be hidden entirely when the user has no product lists (empty state in sidebar), or should the section header still appear with a "No collections" placeholder? Prefer hiding the header when the list is empty — avoids clutter for users who don't use collections.
- Should `list_product_list_items` be called for the initial membership resolution (to get all IDs accurately) or should we try parsing the raw items from the collection list response if any are embedded? The `product_list_items` endpoint is the authoritative source; use it, extracting only `orderProductId` from the raw values.
