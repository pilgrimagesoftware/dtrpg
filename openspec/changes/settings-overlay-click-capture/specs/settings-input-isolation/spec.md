## ADDED Requirements

### Requirement: The settings panel overlay blocks all pointer events from reaching elements beneath it
When the settings panel is open, the system SHALL prevent any pointer event (mouse down, mouse up, click, hover) from being delivered to any element rendered behind the overlay, including catalog rows, sidebar filters, toolbar buttons, and the notification banner.

#### Scenario: Clicking a settings tab does not select a catalog entry
- **WHEN** the settings panel is open and the user clicks a tab in the settings tab strip
- **THEN** only the tab's action fires (switching the active settings section); no catalog entry is selected and the detail panel does not open

#### Scenario: Clicking the backdrop does not interact with underlying controls
- **WHEN** the settings panel is open and the user clicks an area of the backdrop that is not the modal card
- **THEN** no click handler on any element below the backdrop fires; the panel remains open

#### Scenario: Closing the settings panel restores normal pointer interaction with the catalog
- **WHEN** the settings panel is closed by clicking the × button
- **THEN** subsequent clicks on catalog entries, toolbar controls, and sidebar filters function normally

### Requirement: The settings panel overlay does not block scroll events on the catalog
The system SHOULD allow scroll wheel events to reach the catalog scroll container while the settings panel is open, so that a scroll gesture over the overlay does not silently consume the scroll.

#### Scenario: Scroll wheel over open settings panel
- **WHEN** the settings panel is open and the user scrolls the mouse wheel over the overlay
- **THEN** the scroll event is not delivered to the catalog (since the overlay fully covers the catalog, there is no meaningful scroll target visible)

### Requirement: Hover styles on catalog elements are suppressed while the settings panel is open
No catalog row, sidebar item, or toolbar button SHALL display a hover highlight while any part of the settings overlay covers it.

#### Scenario: Mouse moves over overlay-covered catalog row
- **WHEN** the settings panel is open and the user moves the mouse over a catalog row position
- **THEN** the catalog row does not render a hover highlight; the cursor remains a default pointer
