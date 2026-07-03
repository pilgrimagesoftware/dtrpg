## ADDED Requirements

### Requirement: Catalog load activity label reflects current phase

The catalog load activity item SHALL update its label as the load sequence advances through its known
phases, using a single activity item updated in place rather than one item per phase.

#### Scenario: Item count phase

- **WHEN** the catalog load begins fetching the total item count
- **THEN** the activity item label SHALL read "Getting count of items"

#### Scenario: Collections phase

- **WHEN** the catalog load begins fetching collections
- **THEN** the activity item label SHALL read "Loading collections"

#### Scenario: Library phase

- **WHEN** the catalog load begins fetching library items
- **THEN** the activity item label SHALL read "Loading library"

#### Scenario: Single activity item throughout

- **WHEN** the catalog load transitions between phases
- **THEN** the same `ActivityItem` SHALL be updated via `update_label` rather than a new activity item
  being created per phase
