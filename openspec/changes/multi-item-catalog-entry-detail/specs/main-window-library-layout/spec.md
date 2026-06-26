## ADDED Requirements

### Requirement: Library browsing surface MUST navigate to catalog entry detail view on selection
The desktop application main window library browsing surface MUST navigate to or reveal the catalog entry detail view when the user selects a catalog entry, whether in list, tree, or grid presentation.

#### Scenario: Selecting an entry from list or tree view
- **WHEN** the user activates a catalog entry in list or tree view
- **THEN** the catalog entry detail view becomes visible and displays the selected entry's metadata

#### Scenario: Selecting an entry from grid view
- **WHEN** the user activates a catalog entry in grid view
- **THEN** the catalog entry detail view becomes visible and displays the selected entry's metadata

#### Scenario: Selecting a different entry while detail view is open
- **WHEN** the catalog entry detail view is open and the user selects a different catalog entry from the browsing surface
- **THEN** the detail view updates in place to show the newly selected entry without closing or reinitializing the detail surface

### Requirement: Library browsing surface MUST indicate multi-item catalog entries
The desktop application main window library browsing surface MUST display a visible indicator on catalog entries that contain more than one item, in both list and grid presentations, so users can identify multi-item entries before opening the detail view.

#### Scenario: Multi-item entry in list or tree view
- **WHEN** a catalog entry in list or tree view contains more than one item
- **THEN** the row displays a visible indicator (such as an item count badge or icon) distinguishing it from single-item entries

#### Scenario: Multi-item entry in grid view
- **WHEN** a catalog entry in grid view contains more than one item
- **THEN** the grid tile displays a visible indicator (such as an item count badge overlaid on the cover thumbnail) distinguishing it from single-item entries

#### Scenario: Single-item entry in list or grid view
- **WHEN** a catalog entry contains exactly one item
- **THEN** no multi-item indicator is shown for that entry in the browsing surface
