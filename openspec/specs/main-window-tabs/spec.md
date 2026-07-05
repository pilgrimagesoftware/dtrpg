# main-window-tabs Specification

## Purpose
Define the desktop application's main content area tab strip, including the non-closable catalog tab, dynamic segmented tabs with overflow, and single-click/double-click catalog item interaction, as the shared structure child app repositories implement.

## Requirements
### Requirement: Main content area MUST use a dynamic tab strip
The desktop application main content area MUST present a dynamic segmented tab strip with an overflow "more" menu for tabs that do not fit the available width.

#### Scenario: Opening the overflow menu
- **WHEN** the tab strip has more open tabs than fit the available width
- **THEN** the app provides a "more" menu listing the remaining tabs, and selecting one activates it

### Requirement: The catalog tab MUST be non-closable and always first
The desktop application main content area MUST include a catalog tab as the first tab, and this tab MUST NOT be closable.

#### Scenario: Attempting to close the catalog tab
- **WHEN** the user views the catalog tab
- **THEN** the app does not present a close control for that tab

### Requirement: Catalog tab header MUST provide search, sort, and view mode controls
The desktop application catalog tab MUST include a header with a title, a search box, sorting controls, and a view mode control, and MUST display catalog contents according to the active mode without pagination.

#### Scenario: Filtering and sorting catalog contents
- **WHEN** the user changes the search text, sort order, or view mode in the catalog tab header
- **THEN** the catalog tab's content area updates to reflect the new search, sort, and view mode state without pagination controls

### Requirement: Single-clicking a catalog item MUST open a popover detail view
The desktop application MUST open a popover detail view when the user single-clicks a catalog item, without creating a new tab.

#### Scenario: Inspecting an item via popover
- **WHEN** the user single-clicks a catalog item
- **THEN** the app displays a popover anchored to the item showing its detail, and the tab strip is unchanged

### Requirement: Double-clicking a catalog item MUST open an expanded detail tab
The desktop application MUST open a new closable tab with an expanded detail view when the user double-clicks a catalog item. The expanded detail view MUST show a large thumbnail, item attributes, and a file list when the catalog item has multiple items.

#### Scenario: Opening an expanded detail tab
- **WHEN** the user double-clicks a catalog item
- **THEN** the app opens a new closable tab showing a large thumbnail and the item's attributes

#### Scenario: Viewing the file list for a multi-item entry
- **WHEN** the double-clicked catalog item bundles multiple items
- **THEN** the expanded detail tab includes a file list alongside the thumbnail and attributes

#### Scenario: Closing an expanded detail tab
- **WHEN** the user activates the close control on an expanded detail tab
- **THEN** the app closes that tab and activates the previously active tab
