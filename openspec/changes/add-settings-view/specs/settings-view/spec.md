## ADDED Requirements

### Requirement: Settings is accessible from the main window
The application SHALL provide a clearly discoverable entry point to open the settings view from the main library window. The entry point SHALL be present at all times, regardless of catalog state.

#### Scenario: Settings opened via toolbar button (Rust app)
- **WHEN** the user clicks the settings/gear button in the main toolbar
- **THEN** the settings panel or window opens and the library view remains visible behind it

#### Scenario: Settings opened via application menu (Swift app)
- **WHEN** the user selects the application's "Settings…" menu item (Cmd+,)
- **THEN** the SwiftUI Settings scene opens as a separate window, following macOS conventions

#### Scenario: Settings entry point is always visible
- **WHEN** the catalog is loading, empty, or in an error state
- **THEN** the settings entry point remains accessible and functional

### Requirement: Settings contains an Account section
The settings view SHALL include an Account section that displays the connected DriveThruRPG account identity and provides controls to log out or reset the API key.

#### Scenario: Account section shows connected account
- **WHEN** the user opens settings and a valid session exists
- **THEN** the Account section displays identifying information (username or email) associated with the authenticated account

#### Scenario: Logout clears the session
- **WHEN** the user clicks "Log Out" in the Account section and confirms the action
- **THEN** all stored credentials are cleared (via the credential store), the session is terminated, and the application returns to the unauthenticated/login state

#### Scenario: Logout requires confirmation
- **WHEN** the user clicks "Log Out"
- **THEN** the application presents a confirmation prompt before clearing the session; clicking "Cancel" leaves the session intact

#### Scenario: Reset API key prompts re-authentication
- **WHEN** the user clicks "Reset API Key" (or equivalent) in the Account section
- **THEN** the stored API key credential is cleared and the application presents the API key entry flow, allowing the user to supply a new key without a full logout

#### Scenario: Account section reflects unauthenticated state
- **WHEN** the user opens settings and no valid session exists
- **THEN** the Account section shows a "Not signed in" state with a prompt or button to authenticate

### Requirement: Settings contains a Storage section
The settings view SHALL include a Storage section that displays the current catalog data storage location and provides controls to change it and reveal it in the OS file manager. The Storage section SHALL delegate to the `storage-location-preference` and `reveal-in-file-manager` capabilities.

#### Scenario: Storage section displays current path
- **WHEN** the user opens the Storage section of settings
- **THEN** the full absolute path of the current storage root is shown

#### Scenario: Change storage location via folder picker
- **WHEN** the user clicks "Change…" in the Storage section
- **THEN** the OS-native folder picker opens and, on confirmation, the new path is validated and saved (per `storage-location-preference` requirements)

#### Scenario: Reveal storage root in file manager
- **WHEN** the user clicks "Show in Finder / Explorer / Files" in the Storage section
- **THEN** the OS file manager opens at the configured storage root (per `reveal-in-file-manager` requirements)

### Requirement: Settings contains a File Openers section
The settings view SHALL include a File Openers section that lists user-defined file-type → application overrides and provides controls to add, edit, and remove entries.

#### Scenario: File Openers section shows current overrides
- **WHEN** the user opens the File Openers section with no overrides configured
- **THEN** an empty state message is shown explaining that the OS default application will be used for all file types

#### Scenario: File Openers section lists configured overrides
- **WHEN** one or more file-type → application overrides are saved
- **THEN** each override is shown as a row with the file extension (e.g., `.pdf`) and the target application name

#### Scenario: User can remove an override
- **WHEN** the user activates the remove/delete control on an override row
- **THEN** the override is removed from the list and the OS default application will be used for that file type going forward

### Requirement: Settings sections are independently navigable
The settings view SHALL organize its sections so the user can navigate directly to any section without scrolling through all settings. On macOS this is typically a toolbar-style tab bar; on gpui it may be a sidebar or tab strip within the settings panel.

#### Scenario: User navigates directly to Storage section
- **WHEN** the user opens settings and clicks the "Storage" tab or section label
- **THEN** the Storage section content is shown without requiring the user to scroll past the Account section

#### Scenario: Settings remembers last-viewed section
- **WHEN** the user closes and reopens settings
- **THEN** the settings opens on the same section the user was viewing when they closed it
