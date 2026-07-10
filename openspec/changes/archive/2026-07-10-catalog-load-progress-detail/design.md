## Context

`LibraryController::start_load_inner` starts an activity with `a.start(&t!("activity.loading_library"),
None, cx)` and updates its label mid-flight at each phase transition, the same mechanism already used for
thumbnail loading (`a.update_label(id, "Loading thumbnails\u{2026}", cx)`, with a remaining-count suffix).

The actual phase order is collections → optional count-check → library fetch, not count → collections →
library as originally proposed:

1. **Collections** (`activity.loading_library_collections`, "Loading library: getting collections…")
   runs first — always, unconditionally.
2. **Count-check** (`activity.loading_library_count`, "Loading library: getting count of items…") only
   runs on the auto-load fast path, when the on-disk cache is non-empty and fresh (< 7 days old); it
   compares a cheap remote count against the cached item count to decide whether the full fetch can be
   skipped. When the cache is stale, empty, or `force_reload` is set, this phase is skipped entirely.
3. **Library fetch** (`activity.loading_library`, "Loading library…") runs the paginated live fetch,
   reusing the same label the activity started with.

## Goals / Non-Goals

**Goals:**

- Surface which phase of the catalog load is running, using the same activity item (no new items spawned
  per phase).
- Phase labels are localized like all other user-facing strings.

**Non-Goals:**

- Numeric progress bars for the phase itself (that's the separate `activity-button-progress-bar` change).
- Retrying or restructuring the load sequence — this only documents what label is shown while it runs.
- Guaranteeing the count-check phase always fires — it's conditional on the auto-load fast path.

## Decisions

**Call `update_label` at each phase transition, keyed off the existing activity ID returned by `start`.**

Rationale: matches the established pattern (`update_label` already used for thumbnails), avoids
introducing a new activity-item-per-phase model that would clutter the activity panel with items that
complete in milliseconds.

**Label strings live in i18n files, not inline literals.**

Rationale: the codebase's i18n key convention (`tooltip_*`, `*_tooltip`, etc. in `en.yaml`/`fr.yaml`)
means every other user-facing string already goes through this path; catalog load labels are user-facing
text and should not be an exception.

## Risks / Trade-offs

- If a phase completes faster than a render frame, the label flash may not be visible — acceptable, this
  is a best-effort progress indicator, not a guarantee of visibility per phase.
- The count-check phase is conditional (fast-path only), so users won't always see it — acceptable, since
  its absence means the full fetch phase is about to run instead, and that phase has its own label.
- Adding phases later (e.g. a new fetch step) requires remembering to add a label update at that call
  site — no structural enforcement; documented in code comments at each `update_label` call.
