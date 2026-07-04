# activity-item-progress Specification

## Purpose
TBD - created by archiving change activity-panel-progress. Update Purpose after archive.
## Requirements
### Requirement: Activity items record their start time
The system SHALL record a `started_at: std::time::Instant` on each `ActivityItem` at the moment `ActivityController::start()` is called. In-progress items SHALL display elapsed time (e.g. "23s", "1m 4s") computed from `started_at` to `now` at render time. Completed and error items SHALL display the total duration from `started_at` to the moment the item transitioned out of `InProgress`.

#### Scenario: Elapsed time shown for in-progress item
- **WHEN** an item is in `InProgress` state and the panel is open
- **THEN** the row displays the time elapsed since `started_at`, formatted as seconds ("Xs") for under one minute or minutes-and-seconds ("Xm Ys") for one minute or more

#### Scenario: Duration shown for completed item
- **WHEN** an item transitions to `Complete` or `Error`
- **THEN** the total elapsed duration at the time of transition is frozen and displayed in the panel row

### Requirement: Activity items support a progress value
The system SHALL allow callers to report a progress value between 0.0 and 1.0 for an in-progress item via `ActivityController::update_progress(id, progress, cx)`. If no progress value has been set, the item's progress field is `None`. Each in-progress row SHALL render a horizontal progress bar below the label:
- `None` progress: indeterminate bar (animated fill or pulsing appearance)
- `Some(f)` progress: determinate bar filled to `f * 100%` of the row width

Completed and error rows SHALL NOT show a progress bar.

#### Scenario: Indeterminate bar for new item
- **WHEN** an item is in `InProgress` and no `update_progress` call has been made
- **THEN** the row shows an indeterminate progress bar

#### Scenario: Determinate bar after progress update
- **WHEN** `update_progress(id, 0.6, cx)` is called
- **THEN** the progress bar for that item is filled to 60% of its width

#### Scenario: Progress value clamped to valid range
- **WHEN** `update_progress` is called with a value outside [0.0, 1.0]
- **THEN** the value is clamped to 0.0 or 1.0 before storing

#### Scenario: No progress bar on completed item
- **WHEN** an item transitions to `Complete`
- **THEN** the row no longer displays a progress bar

