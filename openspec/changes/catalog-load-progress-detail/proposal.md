## Why

The catalog load activity item currently shows a single static label ("Loading catalog…") for the entire
multi-step load sequence (item count, collections, library data). Users have no visibility into which
step is running or whether the app is stuck, especially on slow connections or large libraries.

## What Changes

- Update the catalog load's activity item label as the load progresses through its known phases:
  - "Loading library: getting collections…" while the collections fetch runs
  - "Loading library: getting count of items…" during the fast-path count check (only reached when
    the on-disk cache is fresh and a live count comparison decides whether a full re-fetch is needed)
  - "Loading library…" while the paginated item fetch runs
- Each phase updates the existing `ActivityItem` label in place (same activity item, not a new one per
  phase) via the existing `update_label` mechanism already used for thumbnail loading progress.
- This was already implemented as part of the `catalog-live-merge` / auto-load-policy work in
  `LibraryController::start_load_inner`, using the `activity.loading_library*` i18n keys. This change
  formalizes it as a documented capability rather than adding new behavior.

## Capabilities

### New Capabilities

- `catalog-load-progress-detail`: The catalog load activity item shows a phase-specific label that
  updates as the load sequence advances through its known phases (collections, optional count-check,
  library fetch).

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/controllers/library.rs`: catalog load sequence (`start`,
  `update_label` calls around collections fetch, count-check fast path, and library fetch).
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/activity.rs`: no data model change — reuses `ActivityItem`
  label field.
- `dtrpg-app/rust/crates/dtrpg-ui/i18n/en.yaml` (and other locales): existing `activity.loading_library`,
  `activity.loading_library_collections`, `activity.loading_library_count` keys.
