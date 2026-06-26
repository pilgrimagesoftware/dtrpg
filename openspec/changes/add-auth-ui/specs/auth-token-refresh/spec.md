## ADDED Requirements

### Requirement: 401 responses produce a NeedsReauth signal
When the service layer receives a `401 Unauthorized` response from the DriveThruRPG API, it SHALL return a `NeedsReauth` error variant rather than propagating a generic HTTP error. This signal is defined in `dtrpg-core` service errors and is the boundary between the service layer (which detects 401s) and the UI layer (which handles re-authentication).

#### Scenario: 401 HTTP response maps to NeedsReauth
- **WHEN** the SDK or HTTP client returns a 401 status code
- **THEN** the service layer returns `Err(LibraryServiceError::NeedsReauth)` to the caller

### Requirement: NeedsReauth triggers a token refresh attempt
When the UI layer receives `NeedsReauth`, it SHALL attempt to refresh the access token using the stored refresh token via the SDK auth endpoint. If the refresh succeeds, the new access and refresh tokens SHALL be stored via `KeyringCredentialStore::store()` and the original operation SHALL be retried once.

#### Scenario: Successful refresh retries the original request
- **WHEN** a `NeedsReauth` error is received and the refresh token is present and valid
- **THEN** new tokens are fetched, stored, and the original SDK call is retried exactly once

#### Scenario: Refresh token absent routes to login
- **WHEN** a `NeedsReauth` error is received and no refresh token is stored
- **THEN** the app opens the login window without attempting a refresh

### Requirement: Failed token refresh routes to the login window
If the token refresh call itself returns an error (expired refresh token, network failure), the app SHALL delete all stored credentials and open the login window. It SHALL NOT loop or retry the refresh.

#### Scenario: Refresh call fails — logout and open login
- **WHEN** the token refresh SDK call returns an error
- **THEN** `delete()` is called for all credential keys and the login window opens

### Requirement: Token refresh implementation is deferred until SDK wiring is live
The full token refresh loop depends on `connect-sdk-to-rust-app` being implemented (specifically `HttpSdkLibraryGateway` and the `LibraryService` trait). Until that change is merged, `NeedsReauth` SHALL be defined as an error variant but its handler SHALL be a stub that logs a warning and opens the login window.

#### Scenario: Stub handler routes to login
- **WHEN** `NeedsReauth` is received and the refresh loop stub is active
- **THEN** a warning is logged and the login window opens
