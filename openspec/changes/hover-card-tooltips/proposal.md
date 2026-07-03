## Why

Existing tooltips (e.g. `tooltip_download_first`, `activity_tooltip`) render as plain single-line text.
Several of these would communicate better as richer content — for example, the "download this item
first" hint benefits from a lighter color and smaller font, and the activity tooltip could show a
per-activity breakdown instead of a single summary line. `gpui-component`'s `HoverCard` supports this
richer content.

## What Changes

- Replace plain-text tooltips that carry more than a single short label with `gpui-component`'s
  `HoverCard` where richer formatting (multi-line, secondary text styling, structured content) improves
  clarity.
- Candidates: the read button's "download this item first" hint (explicitly called out as on-hold in
  project notes), and the activity button's tooltip breakdown.
- Simple, single-word tooltips (e.g. "Settings", "Search") remain plain tooltips — `HoverCard` is reserved
  for tooltips with more than one visual treatment or piece of information.

## Capabilities

### New Capabilities

- `hover-card-tooltips`: Multi-part or richly styled tooltips render via `gpui-component`'s `HoverCard`
  instead of plain single-style tooltip text.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/detail_panel_view.rs` (or wherever the read button lives):
  "download this item first" hint.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/status_bar_view.rs` or `activity_panel_view.rs`: activity
  button tooltip.
- No new dependencies — `gpui-component` already provides `HoverCard`.
