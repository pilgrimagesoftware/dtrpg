## ADDED Requirements

### Requirement: Context menu appears on right-click

Any catalog item in list, thumbs, or grid layout SHALL display a context menu when the user right-clicks (secondary-clicks) on the item. The menu SHALL appear anchored near the cursor position. Left-click behavior (item selection) SHALL be unaffected.

#### Scenario: Right-click opens menu on list row

- **WHEN** the user right-clicks a catalog list row
- **THEN** a context menu SHALL appear near the cursor with actions relevant to that item's download state

#### Scenario: Right-click opens menu on thumb row

- **WHEN** the user right-clicks a catalog thumb row
- **THEN** a context menu SHALL appear near the cursor with actions relevant to that item's download state

#### Scenario: Right-click opens menu on grid card

- **WHEN** the user right-clicks a catalog grid card
- **THEN** a context menu SHALL appear near the cursor with actions relevant to that item's download state

#### Scenario: Left-click is unaffected

- **WHEN** the user left-clicks any catalog item while no context menu is open
- **THEN** the item SHALL be selected as normal and no context menu SHALL appear

### Requirement: Context menu items are gated on download state

The context menu SHALL show only the actions that apply to the item's current download state. No disabled or greyed-out items SHALL be shown for inapplicable actions.

#### Scenario: Downloaded item shows reveal and remove actions

- **WHEN** the context menu is opened on an item with status `Downloaded`
- **THEN** the menu SHALL contain "Show in Finder" (macOS), "Show in Explorer" (Windows), or "Show in Files" (Linux) AND "Remove Download"
- **THEN** the menu SHALL NOT contain "Download"

#### Scenario: Cloud item shows download action

- **WHEN** the context menu is opened on an item with status `Cloud`
- **THEN** the menu SHALL contain "Download"
- **THEN** the menu SHALL NOT contain "Show in Finder / Explorer / Files" or "Remove Download"

### Requirement: Reveal action opens file manager at item file

Selecting "Show in Finder / Explorer / Files" from the context menu SHALL reveal the item's downloaded file in the platform file manager. The action SHALL only be available when the item status is `Downloaded`.

#### Scenario: Reveal opens file manager for downloaded item

- **WHEN** the user selects "Show in Finder / Explorer / Files" from the context menu of a downloaded item
- **THEN** the platform file manager SHALL open and select the item's file at `<storage_root>/items/<item_id>`

#### Scenario: Reveal warns when file is missing

- **WHEN** the user selects "Show in Finder / Explorer / Files" but the expected file path does not exist on disk
- **THEN** a warning SHALL be logged and the file manager SHALL NOT be invoked with a non-existent path

### Requirement: Download action initiates item download

Selecting "Download" from the context menu of a `Cloud` item SHALL begin downloading the item, equivalent to clicking "Download" in the detail panel.

#### Scenario: Download triggers download action

- **WHEN** the user selects "Download" from the context menu of a `Cloud` item
- **THEN** the download action SHALL be triggered for that item via `LibraryController::toggle_download`

### Requirement: Remove Download action removes the local file

Selecting "Remove Download" from the context menu of a `Downloaded` item SHALL remove the local file and mark the item as `Cloud`, equivalent to the toggle-download action in the detail panel.

#### Scenario: Remove Download changes item to cloud state

- **WHEN** the user selects "Remove Download" from the context menu of a `Downloaded` item
- **THEN** the item's local file SHALL be marked for removal and its status SHALL transition to `Cloud`

### Requirement: Context menu dismisses on outside click or Escape

The context menu SHALL close when the user clicks outside its bounds or presses Escape, without affecting item selection or triggering any action.

#### Scenario: Click-away dismisses the menu

- **WHEN** a context menu is open and the user clicks anywhere outside the menu
- **THEN** the context menu SHALL close and no action SHALL be performed

#### Scenario: Escape key dismisses the menu

- **WHEN** a context menu is open and the user presses Escape
- **THEN** the context menu SHALL close and no action SHALL be performed
