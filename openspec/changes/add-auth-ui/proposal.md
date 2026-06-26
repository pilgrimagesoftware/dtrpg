## Why

The `secure-credential-storage` change implemented `KeyringCredentialStore` and the `CredentialStore` trait, but the app has no login view, no startup credential check, and no logout handler — so stored credentials are never read or written in practice. This change adds the missing auth UI and wiring that make credential storage functional.

## What Changes

- A **login view** is added to the Rust desktop app (`dtrpg-ui`): an overlay panel or modal that accepts a DriveThruRPG API key and initiates authentication via the SDK.
- A **`LoginController`** is added to `dtrpg-ui/src/controllers/` that validates input, calls the SDK to exchange the API key for an access/refresh token pair, then calls `KeyringCredentialStore::store()` for each credential.
- The **app startup path** (`ui/app/mod.rs`) is updated to call `KeyringCredentialStore::load()` for the stored API key; if no credential is found (first run) or loading fails, the login view is shown instead of the library view.
- A **logout action** is wired into the Settings Account tab: calls `KeyringCredentialStore::delete()` for all three credential keys and returns the app to the login view.
- A **token refresh path** is added: on a `401 Unauthorized` response from the SDK, the app attempts to refresh the access token using the stored refresh token, persists the new tokens, and retries the original request; on refresh failure the app returns to the login view.

## Capabilities

### New Capabilities

- `auth-login-view`: The login screen — UI layout, input validation, SDK auth call, error display, and transition to the library view on success.
- `auth-startup-routing`: The app startup credential check — load stored credentials, route to login view or library view, surface load errors.
- `auth-logout`: Logout action wired to the Settings Account section — delete all stored credentials, return to login view.
- `auth-token-refresh`: Token refresh path — intercept 401 responses, use stored refresh token to obtain new access token, persist updated tokens, retry.

### Modified Capabilities

<!-- No existing top-level OpenSpec specs have requirement-level changes from this work. -->

## Impact

- **`dtrpg-app/rust` / `dtrpg-ui`**:
  - New `src/ui/views/login_view.rs` — login form UI
  - New `src/controllers/login.rs` — `LoginController` with SDK call and credential store wiring
  - `src/ui/app/mod.rs` — updated startup to check credentials before opening the library window
  - `src/ui/views/root_view.rs` — may gain a login-state branch if credential check is done at view level
  - `src/ui/views/settings_account_view.rs` — logout button wired to `CredentialStore::delete()`
  - `src/controllers/settings.rs` — logout event routing
- **`dtrpg-app/rust` / `dtrpg-core`**: Token refresh may live here if the `LibraryService` layer owns the retry logic.
- **`dtrpg-sdk`**: No SDK changes; the SDK's `AuthClient` (or equivalent) is called by `LoginController` to exchange the API key for tokens. The SDK does not persist credentials.
- **`dtrpg-api`**: No changes; existing token exchange endpoint is used.
- **Completes** `secure-credential-storage` tasks 3.1–3.5 (auth flow integration in the Rust app).
