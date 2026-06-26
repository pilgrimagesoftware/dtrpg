## Why

Authentication and session behavior now live at several layers of the DriveThruRPG repo family, but there is no umbrella change that explains how API contract updates, SDK behavior, and desktop app UX should move together. That makes auth work easy to start locally and easy to mis-sequence across repositories.

## What Changes

- Introduce a top-level capability that defines how cross-repo auth/session initiatives are coordinated.
- Define the dependency order between API, SDK, and app changes for auth/session lifecycle work.
- Record the child repositories expected to carry implementation-level proposals for API contract, SDK behavior, and app UX changes.
- Clarify that cross-repo auth/session rollout planning belongs in the top-level meta-repository rather than any single implementation repository.

## Capabilities

### New Capabilities
- `auth-session-rollout`: Defines how umbrella auth/session initiatives are scoped, sequenced, and delegated across the repo family.

### Modified Capabilities
- `cross-repo-compatibility`: Clarifies that compatibility planning must capture auth/session dependency order across API, SDK, and app repositories.

## Impact

- `dtrpg/openspec`: New umbrella capability and rollout guidance
- `dtrpg-api`: Will eventually need a child change for token/session contract details
- `dtrpg-sdk` and language SDK repos: Will eventually need child changes for auth lifecycle behavior
- `dtrpg-app` and app implementation repos: Will eventually need child changes for session expiry and recovery UX
