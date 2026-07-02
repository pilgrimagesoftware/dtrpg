## ADDED Requirements

### Requirement: Main window structure revamps MUST identify dependent app-level capabilities
The top-level meta-repository MUST record which existing app-level capabilities a main window structure revamp depends on when it consolidates or relocates functionality already implemented in child repositories.

#### Scenario: Coordinating a status bar that consolidates existing indicators
- **WHEN** a coordinating proposal moves or consolidates behavior already specified by app-level capabilities such as `activity-panel`, `notification-banner`, `app-menu-bar`, or settings-related capabilities
- **THEN** the coordinating specification records which app-level capabilities are depended upon and confirms they are not being redefined, only relocated or referenced
