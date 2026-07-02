# Notes

A place to keep track of things to tell the robot when limits are reached

Prompt for the robot

```
identify changes or create them, work through the list; some items might already be complete; some changes have been completed in the interim, archive if so
```

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
- Fixed: page size control was missing from the pagination area. Added a "N / page"
  dropdown (`render_page_size_selector` in `ui/views/catalog_view.rs`) wired to the
  existing `LibraryController::set_page_size`. The pagination bar now also renders
  whenever the catalog is non-empty (not just when there's more than one page), so the
  selector is reachable even on a single page of results.
- Fixed: pagination "First"/"Last" button labels were hardcoded English strings. Now
  routed through `t!()` with new keys `catalog.pagination_first` / `pagination_last` in
  en/de/fr.
- Fixed: the "About" menu action was a no-op stub. `LibraryRootView` now handles it via
  `window.open_dialog`, showing app name, version (`CARGO_PKG_VERSION`), and a short
  description (new `about.*` i18n keys).
- Added: "Advanced" settings page with a "Clear Cache" button (confirmation via
  `window.open_alert_dialog`, following the existing file-openers-removal pattern).
  `SettingsController::clear_cache` deletes `app_cache_dir()` (catalog/collections cache
  + cached avatar); downloaded content, credentials, and preferences are untouched.
- Added: "About" settings page mirroring the About dialog content, satisfying both
  "About dialog from the app menu" and "About section in Settings" in one implementation
  (`ui/views/settings_advanced_view.rs`).
- Added: "Refresh Thumbnails" item to the Catalog menu (`RefreshThumbnails` action) and a
  per-item "Refresh thumbnail" icon button on the detail panel's cover image. Both reuse
  the existing thumbnail queue (`LibraryController::load_thumbnail` for the single-item
  case, new `refresh_all_thumbnails` for the bulk case) — neither skips already-cached
  items, unlike the normal enqueue path.
- Fixed: the detail view's "Status" field was a plain text row in the metadata table.
  Replaced with a checkmark/cloud icon next to the item title (tooltip carries the same
  text) via `render_status_icon` in `ui/views/detail_panel_view.rs`.
- Fixed: the large "Read"/"Download"/"Reveal" buttons in the detail view are now compact
  icon buttons (`IconName::BookOpen` / `ArrowDown`/`CircleCheck` / `FolderOpen`) with
  tooltips, using the gpui-component `Button::icon()` API instead of full-width labeled
  buttons.
- Fixed: activity panel's bottom-left corner nudged up and right
  (`bottom(px(44))` → `bottom(px(56))`, `left_0()` → `left(px(8))`) in
  `ui/views/activity_panel_view.rs`.
- Added: View menu items for catalog presentation (List/Thumbs/Grid), sort
  (Title/Publisher/Date Added/Pages, Ascending/Descending, Group by Publisher), and a
  "Find in Library" item that focuses the search input — new actions in `ui/actions.rs`
  (`ViewAsList`, `SortByTitle`, `ToggleGroupByPublisher`, `FocusSearch`, etc.), handled in
  `ui/views/root_view.rs`, calling the same `LibraryController` methods the toolbar
  dropdowns already use.
- Confirmed already implemented: a "load thumbnail" button with tooltip exists on the
  detail panel's cover image (`detail-refresh-thumbnail` in `detail_panel_view.rs`); it
  fetches on first load and re-fetches when already cached, so it covers both "load" and
  "refresh" cases with one control.
- Confirmed already implemented: the disabled "Read" button already shows a
  `detail.tooltip_download_first` hint via `Button::tooltip`.
- Fixed (2026-07-02): clicks inside the alert history panel passed through to the
  catalog view underneath — the panel's root `div` was missing `.occlude()` (present on
  the equivalent settings/detail panel overlays but not this one). Added in
  `ui/views/alert_history_view.rs`.
- Fixed (2026-07-02): "Clear Cache" only deleted on-disk cache files;
  `LibraryController`'s in-memory catalog/collections were untouched, so cleared content
  stayed visible until an unrelated reload (and even then wouldn't repopulate cleanly
  since the disk cache it reads from was gone). `SettingsController::clear_cache` now
  emits a `CacheCleared` event; `LibraryController::clear_and_reload` (new) drops the
  in-memory catalog/collections and forces a live re-fetch. This also addresses the
  "Reload disabled after cache clear" report — the menu item was never actually disabled
  by app code, but reload after a cache clear previously reloaded from a now-missing
  cache file into a catalog that had never been cleared, which likely read as "stuck".
- Fixed (2026-07-02): View menu's presentation and sort items were a single flat list.
  Grouped into "Presentation" (List/Thumbs/Grid) and "Sort" (Title/Publisher/Date
  Added/Pages, Ascending/Descending, Group by Publisher) submenus via
  `MenuItem::submenu` in `ui/app/mod.rs`, with matching en/de/fr label updates.
- Fixed (2026-07-02): table coloring in the ungrouped list view didn't match the app —
  the catalog `DataTable` reads its row/header/stripe colors from
  `cx.theme()` (`gpui_component::Theme`), a separate global from `LibriTheme` that was
  never synced with the active Libri palette, so the table always rendered with
  `gpui-component`'s default light colors regardless of theme (most visibly wrong on the
  dark "Ink" theme). Added `apply_table_colors` in `data/theme.rs`, which overrides just
  the `table*` fields on both `Theme.colors` and `Theme.tokens` (the latter is what
  `DataTable` actually reads) from the active `ColorTokens`. Called at startup
  (`ui/app/mod.rs::setup`) and whenever the user switches themes
  (`LibraryController::set_theme`). The grouped list view was already correct — it
  hand-rolls rows directly from `ColorTokens`, unrelated to this global.

## Known API limitation (not a bug)

- Page count in detail view always shows 0 — the DriveThruRPG order-product API does not
  return a page count field at all (`OrderProductAttributes` has no such field). Not
  fixable without a different endpoint or a PDF-parsing fallback.

## Still open

- Catalog items may bleed off the right edge instead of reflowing — grid uses `flex_wrap`
  already; needs visual re-verification against current layout before treating as a bug.
- Localizations still missing: autofill/dictation/emoji menu items (OS-provided, may not
  be controllable), "Updated <date>" label wording in detail view.
- Grouped list view does not use `DataTable` — confirmed: `catalog_view.rs`'s
  `(CatalogPresentation::List, true)` branch still hand-rolls
  `render_group_header`/`render_grouped_list_header`/`render_grouped_list_row` instead of
  the virtualized `DataTable` used by the ungrouped branch. Likely cause of laggy
  scrolling. Candidate changes: `gpui-component-view-rework` (26/32),
  `catalog-virtualized-rendering` (23/29) — check scope before creating a new change.
  This is the largest remaining item — a real refactor, not a small fix.
- If a catalog item's kind is a "badge" type, render as icon + tooltip; otherwise render
  as a plain text label in a separate column — not verified against current
  `render_grid`/list row rendering; needs investigation.
- Visually separate the titlebar area and position the app title/controls within it —
  `ui-layout-fixes` change shows 8/8 tasks done; verify visually whether this specific
  item was in scope, otherwise needs a new change.
- Rich-text tooltip for the read button's "download this item first" hint (lighter
  color, smaller font) — not straightforward: `gpui-component`'s `Button::tooltip` only
  accepts a plain `SharedString`, not a `Tooltip::element` builder. Achieving styled text
  would mean dropping `Button` for this control and hand-rolling a div with its own
  click/hover/disabled states plus a custom tooltip, which risks losing the existing
  disabled-state styling without a way to visually verify the result here. Left open;
  do this one interactively with visual feedback rather than blind.
- Make all text fields' content selectable and copyable — not verified against current
  `Input`/`InputState` usage; needs investigation into whether `gpui-component`'s input
  widgets already support selection or need an explicit flag.
- Cache clear should cancel in-progress thumbnail loads and catalog loading.
- Add sub-progress text to catalog load activity item message:
  - "Getting count of items"
  - "Loading collections"
  - "Loading library"
  - Etc.
- Put a question mark "?" for the collection count until it's known (e.g. after "Loading collections")
- Thumb view item rows should extend full width of the table, not just the text content
- List view table header text should be vertically centered in the header cell
- Presentation, Sort, and Find in Library menu items or submenu items are all disabled when they should not be
- If there is no page information, or it doesn't make sense for the type of item, don't show it in the detail view
