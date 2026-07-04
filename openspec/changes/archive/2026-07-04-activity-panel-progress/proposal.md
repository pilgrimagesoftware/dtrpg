## Why

The activity panel currently shows in-progress operations as a static label with a spinning icon, giving the user no indication of how far along an operation is, how long it has been running, or any way to stop it. Adding per-item progress bars, elapsed time, and a cancel action makes long-running operations (library syncs, batch downloads) visible and controllable without requiring the user to wait passively.

## What Changes

- Add `progress: Option<f32>` (0.0–1.0) to `ActivityItem`; `None` renders an indeterminate bar, a value renders a filled determinate bar
- Add `started_at: std::time::Instant` to `ActivityItem`, set in `ActivityController::start()`
- Add `cancel_fn: Option<Arc<dyn Fn() + Send + Sync + 'static>>` to `ActivityItem`; callers that support cancellation provide it at `start()`
- Add `ActivityController::update_progress(id, f32, cx)` to let callers report progress
- Add `ActivityController::cancel_activity(id, cx)` which calls the stored cancel fn and transitions the item to `Error("Cancelled")`
- Widen the panel from 250 px to 340 px; increase the scrollable item list max-height from 300 px to 400 px
- Each in-progress row renders: label, elapsed time (e.g. "1m 23s"), a progress bar (indeterminate or filled), and a cancel button (only when a cancel fn is registered)
- Completed and error rows show the label and elapsed duration (time taken, not time since), with no progress bar or cancel button

## Capabilities

### New Capabilities

- `activity-item-progress`: Per-item progress bar (determinate when a progress value is reported, indeterminate otherwise) and elapsed/duration time display in the activity panel
- `activity-item-cancellation`: Cancel button on in-progress items that have a registered cancel fn; calls the fn and transitions the item to error state with "Cancelled" message

### Modified Capabilities

- `activity-panel`: Panel now 340 px wide with 400 px max list height; row layout restructured to fit progress bar, elapsed time, and cancel button

## Impact

- `dtrpg-ui/src/data/activity.rs`: `ActivityItem` and `ActivitySnapshot` struct changes
- `dtrpg-ui/src/controllers/activity.rs`: new `update_progress` and `cancel_activity` methods; `start()` gains an optional cancel fn parameter
- `dtrpg-ui/src/ui/views/activity_panel_view.rs`: row rendering expanded, panel dimensions updated
- All existing callers of `ActivityController::start()` must be updated to pass `None` as the cancel fn (no behavior change)
