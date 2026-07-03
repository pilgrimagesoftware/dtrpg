## Why

The sidebar shows a collection count of `0` while collections are still loading, which reads as "you have
no collections" rather than "still loading." A placeholder distinguishes "not yet known" from "known to be
zero."

## What Changes

- Sidebar collection count badge (and the "All Collections" aggregate count) shows `?` instead of `0`
  until the collections load has completed at least once for the current session.
- Once collections finish loading, the badge switches to the real numeric count, including `0` if the
  user genuinely has no collections.

## Capabilities

### New Capabilities

- `collection-count-placeholder`: The sidebar collection count renders `?` while the count is unknown
  (collections not yet loaded) and the real number once loaded.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/sidebar_view.rs`: `collections_count` and the
  `SectionCounts`-driven badges.
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/collections_cache.rs` or
  `dtrpg-app/rust/crates/dtrpg-ui/src/services/collections.rs`: needs a loaded/not-yet-loaded state
  distinct from an empty `Vec`.
