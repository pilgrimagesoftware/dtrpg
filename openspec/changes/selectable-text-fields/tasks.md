## 1. Audit Call Sites

- [ ] 1.1 List every `div().child(text)` in `detail_panel_view.rs`, `catalog_view.rs`,
  `settings_account_view.rs`, `settings_advanced_view.rs`, `settings_storage_view.rs`,
  `settings_file_openers_view.rs`, and `alert_history_view.rs`
- [ ] 1.2 Classify each as "data field" (convert) or "structural" (leave as-is)

## 2. Convert Detail Panel

- [ ] 2.1 Replace title, description, publisher, and metadata value renders with `TextView`
- [ ] 2.2 Match existing font size, weight, and color via `TextView` styling props

## 3. Convert Catalog Views

- [ ] 3.1 Replace item title/publisher text in list row, thumb row, and grid card with `TextView`

## 4. Convert Settings and Alerts

- [ ] 4.1 Replace read-only settings values (storage path, account email, API key display) with `TextView`
- [ ] 4.2 Replace alert/error message text in `alert_history_view.rs` with `TextView`

## 5. Build and Verify

- [ ] 5.1 Run `cargo check --workspace`
- [ ] 5.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 5.3 Manually verify selection and copy in detail panel, catalog, settings, and alert views
- [ ] 5.4 Manually verify button labels and headers remain non-selectable
