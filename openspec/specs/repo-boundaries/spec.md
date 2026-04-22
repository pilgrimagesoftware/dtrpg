## Purpose
Define which concerns belong in the top-level meta-repository and which concerns belong in child repositories so multi-repo work is specified at the nearest correct ownership boundary.

## Requirements

### Requirement: Repository ownership boundaries must be explicit
The meta-repository MUST define which kinds of behavior are owned at the top level and which kinds of behavior are owned by child repositories.

#### Scenario: Routing a new requirement to the correct repository
- **WHEN** a change affects only one implementation repository or one API repository
- **THEN** the change is owned and specified in that repository instead of the meta-repository

### Requirement: The meta-repository must coordinate shared initiatives
The meta-repository MUST be used for initiatives that are not complete until multiple child repositories move together.

#### Scenario: Coordinating a cross-repository initiative
- **WHEN** a feature requires coordinated changes across the API, SDK, or application repositories
- **THEN** the umbrella initiative is specified in the meta-repository with child work delegated to the owning repositories
