## ADDED Requirements

### Requirement: Dragging a catalog item onto a collection adds it as a member

A catalog item (list row, thumb row, or grid card) SHALL be draggable, and dropping it onto a sidebar
collection entry SHALL add the item as a member of that collection.

#### Scenario: Successful drag-and-drop add

- **WHEN** the user drags a catalog item and drops it onto a sidebar collection entry
- **THEN** the item SHALL be added as a member of that collection

#### Scenario: Drop onto a collection the item already belongs to

- **WHEN** the user drags a catalog item and drops it onto a collection it is already a member of
- **THEN** no service call SHALL be made and the collection membership SHALL remain unchanged

### Requirement: Drop targets provide hover feedback

Sidebar collection entries SHALL visually highlight while a compatible drag is hovering over them, and
SHALL NOT highlight for non-collection sidebar sections.

#### Scenario: Hover over a valid collection target

- **WHEN** a dragged catalog item hovers over a sidebar collection entry
- **THEN** the collection entry SHALL render a highlighted drop-target state

#### Scenario: Hover over a non-collection section

- **WHEN** a dragged catalog item hovers over a non-collection sidebar section (e.g. "All Items")
- **THEN** no highlight SHALL appear and dropping there SHALL be a no-op
