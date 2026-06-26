## Why

DriveThruRPG/OneBookshelf account credentials must not be stored in plaintext (e.g., config files or environment variables) because the desktop application runs on user machines where such files are easily exposed. Platform-native secure storage — macOS Keychain, Windows Credential Manager, and Linux Secret Service (via libsecret/keyring) — is the expected standard for desktop apps handling user credentials.

## What Changes

- Credentials (API key / username+password / OAuth tokens) are written to and read from the platform's native credential store, never from plaintext files.
- A unified `CredentialStore` abstraction is introduced that dispatches to the correct platform backend at runtime.
- Any existing plaintext credential handling is removed or migrated. **BREAKING**: config files that previously held credential fields will no longer accept them; users must re-authenticate after upgrading.

## Capabilities

### New Capabilities

- `credential-store`: Cross-platform secure credential storage abstraction — stores, retrieves, and deletes DriveThruRPG credentials via macOS Keychain (Security framework), Windows Credential Manager (Win32 `wincred`), and Linux Secret Service (DBus / `libsecret`).

### Modified Capabilities

<!-- No existing specs have requirement-level changes from this work. -->

## Impact

- **dtrpg-app/rust**: Primary consumer — Rust desktop app must link platform credential libraries and call the new abstraction at login/logout/token-refresh time.
- **dtrpg-app/swift**: macOS Swift app uses `Security.framework` (Keychain) via native Swift APIs.
- **dtrpg-sdk/rust**: If the SDK caches auth tokens, it must delegate persistence to the caller rather than writing to disk itself.
- **dtrpg-api**: No API contract changes; this is purely a client-side persistence concern.
- **Build system**: Linux builds gain a dependency on `libsecret-1` (or equivalent); Windows builds gain `wincred`; macOS already has `Security.framework`.
