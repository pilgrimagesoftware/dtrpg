## ADDED Requirements

### Requirement: SidebarFilter has a Collection variant
The `SidebarFilter` enum in `dtrpg-ui/src/data/enums.rs` SHALL gain a `Collection(u64)` variant holding the `product_list_id`. The existing variants (`All`, `RecentlyAdded`, `OnDevice`, `InCloud`, `Publisher`) SHALL remain unchanged.

#### Scenario: Collection variant is settable on LibraryController
- **WHEN** `LibraryController::set_filter(SidebarFilter::Collection(id), cx)` is called
- **THEN** `filter` is updated, `collection_members` is populated with the matching `CollectionEntry.member_ids`, and a `LibraryChanged` event is emitted

### Requirement: Collection membership set drives catalog filtering
`LibraryController` SHALL maintain a `collection_members: HashSet<u64>` field. When `SidebarFilter::Collection(_)` is active, `visible_items()` SHALL include only items whose `numeric_id` is in `collection_members`. When any other filter is active, `collection_members` is ignored.

#### Scenario: Catalog filtered to collection members
- **WHEN** `SidebarFilter::Collection(id)` is set and `visible_items()` is called
- **THEN** only `LibraryItem` values whose `numeric_id` appears in `collection_members` are returned

#### Scenario: Non-collection filter does not consult membership set
- **WHEN** `SidebarFilter::All` or any other non-collection variant is active
- **THEN** `visible_items()` returns items based solely on the existing filter predicate, ignoring `collection_members`
