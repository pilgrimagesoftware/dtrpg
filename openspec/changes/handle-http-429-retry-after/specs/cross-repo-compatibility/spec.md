## MODIFIED Requirements

### Requirement: Coordinated rollouts must identify dependency order
The meta-repository MUST capture rollout order when one repository depends on another repository's released behavior, including auth/session work that must move in sequence across API, SDK, and application repositories, and shared HTTP-behavior work (such as exposing a response header) that must land in the SDK before an application repository can depend on it.

#### Scenario: Rolling out a dependent change
- **WHEN** an API or shared SDK change must land before application behavior can rely on it
- **THEN** the coordinating specification records the required sequencing across repositories

#### Scenario: Sequencing an auth/session rollout
- **WHEN** an auth or session initiative changes API contract behavior, SDK lifecycle behavior, and application recovery UX
- **THEN** the coordinating proposal records which repository changes must land first and which downstream repositories depend on them

#### Scenario: Sequencing an SDK-exposed HTTP behavior rollout
- **WHEN** an application-visible behavior change (such as honoring the `Retry-After` header on HTTP 429 responses) depends on the SDK layer capturing and exposing data not currently available to the application
- **THEN** the coordinating proposal records that the SDK child change must be implemented and released before the application child change can be implemented, and confirms the application falls back to its existing behavior when the SDK-exposed value is absent
