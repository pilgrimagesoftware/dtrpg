## Context

`ActivityItem` already carries `progress: Option<f32>` in `[0.0, 1.0]`, with `None` meaning indeterminate.
No aggregation across items exists today — the activity button only surfaces `in_progress_count` via
`ActivitySnapshot`. `gpui-component` provides a `ProgressCircle` widget usable for both determinate and
indeterminate display.

## Goals / Non-Goals

**Goals:**

- The activity button shows a `Progress` bar summarizing all currently in-progress activities when at
  least one exists.
- Falls back to the current icon-only appearance when nothing is in progress.

**Non-Goals:**

- Per-activity progress bars in the activity panel list (this change is button-level, aggregate only).
- Precise time-remaining estimates — only a progress fraction, not an ETA.

## Decisions

**Aggregate progress = mean of known (`Some`) progress values among in-progress items; indeterminate mode
if any in-progress item has `progress: None` and no items have `Some`.**

Rationale: a straightforward, easy-to-reason-about aggregate. Mixed known/unknown progress is common
(e.g. thumbnail loading reports progress, catalog loading in `catalog-load-progress-detail` does not) —
averaging only the known values gives a reasonable approximation without overcomplicating the aggregate
with weighting logic.

**Use `gpui-component`'s `ProgressCircle` widget in indeterminate mode when no in-progress item reports a
known progress value.**

Rationale: `ProgressCircle` already supports both modes; falling back to indeterminate avoids showing a
misleading fixed fraction (e.g. always 0%) when no item tracks real progress. A circular indicator was
chosen over the linear `Progress` bar to fit compactly alongside the button's existing glyph and count
label in the status bar row.

## Risks / Trade-offs

- A simple mean across in-progress items can be misleading if one long-running item and one near-instant
  item are both active (the near-instant one skews the average briefly) — acceptable for an at-a-glance
  indicator, not a precise readout.
- If most activities never set `progress`, the button will render as indeterminate most of the time,
  reducing the visual value of this change until more call sites set progress. Not a blocker, but worth
  noting as a follow-up opportunity.
