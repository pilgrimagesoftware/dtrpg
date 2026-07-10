# catalog-load-progress-detail Specification

## Purpose
TBD - created by archiving change catalog-load-progress-detail. Update Purpose after archive.
## Requirements
### Requirement: Catalog load activity label reflects current phase

The catalog load activity item SHALL update its label as the load sequence advances through its known
phases, using a single activity item updated in place rather than one item per phase.

#### Scenario: Collections phase

- **WHEN** the catalog load begins fetching collections
- **THEN** the activity item label SHALL read "Loading library: getting collections…"

#### Scenario: Count-check phase (auto-load fast path only)

- **WHEN** the catalog load's cache is non-empty and fresh, and it begins the remote count check to
  decide whether a full re-fetch is needed
- **THEN** the activity item label SHALL read "Loading library: getting count of items…"
- **AND** this phase SHALL be skipped (not shown) when the cache is empty, stale, or `force_reload` is
  set — the load proceeds directly to the library fetch phase in that case

#### Scenario: Library fetch phase

- **WHEN** the catalog load begins the paginated live item fetch
- **THEN** the activity item label SHALL read "Loading library…"

#### Scenario: Single activity item throughout

- **WHEN** the catalog load transitions between phases
- **THEN** the same `ActivityItem` SHALL be updated via `update_label` rather than a new activity item
  being created per phase

