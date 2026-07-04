## Why

The detail view currently stacks the cover thumbnail above the item's information (`flex_col`, centered
cover in a `py(16.0)` band, then info below). A side-by-side layout — thumbnail on the left, information
on the right — is a more conventional catalog-detail layout and makes better use of horizontal space on
typical desktop window widths.

## What Changes

- Change `render_detail_tab_content`'s top-level layout from a vertical stack (cover above info) to a
  horizontal split (cover on the left, info panel on the right).
- The cover keeps its current fixed aspect ratio and refresh-thumbnail overlay button.
- The info panel (publisher, title, status icon, line, description, and remaining fields/actions) keeps
  its existing internal vertical layout and scroll behavior, just repositioned to the right column.

## Capabilities

### New Capabilities

- `detail-view-thumbnail-layout`: The detail view's top-level layout places the cover thumbnail on the
  left and the item information panel on the right.

### Modified Capabilities

<!-- none -->

Note: no existing spec in `openspec/specs/` currently governs detail-panel layout, so this is a new
capability rather than a modification. Check the open `detail-panel-layered-sidebar` and
`multi-item-catalog-entry-detail` changes for overlap before implementing, since both touch detail-panel
layout and may land first.

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/detail_panel_view.rs`: `render_detail_tab_content`
  top-level `div()` changes from `.flex_col()` with a cover block then info block, to `.flex()` (row) with
  a fixed-width cover column and a flexible info column.
- Check `detail-panel-layered-sidebar` and `multi-item-catalog-entry-detail` open changes for overlap
  before implementing, since both touch detail-panel layout.
