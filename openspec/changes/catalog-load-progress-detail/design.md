## Context

`LibraryController` already starts an activity with `a.start("Loading catalog\u{2026}", None, cx)` and
updates its label mid-flight for thumbnail loading (`a.update_label(id, "Loading thumbnails\u{2026}", cx)`,
with a remaining-count suffix). The catalog load sequence itself (count → collections → library) currently
keeps the same static label the whole time.

## Goals / Non-Goals

**Goals:**

- Surface which phase of the catalog load is running, using the same activity item (no new items spawned
  per phase).
- Phase labels are localized like all other user-facing strings.

**Non-Goals:**

- Numeric progress bars for the phase itself (that's the separate `activity-button-progress-bar` change).
- Retrying or restructuring the load sequence — this only changes what label is shown while it runs.

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
- Adding phases later (e.g. a new fetch step) requires remembering to add a label update at that call
  site — no structural enforcement; documented in code comments at each `update_label` call.
