## ADDED Requirements

### Requirement: Content views show a loading indicator before first data load

Any list or content view whose data is fetched asynchronously SHALL show a loading indicator until that
data's first fetch completes, distinct from both populated and genuinely empty states.

#### Scenario: Catalog view before first load

- **WHEN** the catalog view is opened before its backing data has completed loading
- **THEN** the view SHALL show a loading indicator instead of an empty or blank state

#### Scenario: Catalog view after load with items

- **WHEN** the catalog data finishes loading and contains items
- **THEN** the loading indicator SHALL be replaced by the item list

#### Scenario: Catalog view after load with no items

- **WHEN** the catalog data finishes loading and contains no items
- **THEN** the loading indicator SHALL be replaced by the genuine empty state, not shown simultaneously
  with it
