## 1. Aggregate Computation

- [x] 1.1 Add an aggregate-progress computation to `ActivitySnapshot` (or a controller method) that means
  the known `progress` values among in-progress items
- [x] 1.2 Return an indeterminate signal when no in-progress item has a known `progress` value

## 2. Button Rendering

- [x] 2.1 Render `gpui_component::progress::ProgressCircle` on the activity button when
  `in_progress_count > 0`, driven by the aggregate computation
- [x] 2.2 Fall back to the existing icon-only rendering when `in_progress_count == 0`

## 3. Build and Verify

- [x] 3.1 Run `cargo check --workspace`
- [x] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 3.3 Manually verify determinate progress during a thumbnail-loading activity
- [x] 3.4 Manually verify indeterminate rendering during an activity with no known progress
- [x] 3.5 Manually verify icon-only fallback when idle
