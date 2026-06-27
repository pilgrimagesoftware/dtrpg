## Why

The activity button currently shows "✓" whenever no operation is in flight, conflating two meaningfully different states: "the panel is truly empty" and "operations just finished." Users have no way to tell at a glance whether anything ran recently. Additionally, completed items accumulate in the panel indefinitely, making it harder to distinguish recent completions from older ones.

## What Changes

- **Three-state button icon**: Replace the binary "↻ / ✓" icon with three distinct states:
  - *No activity* — `recent` is empty and nothing is in flight: a subtle hollow icon (e.g. "○") indicating the panel has nothing to show.
  - *Active* — one or more operations are in flight: "↻ (N)" as today.
  - *Recently completed* — operations finished but recent items are still present: a filled indicator (e.g. "●") that tells the user "something just happened."
- **Auto-expiry of recent items**: When an item moves from `in_progress` to `recent` (on complete or error), a 15-second countdown begins. After the countdown the item is removed from `recent` and `ActivityChanged` is emitted. Once all recent items expire and nothing is in flight, the button returns to the *no activity* state.

## Capabilities

### New Capabilities

- `activity-button-states`: Three distinct sidebar button states (no-activity, active, recently-completed) derived from `ActivitySnapshot` counts.
- `activity-item-expiry`: Recent items auto-expire from the panel 15 seconds after resolution via a per-item gpui background timer.

### Modified Capabilities

## Impact

- `dtrpg-ui/src/controllers/activity.rs`: `complete` and `error` spawn a gpui timer per item; new `expire_item(id)` method removes by id from `recent`.
- `dtrpg-ui/src/data/activity.rs`: `ActivitySnapshot` gains `recent_count: usize`.
- `dtrpg-ui/src/ui/views/sidebar_view.rs`: `render_activity_button` derives a three-way state and renders the appropriate icon.
- No changes to the service layer, SDK, or API contract.
