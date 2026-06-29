## Why

When the application launches without valid credentials, the catalog view renders in a meaningless state (empty or with stub data) and the user has no affordance to understand what is wrong or how to fix it. The application must guide unauthenticated users to set up their account rather than silently presenting a broken experience.

## What Changes

- Add an authentication state check evaluated at app startup and whenever the session becomes invalid.
- Introduce a persistent notification banner/area in the main window that appears when the user is unauthenticated or the session has expired.
- Notifications are interactive: the "Not signed in" banner contains a primary action button that opens the Settings panel directly to the Account tab.
- The notification area is dismissible but reappears on next launch while the user remains unauthenticated.
- When credentials are successfully established, the notification area clears automatically without requiring an app restart.

## Capabilities

### New Capabilities

- `auth-state-awareness`: Track and expose authentication state (unauthenticated, authenticated, session-expired) to the UI layer so views can branch on it.
- `notification-banner`: A dismissible, action-bearing notification banner rendered below the toolbar in `LibraryRootView`; can display one or more priority-ordered notices.

### Modified Capabilities

- None.

## Impact

- **Rust app** (`dtrpg-ui`): `LibraryRootView`, `SettingsController`, new `NotificationBanner` view, new `AuthStateController` (or auth state exposed through `SettingsController`).
- **Dependencies**: Requires `secure-credential-storage` to read the actual auth state; stubs via an env-var or in-memory flag until that change is complete.
- No API or SDK changes required.
