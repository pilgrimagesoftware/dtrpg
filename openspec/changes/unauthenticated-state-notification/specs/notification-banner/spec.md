## ADDED Requirements

### Requirement: Notification banner renders below the toolbar when notices are present
The system SHALL render a notification banner between the toolbar and the catalog content area when one or more notices are queued.  When no notices are present, the banner SHALL not occupy any vertical space.

#### Scenario: Unauthenticated state shows banner
- **WHEN** `AuthState` is `Unauthenticated`
- **THEN** the notification banner is visible with the message "Not signed in" and a "Set Up Account" action button

#### Scenario: Expired session shows banner
- **WHEN** `AuthState` is `SessionExpired`
- **THEN** the notification banner is visible with the message "Session expired" and a "Sign In Again" action button

#### Scenario: Authenticated state hides banner
- **WHEN** `AuthState` is `Authenticated`
- **THEN** the notification banner is not rendered and the catalog occupies the full content height

### Requirement: Notification action navigates to the Account settings tab
The system SHALL open the settings panel to the Account tab when the user activates the primary action button in an auth-related notification.

#### Scenario: "Set Up Account" button pressed
- **WHEN** the user clicks "Set Up Account" in the "Not signed in" notification
- **THEN** `SettingsController` opens with the Account tab selected

#### Scenario: "Sign In Again" button pressed
- **WHEN** the user clicks "Sign In Again" in the "Session expired" notification
- **THEN** `SettingsController` opens with the Account tab selected

### Requirement: Notification banner is dismissible per session
The system SHALL render a dismiss control (×) on each notification.  When dismissed, the notice SHALL not reappear until the next app launch.  Dismissal does not change `AuthState`.

#### Scenario: User dismisses the banner
- **WHEN** the user clicks × on the notification banner
- **THEN** the banner is hidden for the remainder of the session even if `AuthState` remains `Unauthenticated`

#### Scenario: Banner reappears after restart
- **WHEN** the app is restarted and `AuthState` is still `Unauthenticated`
- **THEN** the notification banner is visible again (the dismissal was session-scoped only)

### Requirement: Notification banner supports multiple queued notices
The system SHALL support displaying more than one notice simultaneously.  Notices SHALL be priority-ordered: auth notices appear above informational notices.  Each notice has its own dismiss control.

#### Scenario: Multiple notices queued
- **WHEN** both an auth notice and a separate informational notice are active
- **THEN** the auth notice is displayed above the informational notice in the banner

#### Scenario: Dismissing one notice leaves others visible
- **WHEN** the user dismisses one notice in a multi-notice banner
- **THEN** only that notice is removed; remaining notices stay visible

### Requirement: Notification banner is visually distinct from the toolbar and catalog
The banner SHALL use a warning-tinted background color that clearly differentiates it from the toolbar above and the catalog below.  Text and action buttons SHALL meet a minimum 4.5:1 contrast ratio against the banner background.

#### Scenario: Banner background color
- **WHEN** the notification banner renders
- **THEN** it uses a warning-tinted background distinct from `ColorTokens::surface` and `ColorTokens::surface_alt`
