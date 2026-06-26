## MODIFIED Requirements

### Requirement: Coordinated rollouts must identify dependency order
The meta-repository MUST capture rollout order when one repository depends on another repository's released behavior, including auth/session work that must move in sequence across API, SDK, and application repositories.

#### Scenario: Rolling out a dependent change
- **WHEN** an API or shared SDK change must land before application behavior can rely on it
- **THEN** the coordinating specification records the required sequencing across repositories

#### Scenario: Sequencing an auth/session rollout
- **WHEN** an auth or session initiative changes API contract behavior, SDK lifecycle behavior, and application recovery UX
- **THEN** the coordinating proposal records which repository changes must land first and which downstream repositories depend on them
