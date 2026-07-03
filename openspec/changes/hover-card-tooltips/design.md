## Context

Current tooltips in the app are plain strings passed to whatever base tooltip mechanism `gpui`/
`gpui-component` provides (`tooltip_download_first`, `activity_tooltip`, etc. — see `i18n/en.yaml`). Some
of these strings, like `activity_tooltip: "%{in_progress} in progress, %{completed} completed"`, already
pack multiple pieces of information into a single-line string. `HoverCard` gives these a proper layout
(multiple text runs, secondary color/size) instead of concatenating everything into one plain string.

## Goals / Non-Goals

**Goals:**

- The "download this item first" hint on the read button renders with a lighter color / smaller font,
  matching the on-hold note's intent, via `HoverCard`.
- The activity button tooltip shows in-progress/completed counts as visually distinct pieces of
  information rather than one flat sentence.

**Non-Goals:**

- Converting every existing tooltip to `HoverCard` — single-word tooltips stay as they are; only tooltips
  with multi-part or richly styled content are in scope.
- Interactive hover cards (e.g. clickable content inside the card) — content is display-only.

## Decisions

**Use `HoverCard` only where content has more than one visual treatment.**

Rationale: converting every tooltip would add rendering overhead and inconsistency for cases where a
plain tooltip is already sufficient; the bar for conversion is "this tooltip's content benefits from
structured layout," not "this is a tooltip."

**Do the read-button hint interactively, with visual feedback, per the existing on-hold note.**

Rationale: the project notes explicitly flag this item as "(On hold) ... do this one interactively with
visual feedback" — this change proposal exists so the work is tracked, but actual visual tuning (exact
color/size) happens during implementation with live feedback rather than being fully specified upfront.

## Risks / Trade-offs

- `HoverCard` may have different show/hide timing than the base tooltip mechanism — needs a manual check
  that it doesn't feel laggier or flash unexpectedly compared to existing tooltips.
