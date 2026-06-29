# auth-state-awareness Specification

## Purpose
TBD - created by archiving change unauthenticated-state-notification. Update Purpose after archive.
## Requirements
### Requirement: Auth state is tracked in a dedicated controller
The system SHALL maintain a single authoritative `AuthState` value (`Unauthenticated`, `Authenticated`, `SessionExpired`) accessible to all views via an `AuthStateController` entity.  The initial state SHALL be derived at startup by querying the credential store; while the credential store is absent or returns no credential, the state SHALL default to `Unauthenticated`.

#### Scenario: Fresh install with no credentials
- **WHEN** the app launches and the credential store contains no DTRPG credentials
- **THEN** `AuthStateController` emits `AuthState::Unauthenticated`

#### Scenario: Valid session present at launch
- **WHEN** the app launches and the credential store contains a valid, non-expired access token
- **THEN** `AuthStateController` emits `AuthState::Authenticated`

#### Scenario: Stored token has expired
- **WHEN** the app launches and the credential store contains a token whose expiry timestamp is in the past
- **THEN** `AuthStateController` emits `AuthState::SessionExpired`

### Requirement: Auth state updates propagate to subscribed views without restart
The system SHALL emit an `AuthStateChanged` event whenever `AuthState` transitions, and `LibraryRootView` SHALL re-render in response.

#### Scenario: User authenticates while the app is running
- **WHEN** the user completes authentication in the Account settings section
- **THEN** `AuthStateController` transitions to `Authenticated` and the notification banner clears within one render cycle

#### Scenario: Session expires while the app is running
- **WHEN** a previously valid token expires during an active session
- **THEN** `AuthStateController` transitions to `SessionExpired` and the notification banner reappears

### Requirement: Auth state is stubbed when credential store is unavailable
The system SHALL fall back to reading the environment variable `DTRPG_AUTH_STATE_OVERRIDE` (`"authenticated"` | `"unauthenticated"` | `"expired"`) when the credential store implementation is absent.  If the variable is unset, the stub SHALL return `Unauthenticated`.

#### Scenario: Stub override set to authenticated
- **WHEN** `DTRPG_AUTH_STATE_OVERRIDE=authenticated` is set in the environment
- **THEN** `AuthStateController` reports `Authenticated` without querying a real credential store

#### Scenario: Stub override absent
- **WHEN** `DTRPG_AUTH_STATE_OVERRIDE` is not set and no credential store is wired
- **THEN** `AuthStateController` reports `Unauthenticated`

