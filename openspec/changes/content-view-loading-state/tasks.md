## 1. Loaded-State Audit

- [ ] 1.1 Identify which content views (catalog, alert history, settings panels) lack a loaded/not-loaded
  distinction on their backing cache
- [ ] 1.2 Add a loaded/not-loaded flag (or `Option<T>`) to any cache missing one, following the same
  pattern as `collection-count-placeholder`

## 2. Loading Indicator

- [ ] 2.1 Apply `gpui-component`'s list loading capability to `catalog_view.rs`
- [ ] 2.2 Apply the same capability to `alert_history_view.rs` and any other affected content view

## 3. Build and Verify

- [ ] 3.1 Run `cargo check --workspace`
- [ ] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 3.3 Manually verify the loading indicator appears before first load and clears after, for both
  populated and empty results
