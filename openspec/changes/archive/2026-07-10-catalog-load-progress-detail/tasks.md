## 1. i18n Strings

- [x] 1.1 Confirmed existing `activity.loading_library_collections` and `activity.loading_library_count`
  keys in `en.yaml` (and other locale files) already cover the collections and count-check phases;
  `activity.loading_library` covers the library-fetch phase. No new keys needed — see updated
  proposal.md/design.md for the reconciled phase order.

## 2. Controller Updates

- [x] 2.1 Located the collections-fetch, count-check, and library-fetch call sites in
  `controllers/library.rs::start_load_inner`
- [x] 2.2 Confirmed `a.update_label(activity_id, t!("activity.loading_library_count"), cx)` is called at
  the start of the fast-path count check
- [x] 2.3 Confirmed `a.update_label(activity_id, t!("activity.loading_library_collections"), cx)` is
  called at the start of the collections fetch
- [x] 2.4 Confirmed `a.update_label(activity_id, t!("activity.loading_library"), cx)` is called at the
  start of the library fetch

## 3. Build and Verify

- [x] 3.1 Run `cargo check --workspace`
- [x] 3.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [x] 3.3 Manually trigger a catalog load and confirm the activity label updates through each phase
