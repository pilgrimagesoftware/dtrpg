## 1. Rust App — CredentialStore Trait and Model

- [ ] 1.1 Add `keyring` crate dependency to `dtrpg-app/rust/Cargo.toml` (enable appropriate platform features)
- [ ] 1.2 Define `Credential` value type with `service`, `account`, and `secret` fields in `dtrpg-app/rust`
- [ ] 1.3 Define `CredentialError` error enum using `thiserror` covering store/load/delete failure cases
- [ ] 1.4 Define `CredentialStore` trait with `store`, `load`, and `delete` methods returning `Result<_, CredentialError>`
- [ ] 1.5 Implement `KeyringCredentialStore` struct that wraps `keyring::Entry` and satisfies `CredentialStore`
- [ ] 1.6 Write unit tests for `KeyringCredentialStore` (mock or integration-mode against real keyring in CI)

## 2. Rust App — Namespace and Key Schema

- [ ] 2.1 Define constants for service name (`com.pilgrimagesoftware.dtrpg`) and account key names (`api-key`, `access-token`, `refresh-token`) in a `credentials::keys` module
- [ ] 2.2 Verify all `CredentialStore` call sites use the constants, not inline strings

## 3. Rust App — Authentication Flow Integration

- [ ] 3.1 Identify the login/authentication handler in `dtrpg-app/rust` and call `store()` on successful auth
- [ ] 3.2 Identify the app startup sequence and call `load()` to restore credentials; skip login prompt if credentials are present and valid
- [ ] 3.3 Identify the logout/sign-out handler and call `delete()` to remove all stored entries
- [ ] 3.4 Handle `load()` returning `None` or error by routing to the login flow
- [ ] 3.5 Handle `store()` / `delete()` errors by surfacing a user-facing error message (do not silently fail)

## 4. Swift App — KeychainCredentialStore

- [ ] 4.1 Define `CredentialStorable` protocol in the Swift app with `store`, `load`, and `delete` methods
- [ ] 4.2 Implement `KeychainCredentialStore` struct using `SecItemAdd`, `SecItemCopyMatching`, and `SecItemDelete` from `Security.framework`
- [ ] 4.3 Use `kSecAttrService` = `com.pilgrimagesoftware.dtrpg` and `kSecAttrAccount` per credential type
- [ ] 4.4 Map `OSStatus` errors to a typed `KeychainError` enum conforming to `LocalizedError`
- [ ] 4.5 Write XCTest unit tests for each operation (store, load, delete, load-after-delete)

## 5. Swift App — Authentication Flow Integration

- [ ] 5.1 Call `store()` on `KeychainCredentialStore` after successful DriveThruRPG authentication
- [ ] 5.2 Call `load()` at app startup; bypass login view if a valid credential is found
- [ ] 5.3 Call `delete()` on sign-out and verify the credential is gone from the Keychain
- [ ] 5.4 Handle Keychain errors with user-visible alerts (do not silently swallow errors)

## 6. Build and Platform Verification

- [ ] 6.1 Confirm the Rust app builds successfully on macOS (`aarch64-apple-darwin`) with `keyring` linking `Security.framework`
- [ ] 6.2 Confirm the Rust app builds successfully on Windows (`x86_64-pc-windows-msvc`) with `keyring` using Windows Credential Manager
- [ ] 6.3 Confirm the Rust app builds successfully on Linux (`x86_64-unknown-linux-gnu`) with `keyring` and `libsecret-1` available
- [ ] 6.4 Add `libsecret-1-dev` (or equivalent) to the Linux CI build environment
- [ ] 6.5 Verify CI runs all credential store tests on each target platform (or cross-compilation where possible)

## 7. SDK Audit

- [ ] 7.1 Audit `dtrpg-sdk/rust` for any code that writes auth tokens or credentials to disk
- [ ] 7.2 If found, refactor to remove persistence from the SDK and document that callers must provide storage
- [ ] 7.3 Update SDK documentation to clarify that credential storage is the caller's responsibility

## 8. Cleanup and Documentation

- [ ] 8.1 Confirm no plaintext credential paths remain in config file parsing code (grep for field names like `api_key`, `password`, `token` in config loading)
- [ ] 8.2 Update the app's README / installation docs with the Linux `libsecret` requirement
- [ ] 8.3 Document the `com.pilgrimagesoftware.dtrpg` namespace convention in the relevant `CLAUDE.md` or architecture notes for future contributors
