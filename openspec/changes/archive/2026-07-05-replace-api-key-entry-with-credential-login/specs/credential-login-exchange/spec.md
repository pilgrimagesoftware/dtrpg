## ADDED Requirements

### Requirement: SDK exchanges email and password for an application key
The SDK SHALL provide a single operation that exchanges a DriveThruRPG email and password
for an application key, by calling `POST https://www.drivethrurpg.com/validate_login_credentials.php`
followed by `POST https://www.drivethrurpg.com/create_account_app.php`, both with a
`multipart/form-data` body containing `email_address` and `password` fields, per
`dtrpg-api/LOGIN.md`.

#### Scenario: Valid credentials return an application key
- **WHEN** the operation is called with an email and password that DriveThruRPG accepts
- **THEN** it returns the application key from `create_account_app.php`'s
  `message.key` field

#### Scenario: Invalid credentials are rejected before the key request
- **WHEN** `validate_login_credentials.php` indicates the credentials are invalid
- **THEN** the operation returns an error without calling `create_account_app.php`

#### Scenario: Key request failure surfaces distinctly from credential failure
- **WHEN** credentials validate successfully but `create_account_app.php` returns a
  non-success status
- **THEN** the operation returns an error distinguishable from an invalid-credentials
  error

### Requirement: Credential exchange does not use the api.drivethrurpg.com client
The credential exchange operation SHALL issue requests against `www.drivethrurpg.com`
independently of the `Config`/base-URL used for `api.drivethrurpg.com` operations such as
`auth_client::authenticate`.

#### Scenario: Overriding the API base URL does not affect the credential exchange
- **WHEN** the SDK is configured with a non-default `api.drivethrurpg.com` base URL (e.g.
  for testing)
- **THEN** the credential exchange still targets `www.drivethrurpg.com`
