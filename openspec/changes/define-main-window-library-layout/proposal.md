## Why

The desktop application needs a consistent main-window layout for browsing DriveThruRPG library content before implementation diverges across app repositories. Defining the layout as an umbrella change lets the meta-repository coordinate shared UX expectations while leaving platform-specific implementation details to the child app repositories.

## What Changes

- Introduce a top-level capability for coordinating the main window library browsing layout across desktop app implementations.
- Define the required main window regions: low-profile search/filter controls, account menu access, library content display, view summary, and background sync status.
- Require both list/tree and grid browsing presentations for library content, with sorting, filtering, grouping, and section summaries represented consistently.
- Require the account button menu to expose DriveThruRPG account identity, access-token actions, and application settings access.
- Require sync/update indicators to remain low profile and non-blocking, with detail available through tooltip or equivalent affordance.
- Record the child app repositories expected to carry implementation-level proposals for native UI behavior.

## Capabilities

### New Capabilities

- `main-window-library-layout`: Defines the shared UX requirements for the desktop app main window library browsing surface.

### Modified Capabilities

- `cross-repo-compatibility`: Extends compatibility planning to include desktop UI layout initiatives that depend on shared library data models, auth state, and application implementation work.

## Impact

- `dtrpg/openspec`: New umbrella capability and rollout guidance
- `dtrpg-app`: Needs child implementation proposals for desktop app shell layout coordination
- `dtrpg-app/swift`: Needs a child change for native macOS main-window UI behavior
- `dtrpg-app/rust`: Needs a child change if the Rust desktop app shares the same library browsing surface
- `dtrpg-sdk` and `dtrpg-api`: No new contract is required by this proposal, but implementations depend on existing library item metadata and auth/session state being available to the app layer
