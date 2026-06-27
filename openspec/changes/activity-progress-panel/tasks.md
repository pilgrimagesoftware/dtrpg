## 1. Activity Data Model

- [ ] 1.1 Create `dtrpg-ui/src/data/activity.rs` with `ActivityStatus` enum (`InProgress`, `Complete`, `Error(String)`) and `ActivityItem` struct (`id: u64`, `label: Arc<str>`, `status: ActivityStatus`)
- [ ] 1.2 Add `ActivityChanged` event struct to `data/events.rs`
- [ ] 1.3 Register `activity` module in `data/mod.rs`

## 2. ActivityController

- [ ] 2.1 Create `dtrpg-ui/src/controllers/activity.rs` with `ActivityController` struct holding `next_id: u64`, `in_progress: Vec<ActivityItem>`, `recent: VecDeque<ActivityItem>` (cap 25), `panel_open: bool`
- [ ] 2.2 Implement `ActivityController::start(label: &str, cx: &mut Context<Self>) -> u64` — assigns next id, pushes `InProgress` item, emits `ActivityChanged`, returns id
- [ ] 2.3 Implement `ActivityController::complete(id: u64, cx: &mut Context<Self>)` — moves item from `in_progress` to front of `recent` as `Complete`, evicts oldest if at cap, emits `ActivityChanged`; no-op on unknown id
- [ ] 2.4 Implement `ActivityController::error(id: u64, message: String, cx: &mut Context<Self>)` — same as `complete` but sets status to `Error(message)`
- [ ] 2.5 Implement `ActivityController::toggle_panel(cx: &mut Context<Self>)` — flips `panel_open`, emits `ActivityChanged`
- [ ] 2.6 Implement `ActivityController::snapshot()` returning `ActivitySnapshot` with `in_progress_count`, `recent_error_count`, `panel_open`, and combined `items` vec (in-progress first)
- [ ] 2.7 Implement `EventEmitter<ActivityChanged>` for `ActivityController` in `data/events.rs`
- [ ] 2.8 Register `activity` module in `controllers/mod.rs`

## 3. Wire ActivityController into LibraryRootView

- [ ] 3.1 In `root_view.rs`, create `activity: Entity<ActivityController>` in `LibraryRootView::new()` via `cx.new(|_| ActivityController::new())`
- [ ] 3.2 Subscribe to `ActivityChanged` in `LibraryRootView::new()` to call `cx.notify()`, following the existing `LibraryChanged` subscription pattern
- [ ] 3.3 Update `LibraryController::new()` signature to accept `activity: Entity<ActivityController>` as a third parameter (after `service` and before `cx`)
- [ ] 3.4 Update the `cx.new(|cx| LibraryController::new(service, cx))` call in `root_view.rs` to pass the activity entity: `cx.new(|cx| LibraryController::new(service, activity.clone(), cx))`
- [ ] 3.5 Store the `Entity<ActivityController>` as a field on `LibraryController`

## 4. Instrument SDK Calls in LibraryController

- [ ] 4.1 In the `cx.spawn` background task in `LibraryController::new()`, call `activity_entity.update(async_cx, |a, cx| a.start("Loading catalog…", cx))` before spawning the blocking executor task, capturing the returned id
- [ ] 4.2 After the executor task returns `Ok(_)`, call `activity_entity.update(async_cx, |a, cx| a.complete(id, cx))` before `this.update(...)` 
- [ ] 4.3 After the executor task returns `Err(e)`, call `activity_entity.update(async_cx, |a, cx| a.error(id, e.to_string(), cx))` before `this.update(...)`
- [ ] 4.4 In `LibraryController::select_item()`, call `activity.update(cx, |a, cx| a.start("Loading item…", cx))` before the service call, capture id
- [ ] 4.5 After `select_item` returns `Ok`, call `activity.update(cx, |a, cx| a.complete(id, cx))`
- [ ] 4.6 After `select_item` returns `Err(e)`, call `activity.update(cx, |a, cx| a.error(id, e.to_string(), cx))`

## 5. Activity Panel View

- [ ] 5.1 Create `dtrpg-ui/src/ui/views/activity_panel_view.rs` with `render_activity_panel(snap: &ActivitySnapshot, entity: Entity<ActivityController>, colors: &ColorTokens) -> impl IntoElement`
- [ ] 5.2 Render a fixed-width panel (match sidebar width 250px) anchored at the bottom of the sidebar column using `absolute().bottom_0().left_0()`
- [ ] 5.3 Render a header row with "Activity" label and a close button that calls `entity.update(cx, |a, cx| a.toggle_panel(cx))`
- [ ] 5.4 Render each item row: spinner icon for `InProgress`, checkmark for `Complete`, warning icon for `Error`; show item label; for `Error` rows show error message below label in `text_tertiary` color
- [ ] 5.5 Render "No recent activity" empty state when `items` is empty
- [ ] 5.6 Register `activity_panel_view` in `ui/views/mod.rs`

## 6. Sidebar Activity Button

- [ ] 6.1 Add `activity_entity: Entity<ActivityController>` and `activity_in_progress: usize` parameters to `render_sidebar()`
- [ ] 6.2 In the sidebar footer, add an activity button row below the existing count/size row
- [ ] 6.3 Button shows spinner text ("↻") when `activity_in_progress > 0`, checkmark ("✓") when idle
- [ ] 6.4 Button shows a count badge (e.g., " (N)") appended to the icon text when `activity_in_progress > 0`
- [ ] 6.5 Button `on_click` calls `activity_entity.update(cx, |a, cx| a.toggle_panel(cx))`
- [ ] 6.6 Update `root_view.rs` `render_sidebar` call to pass `activity.clone()` and `activity_snap.in_progress_count`

## 7. Render Activity Panel in Root View

- [ ] 7.1 Read `activity_snap = self.activity.read(cx).snapshot()` in `LibraryRootView::render`
- [ ] 7.2 Conditionally render `render_activity_panel(&activity_snap, activity_entity.clone(), colors)` as an overlay child of the sidebar column when `activity_snap.panel_open`

## 8. Build and Quality

- [ ] 8.1 Run `cargo check --workspace` and fix any compilation errors
- [ ] 8.2 Run `cargo test --workspace` and confirm all tests pass
- [ ] 8.3 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings

## 9. Manual Verification

- [ ] 9.1 Launch the app and observe the sidebar footer — the activity button should be visible showing "✓" at rest
- [ ] 9.2 Trigger a catalog load (or restart the app) and confirm the button shows "↻ (1)" while loading, then reverts to "✓" when done
- [ ] 9.3 Click the activity button and confirm the activity panel opens; click it again or the close button and confirm it closes
- [ ] 9.4 While loading, open the panel and confirm the in-progress "Loading catalog…" item appears with a spinner
- [ ] 9.5 After loading, confirm the panel shows "Loading catalog…" as a completed item with a checkmark
- [ ] 9.6 Select a catalog item and confirm a "Loading item…" activity appears and resolves in the panel
- [ ] 9.7 (If credentials are missing) confirm an error activity item appears in the panel showing the error message
