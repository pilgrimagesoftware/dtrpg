# Notes

A place to keep track of things to tell the robot when limits are reached

Last triaged 2026-07-02 against `dtrpg-app/rust` source + openspec. Items confirmed
implemented were removed; remaining items are unresolved and annotated with the
relevant openspec change (if one already exists) or a note on why no change exists yet.

## Resolved (verified in code, removed from active list)

- Catalog automatic load logic (fresh-cache skip / staleness / count-mismatch) — implemented
  in `controllers/library.rs`; matches `openspec/specs/catalog-auto-load-policy`.
- "Window" menu Show Activity / Show Alert History — implemented in `ui/app/mod.rs` and
  `ui/views/root_view.rs`; matches `openspec/specs/window-menu`.
- Account view (Settings) and Avatar menu user info — both render `auth.email`, and
  `email_draft` is restored from `ProfileConfig::load()` at startup so re-auth on launch
  populates it correctly (`controllers/settings.rs`).
- Detail view close button — implemented in `ui/views/detail_panel_view.rs`; matches
  archived change `2026-07-02-detail-panel-close-button-visibility`.
- Alert history view — implemented (`ui/views/alert_history_view.rs`,
  `controllers/activity.rs`, `data/activity.rs`); change `alert-history-view` is 20/21
  tasks done, remaining task is likely polish only.
- Localizations for "Collections", "Collection", "X items"/"X titles" (via `pluralize`),
  and "Search…" placeholder are all present in `i18n/en.yaml` (and de/fr).
- App creates the download path if missing — `StorageConfig::ensure_root_exists` /
  `reveal_storage_location` both call `create_dir_all`.
- "Pre-existing docset failure" — this was a doctest failure in `credentials/mod.rs`
  mentioned in several old change `tasks.md` files as "pre-existing and unrelated".
  `cargo test --doc -p dtrpg-ui` now passes clean (4/4). No longer an issue.
- Fixed: "format" field in the detail view was using the API file's `title` (a display
  name, not a format type) instead of deriving from the file extension. Fixed in
  `dtrpg-core/src/services/sdk.rs` (`file_extension_label`), with regression tests
  `map_order_product_derives_format_from_file_extension_not_title` and
  `map_order_product_joins_multiple_distinct_extensions`.

## Known API limitation (not a bug)

- Page count in detail view always shows 0 — the DriveThruRPG order-product API does not
  return a page count field at all (`OrderProductAttributes` has no such field). Not
  fixable without a different endpoint or a PDF-parsing fallback.

## Still open

- The page size control is missing from the pagination area (`ui/views/catalog_view.rs`
  only renders First/Pagination/Last — no per-page selector). No existing openspec change.
- Pagination "First"/"Last" button labels are hardcoded English strings, not run through
  `t!()` — localization gap.
- Catalog items may bleed off the right edge instead of reflowing — grid uses `flex_wrap`
  already; needs visual re-verification against current layout before treating as a bug.
- Localizations still missing: autofill/dictation/emoji menu items (OS-provided, may not
  be controllable), "Updated <date>" label wording in detail view.
- Add a "Refresh thumbnails" item to the Catalog menu — not present in
  `openspec/specs/catalog-menu` or the app menu. No existing change; needs one.
- Add a "Refresh thumbnail" button to the detail view — not found in
  `ui/views/detail_panel_view.rs`. No existing change; needs one.
- Move the bottom-left corner of the activity view up and to the right slightly —
  cosmetic; change `activity-panel-improvements` (18/25 done) may already cover related
  layout work — check before creating a new change.
- Remove the "status" data in the detail view and replace with an icon next to the item
  title — currently rendered as a text field (`detail.field_status`); no existing change.
- Replace the large "Read" and "Download" buttons with icon buttons (with tooltips) — see
  `detail-read-button-state` (6/8 done) and `file-openers-button-ux` (11/14 done); check
  whether either already covers this before creating a new change.
- Add a "Clear cache" item to Settings in a new "Advanced" section — not found anywhere
  in `crates/dtrpg-ui/src`. No existing change; needs one.
- Add an About dialog from the application menu — the `About` action exists in the menu
  bar but its handler is a no-op stub (`cx.on_action::<About>(|_, _cx| {})` in
  `ui/app/mod.rs`). No existing change; needs one.
- Add an "About" section to the Settings view — not found. No existing change.
- Grouped list view does not use `DataTable` — confirmed: `catalog_view.rs`'s
  `(CatalogPresentation::List, true)` branch still hand-rolls
  `render_group_header`/`render_grouped_list_header`/`render_grouped_list_row` instead of
  the virtualized `DataTable` used by the ungrouped branch. Likely cause of laggy
  scrolling. Candidate changes: `gpui-component-view-rework` (26/32),
  `catalog-virtualized-rendering` (23/29) — check scope before creating a new change.
- Add menu items for: selecting catalog view mode, sorting (attribute,
  ascending/descending, group by publisher), and search — confirmed absent from
  `ui/app/mod.rs`; these currently only exist as toolbar controls. No existing change.
- Table coloring for list view should match surrounding area — needs visual check;
  `catalog-list-column-alignment` (19/21 done) may be adjacent but is about alignment,
  not color.
- If a catalog item's kind is a "badge" type, render as icon + tooltip; otherwise render
  as a plain text label in a separate column — not verified against current
  `render_grid`/list row rendering; needs investigation.
- Visually separate the titlebar area and position the app title/controls within it —
  `ui-layout-fixes` change shows 8/8 tasks done; verify visually whether this specific
  item was in scope, otherwise needs a new change.
