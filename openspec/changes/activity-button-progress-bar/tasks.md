## 1. Aggregate Computation

- [ ] 1.1 Add an aggregate-progress computation to `ActivitySnapshot` (or a controller method) that means
  the known `progress` values among in-progress items
- [ ] 1.2 Return an indeterminate signal when no in-progress item has a known `progress` value

## 2. Button Rendering

- [ ] 2.1 Render `gpui_component::progress::Progress` on the activity button when
  `in_progress_count > 0`, driven by the aggregate computation
- [ ] 2.2 Fall back to the existing icon-only rendering when `in_progress_count == 0`

## 3. Build and Verify

- [ ] 3.1 Run `cargo check --workspace`
- [ ] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 3.3 Manually verify determinate progress during a thumbnail-loading activity
- [ ] 3.4 Manually verify indeterminate rendering during an activity with no known progress
- [ ] 3.5 Manually verify icon-only fallback when idle
