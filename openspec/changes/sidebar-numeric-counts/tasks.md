## 1. Update Collection Count Badge Rendering

- [x] 1.1 Locate the `render_collections_section` function in `dtrpg-ui/src/ui/views/sidebar_view.rs`
- [x] 1.2 Find where the collection count badge is rendered (likely using `Badge` or a div with count text)
- [x] 1.3 Remove any trailing text (e.g., "items", "titles") from the badge, keeping only the numeric value
- [x] 1.4 Verify the badge still displays the count correctly with just the number
- [x] 1.5 Run `cargo check -p dtrpg-ui` to confirm no compilation errors

## 2. Update Publisher Count Badge Rendering

- [x] 2.1 Locate the `render_publishers_section` function in `dtrpg-ui/src/ui/views/sidebar_view.rs`
- [x] 2.2 Find where the publisher count badge is rendered
- [x] 2.3 Remove any trailing text from the badge, keeping only the numeric value
- [x] 2.4 Verify the badge still displays the count correctly with just the number
- [x] 2.5 Run `cargo check -p dtrpg-ui` to confirm no compilation errors

## 3. Verify Accessibility

- [x] 3.1 Check that collection entries have appropriate aria-labels or context for screen readers
- [x] 3.2 Check that publisher entries have appropriate aria-labels or context for screen readers
- [x] 3.3 If missing, add aria-labels that provide full context (e.g., "Collection: My Favorites, 5 items")

## 4. Quality Assurance

- [x] 4.1 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any new warnings
- [x] 4.2 Run `cargo test -p dtrpg-ui` to ensure no tests break
- [ ] 4.3 Launch the app and verify collection badges show numeric-only counts
- [ ] 4.4 Launch the app and verify publisher badges show numeric-only counts
- [ ] 4.5 Verify the catalog footer still shows full context text (e.g., "12 titles", "Viewing 5 items from Collection Name")
- [ ] 4.6 Check visual alignment and spacing of badges hasn't changed
