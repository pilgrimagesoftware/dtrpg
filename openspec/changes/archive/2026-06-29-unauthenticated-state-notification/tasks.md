## 1. Auth State Model

- [x] 1.1 Define `AuthState` enum in `dtrpg-ui/src/data/auth_state.rs` with variants: `Unauthenticated`, `Authenticated`, `SessionExpired`
- [x] 1.2 Add `AuthStateChanged` event struct to `dtrpg-ui/src/data/events.rs`
- [x] 1.3 Define `NoticeKind` enum (`NotSignedIn`, `SessionExpired`) and `Notice` struct (`kind`, `dismissed: bool`) in `dtrpg-ui/src/data/notification.rs`
- [x] 1.4 Define `NoticeAction` enum (`OpenSettings(SettingsTab)`) in the same file
- [x] 1.5 Add `pub mod auth_state;` and `pub mod notification;` to `dtrpg-ui/src/data/mod.rs`

## 2. AuthStateController

- [x] 2.1 Create `dtrpg-ui/src/controllers/auth_state.rs` with `AuthStateController` struct owning `state: AuthState` and `notices: Vec<Notice>`
- [x] 2.2 Implement `AuthStateController::new()`: read `DTRPG_AUTH_STATE_OVERRIDE` env var under `#[cfg(debug_assertions)]` to set initial `AuthState`; default to `Unauthenticated` when unset or in release
- [x] 2.3 Implement `AuthStateController::state() -> AuthState` and `AuthStateController::active_notices() -> Vec<&Notice>` (returns non-dismissed notices)
- [x] 2.4 Implement `AuthStateController::set_state(state: AuthState, cx)`: updates `state`, regenerates the notice list from the new state, emits `AuthStateChanged`
- [x] 2.5 Implement `AuthStateController::dismiss_notice(kind: NoticeKind, cx)`: sets `dismissed = true` on the matching notice, emits `AuthStateChanged`
- [x] 2.6 Implement `EventEmitter<AuthStateChanged>` for `AuthStateController`
- [x] 2.7 Add `pub mod auth_state;` to `dtrpg-ui/src/controllers/mod.rs`
- [x] 2.8 Write unit tests: `new()` defaults to `Unauthenticated`; `set_state(Authenticated)` clears notices; `dismiss_notice` removes only the target notice from `active_notices()`

## 3. Root View Integration

- [x] 3.1 Construct `Entity<AuthStateController>` in `LibraryRootView::new()` alongside the existing `LibraryController` and `SettingsController` entities
- [x] 3.2 Subscribe to `AuthStateChanged` in `LibraryRootView::new()` with `cx.subscribe` → `cx.notify()`; detach the subscription
- [x] 3.3 In `LibraryRootView::render()`, call `self.auth_state.read(cx).active_notices().to_vec()` to get the current notice list
- [x] 3.4 Pass `auth_entity` and `settings_entity` to the `NotificationBanner` render function; insert the banner between the toolbar and catalog in the main content column

## 4. NotificationBanner View

- [x] 4.1 Create `dtrpg-ui/src/ui/views/notification_banner_view.rs`
- [x] 4.2 Implement `render_notification_banner(notices, auth_entity, settings_entity, colors) -> AnyElement`: returns an empty `div()` when `notices` is empty; otherwise renders the banner column
- [x] 4.3 Render the banner with a warning-tinted background: `gpui::hsla(0.11, 0.9, 0.5, 0.12)` (amber, 12% opacity) on top of `surface`; add a bottom border in `border_strong`
- [x] 4.4 For each notice, render a row containing: notice message text, primary action button, and dismiss × button
- [x] 4.5 "Not signed in" row: message = `"Not signed in to DriveThruRPG"`, action button label = `"Set Up Account"`
- [x] 4.6 "Session expired" row: message = `"Session expired — sign in again to refresh your library"`, action button label = `"Sign In Again"`
- [x] 4.7 Action button click handler: call `settings_entity.update(|ctrl, cx| { ctrl.set_tab(SettingsTab::Account, cx); ctrl.open(cx); })`
- [x] 4.8 Dismiss × click handler: call `auth_entity.update(|ctrl, cx| ctrl.dismiss_notice(notice.kind, cx))`
- [x] 4.9 Add `pub mod notification_banner_view;` to `dtrpg-ui/src/ui/views/mod.rs`

## 5. Color Token Addition

- [x] 5.1 Add `warning_bg: Hsla` and `warning_text: Hsla` fields to `ColorTokens` in `dtrpg-ui/src/data/theme.rs`
- [x] 5.2 Set `warning_bg = hsla(0.11, 0.9, 0.5, 0.12)` and `warning_text = hsla(0.08, 0.85, 0.35, 1.0)` in the existing theme construction; update both light and dark variants if they diverge
- [x] 5.3 Use `colors.warning_bg` and `colors.warning_text` in `render_notification_banner` instead of hardcoded values

## 6. Verification

- [x] 6.1 Run `DTRPG_AUTH_STATE_OVERRIDE=unauthenticated cargo run`; confirm the amber banner appears below the toolbar with "Not signed in" and a "Set Up Account" button
- [x] 6.2 Click "Set Up Account"; confirm the settings panel opens on the Account tab
- [x] 6.3 Click the × dismiss button; confirm the banner disappears
- [x] 6.4 Run `DTRPG_AUTH_STATE_OVERRIDE=expired cargo run`; confirm the "Session expired" banner appears and "Sign In Again" opens the Account tab
- [x] 6.5 Run `DTRPG_AUTH_STATE_OVERRIDE=authenticated cargo run`; confirm no banner is rendered and the catalog fills the full content height
- [x] 6.6 Run `cargo check -p dtrpg-ui` and confirm zero errors
- [x] 6.7 Run `cargo test -p dtrpg-ui` and confirm `AuthStateController` unit tests pass
