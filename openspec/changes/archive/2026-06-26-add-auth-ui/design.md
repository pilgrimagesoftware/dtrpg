## Context

The `secure-credential-storage` change added `KeyringCredentialStore` and the `CredentialStore` trait to `dtrpg-ui`. The credentials infrastructure is complete, but three code paths that use it do not exist yet:

1. **Startup** — `app/mod.rs` opens the library window unconditionally; it never checks whether credentials are stored.
2. **Login** — there is no view or controller that accepts an API key, calls the SDK auth endpoint, and stores the resulting tokens.
3. **Logout** — `settings_account_view.rs` renders "Log Out" and "Reset API Key" buttons, but they have no event handlers.

The `connect-sdk-to-rust-app` change (not yet implemented) will uncomment the `RustSdkLibraryService` layer and wire the SDK to the library view. That change reads credentials from environment variables as a first-pass bridge; this change replaces that bridge with the keyring-backed store and adds the missing auth UI.

## Goals / Non-Goals

**Goals:**

- Add a login view that accepts a DriveThruRPG API key and initiates token exchange via the SDK auth client.
- Add a `LoginController` that owns login state, calls the SDK, and stores resulting credentials via `KeyringCredentialStore`.
- Update `app/mod.rs` to check for stored credentials at startup and open the login window when none are found.
- Wire the "Log Out" button in `settings_account_view.rs` to delete all stored credentials and return to the login window.
- Stub the token-refresh path so that a `401` response produces a defined `NeedsReauth` signal; full refresh logic is completed in a follow-on task once `connect-sdk-to-rust-app` is live.
- Add `is_authenticated` to `SettingsSnapshot` so the account view shows the correct branch without its current hardcoded `true` stub.

**Non-Goals:**

- Full OAuth flow — DriveThruRPG uses API key + token exchange, not browser-based OAuth.
- Two-factor authentication or account creation.
- Swift app auth UI — addressed in `secure-credential-storage` tasks 4–5, independent of this change.
- Token auto-refresh with retry — deferred until `connect-sdk-to-rust-app` is live; this change only defines the signal boundary.

## Decisions

### D1: Login window vs. login overlay

**Decision**: Open a separate, small login window rather than an overlay inside the library window.

**Rationale**: At first launch there is no library content to show behind an overlay. The existing settings overlay pattern works because the library is always visible underneath it. A dedicated window (`LoginWindow`) matches the first-run pattern most desktop apps use and avoids rendering an empty library behind a modal.

**Alternative considered**: Show a full-screen overlay on the library window (like the settings panel). Rejected because the library controller would still initialise and attempt to load data before credentials exist, producing spurious errors.

### D2: Credential check location

**Decision**: Credential check happens in `app/mod.rs` before any window is opened.

**Rationale**: Earliest possible interception point. If credentials are absent, the login window opens; if present, the library window opens. This avoids having the library controller or view ever enter a "no credentials" state.

**Alternative considered**: Check inside `LibraryRootView::new`. Rejected because the library controller initialises as part of view construction — it would attempt a fetch immediately and the startup sequence would contain an error branch by design.

### D3: LoginController placement

**Decision**: `LoginController` lives in `dtrpg-ui/src/controllers/login.rs`, following the existing `LibraryController` / `SettingsController` pattern.

**Rationale**: Credentials are stored via `dtrpg-ui::credentials`; the controller stays in the same crate. The SDK auth call is a thin synchronous wrapper around the Rust SDK (matching how `RustSdkLibraryService` will be structured in `connect-sdk-to-rust-app`).

### D4: Token refresh boundary

**Decision**: Define a `NeedsReauth` error variant in `dtrpg-core` service errors; the refresh implementation is a follow-on task.

**Rationale**: `connect-sdk-to-rust-app` introduces the `LibraryService` trait and `HttpSdkLibraryGateway`. The refresh loop must live where the HTTP call is made (core service layer) but must write tokens back to the keyring (UI layer). That cross-layer coordination needs the full service wiring to be present first. The signal (`NeedsReauth`) can be stubbed now so the UI compiles cleanly.

### D5: SettingsSnapshot auth state

**Decision**: Add `is_authenticated: bool` to `SettingsSnapshot` and `SettingsController`. `SettingsController` reads the stored `api-key` credential at construction to determine initial auth state; logout clears it to `false`.

**Rationale**: Removes the hardcoded `true` in `settings_account_view.rs`. The account view already has both authenticated and unauthenticated branches; wiring up the flag is the minimal change.

## Risks / Trade-offs

- **Race between windows**: If opening the library window before the credential check completes (e.g., on a slow keyring), the library could flash. Mitigation: credential check is synchronous at startup — `keyring::Entry::get_password` blocks, which is acceptable once on the main thread before the event loop starts.
- **Keyring unavailable at startup**: On Linux, if the Secret Service daemon is not running, `load()` returns `CredentialError::Unavailable`. Mitigation: treat `Unavailable` the same as `None` at startup — open the login window with a message that the keyring is unavailable; do not crash.
- **API key storage only vs. full token set**: The login view collects only the API key; the SDK exchanges it for an access/refresh token pair. Only the access and refresh tokens are stored long-term. The API key itself is also stored (in `api-key`) so the app can re-authenticate after a refresh-token expiry without prompting the user again.
- **SDK auth client availability**: The DriveThruRPG SDK Rust crate must expose a token-exchange function. If it does not exist yet, `LoginController::authenticate()` is a stub that stores the raw API key as a stand-in for the access token. This is documented clearly and replaced once the SDK endpoint is available.

## Migration Plan

1. This change adds new files only; no existing files are deleted.
2. `settings_account_view.rs` gains a real event handler for "Log Out" — the existing stub render is preserved, only the click handler is wired.
3. `app/mod.rs` gains the credential check branch — the `open_window` call for the library window moves inside the "credentials present" branch.
4. No data migration required; credentials already stored (if any) are read via the same keyring keys.

## Open Questions

- Does the Rust SDK (`dtrpg-sdk/rust`) currently expose a function to exchange an API key for an access + refresh token pair? If not, `LoginController` stores the API key as a stand-in until it does.
- Should the login window close automatically when the user logs in, or should the library window open as a new window while the login window closes? (Proposed: library window opens first, then login window closes.)
