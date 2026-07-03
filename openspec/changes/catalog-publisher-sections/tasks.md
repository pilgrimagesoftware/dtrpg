## 1. Prerequisite: Migrate Grouped List to DataTable

- [ ] 1.1 Replace the hand-rolled grouped-list row rendering in `catalog_view.rs` with the same
  `DataTable`-based path used by the ungrouped list
- [ ] 1.2 Verify scroll performance parity with the ungrouped list

## 2. Publisher Sections

- [ ] 2.1 Add publisher-derived section headers using `gpui-component`'s sections capability on top of
  the migrated `DataTable` path
- [ ] 2.2 Ensure sort order is applied within each publisher section, not across the flat list

## 3. Toggle Control

- [ ] 3.1 Add a "group by publisher" toggle to `toolbar_view.rs`
- [ ] 3.2 Persist the toggle state consistent with other list-layout preferences

## 4. Build and Verify

- [ ] 4.1 Run `cargo check --workspace`
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Manually verify grouping renders correct sections and sort order
- [ ] 4.4 Manually verify scroll performance on a large library with grouping enabled
- [ ] 4.5 Manually verify grid/thumb layouts are unaffected
