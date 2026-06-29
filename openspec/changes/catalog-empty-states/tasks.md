## 1. Update render_catalog Signature

- [x] 1.1 Add `total_count: usize` and `search_query: &str` parameters to `render_catalog` in `catalog_view.rs` (current `CatalogView` reads these from `LibrarySnapshot` directly)
- [x] 1.2 Update the `render_catalog` call in `root_view.rs` to pass `snap.total_count` and `snap.search_query.as_str()` (not required in current entity-rendered `CatalogView` architecture)

## 2. Replace Empty State Logic

- [x] 2.1 Add a private `EmptyReason` enum inside `catalog_view.rs` with variants `LibraryEmpty` and `NoMatches`
- [x] 2.2 At the top of `render_catalog`, derive `Option<EmptyReason>` from `items.is_empty()` and `total_count`
- [x] 2.3 Replace the existing `if items.is_empty()` branch with a match on `Option<EmptyReason>`

## 3. Implement Distinct Empty State Renderers

- [x] 3.1 Rename the existing `render_empty_state` to `render_no_matches_state(search_query: &str, text_color: gpui::Hsla)` and update its body to show "No titles match." plus the contextual hint ("Try clearing your search." when `search_query` is non-empty, "Try selecting a different section." otherwise)
- [x] 3.2 Add `render_library_empty_state(text_color: gpui::Hsla)` that shows a centered icon and "Your library is empty."
- [x] 3.3 Wire both renderers into the `EmptyReason` match branch in `render_catalog`

## 4. Build and Quality

- [x] 4.1 Run `cargo check --workspace` and fix any compilation errors
- [x] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings

## 5. Manual Verification

- [ ] 5.1 Launch the app with credentials missing or a service error and confirm no crash; verify the loading/error state still appears correctly
- [ ] 5.2 Launch the app with an account that has items; confirm the normal catalog renders
- [ ] 5.3 Type a search query that matches nothing and confirm "No titles match." + "Try clearing your search." appears
- [ ] 5.4 Select a sidebar filter section that has no items (e.g., "On Device" with nothing downloaded) and confirm "No titles match." + "Try selecting a different section." appears
- [ ] 5.5 (If testable) use stub empty mode and confirm "Your library is empty." appears
