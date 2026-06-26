## Context

The application currently has no concept of authentication state at the view layer. The `LibraryController` initializes with a stub catalog regardless of whether credentials are present. When `secure-credential-storage` is complete, the SDK will require a valid session before returning real data — at that point the catalog would be empty and the user would have no guidance on why or what to do.

This change introduces an `AuthStateController` (a lightweight gpui `Entity`) that is the single source of truth for auth state and a `NotificationBanner` view component that bridges it to the user. Both are designed so they can be wired to the real credential store with a one-line change once `secure-credential-storage` ships.

The `add-settings-view` change established `SettingsController` as a second entity in `LibraryRootView`. This change adds a third entity (`AuthStateController`) and a new render slot (the notification banner) between the toolbar and the catalog.

## Goals / Non-Goals

**Goals:**
- An `AuthStateController` entity that emits `AuthStateChanged` on transitions and exposes the current `AuthState`.
- A `NotificationBanner` view component that renders zero height when empty and a warning-tinted banner row per notice when notices are present.
- Auth-related notices (`NotSignedIn`, `SessionExpired`) carry an action that opens `SettingsController` to the Account tab.
- A dismissible-per-session in-memory flag so dismissed notices don't reappear until the next launch.
- Stub implementation driven by `DTRPG_AUTH_STATE_OVERRIDE` env var so the feature is exercisable without a real credential store.
- Swift app parity: an equivalent banner under the toolbar (or a SwiftUI `.toolbar` badge) once the Swift app target exists.

**Non-Goals:**
- Performing the actual authentication flow (that belongs in `secure-credential-storage` and the Account settings section).
- Persisting dismissals across app restarts (dismissal is session-scoped by design).
- General-purpose notification routing infrastructure (toast-style, timed, push-driven) — this is a targeted auth-state affordance.
- Displaying notices for non-auth events (download errors, network issues) — those are separate concerns.

## Decisions

### Decision 1: `AuthStateController` is a separate `gpui::Entity`, not merged into `SettingsController`

Auth state and settings state have different lifecycles and subscribers. Auth state is checked at startup, updated by the SDK layer, and observed by multiple views (library, notification banner, account section in settings). Settings open/close state is owned by `SettingsController` as a UI concern. Merging them would couple the credential layer to the settings UI.

`AuthStateController` is constructed in `LibraryRootView::new()` alongside `LibraryController` and `SettingsController`, and its `AuthStateChanged` event triggers `cx.notify()` in the root view — the same pattern used for `LibraryChanged` and `SettingsChanged`.

**Alternative considered**: Expose auth state as a field on `SettingsController`. Rejected because settings concerns should not require being aware of credential reads, and the auth state will eventually be driven by the SDK session manager, not the settings UI.

### Decision 2: `NotificationBanner` renders inline between the toolbar and catalog, not as an overlay

A banner inserted into the vertical flex layout (toolbar → banner → catalog) is naturally zero-height when empty and pushes the catalog down proportionally when notices are present. This is simpler than an absolute-positioned overlay and avoids obscuring catalog content.

The banner is rendered by `LibraryRootView` inside the main content column div, conditioned on `!notices.is_empty()`.

**Alternative considered**: Overlay positioned absolute at the top of the catalog. Rejected — it would cover the first row of catalog items and require explicit z-ordering.

### Decision 3: Notice list is owned by `AuthStateController`, not a separate `NotificationQueue`

For the scope of this change (auth-only notices), the notice list is a `Vec<Notice>` inside `AuthStateController`. `Notice` has a `kind: NoticeKind` (auth-specific variants), a `dismissed: bool` flag, and an `action: NoticeAction` (e.g., `OpenSettings(SettingsTab)`). When `AuthState` changes, `AuthStateController` regenerates the active notice list and emits `AuthStateChanged`.

**Alternative considered**: A global notification queue singleton that any controller can push to. More general but significantly more complex. Deferred to a future change if non-auth notices are ever needed.

### Decision 4: Action dispatch uses a callback rather than direct `SettingsController` coupling in `AuthStateController`

`NotificationBanner` view receives both the `Entity<AuthStateController>` and the `Entity<SettingsController>` from `LibraryRootView`. When the action button is clicked, the view directly calls `settings_entity.update(|ctrl, cx| ctrl.set_tab(SettingsTab::Account, cx)); settings_entity.update(|ctrl, cx| ctrl.open(cx))`. `AuthStateController` does not hold a reference to `SettingsController`.

This keeps `AuthStateController` free of UI dependencies and consistent with how other controllers communicate — through the view layer, not through direct entity-to-entity calls.

### Decision 5: Stub implementation reads `DTRPG_AUTH_STATE_OVERRIDE` at controller construction

`AuthStateController::new()` reads the env var once and sets the initial `AuthState`. When the real credential store is available, `new()` will call the store's `read()` method instead. This is a one-line change at `new()` — no view layer changes required. The env var fallback is guarded by `#[cfg(debug_assertions)]` so it cannot be used in release builds.

## Risks / Trade-offs

**[Risk] `AuthStateController` transitions are not reactive to external credential changes (e.g., another process deletes the keychain entry)** → Mitigation: Acceptable for the current scope. Real-time credential watching can be added later via a background polling task or OS keychain notification.

**[Risk] The notification banner adds a third entity subscription in `LibraryRootView`, increasing render complexity** → Mitigation: Each entity subscription is a single `cx.subscribe()` call that triggers `cx.notify()`. The pattern is established and cheap. The root view's render function already reads from two entities; adding a third is straightforward.

**[Risk] Notice dismissal state lives in memory and is lost if the app crashes before shutdown** → Mitigation: This is intentional (dismissal is session-scoped). Users who dismiss a notice and then crash will see it again on restart, which is the correct behavior.

**[Risk] The `DTRPG_AUTH_STATE_OVERRIDE` env var could be set accidentally in a production build** → Mitigation: The env var read is wrapped in `#[cfg(debug_assertions)]`, which is false in release builds.

## Migration Plan

New capability — no migration required. Rollout order:

1. Define `AuthState`, `AuthStateController`, and `AuthStateChanged` in `dtrpg-ui`.
2. Construct `AuthStateController` in `LibraryRootView::new()` and subscribe.
3. Implement `NotificationBanner` view.
4. Insert `NotificationBanner` into the main content column between toolbar and catalog.
5. Wire the action button in the banner to `SettingsController::open()` + `set_tab(Account)`.
6. Verify with `DTRPG_AUTH_STATE_OVERRIDE=unauthenticated` / `authenticated` / `expired`.
7. When `secure-credential-storage` ships, replace the env-var stub in `AuthStateController::new()` with a real credential store read.

## Open Questions

- **Session expiry check frequency**: Should `AuthStateController` poll for token expiry periodically while the app is running, or only at launch? Polling adds complexity; at-launch-only misses mid-session expiry but is simpler and sufficient for the initial release.
- **Banner height and layout**: Should the banner collapse with an animation or snap in/out? gpui does not have built-in animation primitives — a snap change is the correct starting point.
- **Multiple simultaneous notices**: The spec allows multiple notices, but the initial auth-state model produces at most one auth notice. Is the multi-notice path worth implementing now or can it be deferred?
