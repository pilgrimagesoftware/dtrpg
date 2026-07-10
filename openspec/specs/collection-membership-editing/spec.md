# collection-membership-editing Specification

## Purpose
TBD - created by archiving change collection-membership-editing. Update Purpose after archive.
## Requirements
### Requirement: Context menu offers add/remove-from-collection

Right-clicking a catalog item in a non-collection view SHALL show an "Add to…" submenu listing the user's
collections, with collections the item already belongs to shown checked.

#### Scenario: Adding an item to a collection

- **WHEN** the user selects an unchecked collection from the "Add to…" submenu
- **THEN** the item SHALL be added as a member of that collection

#### Scenario: Removing an item from a collection via the submenu

- **WHEN** the user selects a checked collection from the "Add to…" submenu
- **THEN** the item SHALL be removed as a member of that collection

### Requirement: Direct remove action when viewing a collection

When the current catalog view is itself a collection, the context menu SHALL show a direct "Remove from
this collection" item instead of the general "Add to…" submenu for that collection.

#### Scenario: Removing from the currently viewed collection

- **WHEN** the user right-clicks an item while viewing a collection and selects "Remove from this
  collection"
- **THEN** the item SHALL be removed as a member of the currently viewed collection

### Requirement: Membership changes update the UI immediately

Adding or removing an item from a collection SHALL update the collections cache and any currently
displayed item list for that collection without requiring a manual refresh.

#### Scenario: Optimistic update on add

- **WHEN** the user adds an item to a collection
- **THEN** the collection's member count and the item's checked state in the submenu SHALL update
  immediately, before the service call resolves

#### Scenario: Rollback on service failure

- **WHEN** the add or remove service call fails after an optimistic update
- **THEN** the UI SHALL roll back to the prior state and SHALL surface an error via the existing alert
  mechanism

