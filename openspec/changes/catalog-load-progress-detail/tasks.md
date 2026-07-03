## 1. i18n Strings

- [ ] 1.1 Add `catalog_load_getting_count`, `catalog_load_collections`, `catalog_load_library` keys to
  `en.yaml` and all other locale files

## 2. Controller Updates

- [ ] 2.1 Locate the count-fetch, collections-fetch, and library-fetch call sites in
  `controllers/library.rs`
- [ ] 2.2 Call `a.update_label(id, t!("catalog_load_getting_count"), cx)` at the start of the count fetch
- [ ] 2.3 Call `a.update_label(id, t!("catalog_load_collections"), cx)` at the start of the collections
  fetch
- [ ] 2.4 Call `a.update_label(id, t!("catalog_load_library"), cx)` at the start of the library fetch

## 3. Build and Verify

- [ ] 3.1 Run `cargo check --workspace`
- [ ] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 3.3 Manually trigger a catalog load and confirm the activity label updates through each phase
