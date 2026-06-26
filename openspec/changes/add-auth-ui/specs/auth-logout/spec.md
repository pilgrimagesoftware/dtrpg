## ADDED Requirements

### Requirement: Log Out button deletes all stored credentials
When the user clicks "Log Out" in the Settings Account section, the app SHALL call `KeyringCredentialStore::delete()` for each of the three credential keys (`api-key`, `access-token`, `refresh-token`) and close the library window.

#### Scenario: Log Out clears all credentials
- **WHEN** the user clicks "Log Out" in the Settings → Account tab
- **THEN** `delete()` is called for `api-key`, `access-token`, and `refresh-token`; all three calls succeed or produce a non-fatal warning if the entry did not exist

#### Scenario: Log Out transitions to login window
- **WHEN** all credential delete calls complete (with success or `NoEntry`)
- **THEN** the login window opens and the library window closes

### Requirement: Settings Account section reflects authentication state
The `SettingsSnapshot` SHALL include an `is_authenticated: bool` field. When `true`, the account section shows the authenticated identity and "Log Out" / "Reset API Key" actions. When `false`, it shows the unauthenticated prompt.

#### Scenario: Authenticated state renders correct branch
- **WHEN** `SettingsSnapshot::is_authenticated` is `true`
- **THEN** the account section shows "Signed in to DriveThruRPG" and the "Log Out" button

#### Scenario: Unauthenticated state renders correct branch
- **WHEN** `SettingsSnapshot::is_authenticated` is `false`
- **THEN** the account section shows "Not signed in" and a "Sign In with API Key…" prompt

### Requirement: Log Out errors are surfaced to the user
If any `delete()` call returns a `CredentialError` that is not `NoEntry`, the app SHALL display a user-visible error message describing the failure. The app SHALL NOT silently ignore delete errors.

#### Scenario: Delete error shows error message
- **WHEN** `delete()` returns an error other than `NoEntry`
- **THEN** an alert or inline error message is shown in the settings panel describing the failure
