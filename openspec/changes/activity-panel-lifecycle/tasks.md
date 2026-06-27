## 1. Add recent_count to ActivitySnapshot

- [ ] 1.1 Add `recent_count: usize` field to `ActivitySnapshot` in `data/activity.rs`
- [ ] 1.2 Populate `recent_count` in `ActivityController::snapshot()` from `self.recent.len()`

## 2. Implement Per-Item Expiry Timer

- [ ] 2.1 Add `const EXPIRY_SECS: u64 = 15;` to `controllers/activity.rs`
- [ ] 2.2 Add `ActivityController::expire_item(id: u64, cx: &mut Context<Self>)` — removes item with matching id from `recent` (no-op if not found); emits `ActivityChanged` only if an item was actually removed
- [ ] 2.3 In `ActivityController::complete()`, after pushing to `recent`, call `cx.spawn` with a `WeakEntity` of self; the task sleeps via `async_cx.background_executor().timer(Duration::from_secs(EXPIRY_SECS)).await` then calls `weak.update(async_cx, |a, cx| a.expire_item(id, cx)).ok()`; detach the task
- [ ] 2.4 Apply the same expiry spawn in `ActivityController::error()` after pushing to `recent`
- [ ] 2.5 Add `use std::time::Duration;` import to `controllers/activity.rs`

## 3. Update Button States in Sidebar

- [ ] 3.1 In `render_activity_button` in `sidebar_view.rs`, replace the binary `if in_progress > 0 { "↻ (N)" } else { "✓" }` with a three-way derivation:
  - `in_progress > 0` → `format!("↻ ({})", in_progress)`
  - `in_progress == 0 && recent_count > 0` → `"●".to_string()`
  - `in_progress == 0 && recent_count == 0` → `"○".to_string()`
- [ ] 3.2 Add `recent_count: usize` parameter to `render_activity_button`
- [ ] 3.3 Update the `render_sidebar` call to `render_activity_button` to pass `activity_snap.recent_count`
- [ ] 3.4 Update the `render_sidebar` signature to accept `activity_recent_count: usize` and pass it through, OR read it from the existing `ActivitySnapshot` parameter — choose whichever requires fewer call-site changes
- [ ] 3.5 Update the `render_sidebar` call in `root_view.rs` if the signature changes

## 4. Build and Quality

- [ ] 4.1 Run `cargo check --workspace` and fix any compilation errors
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings
- [ ] 4.3 Run `cargo test --workspace` and confirm all tests pass

## 5. Manual Verification

- [ ] 5.1 Launch the app with no credentials — confirm the button shows "○" (idle) before any load attempt, then switches to "↻ (1)" during the load, then "●" after the error resolves, then back to "○" after 15 seconds
- [ ] 5.2 Launch the app with valid credentials — confirm "↻ (1)" during catalog load, "●" after completion, "○" after 15 seconds
- [ ] 5.3 Open the activity panel while "●" is showing and confirm the completed item is visible; wait 15 seconds and confirm it disappears and the panel shows the empty state
- [ ] 5.4 Confirm the button never shows "✓" in any state
