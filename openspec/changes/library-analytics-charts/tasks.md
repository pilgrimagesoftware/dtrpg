## 1. Charting Approach

- [ ] 1.1 Check `gpui-component` for an existing chart/bar primitive
- [ ] 1.2 If none exists, design a minimal hand-rolled bar-chart element using `gpui` `div` sizing

## 2. Aggregation

- [ ] 2.1 Write a publisher-count aggregation function over the catalog cache
- [ ] 2.2 Write a collection-count aggregation function over the collections cache
- [ ] 2.3 Write a document-type-count aggregation function over the catalog cache

## 3. View

- [ ] 3.1 Create `library_analytics_view.rs` rendering the three charts
- [ ] 3.2 Add a navigation entry point (sidebar item or menu item) to open the view

## 4. Build and Verify

- [ ] 4.1 Run `cargo check --workspace`
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify chart values against a known catalog/collections fixture
- [ ] 4.4 Manually verify charts update after a collection membership change
