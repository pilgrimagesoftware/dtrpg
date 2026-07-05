## ADDED Requirements

### Requirement: Main window MUST provide a status bar
The desktop application main window MUST provide a status bar below the content area showing the total library item count and size, a divider, and a summary of the currently active content area.

#### Scenario: Viewing library totals
- **WHEN** the status bar is displayed
- **THEN** it shows the total number of items in the library and their combined size

#### Scenario: Viewing the active content area summary
- **WHEN** the active tab shows a filtered or selected set of items
- **THEN** the status bar displays the active tab's title, item count, and selection count when items are selected

### Requirement: Status bar MUST provide a theme picker
The desktop application status bar MUST provide a theme picker that shows the current theme on hover and opens a theme selection menu on click.

#### Scenario: Hovering the theme picker
- **WHEN** the user hovers the theme picker
- **THEN** the app displays the name of the currently active theme

#### Scenario: Changing the theme
- **WHEN** the user clicks the theme picker and selects a theme from the menu
- **THEN** the app applies the selected theme

### Requirement: Status bar MUST provide an activity indicator
The desktop application status bar MUST provide an activity indicator showing progress, that reveals in-progress and completed operation counts on hover and opens activity detail on click.

#### Scenario: Hovering the activity indicator
- **WHEN** the user hovers the activity indicator
- **THEN** the app displays the count of in-progress operations and the count of completed operations

#### Scenario: Opening activity detail
- **WHEN** the user clicks the activity indicator
- **THEN** the app opens a detail surface listing current and recent activity

### Requirement: Status bar MUST provide a notification indicator
The desktop application status bar MUST provide a notification indicator showing a bell icon with an unread badge, that reveals the unread notification count on hover and opens the notification panel on click.

#### Scenario: Hovering the notification indicator
- **WHEN** unread notifications exist and the user hovers the notification indicator
- **THEN** the app displays the count of unread notifications

#### Scenario: Opening the notification panel
- **WHEN** the user clicks the notification indicator
- **THEN** the app opens the notification panel showing the user's notifications
