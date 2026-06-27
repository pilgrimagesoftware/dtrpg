## 1. Add recent_count to ActivitySnapshot

- [x] 1.1 Add `recent_count: usize` field to `ActivitySnapshot` in `data/activity.rs`
- [x] 1.2 Populate `recent_count` in `ActivityController::snapshot()` from `self.recent.len()`

## 2. Implement Per-Item Expiry Timer

- [x] 2.1 Add `const EXPIRY_SECS: u64 = 15;` to `controllers/activity.rs`
- [x] 2.2 Add `ActivityController::expire_item(id: u64, cx: &mut Context<Self>)` — removes item with matching id from `recent` (no-op if not found); emits `ActivityChanged` only if an item was actually removed
- [x] 2.3 In `ActivityController::complete()`, after pushing to `recent`, spawn a detached gpui task that sleeps via `async_cx.background_executor().timer(Duration::from_secs(EXPIRY_SECS)).await` then calls `this.update(async_cx, |a, cx| a.expire_item(id, cx)).ok()`
- [x] 2.4 Apply the same expiry spawn in `ActivityController::error()` after pushing to `recent`
- [x] 2.5 Add `use std::time::Duration;` import to `controllers/activity.rs`

## 3. Update Button States in Sidebar

- [x] 3.1 In `render_activity_button` in `sidebar_view.rs`, replaced the binary `if in_progress > 0 { "↻ (N)" } else { "✓" }` with a three-way derivation:
  - `in_progress > 0` → `format!("↻ ({})", in_progress)`
  - `in_progress == 0 && recent_count > 0` → `"●".to_string()`
  - `in_progress == 0 && recent_count == 0` → `"○".to_string()`
- [x] 3.2 Add `recent_count: usize` parameter to `render_activity_button`
- [x] 3.3 Update the `render_sidebar` call to `render_activity_button` to pass `activity_recent_count`
- [x] 3.4 Updated the `render_sidebar` signature to accept `activity_recent_count: usize` and pass it through
- [x] 3.5 Updated the `render_sidebar` call in `root_view.rs` to pass `activity_snap.recent_count`

## 4. Build and Quality

- [x] 4.1 Run `cargo check --workspace` — zero errors
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings` — zero warnings
- [x] 4.3 Run `cargo test --workspace` — 33 tests pass

## 5. Manual Verification

- [ ] 5.1 Launch the app with no credentials — confirm the button shows "○" (idle) before any load attempt, then switches to "↻ (1)" during the load, then "●" after the error resolves, then back to "○" after 15 seconds
- [ ] 5.2 Launch the app with valid credentials — confirm "↻ (1)" during catalog load, "●" after completion, "○" after 15 seconds
- [ ] 5.3 Open the activity panel while "●" is showing and confirm the completed item is visible; wait 15 seconds and confirm it disappears and the panel shows the empty state
- [ ] 5.4 Confirm the button never shows "✓" in any state
