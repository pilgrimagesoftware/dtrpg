## ADDED Requirements

### Requirement: Open downloaded item in OS default application
The application SHALL open a catalog item's downloaded file in the operating system's default application for that file type when the user triggers the "Open" action. The application SHALL NOT bundle its own viewer; all rendering is delegated to the OS.

#### Scenario: Open PDF in default PDF reader (macOS)
- **WHEN** the user triggers "Open" on a downloaded PDF catalog item on macOS
- **THEN** the application passes the local file path to `NSWorkspace.shared.open(_:)` and the system launches the default PDF reader (e.g., Preview, Adobe Acrobat)

#### Scenario: Open file in default application (Windows)
- **WHEN** the user triggers "Open" on a downloaded catalog item on Windows
- **THEN** the application invokes `ShellExecuteW` (or equivalent) with the local file path and the OS launches the registered default application for that file extension

#### Scenario: Open file in default application (Linux)
- **WHEN** the user triggers "Open" on a downloaded catalog item on Linux
- **THEN** the application invokes `xdg-open` with the local file path and the desktop environment launches the associated application

#### Scenario: No default application registered
- **WHEN** the user triggers "Open" and the OS has no default application registered for the file's type
- **THEN** the application displays an error message informing the user that no application is available to open this file type, and offers guidance (e.g., "Install a PDF reader and set it as the default")

### Requirement: Open action accessible from catalog view
The catalog item list and grid view SHALL surface an "Open" affordance (button, context menu item, or double-click gesture) on each item that has a locally available downloaded file.

#### Scenario: Open from catalog list row
- **WHEN** the user activates the "Open" affordance on a catalog item row in the list view
- **THEN** the OS default application is launched for that item's file without navigating away from the catalog view

#### Scenario: Open from catalog grid card
- **WHEN** the user activates the "Open" affordance on a catalog item card in the grid view
- **THEN** the OS default application is launched for that item's file without navigating away from the catalog view

#### Scenario: Open affordance absent for non-downloaded item
- **WHEN** a catalog item has not been downloaded (no local file present)
- **THEN** the "Open" affordance is not shown, or is replaced by a "Download" affordance; activating it SHALL NOT attempt to open a missing file

### Requirement: Open action accessible from item detail view
The catalog item detail view SHALL include a prominent "Open" action button that opens the item's local file in the OS default application.

#### Scenario: Open button present for downloaded item
- **WHEN** the user views the detail view of a catalog item that has been downloaded
- **THEN** an "Open" button is visible and enabled as the primary action

#### Scenario: Open button state for non-downloaded item
- **WHEN** the user views the detail view of a catalog item that has not been downloaded
- **THEN** the "Open" button is either absent or replaced by a "Download" button; the "Open" action is not triggerable

#### Scenario: Open from detail view launches default app
- **WHEN** the user clicks "Open" in the detail view
- **THEN** the OS default application launches for the item's file and the detail view remains visible

### Requirement: Open action respects multi-file items
For catalog items that have multiple downloadable files (e.g., PDF + print-friendly version + extras), the application SHALL open the primary file by default and MAY offer a picker for additional files.

#### Scenario: Single-file item opens directly
- **WHEN** the user triggers "Open" on an item with exactly one downloadable file
- **THEN** that file is opened immediately without any picker dialog

#### Scenario: Multi-file item offers file selection
- **WHEN** the user triggers "Open" on an item with multiple downloadable files
- **THEN** the application presents a list of available files for the user to choose which one to open

#### Scenario: Multi-file item primary file shortcut
- **WHEN** the user triggers "Open" on an item with multiple files and one is designated as the primary file
- **THEN** the primary file is opened immediately and additional files are accessible via a secondary action or expanded menu

### Requirement: Open failure is reported to the user
If the OS fails to open the file (e.g., file is corrupt, permission denied, application crash), the application SHALL detect the failure and display an actionable error message.

#### Scenario: OS reports failure on open
- **WHEN** the OS returns an error code when attempting to open the file
- **THEN** the application displays an error message describing the failure and does not silently ignore the error

#### Scenario: Local file missing at open time
- **WHEN** the user triggers "Open" but the local file that was previously downloaded is no longer present on disk
- **THEN** the application informs the user the file is missing and offers to re-download it
