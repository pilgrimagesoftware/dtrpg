## Why

The catalog view currently shows "No titles match." for any empty result set, regardless of why it is empty. A user who has just signed in to an empty library sees the same message as a user who applied a filter that matched nothing — two very different situations that warrant different copy and guidance.

## What Changes

- Add a `CatalogEmptyReason` enum with variants for the distinct empty states: `LibraryEmpty`, `NoMatches`, and `Loading` (already handled separately, but made explicit).
- Pass `total_count` (unfiltered catalog size) alongside `items` into `render_catalog` so it can derive the reason.
- Replace the single `render_empty_state` function with two distinct renderings:
  - **Library empty**: icon + "Your library is empty." message (shown when the catalog itself has no items).
  - **No matches**: icon + "No titles match." message + contextual hint to clear the search or change the filter.

## Capabilities

### New Capabilities

- `catalog-empty-states`: Two distinct empty-state renderings in the catalog view — one for an empty library and one for a filter/search that yields no results — with appropriate copy and actionable hints.

### Modified Capabilities

## Impact

- `dtrpg-ui/src/ui/views/catalog_view.rs`: replace single `render_empty_state` with two variants; `render_catalog` gains a `total_count: usize` parameter.
- `dtrpg-ui/src/ui/views/root_view.rs`: pass `snap.total_count` to `render_catalog`.
- No changes to the service layer, SDK, or API contract.
