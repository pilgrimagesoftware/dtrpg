# auth-startup-routing Specification

## Purpose
TBD - created by archiving change add-auth-ui. Update Purpose after archive.
## Requirements
### Requirement: App checks credential store before opening any window
At startup, the app SHALL call `KeyringCredentialStore::load()` for the `api-key` account key before opening any window. The result determines which window is opened first.

#### Scenario: Credentials present — open library window
- **WHEN** `load()` returns `Ok(Some(_))` for the `api-key` entry
- **THEN** the library window opens and no login window is shown

#### Scenario: Credentials absent — open login window
- **WHEN** `load()` returns `Ok(None)` for the `api-key` entry
- **THEN** the login window opens and no library window is shown

### Requirement: Keyring errors at startup route to the login window
If `load()` returns a `CredentialError` at startup, the app SHALL open the login window rather than crashing. A non-fatal warning SHALL be logged.

#### Scenario: Load error treated as absent credential
- **WHEN** `load()` returns `Err(CredentialError::Unavailable(_))` or another error variant
- **THEN** the login window opens and a warning is logged; the app does not crash or display a fatal error dialog

### Requirement: Successful login transitions from login window to library window
After `LoginController` stores credentials successfully, the app SHALL open the library window and close the login window without requiring the user to restart.

#### Scenario: Window transition after login
- **WHEN** `LoginController` emits a `LoginSucceeded` event
- **THEN** the library window is opened via `cx.open_window` and the login window is closed

