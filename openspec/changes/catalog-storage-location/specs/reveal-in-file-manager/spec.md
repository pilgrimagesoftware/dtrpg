## ADDED Requirements

### Requirement: Reveal downloaded item's folder in OS file manager
The application SHALL open the OS file manager (Finder on macOS, File Explorer on Windows, the default file manager on Linux) at the folder containing a downloaded catalog item's file when the user triggers the "Show in Finder / Show in Explorer / Show in Files" action.

#### Scenario: Reveal item folder on macOS
- **WHEN** the user triggers "Show in Finder" on a downloaded catalog item on macOS
- **THEN** Finder opens with the item's file selected (highlighted) in its containing folder using `NSWorkspace.shared.activateFileViewerSelecting(_:)`

#### Scenario: Reveal item folder on Windows
- **WHEN** the user triggers "Show in Explorer" on a downloaded catalog item on Windows
- **THEN** File Explorer opens with the item's file selected using `explorer.exe /select,<path>`

#### Scenario: Reveal item folder on Linux
- **WHEN** the user triggers "Show in Files" on a downloaded catalog item on Linux
- **THEN** the default file manager opens at the item's containing directory (using `xdg-open` on the parent directory, or the `dbus` `org.freedesktop.FileManager1.ShowItems` interface when available)

#### Scenario: Reveal action absent for non-downloaded items
- **WHEN** a catalog item has not been downloaded
- **THEN** the "Show in Finder/Explorer/Files" action is not shown or is disabled; it SHALL NOT attempt to reveal a non-existent path

#### Scenario: File missing at reveal time
- **WHEN** the user triggers reveal and the local file no longer exists on disk
- **THEN** the application informs the user the file is missing and offers to re-download it; it does not open the file manager to a missing path

### Requirement: Reveal action accessible from catalog view
The catalog item list and grid view SHALL surface a "Show in Finder / Explorer / Files" action for each item that has a locally available downloaded file.

#### Scenario: Reveal from catalog list row
- **WHEN** the user triggers the reveal action on a catalog item row in the list view
- **THEN** the OS file manager opens at the item's file location without navigating away from the catalog view

#### Scenario: Reveal from catalog grid card
- **WHEN** the user triggers the reveal action on a catalog item card in the grid view
- **THEN** the OS file manager opens at the item's file location without navigating away from the catalog view

### Requirement: Reveal action accessible from item detail view
The catalog item detail view SHALL include a "Show in Finder / Explorer / Files" action alongside the "Open" action.

#### Scenario: Reveal from detail view
- **WHEN** the user triggers the reveal action in the item detail view
- **THEN** the OS file manager opens with the item's file selected and the detail view remains visible

### Requirement: Open storage root in OS file manager from settings
The application settings screen SHALL include a "Show in Finder / Explorer / Files" button that opens the configured storage root directory in the OS file manager.

#### Scenario: Open storage root from settings (macOS)
- **WHEN** the user clicks "Show in Finder" in the storage settings section on macOS
- **THEN** Finder opens at the configured storage root directory

#### Scenario: Open storage root from settings (Windows)
- **WHEN** the user clicks "Show in Explorer" in the storage settings section on Windows
- **THEN** File Explorer opens at the configured storage root directory

#### Scenario: Open storage root from settings (Linux)
- **WHEN** the user clicks "Show in Files" in the storage settings section on Linux
- **THEN** the default file manager opens at the configured storage root directory

#### Scenario: Storage root does not exist
- **WHEN** the user clicks the reveal button and the configured storage root directory does not yet exist on disk
- **THEN** the application creates the directory and then opens the file manager at it, or informs the user it has not been created yet
