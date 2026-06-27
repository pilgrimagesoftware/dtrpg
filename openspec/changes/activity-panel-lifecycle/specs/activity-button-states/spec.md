## ADDED Requirements

### Requirement: Activity button reflects three distinct states

The system SHALL render the sidebar activity button using one of three distinct icons based on the current `ActivitySnapshot`:

- **Idle** (`in_progress_count == 0` and `recent_count == 0`): a hollow/neutral icon indicating no activity.
- **Active** (`in_progress_count > 0`): a spinner icon with an in-progress count badge.
- **Done** (`in_progress_count == 0` and `recent_count > 0`): a filled indicator showing that operations completed recently.

The button SHALL NOT show a checkmark in any state.

#### Scenario: No activity

- **WHEN** `in_progress_count == 0` and `recent_count == 0`
- **THEN** the button shows a hollow icon (e.g. "○") with no badge

#### Scenario: Operations in flight

- **WHEN** `in_progress_count > 0`
- **THEN** the button shows a spinner icon (e.g. "↻") and a count badge showing `in_progress_count`

#### Scenario: Operations recently completed

- **WHEN** `in_progress_count == 0` and `recent_count > 0`
- **THEN** the button shows a filled indicator (e.g. "●") with no badge

#### Scenario: In-flight and recent items coexist

- **WHEN** `in_progress_count > 0` and `recent_count > 0`
- **THEN** the Active state takes priority and the button shows the spinner with count badge

### Requirement: ActivitySnapshot exposes recent item count

The system SHALL include `recent_count: usize` in `ActivitySnapshot`, representing the number of items currently in the recent list (excluding expired items).

#### Scenario: Snapshot with recent items

- **WHEN** `ActivityController::snapshot()` is called and `recent` contains N items
- **THEN** `ActivitySnapshot::recent_count` equals N
