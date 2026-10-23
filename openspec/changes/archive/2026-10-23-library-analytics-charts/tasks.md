## 1. Charting Approach

- [x] 1.1 Check `gpui-component` for an existing chart/bar primitive
- [x] 1.2 If none exists, design a minimal hand-rolled bar-chart element using `gpui` `div` sizing

## 2. Aggregation

- [x] 2.1 Write a publisher-count aggregation function over the catalog cache
- [x] 2.2 Write a collection-count aggregation function over the collections cache
- [x] 2.3 Write a document-type-count aggregation function over the catalog cache

## 3. View

- [x] 3.1 Create `library_analytics_view.rs` rendering the three charts
- [x] 3.2 Add a navigation entry point (sidebar item or menu item) to open the view

## 4. Build and Verify

- [x] 4.1 Run `cargo check --workspace`
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 4.3 Manually verify chart values against a known catalog/collections fixture
- [x] 4.4 Manually verify charts update after a collection membership change
