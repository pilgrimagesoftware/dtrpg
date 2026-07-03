## Why

The catalog list view renders a flat list of items with no grouping. Grouping by publisher, using
`gpui-component`'s section-header list capability, makes large libraries easier to scan — matching the
sidebar's existing per-publisher navigation entries.

## What Changes

- Add a "group by publisher" mode to the catalog list view using `gpui-component`'s list "sections"
  capability: each publisher renders as a section header followed by its items.
- Section grouping applies to the list layout; grid and thumb layouts are unaffected by this change.
- Sections respect the current sort order within each publisher group.

## Capabilities

### New Capabilities

- `catalog-publisher-sections`: The catalog list view can group items into publisher sections using
  `gpui-component`'s list sections capability.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: list rendering path — note the existing
  project feedback that the grouped list view currently hand-rolls its own rows instead of using the
  virtualized `DataTable` used by the ungrouped branch; this change should route through the same
  `DataTable`-based rendering with sections rather than perpetuating the hand-rolled path.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/toolbar_view.rs`: a toggle or sort-adjacent control to
  enable publisher grouping.
- `dtrpg-app/rust/crates/dtrpg-ui/src/sort.rs`: sort order must compose with section grouping.
