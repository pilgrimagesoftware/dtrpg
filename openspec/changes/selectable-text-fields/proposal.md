## Why

Users cannot select or copy text out of most fields in the Rust app (item titles, descriptions, publisher
names, metadata values, error messages). Every value renders as a plain `gpui` `div().child(text)`, which
`gpui` does not make selectable by default. Users routinely want to copy a title, an order ID, or an error
message into a bug report or a search box.

## What Changes

- Replace plain-text `div` renders of user-facing field content with `gpui-component`'s `TextView` (or the
  equivalent selectable text primitive it exposes) wherever the content is a value a user would plausibly
  want to copy: detail panel fields, catalog item titles, publisher names, settings values, error/alert
  messages.
- Leave purely decorative or structural text (button labels, section headers, icons-with-text) as plain
  `div` renders — only user data fields become selectable.

## Capabilities

### New Capabilities

- `selectable-text-fields`: User-facing data fields in the Rust app render as selectable, copyable text via
  `gpui-component`'s `TextView`.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/detail_panel_view.rs`: field value rendering.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: item title/publisher text in list, thumb,
  and grid layouts.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/settings_*.rs`: read-only settings values.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/alert_history_view.rs`: alert/error messages.
- No new dependencies — `gpui-component` is already a workspace dependency.
