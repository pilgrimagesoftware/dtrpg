# main-window-sidebar-navigation Specification

## Purpose
Define the desktop application's collapsible left navigation sidebar, including its default sections, Collections section, and Publishers section, as the shared structure child app repositories implement.

## Requirements
### Requirement: Main window MUST provide a collapsible left navigation sidebar
The desktop application main window content area MUST provide a collapsible left sidebar for navigation, distinct from the tabbed main content area.

#### Scenario: Collapsing and expanding the sidebar
- **WHEN** the user toggles the sidebar
- **THEN** the main content area gains or loses the width previously occupied by the sidebar, and the sidebar's expanded/collapsed state persists across navigation within the session

### Requirement: Sidebar MUST show default navigation sections with counts
The desktop application sidebar MUST display default navigation sections, each showing a numeric item count.

#### Scenario: Viewing default section counts
- **WHEN** the sidebar is expanded
- **THEN** each default navigation section displays its current numeric item count

### Requirement: Sidebar MUST provide a Collections section
The desktop application sidebar MUST provide a Collections section showing an item count, search controls, an add button, and a collapse control.

#### Scenario: Searching within the Collections section
- **WHEN** the user enters text in the Collections section's search control
- **THEN** the section's visible collections are filtered to those matching the search text

#### Scenario: Adding a collection from the sidebar
- **WHEN** the user activates the Collections section's add button
- **THEN** the app presents the collection-creation flow

### Requirement: Sidebar MUST provide a Publishers section
The desktop application sidebar MUST provide a Publishers section showing an item count, search controls, and a collapse control.

#### Scenario: Searching within the Publishers section
- **WHEN** the user enters text in the Publishers section's search control
- **THEN** the section's visible publishers are filtered to those matching the search text

#### Scenario: Collapsing the Publishers section
- **WHEN** the user collapses the Publishers section
- **THEN** the section header remains visible with its item count while its list of publishers is hidden
