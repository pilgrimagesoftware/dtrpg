## ADDED Requirements

### Requirement: In-progress items may register a cancel function
The system SHALL allow callers to supply an optional cancel function when starting an activity via `ActivityController::start(label, cancel_fn, cx)`. The cancel function has the type `Option<Arc<dyn Fn() + Send + Sync + 'static>>`. Items started without a cancel function (`None`) are not cancellable.

#### Scenario: Item started with cancel fn
- **WHEN** `start()` is called with `Some(cancel_fn)`
- **THEN** the resulting `ActivityItem` stores the cancel function and the row is considered cancellable

#### Scenario: Item started without cancel fn
- **WHEN** `start()` is called with `None`
- **THEN** no cancel button is shown for that item

### Requirement: Cancellable in-progress items show a cancel button
The system SHALL render a cancel button ("✕") on each in-progress row whose `ActivityItem` has a stored cancel function. The button SHALL NOT appear on rows that have no cancel function, or on completed or error rows.

#### Scenario: Cancel button visible for cancellable item
- **WHEN** the panel is open and an in-progress item has a cancel function
- **THEN** a cancel button is rendered at the right edge of that row

#### Scenario: Cancel button absent for non-cancellable item
- **WHEN** the panel is open and an in-progress item has no cancel function
- **THEN** no cancel button is rendered for that row

### Requirement: Clicking the cancel button stops the activity
The system SHALL call `ActivityController::cancel_activity(id, cx)` when the cancel button is clicked. `cancel_activity` SHALL invoke the stored cancel function and immediately transition the item to `Error("Cancelled")` state (which starts the standard error expiry timer). Callers are responsible for observing the cancellation signal and halting their work.

#### Scenario: Clicking cancel calls the cancel fn and transitions the item
- **WHEN** the user clicks the cancel button for an in-progress item
- **THEN** the stored cancel function is called, the item moves to `Error("Cancelled")`, and the cancel button disappears

#### Scenario: Cancelling a non-existent or already-complete item is a no-op
- **WHEN** `cancel_activity` is called for an id that is not in the in-progress list
- **THEN** nothing happens and no error is emitted
