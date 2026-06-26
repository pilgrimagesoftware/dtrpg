## ADDED Requirements

### Requirement: Selection is a two-level state machine
The application SHALL model detail panel selection as two independent levels: a **catalog entry selection** (first level) and an **item-within-entry selection** (second level). The item-within-entry level SHALL only be applicable when the selected catalog entry contains more than one item. Selecting a catalog entry SHALL always replace any previous selection at either level.

#### Scenario: Selecting a catalog entry clears any prior item selection
- **WHEN** an item-within-entry is selected and the user selects a different catalog entry from the catalog view
- **THEN** the new catalog entry becomes the first-level selection, the prior item-within-entry selection is cleared, and the appropriate detail layer for the new entry is shown

#### Scenario: Second-level selection requires a first-level selection
- **WHEN** no catalog entry is selected
- **THEN** no item-within-entry selection is possible and the detail panel shows nothing

#### Scenario: First-level selection persists while second-level changes
- **WHEN** the user selects a different item within the same multi-item catalog entry
- **THEN** the catalog entry (first-level) selection is unchanged; only the item overlay updates

### Requirement: Single-item catalog entry shows item detail directly
When the selected catalog entry contains exactly one item, the application SHALL display the item detail view as the sole content of the detail panel. No item list or selection affordance SHALL be shown.

#### Scenario: Single-item entry opens item detail without overlay
- **WHEN** the user selects a catalog entry with exactly one item
- **THEN** the detail panel shows the item detail view occupying the full panel width with no item list visible

#### Scenario: Single-item detail has a close control
- **WHEN** the single-item detail is displayed
- **THEN** a close control is visible; activating it clears the catalog entry selection and hides the detail panel

### Requirement: Multi-item catalog entry shows multi-item detail as the base layer
When the selected catalog entry contains more than one item, the application SHALL display the multi-item detail view (entry metadata + scrollable item list) as the base layer occupying the full detail panel column. No item is pre-selected.

#### Scenario: Multi-item entry opens base layer with no item pre-selected
- **WHEN** the user selects a catalog entry with more than one item
- **THEN** the multi-item detail view fills the detail panel column; no item detail overlay is shown; no item in the list is highlighted

#### Scenario: Multi-item base layer has a close control
- **WHEN** the multi-item base layer is displayed
- **THEN** a close control is visible; activating it clears the catalog entry selection and hides the detail panel entirely

### Requirement: Item selection within multi-item entry overlays the base layer
When the user selects an item from the item list in the multi-item detail view, the application SHALL display the item detail view as an overlay on the right portion of the detail panel column. The overlay SHALL partially cover the base layer while leaving a visible strip of the base layer on the left side.

#### Scenario: Selecting an item shows the item detail overlay
- **WHEN** the user selects an item from the item list in the multi-item base layer
- **THEN** the item detail overlay appears on the right portion of the detail panel; the left strip of the base layer remains visible and interactive

#### Scenario: Selecting a different item updates the overlay in place
- **WHEN** an item detail overlay is visible and the user selects a different item from the visible strip of the base layer
- **THEN** the overlay content updates to show the newly selected item without dismissing and re-showing the overlay

#### Scenario: Item overlay has a close control
- **WHEN** the item detail overlay is visible
- **THEN** a close control is present within the overlay; activating it dismisses the overlay and returns to the multi-item base layer alone

### Requirement: Item detail overlay is dismissed only by explicit user action
The item detail overlay SHALL be dismissed exclusively by: (a) the user activating the overlay's close control, or (b) the user clicking or tapping in the visible portion of the multi-item base layer. Clicking or tapping anywhere in the catalog view, sidebar, or toolbar area outside the detail panel SHALL NOT dismiss the overlay or the base layer.

#### Scenario: Clicking in the visible base layer strip dismisses the overlay
- **WHEN** the item detail overlay is visible and the user clicks in the visible portion of the multi-item base layer
- **THEN** the item detail overlay is dismissed; the item-within-entry selection is cleared; the base layer remains visible and fully interactive

#### Scenario: Clicking in the catalog view does not dismiss either layer
- **WHEN** the item detail overlay (or the base layer alone) is visible and the user clicks anywhere in the catalog list or grid area
- **THEN** neither the item detail overlay nor the base layer is dismissed; no selection is cleared

#### Scenario: Clicking in the sidebar does not dismiss either layer
- **WHEN** any detail layer is visible and the user clicks anywhere in the sidebar filter list
- **THEN** no detail layer is dismissed; the sidebar filter change takes effect normally

#### Scenario: Overlay close control dismisses only the overlay
- **WHEN** the user activates the item overlay close control
- **THEN** the item detail overlay is dismissed and the first-level catalog entry selection remains active; the multi-item base layer is still visible

### Requirement: Selecting a catalog entry from the catalog view while a detail layer is open replaces the detail
When any detail layer is visible and the user selects a catalog entry from the catalog list or grid, the application SHALL replace all current detail state with the appropriate detail for the newly selected entry.

#### Scenario: Selecting a new catalog entry replaces multi-item base layer
- **WHEN** the multi-item base layer is visible and the user selects a different catalog entry
- **THEN** both the base layer and any item overlay are replaced by the detail appropriate for the new entry (single-item detail or a fresh multi-item base layer with no item selected)

#### Scenario: Selecting the same catalog entry again is a no-op
- **WHEN** a catalog entry is already selected and the user clicks its row again in the catalog view
- **THEN** the selection and detail state are unchanged
