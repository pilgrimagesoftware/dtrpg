## 1. LoginController and Credential Wiring

- [x] 1.1 Create `dtrpg-ui/src/controllers/login.rs` with a `LoginController` struct holding login state (`idle`, `in_progress`, `error(String)`) and an `api_key_draft: String` field
- [x] 1.2 Add `pub mod login;` to `dtrpg-ui/src/controllers/mod.rs`
- [x] 1.3 Implement `LoginController::set_api_key(value: String)` that updates the draft and emits a `LoginStateChanged` event
- [x] 1.4 Implement `LoginController::submit()` that validates the draft (non-empty, trimmed), calls the SDK auth exchange (or stores the raw API key as a documented stub), then calls `KeyringCredentialStore::store()` for each credential
- [x] 1.5 Define a `LoginStateChanged` event in `dtrpg-ui/src/data/events.rs` analogous to `LibraryChanged` and `SettingsChanged`
- [x] 1.6 Implement `LoginController::logout()` that calls `KeyringCredentialStore::delete()` for `keys::API_KEY`, `keys::ACCESS_TOKEN`, and `keys::REFRESH_TOKEN`; log a warning for any `NoEntry` returns; return `Err` for other errors
- [x] 1.7 Write unit tests for `LoginController` using a `MockCredentialStore` (already defined in `credentials/store.rs`) — cover: empty key blocks submit, valid key stores credentials, SDK error sets error state, logout deletes all three keys

## 2. Login View

- [x] 2.1 Create `dtrpg-ui/src/ui/views/login_view.rs` with a `render_login_window` function following the existing `render_*` view pattern
- [x] 2.2 Add `pub mod login_view;` to `dtrpg-ui/src/ui/views/mod.rs`
- [x] 2.3 Implement the API key input field: a single-line text input bound to `LoginController::set_api_key`, styled to match the existing `gpui-component` theme tokens
- [x] 2.4 Implement the "Sign In" button: disabled when `api_key_draft` is empty or whitespace, active otherwise; calls `LoginController::submit()` on click
- [x] 2.5 Implement the in-progress state: when `LoginController` state is `in_progress`, show a spinner (or disabled button label "Signing in…") and disable the input
- [x] 2.6 Implement the error state: when `LoginController` state is `error(msg)`, show `msg` in red below the input field

## 3. Login Window at Startup

- [x] 3.1 Create `dtrpg-ui/src/ui/windows/login.rs` with an `open_login_window(cx: &mut App)` function that opens a small, centered window containing a `Root`-wrapped login view, similar to the existing `app/mod.rs` pattern
- [x] 3.2 Add `pub mod login;` to `dtrpg-ui/src/ui/windows/mod.rs`
- [x] 3.3 In `dtrpg-ui/src/ui/app/mod.rs`, call `KeyringCredentialStore::new(keys::SERVICE, keys::API_KEY).load()` before `open_window`; if the result is `Ok(Some(_))`, open the library window as before; if `Ok(None)` or any `Err`, call `open_login_window(cx)` instead
- [x] 3.4 Log a warning (via `tracing::warn!`) when `load()` returns `Err`, before falling through to the login window

## 4. Login-to-Library Transition

- [x] 4.1 In the login window's view or a subscription on `LoginController`, listen for a `LoginSucceeded` variant of `LoginStateChanged`
- [x] 4.2 On `LoginSucceeded`, call `crate::ui::app::open_library_window(cx)` (extract the library-window open call into a reusable function if it is not already) and close the login window
- [x] 4.3 Confirm `cargo check --workspace` is clean after transition wiring

## 5. Settings Account Section Wiring

- [x] 5.1 Add `is_authenticated: bool` to `SettingsSnapshot` in `dtrpg-ui/src/controllers/settings.rs`
- [x] 5.2 In `SettingsController::new()`, call `KeyringCredentialStore::new(keys::SERVICE, keys::API_KEY).load()` and set `is_authenticated` to `true` if `Ok(Some(_))`, `false` otherwise
- [x] 5.3 In `dtrpg-ui/src/ui/views/settings_account_view.rs`, replace the hardcoded `let is_authenticated = true;` stub with `entity.read(cx).snapshot().is_authenticated` (or receive it as a parameter from `render_account_section`)
- [x] 5.4 Wire the "Log Out" button click in `render_authenticated` to dispatch a `logout` action on `SettingsController`; the controller calls `LoginController::logout()` and emits a `LogoutCompleted` event
- [x] 5.5 Subscribe to `LogoutCompleted` in the library root or app level: on receipt, open the login window and close the library window

## 6. NeedsReauth Stub

- [x] 6.1 Add a `NeedsReauth` variant to the service error enum in `dtrpg-ui/src/services/mod.rs` (or create the module if it does not exist yet); add a doc comment explaining it is emitted on 401 and triggers the refresh/login flow
- [x] 6.2 Add a stub handler in the UI layer that, when `NeedsReauth` is received, logs `tracing::warn!("session expired, returning to login")` and triggers the logout-and-login-window flow
- [x] 6.3 Document in a `// TODO:` comment in the stub that full refresh logic is deferred until `connect-sdk-to-rust-app` lands

## 7. Verification

- [x] 7.1 Run `cargo test --workspace` and confirm all tests pass
- [ ] 7.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings
- [ ] 7.3 Launch the app with no credentials stored; confirm the login window opens
- [ ] 7.4 Enter an API key and click "Sign In"; confirm tokens are stored (verify with `security find-generic-password -s com.pilgrimagesoftware.dtrpg` on macOS) and the library window opens
- [ ] 7.5 Open Settings → Account while authenticated; confirm "Signed in to DriveThruRPG" and "Log Out" button are visible
- [ ] 7.6 Click "Log Out"; confirm credentials are deleted from the keyring and the login window opens
- [ ] 7.7 Relaunch the app after logout; confirm the login window opens (no credentials present)
