## ADDED Requirements

### Requirement: Collections section appears in the sidebar
The sidebar SHALL display a "Collections" section beneath the existing smart sections (All, Recently Added, On Device, In Cloud) and publisher list when the authenticated user has at least one product list. If the user has no product lists, the Collections section SHALL NOT be rendered.

#### Scenario: User has collections — section is visible
- **WHEN** the library loads and the collections service returns one or more product lists
- **THEN** a "Collections" section header is rendered in the sidebar below the smart sections and publisher entries

#### Scenario: User has no collections — section is hidden
- **WHEN** the library loads and the collections service returns an empty list
- **THEN** no "Collections" section header or entries are rendered in the sidebar

### Requirement: Each collection entry shows name and resolved item count
Each entry in the Collections section SHALL display the collection's name and the count of items from that collection that are present in the user's loaded library. The resolved count (matched against loaded library items) SHALL be used rather than the server-reported `item_count`.

#### Scenario: Collection entry renders name and count
- **WHEN** the Collections section is visible
- **THEN** each entry shows the product list name and the number of library items whose `numeric_id` appears in that collection's membership set

#### Scenario: Collection with no matching library items shows zero count
- **WHEN** a product list contains items not present in the user's loaded library
- **THEN** the entry shows a count of 0 and remains visible in the sidebar

### Requirement: Selecting a collection filters the catalog
When the user clicks a collection entry in the sidebar, the catalog SHALL be filtered to show only the library items whose `numeric_id` is a member of that collection. The filter SHALL behave identically to the existing section-based and publisher-based filters (search query still applies; sort method still applies).

#### Scenario: Click collection entry — catalog filtered
- **WHEN** the user clicks a collection entry
- **THEN** the `SidebarFilter` is set to `Collection(product_list_id)` and the catalog shows only matching library items

#### Scenario: Active collection highlighted in sidebar
- **WHEN** a `Collection` filter is active
- **THEN** the corresponding sidebar entry is rendered with the active selection style

#### Scenario: Switching to another filter clears collection filter
- **WHEN** the user clicks a smart section or publisher entry after a collection is selected
- **THEN** the `SidebarFilter` changes to the new selection and all library items matching the new filter are shown

### Requirement: Collections service errors do not prevent the library from loading
If the collections fetch fails (network error, session error), the library catalog SHALL still open and function normally. The Collections section SHALL be absent from the sidebar; no error banner is shown for this condition.

#### Scenario: Collections fetch fails — library still opens
- **WHEN** `CollectionsService::list_collections()` returns an error
- **THEN** the library window opens and shows the full catalog; the Collections section is not rendered
