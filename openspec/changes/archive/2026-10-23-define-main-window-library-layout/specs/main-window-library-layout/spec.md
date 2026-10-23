## ADDED Requirements

### Requirement: Main window MUST define a low-profile search and filter area
The desktop application main window MUST provide a low-profile search and filter area for library browsing that includes a search/filter input, dropdown controls for view mode, dropdown controls for sort style, and any supported grouping controls.

#### Scenario: Expanding the search and filter area
- **WHEN** the user opens the disclosable search and filter area
- **THEN** the main window displays the search/filter input, view mode control, grouping control, and sort control without replacing the primary library content area

#### Scenario: Collapsing the search and filter area
- **WHEN** the user closes the disclosable search and filter area while search, filter, view mode, grouping, or sort state is active
- **THEN** the main window displays a concise summary of the active library browsing state

### Requirement: Main window MUST expose account actions through an account menu
The desktop application main window MUST provide an account button that opens a compact account menu containing DriveThruRPG account information and account-related actions.

#### Scenario: Opening the account menu
- **WHEN** the user activates the account button
- **THEN** the app displays a menu that includes basic DriveThruRPG account identity or connection status information

#### Scenario: Managing the access token
- **WHEN** the account menu is open
- **THEN** the menu provides actions to set or reset the user's DriveThruRPG access token

#### Scenario: Opening application settings
- **WHEN** the account menu is open
- **THEN** the menu provides an action to open application settings

### Requirement: Main window MUST present library content in list or tree form
The desktop application main window MUST provide a list or tree presentation of the user's library content that includes item title, file or product size when available, update date when available, and other available library metadata needed for browsing.

#### Scenario: Viewing library content as a list
- **WHEN** the selected view mode is a flat list mode
- **THEN** the content area displays matching library items as rows with title, size, update date, and available supporting metadata

#### Scenario: Viewing library content as a tree
- **WHEN** the selected view mode or grouping mode requires hierarchy
- **THEN** the content area displays matching library items in a tree structure grouped by the active grouping dimension

### Requirement: Main window MUST present library content in grid form
The desktop application main window MUST provide a grid presentation of the user's library content that shows a thumbnail image when available, title, and size information for each item.

#### Scenario: Viewing library content as a grid
- **WHEN** the selected view mode is grid
- **THEN** the content area displays matching library items as grid cells with thumbnail, title, and size information

#### Scenario: Displaying grouped grid sections
- **WHEN** grid view is active and the current grouping mode divides results into sections
- **THEN** the grid displays sections by publisher, type, or the active supported grouping dimension and sorts items within each section

### Requirement: Main window MUST summarize the visible library contents
The desktop application main window MUST display a summary of the current library view contents, including total item count, filtered or matched item count, and section count when sections are visible.

#### Scenario: Updating summary counts
- **WHEN** library data, search text, filters, view mode, grouping, or sorting changes
- **THEN** the summary updates to reflect the current total count, matched count, and visible section count

### Requirement: Main window MUST show non-blocking sync and update status
The desktop application main window MUST show low-profile status for library update or sync activity while keeping the UI responsive.

#### Scenario: Syncing library contents in the background
- **WHEN** the app updates or syncs library content
- **THEN** the sync work runs without blocking main window interaction

#### Scenario: Inspecting sync details
- **WHEN** sync status, progress, latency, or last update details are available
- **THEN** the app exposes those details through a tooltip or equivalent low-profile affordance
