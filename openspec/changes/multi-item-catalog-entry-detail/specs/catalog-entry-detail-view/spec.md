## ADDED Requirements

### Requirement: Catalog entry detail view MUST display entry-level metadata
The catalog entry detail view MUST present catalog-entry-level metadata in a primary content area, distinct from any per-item metadata, including at minimum: title, publisher, description or summary, purchase or ownership status, and cover art when available.

#### Scenario: Opening a catalog entry detail view
- **WHEN** the user selects a catalog entry from the library browsing surface
- **THEN** the detail view displays the catalog entry title, publisher, description, and purchase status in the primary content area

#### Scenario: Entry has no cover art
- **WHEN** the catalog entry has no cover art available
- **THEN** the detail view shows a placeholder in place of cover art without blocking or degrading the rest of the entry metadata display

### Requirement: Catalog entry detail view MUST distinguish single-item from multi-item entries
The catalog entry detail view MUST detect the item count for the selected catalog entry and adjust the presentation accordingly: single-item entries collapse item metadata into the entry tier without requiring item selection, and multi-item entries present a visible item list.

#### Scenario: Opening a single-item catalog entry
- **WHEN** the user selects a catalog entry that contains exactly one item
- **THEN** the detail view displays the single item's metadata (type, format, file size, download state) inline within the entry tier without showing an item list or requiring item selection

#### Scenario: Opening a multi-item catalog entry
- **WHEN** the user selects a catalog entry that contains more than one item
- **THEN** the detail view displays an item list alongside the entry-level metadata, and no item is pre-selected by default

### Requirement: Catalog entry detail view MUST present a selectable item list for multi-item entries
For catalog entries with more than one item, the detail view MUST display a persistent item list that remains visible while the user inspects individual items. The item list MUST show at minimum: item name and item type for each item.

#### Scenario: Viewing the item list
- **WHEN** the user opens a multi-item catalog entry detail view
- **THEN** a persistent item list is visible showing all items in the entry, each identified by name and type

#### Scenario: Scrolling a long item list
- **WHEN** the catalog entry contains more items than fit in the visible item list area
- **THEN** the item list is scrollable and all items remain accessible without truncation

### Requirement: Catalog entry detail view MUST display per-item metadata for a selected item
When the user selects an item from the item list in a multi-item catalog entry, the detail view MUST display that item's metadata in a dedicated item metadata area. Item metadata MUST include at minimum: item name, item type, file format, file size, and individual download or availability state.

#### Scenario: Selecting an item from the item list
- **WHEN** the user selects an item from the item list
- **THEN** the item metadata area updates to show the selected item's name, type, format, file size, and download state

#### Scenario: Switching between items
- **WHEN** the user selects a different item from the item list while an item is already selected
- **THEN** the item metadata area updates in place to reflect the newly selected item without navigating away from the catalog entry detail view

#### Scenario: Item metadata area while no item is selected
- **WHEN** the multi-item catalog entry detail view is first shown and no item has been selected
- **THEN** the item metadata area shows a prompt or placeholder indicating that the user should select an item from the list

### Requirement: Catalog entry detail view item selection state SHALL be ephemeral
The selected item within a catalog entry detail view SHALL NOT be persisted across app sessions or catalog entry navigations. When the user returns to a catalog entry, no item SHALL be pre-selected.

#### Scenario: Returning to a previously viewed multi-item entry
- **WHEN** the user navigates away from a multi-item catalog entry detail view and then returns to it
- **THEN** no item is pre-selected and the item metadata area shows its default empty or prompt state
