## Why

Users have no way to see the shape of their library at a glance — how many items per publisher, how items
are distributed across collections, or the split between document types (PDF, ebook, etc.). Simple charts
turn the existing catalog metadata into a quick visual summary.

## What Changes

- Add a library analytics view (accessible from the sidebar or a menu item) showing three charts:
  - **Publishers**: item count per publisher (bar chart).
  - **Collection counts**: item count per collection (bar chart).
  - **Document types**: distribution of item kinds, e.g. PDF/ebook/etc. (pie or bar chart).
- Charts derive entirely from data already loaded into the catalog/collections caches — no new API calls.
- Charts update when the underlying catalog or collections data changes (no manual refresh required).

## Capabilities

### New Capabilities

- `library-analytics-charts`: A library analytics view renders publisher, collection-count, and
  document-type charts derived from existing catalog and collections data.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/`: new `library_analytics_view.rs`.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/sidebar_view.rs` or `tab_strip_view.rs`: navigation entry
  point to the new view.
- Charting: no charting library is currently a dependency — this change either adds one (evaluate a
  `gpui`-compatible option) or hand-rolls simple bar/pie rendering with `gpui` primitives; decision
  recorded in `design.md`.
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/library_data.rs` and `data/collection.rs`: read-only
  aggregation, no shape changes expected.
