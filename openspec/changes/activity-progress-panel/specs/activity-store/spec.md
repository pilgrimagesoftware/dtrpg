## ADDED Requirements

### Requirement: Activity items can be registered and resolved

The system SHALL provide an `ActivityController` that tracks in-progress and recently-completed background operations. Callers register a new item (receiving a unique id) and later resolve it as complete or as an error.

#### Scenario: Register an in-progress item

- **WHEN** a caller invokes `start(label)` on `ActivityController`
- **THEN** the controller adds an `ActivityItem` with status `InProgress`, assigns it a unique monotonically-increasing `u64` id, emits `ActivityChanged`, and returns the id

#### Scenario: Resolve an item as complete

- **WHEN** a caller invokes `complete(id)` on `ActivityController` with a valid id
- **THEN** the item is removed from `in_progress`, added to the front of `recent` with status `Complete`, and `ActivityChanged` is emitted

#### Scenario: Resolve an item as errored

- **WHEN** a caller invokes `error(id, message)` on `ActivityController` with a valid id
- **THEN** the item is removed from `in_progress`, added to the front of `recent` with status `Error` and the provided message, and `ActivityChanged` is emitted

#### Scenario: Resolve with an unknown id

- **WHEN** a caller invokes `complete(id)` or `error(id, _)` with an id that is not in `in_progress`
- **THEN** the call is a no-op and `ActivityChanged` is NOT emitted

### Requirement: Recent history is bounded

The system SHALL keep at most 25 recently-completed items. When a new resolved item would exceed this limit, the oldest entry in `recent` is dropped.

#### Scenario: Recent list at capacity

- **WHEN** `complete(id)` is called and `recent` already holds 25 items
- **THEN** the oldest item is removed from `recent` and the newly completed item is prepended

### Requirement: Activity snapshot exposes derived counts

The system SHALL provide an `ActivitySnapshot` struct containing: `in_progress_count: usize`, `recent_error_count: usize`, `panel_open: bool`, `items: Vec<ActivityItem>` (in-progress first, then recent).

#### Scenario: Snapshot reflects current state

- **WHEN** `ActivityController::snapshot()` is called
- **THEN** it returns counts and a combined item list matching the current controller state without cloning the internal vecs unnecessarily

### Requirement: Activity panel open state is togglable

The system SHALL track whether the activity panel is open via a `panel_open: bool` field on `ActivityController`. A `toggle_panel()` method flips the value and emits `ActivityChanged`.

#### Scenario: Toggle panel open

- **WHEN** `toggle_panel()` is called and `panel_open` is `false`
- **THEN** `panel_open` becomes `true` and `ActivityChanged` is emitted

#### Scenario: Toggle panel closed

- **WHEN** `toggle_panel()` is called and `panel_open` is `true`
- **THEN** `panel_open` becomes `false` and `ActivityChanged` is emitted
