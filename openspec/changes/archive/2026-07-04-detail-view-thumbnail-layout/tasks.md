## 1. Layout Change

- [x] 1.1 Change the root `div()` in `render_detail_tab_content` from `.flex_col()` to `.flex()`
- [x] 1.2 Change the cover block from a full-width, centered, `py`-padded block to a `.flex_none()`
  fixed-width column with appropriate right-side spacing
- [x] 1.3 Confirm the info panel's `.flex_1().min_h_0()` sizing produces a correctly filling right column
  in the new row context

## 2. Verification Against Overlapping Changes

- [x] 2.1 Check `detail-panel-layered-sidebar` and `multi-item-catalog-entry-detail` for conflicting
  in-flight edits to `detail_panel_view.rs`; sequence accordingly

## 3. Build and Verify

- [x] 3.1 Run `cargo check --workspace`
- [x] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 3.3 Manually verify the side-by-side layout at typical and minimum window widths
- [x] 3.4 Manually verify refresh-thumbnail and info-panel scrolling still work correctly
