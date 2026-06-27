## ADDED Requirements

### Requirement: Catalog list load registers an activity item

The system SHALL register an in-progress activity item when the background catalog list fetch begins, and SHALL resolve it as complete or error when the fetch returns.

#### Scenario: Catalog load starts

- **WHEN** `LibraryController::new()` spawns the background catalog fetch task
- **THEN** an activity item with label "Loading catalog…" is registered via `ActivityController::start()` before the service call

#### Scenario: Catalog load completes successfully

- **WHEN** the background catalog fetch returns `Ok(_)`
- **THEN** the activity item is resolved via `ActivityController::complete(id)` before `apply_load_result` is called

#### Scenario: Catalog load fails

- **WHEN** the background catalog fetch returns `Err(e)`
- **THEN** the activity item is resolved via `ActivityController::error(id, message)` with the error's display string before `apply_load_result` is called

### Requirement: Item detail fetch registers an activity item

The system SHALL register an in-progress activity item when an item detail fetch begins, and SHALL resolve it as complete or error when the fetch returns.

#### Scenario: Detail fetch starts

- **WHEN** `LibraryController::select_item(id)` is called
- **THEN** an activity item with label "Loading item…" is registered via `ActivityController::start()` before the service call

#### Scenario: Detail fetch completes successfully

- **WHEN** the detail fetch returns `Ok(_)`
- **THEN** the activity item is resolved via `ActivityController::complete(id)`

#### Scenario: Detail fetch fails

- **WHEN** the detail fetch returns `Err(e)`
- **THEN** the activity item is resolved via `ActivityController::error(id, message)` with the error's display string

### Requirement: `LibraryController` receives `ActivityController` at construction

The system SHALL update `LibraryController::new()` to accept an `Entity<ActivityController>` parameter, which is stored and used for all activity registration calls.

#### Scenario: Construction with activity controller

- **WHEN** `LibraryController::new(service, activity, cx)` is called
- **THEN** the controller stores the activity entity and uses it in all background task closures
