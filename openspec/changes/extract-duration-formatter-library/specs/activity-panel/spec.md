## MODIFIED Requirements

### Requirement: Activity panel lists operations
The system SHALL render an `ActivityPanelView` overlay when `panel_open == true`. The panel SHALL list all items from the `ActivitySnapshot` — in-progress items first, followed by recently-completed items. Each row shows:
- **In-progress**: label, elapsed time, a progress bar (indeterminate or determinate), and optionally a cancel button
- **Complete**: label and total duration, no progress bar, no cancel button
- **Error**: label, total duration, error message, and no progress bar

Elapsed time and total duration SHALL be rendered using the extracted, published duration-formatting crate rather than an internal private formatter, and SHALL respect the app's active `rust_i18n` locale.

The panel SHALL be 340 px wide and the scrollable item list SHALL have a maximum height of 400 px.

#### Scenario: Panel renders in-progress items
- **WHEN** the panel is open and `in_progress` is non-empty
- **THEN** each in-progress item appears with a spinner icon, its label, elapsed time formatted via the published duration-formatting crate, a progress bar, and a cancel button if cancellable

#### Scenario: Panel renders completed items
- **WHEN** the panel is open and `recent` contains completed items
- **THEN** each item appears with a checkmark icon, its label, and its total duration formatted via the published duration-formatting crate

#### Scenario: Panel renders error items
- **WHEN** the panel is open and `recent` contains error items
- **THEN** each item appears with a warning icon, its label, its total duration formatted via the published duration-formatting crate, and the error message

#### Scenario: Empty panel
- **WHEN** the panel is open and both `in_progress` and `recent` are empty
- **THEN** a "No recent activity" message is shown

#### Scenario: Duration text respects active locale
- **WHEN** the panel is open and the app's active locale is `de` or `fr`
- **THEN** elapsed time and total duration strings use the corresponding locale's unit labels instead of English
