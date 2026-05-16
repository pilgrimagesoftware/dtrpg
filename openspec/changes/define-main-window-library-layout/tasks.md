## 1. Umbrella Specification

- [x] 1.1 Review `main-window-library-layout` requirements with the app repositories and confirm the required main window regions
- [x] 1.2 Confirm `cross-repo-compatibility` captures the child repository responsibilities for shared desktop UI layout work
- [x] 1.3 Identify whether Swift, Rust, or both desktop apps are in scope for the first implementation pass

## 2. Child Proposal Planning

- [x] 2.1 Create or update a `dtrpg-app` child proposal that maps the shared layout contract to app-level coordination
- [x] 2.2 Create or update a `dtrpg-app/swift` child proposal for the native macOS main-window layout implementation
- [x] 2.3 Create or update a `dtrpg-app/rust` child proposal if the Rust desktop app will implement the same library browsing surface

## 3. Layout Implementation Readiness

- [x] 3.1 Define the shared library browsing state needed by search, filters, view mode, grouping, sorting, and summary counts
- [x] 3.2 Define account menu state for account identity, access-token status, set/reset token actions, and settings navigation
- [x] 3.3 Define background sync status state for progress, latency, last update, and tooltip detail
- [x] 3.4 Confirm thumbnail loading and library metadata display can remain responsive while sync work runs

## 4. Verification

- [ ] 4.1 Verify expanded and collapsed search/filter states in each child app implementation
- [ ] 4.2 Verify list/tree and grid views use the same filtered and sorted library result set
- [ ] 4.3 Verify grouped grid sections report correct section and item summary counts
- [ ] 4.4 Verify account menu actions are reachable without exposing raw access-token values outside token edit flows
- [ ] 4.5 Verify library sync/update activity does not block main window interaction
