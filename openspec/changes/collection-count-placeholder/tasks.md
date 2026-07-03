## 1. Data Model

- [ ] 1.1 Add a loaded/not-loaded distinction to the collections cache (e.g. `Option<Vec<Collection>>` or
  a `loaded: bool` field alongside the existing `Vec`)
- [ ] 1.2 Update all cache write sites to set the loaded flag on first successful fetch

## 2. Sidebar Rendering

- [ ] 2.1 Update `sidebar_view.rs` collections badge to render `?` when not-yet-loaded
- [ ] 2.2 Update the "All Collections" aggregate count to follow the same rule

## 3. Build and Verify

- [ ] 3.1 Run `cargo check --workspace`
- [ ] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 3.3 Manually verify `?` shows on cold start before collections load
- [ ] 3.4 Manually verify the badge switches to `0` for a user with no collections
- [ ] 3.5 Manually verify the badge switches to the real count for a user with collections
