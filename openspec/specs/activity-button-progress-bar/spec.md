# activity-button-progress-bar Specification

## Purpose
TBD - created by archiving change activity-button-progress-bar. Update Purpose after archive.
## Requirements
### Requirement: Activity button shows aggregate progress while activities are in progress

The activity button SHALL render a `ProgressCircle` reflecting the aggregate progress of all currently
in-progress activity items whenever at least one activity is in progress.

#### Scenario: Determinate aggregate progress

- **WHEN** one or more in-progress activity items report a known `progress` value
- **THEN** the activity button's `ProgressCircle` SHALL show the mean of those known values

#### Scenario: Indeterminate progress

- **WHEN** at least one activity is in progress but none report a known `progress` value
- **THEN** the activity button's `ProgressCircle` SHALL render in indeterminate mode

### Requirement: Activity button falls back to icon-only when idle

The activity button SHALL render its existing icon-only appearance when no activities are in progress.

#### Scenario: No activities in progress

- **WHEN** there are no in-progress activity items
- **THEN** the activity button SHALL render without a `ProgressCircle`, unchanged from current behavior

