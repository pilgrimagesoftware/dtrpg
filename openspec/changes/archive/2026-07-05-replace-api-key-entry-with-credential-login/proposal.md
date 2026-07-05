## Why

Desktop apps currently ask the user to paste a raw DriveThruRPG API key into the login
window. There is no supported way for a user to discover or copy that key from the
DriveThruRPG website UI, so this login flow is a dead end in practice. DriveThruRPG's
website exposes a credential-based login path (`dtrpg-api/LOGIN.md`) that exchanges an
email and password for the same application key. Switching to that flow lets the user
sign in the way they already do on the website.

## What Changes

- Replace the API key text field in the login window with email and password fields.
- On submit, the app exchanges email/password for an application key using the
  DriveThruRPG website login endpoints (`validate_login_credentials.php` then
  `create_account_app.php`), then exchanges that application key for JWT access/refresh
  tokens via the existing `auth_key` SDK call.
- Add an SDK-level credential exchange operation (`dtrpg-sdk/rust`) that wraps the two
  website endpoints and returns the application key, so app code never talks to
  `www.drivethrurpg.com` directly.
- Store the user's email alongside the application key in the platform keychain, instead
  of the application key alone, so the login window can pre-fill the email on
  reauthentication.
- **BREAKING**: any stored raw-API-key-only credential entry is no longer sufficient to
  reauthenticate silently; users with an existing API-key-only entry are prompted to sign
  in again with email/password once.

## Capabilities

### New Capabilities
- `credential-login-exchange`: SDK-level operation that exchanges an email/password pair
  for a DriveThruRPG application key via the website login endpoints.

### Modified Capabilities
- `auth-login-view`: login window collects email and password instead of a raw API key,
  and the submission flow performs the credential exchange before the existing token
  exchange.
- `credential-store`: stored credential includes the account email alongside the
  application key.

## Impact

- `dtrpg-sdk/rust`: new module for the website credential exchange (`validate_login_credentials.php`,
  `create_account_app.php`), separate from the existing `api.drivethrurpg.com` auth client.
- `dtrpg-app/rust`: `LoginController`, login view, and `KeyringCredentialStore` call sites
  that currently assume a single API-key secret.
- `dtrpg-app/swift`: equivalent login view and credential store changes, tracked as a
  parallel implementation of the same shared UX principles.
- No changes to `dtrpg-api` — the website login endpoints are already documented in
  `dtrpg-api/LOGIN.md` and are outside the `api.drivethrurpg.com` OpenAPI contract.
