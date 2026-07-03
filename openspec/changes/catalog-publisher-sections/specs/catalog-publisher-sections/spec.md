## ADDED Requirements

### Requirement: Catalog list can group items by publisher

The catalog list view SHALL support a publisher-grouped mode where items render under section headers
labeled with the publisher name, using `gpui-component`'s virtualized list sections capability.

#### Scenario: Enabling publisher grouping

- **WHEN** the user enables publisher grouping in the list view
- **THEN** items SHALL render under section headers labeled with each item's publisher name

#### Scenario: Sort order within sections

- **WHEN** publisher grouping is enabled with a chosen sort order
- **THEN** items within each publisher section SHALL be ordered according to that sort order

### Requirement: Grouped list uses the virtualized DataTable rendering path

Publisher-grouped list rendering SHALL use the same virtualized `DataTable`-based rendering path as the
ungrouped list, not a separate hand-rolled row implementation.

#### Scenario: Grouped list scroll performance

- **WHEN** the user scrolls a publisher-grouped list containing many items
- **THEN** rendering SHALL remain smooth via virtualization, consistent with the ungrouped list's
  performance

### Requirement: Grouping is scoped to list layout

Publisher grouping SHALL apply only to the list layout; grid and thumb layouts SHALL remain ungrouped.

#### Scenario: Switching to grid layout with grouping enabled

- **WHEN** publisher grouping is enabled and the user switches to grid layout
- **THEN** the grid layout SHALL render its normal ungrouped item cards
