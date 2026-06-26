## Context

The DriveThruRPG desktop application currently has no implemented credential persistence layer. As authentication is being built out, we need to decide where credentials live before any plaintext approach becomes entrenched. The application ships on three platforms (macOS, Windows, Linux) via two technology stacks (Rust/gpui and Swift/SwiftUI on macOS), so the design must cover both and be consistent at the UX and data-model level.

Platform-native secure storage is mandatory for any desktop application that stores passwords or tokens — it leverages OS-level encryption (backed by the Secure Enclave on Apple silicon, DPAPI on Windows, and user-session encryption on Linux), requires no additional crypto code, and meets user expectations set by applications like 1Password, Slack, and GitHub Desktop.

## Goals / Non-Goals

**Goals:**
- Define the `CredentialStore` trait/protocol and its platform implementations for the Rust app and Swift app.
- Establish the credential namespace and key schema used across all platforms.
- Cover store, retrieve, and delete operations.
- Specify build-time platform selection (no runtime feature detection).
- Identify the crate/framework dependencies added to each build target.

**Non-Goals:**
- Encryption of credentials beyond what the platform store provides (no additional layer).
- Syncing credentials across devices (iCloud Keychain sync is incidental; not relied upon).
- Storing non-credential user data (preferences, cache) — this only covers auth secrets.
- A migration path from a prior plaintext store (none exists yet).

## Decisions

### Decision 1: Use the `keyring` crate for Rust (all platforms)

**Choice**: The [`keyring`](https://crates.io/crates/keyring) crate (v2+) provides a single API over macOS Keychain, Windows Credential Manager, and Linux Secret Service. It is the de facto standard for this use case in the Rust ecosystem and is actively maintained.

**Alternatives considered**:
- **`security-framework` (macOS) + `windows` crate + `secret-service` (Linux) separately**: More control, but three separate codepaths to maintain and test. Justified only if we need features `keyring` doesn't expose (e.g., Keychain ACLs for specific apps). We don't.
- **`kwallet` or `libsecret` bindings directly**: Unnecessary complexity; `keyring` wraps these correctly.

**Rationale**: One crate, one API, platform dispatch handled internally. Reduces the `CredentialStore` trait implementation to a thin wrapper.

### Decision 2: `CredentialStore` as a trait with a single concrete type per platform

The Rust codebase exposes:

```rust
pub trait CredentialStore: Send + Sync {
    fn store(&self, credential: &Credential) -> Result<(), CredentialError>;
    fn load(&self) -> Result<Option<Credential>, CredentialError>;
    fn delete(&self) -> Result<(), CredentialError>;
}
```

A `KeyringCredentialStore` struct implements this trait using the `keyring` crate. The concrete type is constructed once at app startup and injected where needed. There is no runtime switching — the same struct is used on all platforms because `keyring` handles dispatch internally.

### Decision 3: Swift app uses Security.framework directly (no third-party library)

The macOS Swift app uses `SecItemAdd`, `SecItemCopyMatching`, and `SecItemDelete` directly. Swift's `Security` module is already linked on every macOS target, adding no dependency. A `KeychainCredentialStore` struct conforms to a `CredentialStorable` protocol with the same three operations (store/load/delete).

**Alternative considered**: `KeychainAccess` or `SwiftKeychainWrapper` — lightweight wrappers, but an unnecessary layer when the Security API calls are ~10 lines per operation and we only need three operations.

### Decision 4: Credential model

A single `Credential` value type carries:
- `service: String` — the namespaced service key (e.g., `com.pilgrimagesoftware.dtrpg`)
- `account: String` — identifies the credential type (e.g., `api-key`, `access-token`)
- `secret: String` — the secret value (API key, bearer token, etc.)

Separate `Credential` instances are stored for each token type so they can be updated independently (e.g., refreshing an access token without touching the API key).

### Decision 5: Namespace convention

All entries use `com.pilgrimagesoftware.dtrpg` as the service name with an account suffix distinguishing credential type. This mirrors the reverse-DNS convention used by macOS entitlements and avoids collision with any other application or system entry.

## Risks / Trade-offs

**[Risk] Linux Secret Service may not be available in all environments** → Mitigation: On headless Linux (CI, server, minimal desktop), the Secret Service daemon may not be running. Since this is a desktop application targeting interactive users, this is acceptable. The error path (Secret Service unavailable) surfaces a clear message directing the user to install a keyring daemon (GNOME Keyring or KWallet). We do NOT fall back to plaintext.

**[Risk] `keyring` crate adds a runtime dependency on `libsecret` on Linux** → Mitigation: Package the app with a note in the Linux installation docs that `libsecret` (or `gnome-keyring`) must be installed. Most desktop Linux distributions ship this by default.

**[Risk] Keychain access may trigger OS permission prompts on macOS** → Mitigation: Use the app's bundle identifier consistently as the service name. Code-signing with the correct Keychain entitlements (`keychain-access-groups`) ensures the prompt appears at most once. This is documented in the Swift implementation guide.

**[Risk] Credential items left behind after uninstall** → Mitigation: The uninstall flow (or a "Remove all data" action in the app) calls `delete()` for each known account key. This is a known limitation of OS-level credential stores — they are not automatically cleaned up on uninstall on all platforms. Document this behavior.

## Migration Plan

No prior credential store exists. This is a greenfield implementation. The migration plan is:

1. Implement `CredentialStore` trait and `KeyringCredentialStore` in the Rust app crate (`dtrpg-app/rust`).
2. Implement `KeychainCredentialStore` in the Swift app (`dtrpg-app/swift`).
3. Wire store/load/delete calls into the authentication flow (login, startup, logout).
4. Verify platform builds compile and link correctly (especially the Linux `libsecret` dependency).
5. Test on each platform: store a credential, restart the app, verify it loads without prompting.

Rollback: Not applicable (no prior credential store to revert to).

## Open Questions

- **Token types**: Does DriveThruRPG's API use only an API key, or also OAuth access+refresh tokens? The credential model supports multiple entries, but the account key names need to be confirmed against the API contract once `dtrpg-api` defines the auth flow.
- **Keychain access group**: For the Swift app, should credentials be shared across extensions (e.g., a future widget or helper)? If so, an App Group Keychain entitlement is needed. For now, assume single-app Keychain access.
- **SDK token caching**: Does `dtrpg-sdk/rust` currently write any auth tokens to disk? If yes, that code must be identified and the persistence responsibility moved to the caller (the app layer).
