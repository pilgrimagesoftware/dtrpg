## Context

The app performs multi-page HTTP fetches (catalog load, item detail) on a background executor thread via `cx.spawn` + `background_executor().spawn`. Currently there is no UI feedback while these operations run. The sidebar has a fixed-height footer that already contains a total-count/size readout — the progress button will live there. The existing `SettingsController` + settings panel overlay in `root_view.rs` establishes the pattern for a toggled overlay panel anchored to the sidebar.

## Goals / Non-Goals

**Goals:**

- Surface background operation status through a non-intrusive button in the sidebar footer.
- Let users open an activity panel listing current and recently-completed operations.
- Instrument catalog load and item detail fetch calls with activity lifecycle events (start/complete/error).
- Keep the model extensible so future download operations can register activity items the same way.

**Non-Goals:**

- Cancellation of in-progress operations.
- Persistent activity history across app restarts.
- Progress fractions for the current HTTP-based operations (no byte-level progress data available).
- Download operations (tracked separately in `catalog-storage-location`).

## Decisions

### 1. Separate `ActivityController` entity

Rather than folding activity state into `LibraryController`, introduce a distinct `Entity<ActivityController>` owned by `LibraryRootView`. This mirrors the existing `Entity<SettingsController>` pattern and keeps the library state controller single-purpose.

*Alternative considered*: Embed an activity list in `LibraryController` and expose it on the snapshot. Rejected because it conflates two unrelated concerns and makes the controller harder to test in isolation.

### 2. `LibraryController` receives `Entity<ActivityController>` at construction

`LibraryController::new()` accepts an additional `Entity<ActivityController>` parameter. Background task closures capture a clone of the entity and call `activity_entity.update(async_cx, ...)` at operation start and completion, alongside the existing `this.update(...)` call.

*Alternative considered*: `LibraryController` emits a typed event; `LibraryRootView` subscribes and forwards to `ActivityController`. Rejected: adds three subscription wires per future operation, each with a separate closure allocation.

### 3. `ActivityItem` keyed by an incrementing `u64`

Each item is assigned a monotonically increasing id from an `AtomicU64` counter in `ActivityController`. No external uuid dependency needed.

### 4. Bounded recent history (cap = 25)

`ActivityController` maintains two vecs: `in_progress: Vec<ActivityItem>` and `recent: VecDeque<ActivityItem>` (capacity 25). On completion or error the item moves from `in_progress` to `recent`; if `recent` is full the oldest entry is dropped.

### 5. Activity panel rendered as a sidebar overlay, toggled by sidebar button

`LibraryRootView::render` conditionally renders `render_activity_panel(...)` as an overlay child of the sidebar column when `activity_snap.panel_open == true`. This is identical in structure to how `render_settings_panel` is overlaid on the main content column.

`render_sidebar` gains an `entity: Entity<ActivityController>` parameter for the toggle button's `on_click` handler; it reads `in_progress_count` and `recent_error_count` from the snapshot to choose the button icon/badge.

### 6. `ActivityChanged` event drives re-renders

`ActivityController` emits `ActivityChanged` whenever items are added, updated, or removed. `LibraryRootView` subscribes and calls `cx.notify()`, following the existing `LibraryChanged` subscription pattern.

## Risks / Trade-offs

- **Closure capture complexity in `LibraryController::new`**: The spawn closure already captures `service_arc` and `this`; adding `activity_entity` is a third capture. The closure structure stays the same — just an additional `activity_entity.update` call before and after the service call. Low risk.
- **`ActivityController` parameter added to `LibraryController::new`**: This is a breaking change to `LibraryController::new`'s signature. Only `LibraryRootView::new` calls it, so the blast radius is one call site.
- **No cancellation**: If the user closes the panel while a fetch is in progress, the operation continues and the item will still move to `recent` on completion. Acceptable for a read-only observability feature.
