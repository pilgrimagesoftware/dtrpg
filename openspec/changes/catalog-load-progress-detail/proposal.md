## Why

The catalog load activity item currently shows a single static label ("Loading catalog…") for the entire
multi-step load sequence (item count, collections, library data). Users have no visibility into which
step is running or whether the app is stuck, especially on slow connections or large libraries.

## What Changes

- Update the catalog load's activity item label as the load progresses through its known steps, e.g.:
  - "Getting count of items"
  - "Loading collections"
  - "Loading library"
- Each step updates the existing `ActivityItem` label in place (same activity item, not a new one per
  step) via the existing `update_label` mechanism already used for thumbnail loading progress.

## Capabilities

### New Capabilities

- `catalog-load-progress-detail`: The catalog load activity item shows a step-specific label that updates
  as the load sequence advances through its known phases.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/controllers/library.rs`: catalog load sequence (`start`,
  `update_label` calls around item-count fetch, collections fetch, and library fetch).
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/activity.rs`: no data model change expected — reuses
  `ActivityItem` label field.
- `dtrpg-app/rust/crates/dtrpg-ui/i18n/en.yaml` (and other locales): new label strings.
