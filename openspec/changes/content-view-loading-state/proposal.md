## Why

List and other content views currently render either their final content or an empty/default state while
data is loading, with no visual distinction between "empty" and "loading." Adopting `gpui-component`'s
built-in "loading" capability on these views gives users a consistent loading indicator across the app
instead of a blank or misleading empty state.

## What Changes

- Apply the loading capability already available on `gpui-component` list/content view primitives to the
  catalog list view and any other content view that currently has no loading indicator (settings panels
  pulling remote data, alert history, etc.).
- Views show the loading indicator while their backing data has not yet completed its first load, and
  switch to normal content (including genuine empty states, see `catalog-empty-states`) once loaded.

## Capabilities

### New Capabilities

- `content-view-loading-state`: List and content views display a loading indicator while their backing
  data is loading, distinct from a genuinely empty result.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: primary list/grid content view.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/alert_history_view.rs`: list content.
- Overlaps with `collection-count-placeholder` (sidebar-specific) and `catalog-empty-states` (existing
  change) — this change is scoped to the loading indicator itself, not empty-state copy or the sidebar
  count badge.
