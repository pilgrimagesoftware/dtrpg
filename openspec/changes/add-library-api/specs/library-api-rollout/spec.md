## ADDED Requirements

### Requirement: Cross-repository library API initiatives MUST have an umbrella owner
The top-level meta-repository MUST own the coordinating change whenever library API features require planned changes in more than one child repository.

#### Scenario: Planning a multi-repository library API initiative
- **WHEN** a proposed library API change affects endpoint contracts, SDK types, or application UX in more than one repository
- **THEN** the coordinating proposal is created in the top-level meta-repository before implementation proceeds independently in child repositories

### Requirement: Umbrella library API changes MUST delegate implementation to child repositories
The top-level coordinating change MUST identify the child repositories that need their own implementation-level proposals for API contracts and SDK behavior.

#### Scenario: Breaking umbrella work into child proposals
- **WHEN** the top-level repo defines a coordinated library API initiative
- **THEN** the proposal names the child repositories expected to carry API contract and SDK behavior changes
