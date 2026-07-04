## Why

The activity button in the status/title bar currently shows only a count of in-progress/completed
activities (via its tooltip). There is no at-a-glance visual indicator of overall progress. Rendering the
sum of all active loaders as a `gpui-component` `Progress` bar gives users a quick visual signal without
needing to hover.

## What Changes

- The activity button renders a `gpui-component` `ProgressCircle` reflecting the aggregate progress of all
  currently active activity items (e.g. sum of known/estimated progress across in-progress items, or a
  simple fraction of completed-vs-total if per-item progress isn't tracked).
- The button falls back to its current icon-only appearance when no activities are in progress.
- This is a visual addition alongside the existing tooltip (see `hover-card-tooltips` for the tooltip
  content itself) — the tooltip and the progress bar are complementary, not exclusive.

## Capabilities

### New Capabilities

- `activity-button-progress-bar`: The activity button renders a `ProgressCircle` reflecting the aggregate
  state of active loaders when any are in progress.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/status_bar_view.rs` (or wherever the activity button
  lives): button rendering.
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/activity.rs`, `controllers/activity.rs`: need an aggregate
  progress computation across active `ActivityItem`s; verify whether `ActivityItem` currently tracks a
  numeric progress fraction or only a label/status — if not, this change needs to add one.
