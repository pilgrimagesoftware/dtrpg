## Context

The DriveThruRPG repository family already separates API contracts, SDK behavior, and desktop applications into child repositories. The app meta-repository contains shared desktop library proposals, and the Swift and Rust app repositories contain implementation-level OpenSpec changes for baseline library UI work.

This change defines the top-level UX contract for the main window layout. It does not prescribe one toolkit-specific implementation, but it does establish the required regions and interaction semantics that child app repositories must preserve.

## Goals / Non-Goals

**Goals:**

- Define the main window as a library browsing surface with search/filter controls, account access, content presentation, view summary, and background sync status.
- Keep search/filter controls low profile and disclosable so they remain useful without dominating the main window.
- Require list/tree and grid presentations to use the same filtering, sorting, grouping, and summary state.
- Define account-menu expectations for DriveThruRPG account identity, token management, and settings access.
- Require sync/update work to happen in the background with visible but unobtrusive status.
- Delegate native UI implementation details to `dtrpg-app`, `dtrpg-app/swift`, and `dtrpg-app/rust`.

**Non-Goals:**

- Define a new DriveThruRPG API contract.
- Define new SDK library models or authentication behavior.
- Mandate a specific native UI toolkit component hierarchy.
- Implement downloads, batch actions, or file-management workflows beyond displaying library metadata.
- Define exact typography, colors, iconography, or animation timing.

## Decisions

### 1. Top-level layout contract, child repository implementation

The top-level `dtrpg` repo owns the shared main-window layout capability. Child app repositories own toolkit-specific implementation proposals and code changes.

**Rationale:** The same user-facing window structure should remain recognizable across desktop implementations, but SwiftUI/AppKit and Rust/GPUI will have different component and state-management details.

**Alternative considered:** Define the layout only inside one app repository. This would be faster for a single implementation but would make the other desktop app more likely to diverge.

### 2. Disclosable low-profile search/filter area

The search/filter area is a compact control strip that can expand to show the full search input and dropdown controls. When collapsed, it shows a concise summary of the active query, filter, view mode, grouping, and sort state.

**Rationale:** Library browsing needs filtering power, but the main content should remain the primary surface. A disclosable control strip supports both focused browsing and compact day-to-day use.

**Alternative considered:** Permanent full filter sidebar. This would provide discoverability but would consume too much window space for a library-focused app.

### 3. Account button as a menu entry point

The account surface is a button that opens a compact account menu, inspired by Zed's low-profile account menu pattern. The menu exposes identity/status information first, then account actions such as setting or resetting the access token and opening application settings.

**Rationale:** Account state is important but not the primary task. A compact menu keeps authentication and settings available without introducing a dedicated account page into the main browsing flow.

**Alternative considered:** Put account state inside the filter area. This mixes unrelated concerns and makes the filter strip responsible for authentication actions.

### 4. Shared library presentation state

List/tree and grid views share the same query, filter, grouping, view mode, and sort state. Grid sections can be grouped by publisher, type, or another supported grouping mode; list/tree mode uses the same grouping state to choose flat list versus hierarchical presentation.

**Rationale:** Users should not get different result sets when switching view modes. View changes should affect presentation, not the underlying filtered library state.

**Alternative considered:** Maintain separate state per view. This preserves per-view customization but makes summary counts and mode switching harder to reason about.

### 5. Summary and sync as persistent low-profile status

The main window includes a summary of visible library contents and a low-profile sync indicator. Sync runs in the background, updates progress independently of UI interaction, and exposes details such as progress, latency, and last update through a tooltip or equivalent platform affordance.

**Rationale:** Library metadata can be stale or actively syncing while the user browses. The UI must communicate this without blocking input or replacing the browsing surface.

**Alternative considered:** Show modal progress during sync. This would be simpler to implement but would make the app feel unresponsive and would block library browsing.

## Risks / Trade-offs

- **Risk: Cross-app visual drift** -> Mitigation: Keep normative requirements at the interaction and information-architecture level, then require child app proposals to map them to each toolkit.
- **Risk: Filter controls become too dense** -> Mitigation: Require a collapsed summary and keep expanded controls limited to search, view mode, grouping, and sort controls unless a child proposal justifies more.
- **Risk: Large libraries make filtering or grouping expensive** -> Mitigation: Require background sync and non-blocking UI behavior; child app proposals should profile filtering and move expensive work off the UI thread where needed.
- **Risk: Account token actions expose sensitive state** -> Mitigation: The menu may show account identity and token status, but child implementations must avoid displaying raw access-token values unless explicitly performing a token edit flow.
- **Risk: Grid thumbnails may load slowly** -> Mitigation: Child implementations should treat thumbnail loading as asynchronous and preserve title/size metadata display while images resolve.

## Migration Plan

1. Land this top-level OpenSpec change to establish the shared contract.
2. Add or update child proposals in `dtrpg-app` for shared desktop layout coordination.
3. Add or update implementation proposals in `dtrpg-app/swift` and `dtrpg-app/rust` to map the shared contract to native UI components.
4. Implement each app behind the existing library UI architecture, preserving current baseline behavior until the new layout is ready.
5. Advance the parent submodule references only after child app changes are complete and verified.

## Open Questions

- Should the first implementation prioritize Swift, Rust, or keep both in lockstep?
- Which grouping modes beyond publisher and type should be included in the first shipped layout?
- Should the collapsed filter summary be interactive, or should it only disclose the expanded controls?
- What thumbnail source should the grid use when a library item has no cached cover image?
