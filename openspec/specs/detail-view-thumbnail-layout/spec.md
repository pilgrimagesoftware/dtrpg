# detail-view-thumbnail-layout Specification

## Purpose
TBD - created by archiving change detail-view-thumbnail-layout. Update Purpose after archive.
## Requirements
### Requirement: Detail view places cover thumbnail left of item information

The detail view SHALL render the item's cover thumbnail in a fixed-width left column and the item's
information (publisher, title, status, description, and remaining fields/actions) in a right column that
fills the remaining width.

#### Scenario: Detail view renders side-by-side

- **WHEN** the detail view is opened for an item
- **THEN** the cover thumbnail SHALL render in a left column and the item's information SHALL render in a
  right column beside it

### Requirement: Cover behavior is preserved

The cover's aspect ratio, size, and refresh-thumbnail overlay button SHALL be unchanged by the layout
change.

#### Scenario: Refresh thumbnail still works

- **WHEN** the user clicks the refresh-thumbnail overlay button in the new left-column layout
- **THEN** the thumbnail SHALL reload exactly as it did in the previous stacked layout

### Requirement: Info panel scrolling is preserved

The right-column information panel SHALL retain its existing internal vertical scroll behavior.

#### Scenario: Scrolling long item details

- **WHEN** an item's information exceeds the visible height of the right column
- **THEN** the right column SHALL scroll independently, consistent with its prior scroll behavior

