## MODIFIED Requirements

### Requirement: Activity panel lists operations
The system SHALL render an `ActivityPanelView` overlay when `panel_open == true`. The panel SHALL list all items from the `ActivitySnapshot` — in-progress items first, followed by recently-completed items. Each row shows:
- **In-progress**: label, elapsed time, a progress bar (indeterminate or determinate), and optionally a cancel button
- **Complete**: label and total duration, no progress bar, no cancel button
- **Error**: label, total duration, error message, and no progress bar

The panel SHALL be 340 px wide and the scrollable item list SHALL have a maximum height of 400 px.

#### Scenario: Panel renders in-progress items
- **WHEN** the panel is open and `in_progress` is non-empty
- **THEN** each in-progress item appears with a spinner icon, its label, elapsed time, a progress bar, and a cancel button if cancellable

#### Scenario: Panel renders completed items
- **WHEN** the panel is open and `recent` contains completed items
- **THEN** each item appears with a checkmark icon, its label, and its total duration

#### Scenario: Panel renders error items
- **WHEN** the panel is open and `recent` contains error items
- **THEN** each item appears with a warning icon, its label, its total duration, and the error message

#### Scenario: Empty panel
- **WHEN** the panel is open and both `in_progress` and `recent` are empty
- **THEN** a "No recent activity" message is shown

### Requirement: Activity panel is anchored above the sidebar footer button
The system SHALL render the activity panel as an overlay child of the sidebar column, positioned so it appears above the footer button and does not overlap the main catalog area.

#### Scenario: Panel position
- **WHEN** the panel is open
- **THEN** it is rendered as an overlay within the sidebar column, anchored at the bottom-left above the footer button
