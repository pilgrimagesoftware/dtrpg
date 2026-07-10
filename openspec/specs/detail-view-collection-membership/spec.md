# detail-view-collection-membership Specification

## Purpose
TBD - created by archiving change collection-manage-dialog. Update Purpose after archive.
## Requirements
### Requirement: Detail view shows a collection membership summary

The catalog entry detail view SHALL display a summary of which collections the entry currently belongs
to.

#### Scenario: Entry belongs to one or more collections

- **WHEN** the detail view is shown for an entry that is a member of one or more collections
- **THEN** the summary SHALL list the names of those collections

#### Scenario: Entry belongs to no collections

- **WHEN** the detail view is shown for an entry that is not a member of any collection
- **THEN** the summary SHALL show an empty-state message instead of an empty list

### Requirement: Detail view provides access to the Manage Collections dialog

The detail view's collection summary SHALL include a "Manage…" button that opens the Manage Collections
dialog scoped to the entry being viewed.

#### Scenario: Opening the dialog from the detail view

- **WHEN** the user clicks the "Manage…" button in the detail view's collection summary
- **THEN** the Manage Collections dialog SHALL open, scoped to the entry currently shown in the detail
  view

#### Scenario: Summary reflects changes made in the dialog

- **WHEN** the user adds or removes the entry's membership in a collection via the dialog opened from the
  detail view
- **THEN** the detail view's collection summary SHALL update to reflect the change once the dialog is
  closed

