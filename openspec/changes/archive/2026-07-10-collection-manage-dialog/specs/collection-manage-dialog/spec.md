## ADDED Requirements

### Requirement: Context menu opens a Manage Collections dialog

Right-clicking a catalog item SHALL show a single "Manage collections…" item in its context menu, in
place of the "Add to…" submenu and "Remove from this collection" item.

#### Scenario: Opening the dialog from the context menu

- **WHEN** the user right-clicks a catalog item and selects "Manage collections…"
- **THEN** the Manage Collections dialog SHALL open, scoped to that item

### Requirement: Dialog lists all collections with membership state

The Manage Collections dialog SHALL list every one of the user's collections, each with a checkbox
reflecting whether the dialog's target item is currently a member.

#### Scenario: Displaying current membership

- **WHEN** the dialog opens for an item that belongs to some but not all collections
- **THEN** the collections it belongs to SHALL show a checked checkbox and the others SHALL show
  unchecked

### Requirement: Toggling a checkbox adds or removes membership

Toggling a collection's checkbox in the dialog SHALL add or remove the target item's membership in that
collection, using the same underlying add/remove actions as before this change.

#### Scenario: Checking an unchecked collection

- **WHEN** the user checks an unchecked collection's checkbox
- **THEN** the target item SHALL be added as a member of that collection

#### Scenario: Unchecking a checked collection

- **WHEN** the user unchecks a checked collection's checkbox
- **THEN** the target item SHALL be removed as a member of that collection

### Requirement: Dialog supports creating a new collection inline

The dialog SHALL provide a "New collection…" affordance that creates a collection without closing the
dialog, and immediately adds the target item as a member of the newly created collection.

#### Scenario: Creating a collection from within the dialog

- **WHEN** the user enters a name via "New collection…" and confirms
- **THEN** a new collection SHALL be created, SHALL appear in the dialog's list checked, and the target
  item SHALL be added as its member

### Requirement: Dialog surfaces add/remove/create failures inline

Failures from add, remove, or create operations SHALL be shown as inline state within the dialog rather
than only as a transient notification, since a failed operation's optimistic UI change rolls back and can
otherwise go unnoticed while the dialog is open.

#### Scenario: A checkbox toggle fails

- **WHEN** an add or remove call fails after the user toggles a checkbox
- **THEN** the checkbox SHALL revert to its prior state and the dialog SHALL display an inline error
  message describing the failure

#### Scenario: Creating a collection fails

- **WHEN** the create-collection call fails after the user confirms a new collection name
- **THEN** the dialog SHALL display an inline error message and SHALL NOT add a collection to the list
