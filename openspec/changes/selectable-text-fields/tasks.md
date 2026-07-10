## 1. Audit Call Sites

- [x] 1.1 List every `div().child(text)` in `detail_panel_view.rs`, `catalog_view.rs`,
  `settings_account_view.rs`, `settings_advanced_view.rs`, `settings_storage_view.rs`,
  `settings_file_openers_view.rs`, and `alert_history_view.rs`
- [x] 1.2 Classify each as "data field" (convert) or "structural" (leave as-is)

## 2. Convert Detail Panel

- [x] 2.1 Replace title, description, publisher, and metadata value renders with `TextView`
- [x] 2.2 Match existing font size, weight, and color via `TextView` styling props

## 3. Convert Catalog Views

- [x] 3.1 Replace item title/publisher text in list row, thumb row, and grid card with `TextView`
  — **reverted**: caused a regression where native menu items (Settings, catalog menu,
  Find in Library, Show Activity, Show Alert History) went permanently disabled. Root
  cause: `TextView.selectable(true)` grabs keyboard focus on click; the affected menu
  actions are all bound via `on_action` on `root_view.rs`'s root div, whose availability
  is resolved by walking up from the *currently focused* dispatch node. Catalog rows are
  virtualized (`DataTable`/`uniform_list`), so a title's `TextView` can hold focus after
  its row scrolls out of the rendered frame; GPUI then can't resolve the stale focus
  handle and falls back to the window's absolute root, above `root_view`'s own div —
  orphaning every `on_action` bound there. Left as plain `div` pending a non-virtualized
  approach (e.g. context-menu copy instead of drag-select) in a follow-up change.

## 4. Convert Settings and Alerts

- [x] 4.1 Replace read-only settings values (storage path, account email, API key display) with `TextView`
- [x] 4.2 Replace alert/error message text in `alert_history_view.rs` with `TextView`

## 5. Build and Verify

- [x] 5.1 Run `cargo check --workspace`
- [x] 5.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 5.3 Manually verify selection and copy in detail panel, catalog, settings, and alert views
- [ ] 5.4 Manually verify button labels and headers remain non-selectable
