## ADDED Requirements

### Requirement: File-opener override list is persisted across app restarts
The application SHALL store user-defined file-type → application overrides in the app's preference store. Overrides SHALL survive app restarts and SHALL be loaded before the first open-item action is attempted.

#### Scenario: Override survives restart
- **WHEN** the user adds an override mapping `.pdf` → `/Applications/Adobe Acrobat.app`, then quits and relaunches
- **THEN** the override is present in the File Openers settings section and is used when opening a PDF

#### Scenario: Empty override list is the default state
- **WHEN** the application is launched for the first time with no preferences saved
- **THEN** the File Openers list is empty and all file types fall through to the OS default application

### Requirement: User can add a new file-opener override
The application SHALL provide an "Add" control that lets the user define a new file-type → application pairing through a two-step picker: first the file extension, then the application.

#### Scenario: Add override via extension input and app picker
- **WHEN** the user clicks "Add" in the File Openers section
- **THEN** the application presents a dialog or inline row allowing entry of a file extension (e.g., `pdf`, `.pdf`) and selection of a target application via the OS-native application picker or file browser

#### Scenario: Extension is normalized to lowercase without leading dot
- **WHEN** the user types `.PDF` or `PDF` as the extension
- **THEN** the stored key is normalized to `pdf` (lowercase, no leading dot) for consistent lookup

#### Scenario: Duplicate extension is rejected or replaced
- **WHEN** the user attempts to add an override for an extension that already has one
- **THEN** the application either replaces the existing override after confirmation or presents an error indicating a duplicate and requiring the user to edit the existing entry

#### Scenario: Application path is validated at add time
- **WHEN** the user selects a target application that no longer exists on disk
- **THEN** the application displays an error and does not save the invalid override

### Requirement: User can edit an existing file-opener override
The application SHALL allow the user to change the target application for an existing override without deleting and re-adding the entry.

#### Scenario: Edit override target application
- **WHEN** the user activates the edit control on an existing override row
- **THEN** the application picker opens pre-populated with the current target; selecting a new application updates the override in place

#### Scenario: Edit does not change the file extension
- **WHEN** the user edits an override's target application
- **THEN** the file extension key is unchanged; only the application path is updated

### Requirement: Open-item action consults override list before OS default
When opening a catalog item file, the application SHALL check the file-opener override list for the file's extension before falling back to the OS default application. If a matching override is found and the target application exists, it SHALL be used exclusively.

#### Scenario: Override is used when present and valid
- **WHEN** the user opens a `.pdf` catalog item and a `pdf` → `/Applications/Preview.app` override is configured
- **THEN** Preview is launched with the file, not the OS-registered default PDF application

#### Scenario: OS default is used when no override matches
- **WHEN** the user opens an `.epub` catalog item and no override for `epub` is configured
- **THEN** the OS default application for `.epub` files is used (as per `open-item` behavior)

#### Scenario: OS default is used when override application is missing
- **WHEN** a `pdf` → `/Applications/OldApp.app` override exists but the application has been uninstalled
- **THEN** the application warns the user that the configured opener is missing, then falls back to the OS default; it does not silently fail

#### Scenario: Override lookup is case-insensitive on file extension
- **WHEN** a catalog item file is named `MyBook.PDF` and a `pdf` override is configured
- **THEN** the override is applied (extension comparison is case-insensitive)

### Requirement: Override list validates stored application paths on settings open
When the File Openers section is opened, the application SHALL validate that each configured application path still exists on disk and surface a warning for any invalid entries.

#### Scenario: Invalid override is flagged in the list
- **WHEN** the user opens the File Openers settings section and a configured application no longer exists
- **THEN** the affected row is visually marked as invalid (e.g., warning icon, greyed-out app name) with an option to update or remove it

#### Scenario: Valid overrides show no warning
- **WHEN** all configured application paths exist on disk
- **THEN** no warnings are shown in the override list
