## ADDED Requirements

### Requirement: Default storage location is platform-appropriate
The application SHALL use a platform-appropriate default directory for catalog data storage when no user preference has been set. The default SHALL be within the user's home directory or standard user data directory, never a system-wide path.

#### Scenario: First launch uses platform default (macOS)
- **WHEN** the application is launched for the first time on macOS with no storage preference configured
- **THEN** catalog data is stored under `~/Library/Application Support/com.pilgrimagesoftware.dtrpg/` or an equivalent user-data path

#### Scenario: First launch uses platform default (Windows)
- **WHEN** the application is launched for the first time on Windows with no storage preference configured
- **THEN** catalog data is stored under `%APPDATA%\PilgrimageSoftware\dtrpg\` or an equivalent user-data path

#### Scenario: First launch uses platform default (Linux)
- **WHEN** the application is launched for the first time on Linux with no storage preference configured
- **THEN** catalog data is stored under `$XDG_DATA_HOME/dtrpg/` (falling back to `~/.local/share/dtrpg/` if `XDG_DATA_HOME` is unset)

### Requirement: User can view the current storage location
The settings screen SHALL display the currently configured storage root path so the user always knows where their data lives.

#### Scenario: Settings shows configured path
- **WHEN** the user opens the application settings and navigates to the storage section
- **THEN** the full absolute path of the current storage root is displayed

#### Scenario: Settings shows default path when no override is set
- **WHEN** no user preference has been saved
- **THEN** the settings screen displays the platform default path (not a blank field)

### Requirement: User can change the storage location via a folder picker
The application SHALL allow the user to select a new storage root directory using the OS-native folder picker dialog. The change SHALL take effect after the user confirms selection.

#### Scenario: User picks a new folder and confirms
- **WHEN** the user clicks "Change…" in settings and selects a new directory via the OS folder picker
- **THEN** the application saves the new path as the storage preference and immediately derives all future file paths from it

#### Scenario: User cancels the folder picker
- **WHEN** the user opens the folder picker and then cancels without selecting a directory
- **THEN** the storage preference is unchanged and no error is shown

#### Scenario: User selects a non-writable directory
- **WHEN** the user selects a directory to which the application does not have write permission
- **THEN** the application displays an error message explaining the directory is not writable and does not save the preference

#### Scenario: User selects a path on an unmounted volume
- **WHEN** the user types or selects a path whose parent volume is not currently mounted
- **THEN** the application warns that the path may be unavailable and asks for confirmation before saving

### Requirement: Storage preference is persisted across app restarts
The configured storage root path SHALL be saved to the application's preference store and restored on every subsequent launch.

#### Scenario: Preference survives restart
- **WHEN** the user sets a custom storage location, quits the application, and relaunches
- **THEN** the application uses the previously saved storage path, not the platform default

#### Scenario: Preference store is corrupted or unreadable
- **WHEN** the application cannot read the stored preference (corrupt file, permission issue)
- **THEN** the application falls back to the platform default and logs a warning; it does not crash

### Requirement: Changing storage location does not move existing files
When the user changes the storage root, the application SHALL NOT automatically move or copy files from the old location to the new one. Files at the old path are treated as absent at the new location.

#### Scenario: Previously downloaded item shows as not-downloaded after location change
- **WHEN** the user changes the storage location to a new empty directory
- **THEN** items that were previously marked as downloaded are no longer shown as available for opening, and the application offers to re-download them

#### Scenario: Application informs user that files will not be moved
- **WHEN** the user confirms a new storage location in settings
- **THEN** the application displays a notice explaining that existing downloaded files at the old location will need to be moved manually or re-downloaded
