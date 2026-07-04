## 1. Data Model: ActivityItem

- [x] 1.1 Add `started_at: std::time::Instant` field to `ActivityItem` in `data/activity.rs`; set to `Instant::now()` everywhere `ActivityItem` is constructed (only in `ActivityController::start()`)
- [x] 1.2 Add `elapsed_secs: Option<u64>` field to `ActivityItem` (None while in-progress, set to `started_at.elapsed().as_secs()` when the item transitions to Complete or Error)
- [x] 1.3 Add `progress: Option<f32>` field to `ActivityItem`; default `None`
- [x] 1.4 Add `cancel_fn: Option<Arc<dyn Fn() + Send + Sync + 'static>>` field to `ActivityItem`; default `None`
- [x] 1.5 Derive or manually implement `Clone` for `ActivityItem` — `cancel_fn` is `Arc` so it clones by reference; `Instant` and `Option<u64>` are `Copy`/`Clone`; confirm `#[derive(Clone)]` now compiles

## 2. Controller: Signature and New Methods

- [x] 2.1 Update `ActivityController::start()` signature to `start(label: &str, cancel_fn: Option<Arc<dyn Fn() + Send + Sync + 'static>>, cx: &mut Context<Self>) -> u64`; set `started_at: Instant::now()`, `elapsed_secs: None`, `progress: None`, `cancel_fn` on the new item
- [x] 2.2 Update both `start()` call sites in `library.rs` (lines 111 and 271) to pass `None` as the cancel fn
- [x] 2.3 When an item transitions to `Complete` in `complete()`, set `item.elapsed_secs = Some(item.started_at.elapsed().as_secs())` before moving to `recent`
- [x] 2.4 When an item transitions to `Error` in `error()`, set `item.elapsed_secs = Some(item.started_at.elapsed().as_secs())` before moving to `recent`
- [x] 2.5 Add `update_progress(&mut self, id: u64, progress: f32, cx: &mut Context<Self>)`: find the item in `in_progress` by id, clamp the value to `[0.0, 1.0]`, set `item.progress`, emit `ActivityChanged`; no-op if id not found
- [x] 2.6 Add `cancel_activity(&mut self, id: u64, cx: &mut Context<Self>)`: find the item in `in_progress` by id; if found, call `cancel_fn` if `Some`, then call `self.error(id, "Cancelled".to_string(), cx)`; no-op if id not found
- [x] 2.7 Run `cargo check -p dtrpg-ui` and fix any errors

## 3. View: Row Layout

- [x] 3.1 In `activity_panel_view.rs`, update `render_item_row` to accept `started_at: std::time::Instant` and `elapsed_secs: Option<u64>` and `progress: Option<f32>` and `has_cancel: bool`
- [x] 3.2 Add a helper `format_duration(secs: u64) -> String` that returns `"Xs"` for under 60 s, `"Xm Ys"` for 60 s or more
- [x] 3.3 In the header line of each row, append the elapsed/duration time: for in-progress items use `format_duration(started_at.elapsed().as_secs())`; for complete/error items use `elapsed_secs.map(format_duration).unwrap_or_default()`
- [x] 3.4 For in-progress rows, add a progress bar div below the label line: full row width, height 3 px, background `colors.border`, with an inner filled div whose width is `progress.unwrap_or(0.3) * 100%`
- [x] 3.5 For in-progress rows that have a cancel fn (`has_cancel == true`), add a "x" cancel button at the right edge of the header line that calls `activity_entity.update(cx, |a, cx| a.cancel_activity(item_id, cx))`
- [x] 3.6 Pass `has_cancel: item.cancel_fn.is_some()` from `render_activity_panel` through to `render_item_row`

## 4. View: Panel Dimensions and Snapshot

- [x] 4.1 Change panel width from `px(250.0)` to `px(340.0)` in `render_activity_panel`
- [x] 4.2 Change list max-height from `px(300.0)` to `px(400.0)` in `render_activity_panel`

## 5. Build and Verification

- [x] 5.1 Run `cargo check --workspace` and confirm zero errors
- [x] 5.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings
- [x] 5.3 Launch the app, trigger a library sync or download, and verify the activity panel shows a progress bar and elapsed time for the in-progress item
- [x] 5.4 Verify that completed items display their total duration and no progress bar
- [x] 5.5 Add a test call with a cancel fn and verify the cancel button appears and clicking it transitions the item to error state
