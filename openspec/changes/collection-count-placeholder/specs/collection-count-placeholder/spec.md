## ADDED Requirements

### Requirement: Collection count shows placeholder until first load completes

The sidebar collection count badge SHALL display `?` while collections have not yet completed their first
load for the current session, and SHALL display the real numeric count thereafter.

#### Scenario: Before first load

- **WHEN** the app has not yet completed its first collections fetch in the current session
- **THEN** the sidebar collection count badge SHALL display `?`

#### Scenario: After load with zero collections

- **WHEN** the collections fetch has completed and the user has no collections
- **THEN** the sidebar collection count badge SHALL display `0`

#### Scenario: After load with collections

- **WHEN** the collections fetch has completed and the user has collections
- **THEN** the sidebar collection count badge SHALL display the actual count
