## ADDED Requirements

### Requirement: Library analytics view is reachable from the app

The app SHALL provide a navigation entry point (sidebar item or menu item) that opens a library analytics
view.

#### Scenario: Opening the analytics view

- **WHEN** the user selects the library analytics navigation entry
- **THEN** the analytics view SHALL open and render the publisher, collection-count, and document-type
  charts

### Requirement: Publisher chart shows item count per publisher

The analytics view SHALL render a chart showing the number of catalog items per publisher, derived from
the currently loaded catalog data.

#### Scenario: Publisher counts reflect the catalog

- **WHEN** the analytics view renders the publisher chart
- **THEN** each publisher bar's value SHALL equal the count of catalog items attributed to that publisher

### Requirement: Collection-count chart shows item count per collection

The analytics view SHALL render a chart showing the number of member items per collection, derived from
the currently loaded collections data.

#### Scenario: Collection counts reflect membership

- **WHEN** the analytics view renders the collection-count chart
- **THEN** each collection bar's value SHALL equal the length of that collection's `member_ids`

### Requirement: Document-type chart shows distribution of item kinds

The analytics view SHALL render a chart showing the distribution of catalog items by document/kind type
(e.g. PDF, ebook).

#### Scenario: Document type counts reflect the catalog

- **WHEN** the analytics view renders the document-type chart
- **THEN** each type's value SHALL equal the count of catalog items of that kind

### Requirement: Charts reflect current data without manual refresh

Charts SHALL recompute from the current catalog/collections cache state whenever that state changes,
without requiring the user to manually refresh the analytics view.

#### Scenario: Chart updates after catalog change

- **WHEN** the catalog data changes (e.g. an item is added to a collection) while the analytics view is
  open
- **THEN** the affected chart SHALL update to reflect the new data on its next render
