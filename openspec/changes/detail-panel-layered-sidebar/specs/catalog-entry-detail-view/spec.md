## ADDED Requirements

### Requirement: Item detail overlay occupies the right portion of the detail panel column
When an item is selected from a multi-item catalog entry's item list, the item detail overlay SHALL be positioned within the detail panel column such that a visible strip of the multi-item base layer remains exposed on the left side. The overlay SHALL NOT extend beyond the detail panel column boundary into the catalog view.

#### Scenario: Overlay leaves base layer strip visible
- **WHEN** the item detail overlay is shown within a 320 px detail panel column
- **THEN** the overlay occupies no more than approximately 80% of the column width, leaving a minimum 60 px strip of the base layer visible on the left

#### Scenario: Overlay is constrained to the detail panel column
- **WHEN** the item detail overlay is shown
- **THEN** the overlay does not overlap the catalog list or grid area; it is contained entirely within the detail panel column

### Requirement: The visible base layer strip is interactive while the overlay is shown
The strip of the multi-item base layer that remains visible while the item detail overlay is shown SHALL be fully interactive. Clicks or taps on the visible strip SHALL dismiss the item overlay and SHALL allow item selection within the base layer without a second click.

#### Scenario: Click on visible strip dismisses overlay and re-selects item
- **WHEN** the item detail overlay is visible and the user clicks an item row in the visible base layer strip
- **THEN** the item detail overlay is dismissed, the clicked item becomes the new item-within-entry selection, and the item detail overlay re-appears for the newly selected item in a single interaction

#### Scenario: Click on non-item area of visible strip dismisses overlay only
- **WHEN** the item detail overlay is visible and the user clicks a non-interactive area of the visible base layer strip (e.g., the entry title or cover art area)
- **THEN** the item detail overlay is dismissed; the item-within-entry selection is cleared; the base layer is shown fully

### Requirement: Item detail overlay appears and disappears without full panel teardown
The item detail overlay SHALL appear and disappear via a visual transition (slide or fade) that does not rebuild the multi-item base layer view from scratch. The base layer's scroll position and item list state SHALL be preserved across overlay show/hide cycles.

#### Scenario: Base layer scroll position is preserved when overlay is dismissed
- **WHEN** the user has scrolled the item list in the base layer and then opens and closes the item detail overlay
- **THEN** the item list returns to the same scroll position it had before the overlay opened

#### Scenario: Overlay appears without layout reflow in the base layer
- **WHEN** an item is selected and the overlay slides in
- **THEN** the base layer's layout does not reflow or re-render from scratch; only the overlay layer is added on top
