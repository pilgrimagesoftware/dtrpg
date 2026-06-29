## Why

Users currently have no visibility into background SDK activity (catalog loads, downloads, detail fetches). A persistent progress indicator in the sidebar footer lets users see what the app is doing and surfaces per-item activity without interrupting the main catalog view.

## What Changes

- Add an `ActivityItem` model and `ActivityStore` to track in-progress SDK operations.
- Add an `ActivityController` (or extend the existing settings/library controller) to manage the active item list.
- Add a progress button in the lower-left corner of the sidebar that shows a spinner or count badge when activity is in progress, and a checkmark when idle.
- Clicking the button toggles an `ActivityPanelView` overlay that lists current and recently-completed activity items with status, label, and optional progress fraction.
- Wrap each SDK call site (catalog list load, item detail fetch, and future download operations) to emit start/complete/error events into the `ActivityStore`.

## Capabilities

### New Capabilities

- `activity-store`: In-memory store tracking active and recently-completed background operations, with add/update/remove semantics and a bounded recent-history list.
- `activity-panel`: UI panel toggled by a sidebar button that lists activity items; button shows a live spinner/count badge while items are in progress.
- `sdk-activity-instrumentation`: Instrumentation applied to catalog list load, item detail fetch, and download calls so they register activity items at start and resolve them on completion or error.

### Modified Capabilities

## Impact

- `dtrpg-ui`: new `data/activity.rs`, new `controllers/activity.rs`, new `ui/views/activity_panel_view.rs`, sidebar view extended with the progress button.
- `dtrpg-ui`: `LibraryController` load and select_item paths updated to emit activity events.
- No changes to `dtrpg-core`, the SDK, or the API contract.
