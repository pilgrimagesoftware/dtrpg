## 1. Coordinate child changes

- [ ] 1.1 Create a child OpenSpec change in `dtrpg-sdk/rust` implementing the
      `credential-login-exchange` capability (new module wrapping
      `validate_login_credentials.php` and `create_account_app.php`)
- [ ] 1.2 Create a child OpenSpec change in `dtrpg-app/rust` implementing the modified
      `auth-login-view` and `credential-store` capabilities for the Rust desktop app
- [ ] 1.3 Create a child OpenSpec change in `dtrpg-app/swift` implementing the same
      `auth-login-view` and `credential-store` capabilities for the Swift desktop app

## 2. SDK: credential exchange (dtrpg-sdk/rust)

- [ ] 2.1 Add a typed response for `validate_login_credentials.php`'s positional JSON
      array, with a unit test fixture from the exact example in `LOGIN.md`
- [ ] 2.2 Add a typed response for `create_account_app.php`'s `{status, message.key}`
      body
- [ ] 2.3 Implement `login_with_credentials(email, password) -> Result<String, ClientError>`
      calling both endpoints in sequence against `www.drivethrurpg.com`
- [ ] 2.4 Add unit tests covering: valid credentials, invalid credentials (stop before
      second call), and key-request failure after valid credentials
- [ ] 2.5 Document the new module's scope relative to `auth_client.rs` in doc comments

## 3. App: login view and controller (dtrpg-app/rust)

- [ ] 3.1 Replace the API key field in the login view with email and password fields
- [ ] 3.2 Update submit-button enablement logic for the two-field form
- [ ] 3.3 Update `LoginController` to call the SDK credential exchange, then the existing
      `authenticate` call, surfacing distinct errors for each failure mode
- [ ] 3.4 Update loading/disabled state handling to span both calls
- [ ] 3.5 Pre-fill the email field when a stored entry has an email but an invalid or
      expired application key

## 4. App: credential storage (dtrpg-app/rust)

- [ ] 4.1 Extend the stored credential payload to include account email alongside the
      application key
- [ ] 4.2 Update `KeyringCredentialStore` read path to tolerate legacy entries with no
      email field
- [ ] 4.3 Update tests in `credentials/store.rs` for the new payload shape and legacy
      read compatibility

## 5. Verification

- [ ] 5.1 Run `cargo test --workspace` in `dtrpg-sdk/rust` and `dtrpg-app/rust`
- [ ] 5.2 Manually verify sign-in with valid and invalid credentials against the real
      DriveThruRPG website endpoints
- [ ] 5.3 Verify a pre-existing legacy (key-only) keychain entry still allows silent
      startup reauthentication until the key is rejected
