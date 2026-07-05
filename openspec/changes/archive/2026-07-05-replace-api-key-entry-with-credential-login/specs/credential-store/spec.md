## MODIFIED Requirements

### Requirement: Store credentials in platform-native secure storage
The application SHALL persist DriveThruRPG account credentials (account email, API key,
access token, refresh token) exclusively in the platform's native secure credential
store: macOS Keychain on macOS, Windows Credential Manager on Windows, and Linux Secret
Service (via DBus / libsecret) on Linux. Credentials SHALL NOT be written to plaintext
config files, environment variables, or unencrypted local databases. The account email
SHALL be stored alongside the application key so a stored key can be attributed to the
account it belongs to.

#### Scenario: Credential written on successful authentication (macOS)
- **WHEN** the user successfully authenticates with DriveThruRPG on macOS
- **THEN** the account email and application key are stored in the macOS Keychain under a
  well-known service name (`com.pilgrimagesoftware.dtrpg`) and account label

#### Scenario: Credential written on successful authentication (Windows)
- **WHEN** the user successfully authenticates with DriveThruRPG on Windows
- **THEN** the account email and application key are stored in Windows Credential Manager
  as a Generic Credential with target name `com.pilgrimagesoftware.dtrpg`

#### Scenario: Credential written on successful authentication (Linux)
- **WHEN** the user successfully authenticates with DriveThruRPG on Linux
- **THEN** the account email and application key are stored in the Secret Service
  keyring (e.g., GNOME Keyring or KWallet) under a collection-agnostic label of
  `com.pilgrimagesoftware.dtrpg`

#### Scenario: No plaintext fallback
- **WHEN** the platform secure store is unavailable or write fails
- **THEN** the application SHALL surface an error to the user and SHALL NOT fall back to
  writing credentials to disk in plaintext

#### Scenario: Legacy application-key-only entry remains readable
- **WHEN** the application reads a credential entry written before this change (no
  account email present)
- **THEN** the application treats the entry as valid for reauthentication with an absent
  email, without requiring a migration step
