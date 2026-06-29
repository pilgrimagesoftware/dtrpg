# activity-panel Specification

## Purpose
TBD - created by archiving change activity-progress-panel. Update Purpose after archive.
## Requirements
### Requirement: Sidebar footer shows an activity progress button

The system SHALL render a button in the sidebar footer that reflects the current activity state. The button SHALL show a spinner icon when one or more items are in progress, and a checkmark icon when `in_progress_count == 0`. When `in_progress_count > 0`, a count badge SHALL be rendered alongside the icon.

#### Scenario: Button with active operations

- **WHEN** `in_progress_count > 0`
- **THEN** the sidebar button shows a spinner icon and a badge displaying the count

#### Scenario: Button when idle

- **WHEN** `in_progress_count == 0` and `recent` is empty
- **THEN** the sidebar button shows a checkmark icon with no badge

#### Scenario: Button when idle with recent items

- **WHEN** `in_progress_count == 0` and `recent` is non-empty
- **THEN** the sidebar button shows a checkmark icon with no badge

### Requirement: Clicking the activity button toggles the activity panel

The system SHALL call `ActivityController::toggle_panel()` when the sidebar activity button is clicked, causing the panel to open or close.

#### Scenario: Open panel via button click

- **WHEN** the activity button is clicked and `panel_open == false`
- **THEN** the activity panel becomes visible

#### Scenario: Close panel via button click

- **WHEN** the activity button is clicked and `panel_open == true`
- **THEN** the activity panel is dismissed

### Requirement: Activity panel lists operations

The system SHALL render an `ActivityPanelView` overlay when `panel_open == true`. The panel SHALL list all items from the `ActivitySnapshot` — in-progress items first, followed by recently-completed items. Each row shows the item label and a status icon (spinner for in-progress, checkmark for complete, warning for error). Error rows SHALL additionally show the error message below the label.

#### Scenario: Panel renders in-progress items

- **WHEN** the panel is open and `in_progress` is non-empty
- **THEN** each in-progress item appears with a spinner icon and its label

#### Scenario: Panel renders completed items

- **WHEN** the panel is open and `recent` contains completed items
- **THEN** each item appears with a checkmark icon and its label

#### Scenario: Panel renders error items

- **WHEN** the panel is open and `recent` contains error items
- **THEN** each item appears with a warning icon, its label, and the error message

#### Scenario: Empty panel

- **WHEN** the panel is open and both `in_progress` and `recent` are empty
- **THEN** a "No recent activity" message is shown

### Requirement: Activity panel is anchored above the sidebar footer button

The system SHALL render the activity panel as an overlay child of the sidebar column, positioned so it appears above the footer button and does not overlap the main catalog area.

#### Scenario: Panel position

- **WHEN** the panel is open
- **THEN** it is rendered as an overlay within the sidebar column, anchored at the bottom-left above the footer button

