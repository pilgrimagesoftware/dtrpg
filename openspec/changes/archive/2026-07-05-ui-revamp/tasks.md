## 1. Umbrella Specification

- [x] 1.1 Review the title bar, sidebar, tabs, and status bar requirements with the app repositories
- [x] 1.2 Confirm which parts of `main-window-library-layout` are retired versus carried forward unchanged
- [x] 1.3 Confirm `cross-repo-compatibility` captures dependency on existing `activity-panel`, `notification-banner`, `app-menu-bar`, and settings capabilities

## 2. Child Proposal Planning

- [x] 2.1 Create or update a `dtrpg-app` child proposal coordinating the shared title bar, sidebar, tabs, and status bar structure
- [x] 2.2 Create or update a `dtrpg-app/rust` child proposal implementing the structure with gpui-components, referencing the gallery demo
- [x] 2.3 Create or update a `dtrpg-app/swift` child proposal implementing the equivalent SwiftUI/AppKit structure

## 3. Layout Implementation Readiness

- [x] 3.1 Define title bar state: window title, account button, and account menu contents (user info, settings, sign out)
- [x] 3.2 Define sidebar state: default section counts, Collections section (count, search, add, collapse), Publishers section (count, search, collapse)
- [x] 3.3 Define tab state: non-closable catalog tab, dynamic segmented tabs, overflow "more" menu, closable detail tabs
- [x] 3.4 Define catalog item interaction state: single-click popover detail vs. double-click expanded detail tab
- [x] 3.5 Define expanded detail tab content: large thumbnail, attributes, file list for multi-item entries
- [x] 3.6 Define status bar state: total item count and size, active tab summary with selection count, theme picker, activity indicator, notification indicator

## 4. Verification

- [x] 4.1 Verify the title bar separator, title, and account menu render and open correctly
- [x] 4.2 Verify sidebar collapse/expand and per-section search, add, and collapse affordances behave as in the current sidebar
- [x] 4.3 Verify the catalog tab is never closable and always reachable regardless of how many detail tabs are open
- [x] 4.4 Verify single-click opens a popover without creating a tab, and double-click opens a closable expanded detail tab
- [x] 4.5 Verify status bar hover states show summary counts and click states open the corresponding detail surfaces
- [x] 4.6 Verify status bar and tab summary counts stay in sync with sidebar navigation and catalog filtering state
