## ADDED Requirements

### Requirement: Download-first hint renders as a rich tooltip

The read button's "download this item first" hint SHALL render via `HoverCard` with a lighter color and
smaller font than the primary tooltip text.

#### Scenario: Hovering the read button on an undownloaded item

- **WHEN** the user hovers the read button of an item that has not been downloaded
- **THEN** a `HoverCard` SHALL appear showing the "download this item first" hint in a lighter color and
  smaller font than standard body text

### Requirement: Activity tooltip shows structured progress breakdown

The activity button's tooltip SHALL render its in-progress and completed counts as visually distinct
pieces of content via `HoverCard`, rather than a single flat sentence.

#### Scenario: Hovering the activity button

- **WHEN** the user hovers the activity button while activities are in progress
- **THEN** a `HoverCard` SHALL appear showing the in-progress count and completed count as separate,
  visually distinguishable lines or segments

### Requirement: Simple tooltips remain unchanged

Tooltips consisting of a single short label SHALL continue to render via the existing plain tooltip
mechanism, not `HoverCard`.

#### Scenario: Hovering a simple icon button

- **WHEN** the user hovers a button with a single-word tooltip (e.g. "Settings", "Search")
- **THEN** the existing plain tooltip SHALL render, unaffected by this change
