## Context

`render_detail_tab_content` currently builds a `.flex_col()` root: first child is a centered cover block
(`w_full().flex().flex_none().justify_center().py(px(16.0))`), second child is the scrollable info panel
(`flex_1().min_h_0().flex().flex_col()` containing publisher, title, status icon, line, description, and
further fields/actions below). The cover itself has a fixed size derived from
`DETAIL_PANEL_COVER_MAX_WIDTH * 1.5` with a `10:7` aspect ratio.

## Goals / Non-Goals

**Goals:**

- Cover renders in a fixed-width left column; info panel fills the remaining width on the right.
- Cover's refresh-thumbnail overlay button and aspect ratio are unchanged.
- Info panel's internal vertical layout, scrolling, and field order are unchanged — only its position
  within the parent shifts from below to beside the cover.

**Non-Goals:**

- Resizing or re-deriving `DETAIL_PANEL_COVER_MAX_WIDTH` — the constant and its `1.5x` multiplier stay as
  they are.
- Responsive behavior for narrow windows (e.g. collapsing back to stacked below some width threshold) —
  out of scope unless it turns out visually broken at the app's minimum window width, in which case it
  becomes a follow-up.

## Decisions

**Root layout changes from `.flex_col()` to `.flex()` (row), with the cover column at `.flex_none()` fixed
width and the info column at `.flex_1()`.**

Rationale: minimal change — swaps the axis and drops the `justify_center()`/`py(16.0)` centering (no longer
needed once the cover is a fixed-width column rather than a centered block above full-width content),
while reusing the existing cover and info sub-trees unchanged internally.

**Cover column keeps a `py`/`px` padding to match existing visual breathing room, adjusted for the new
row context.**

Rationale: the current `py(px(16.0))` was there to separate the cover from the info below; in a row
layout the equivalent spacing is a right margin/padding on the cover column, not top/bottom padding.

## Risks / Trade-offs

- At narrow window widths, a fixed-width cover column plus text-heavy info column may feel cramped —
  verify visually against the app's minimum supported window width before considering this complete.
- Overlaps with `detail-panel-layered-sidebar` and `multi-item-catalog-entry-detail`, both open changes
  touching the same file — sequence this change relative to those to avoid rebase conflicts.
