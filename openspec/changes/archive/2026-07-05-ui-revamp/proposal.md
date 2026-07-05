## Why

The main window layout defined by `main-window-library-layout` puts search, filter, view mode, and sort controls in a disclosable strip above the content area, with no title bar, no persistent navigation sidebar, and no way to keep multiple items open at once. Browsing DriveThruRPG libraries with collections and publishers as first-class navigation, and inspecting more than one catalog entry at a time, needs a window structure with a title bar, a collapsible navigation sidebar, tabbed content, and a status bar that consolidates library counts, sync activity, notifications, and theme selection. This umbrella change redefines the shared main window structure that child app repositories implement.

## What Changes

- Add a title bar region above the content area, separated by a horizontal rule, containing the window title and an account button that opens a menu with user info, settings, and sign out.
- Add a collapsible left sidebar with default navigation sections showing item counts, plus the existing Collections section (count, search, add button, collapsible) and Publishers section (count, search, collapsible).
- Add a tabbed main content area with a dynamic segmented tab strip and overflow ("more") menu. The first tab (catalog) is non-closable; catalog search, sort, and view mode controls move into this tab's own header instead of a separate disclosable filter strip.
- Add single-click-to-popover and double-click-to-tab interactions for catalog items: single-click opens a popover detail view; double-click opens an expanded detail view as a new closable tab, showing a large thumbnail, item attributes, and a file list when the entry has multiple items.
- Add a status bar with total library item count and size, a divider, a summary of the active content area (title, item count, selection count), a theme picker (hover shows current theme, click opens a theme menu), an activity indicator (hover shows in-progress/completed counts, click opens activity detail), and a notification indicator (bell icon with unread badge, hover shows unread count, click opens the notification panel).
- Modify `main-window-library-layout` to retire the standalone disclosable search/filter area and generic sync status requirements in favor of the catalog tab header and status bar defined by this change; list/tree/grid presentation and summary-state requirements carry forward unchanged.
- Modify `cross-repo-compatibility` to record that this revamp coordinates with the existing `activity-panel`, `notification-banner`, `app-menu-bar`, and settings-related app-level capabilities already implemented in `dtrpg-app` child repositories.

## Capabilities

### New Capabilities

- `main-window-title-bar`: Defines the title bar region and account menu entry point.
- `main-window-sidebar-navigation`: Defines the collapsible navigation sidebar and its default, Collections, and Publishers sections.
- `main-window-tabs`: Defines the tabbed content area, the non-closable catalog tab, and popover/tab detail interactions.
- `main-window-status-bar`: Defines the status bar's library summary, theme picker, activity indicator, and notification indicator.

### Modified Capabilities

- `main-window-library-layout`: Retires the standalone search/filter strip and generic sync status requirements in favor of the catalog tab header and status bar; list/tree/grid presentation requirements are unaffected.
- `cross-repo-compatibility`: Extends coordination guidance to cover this revamp's dependency on existing activity, notification, menu bar, and settings capabilities in the app repositories.

## Impact

- `dtrpg/openspec`: New and modified umbrella capabilities for the main window structure.
- `dtrpg-app`: Needs a child implementation proposal mapping the shared window structure (title bar, sidebar, tabs, status bar) to app-level coordination.
- `dtrpg-app/swift`: Needs a child change for the native macOS title bar, sidebar, tab, and status bar implementation.
- `dtrpg-app/rust`: Needs a child change for the gpui-based title bar, sidebar, tab, and status bar implementation, referencing the gpui-components gallery demo.
- `dtrpg-sdk` and `dtrpg-api`: No new contract required; implementations depend on existing library, collection, publisher, activity, and notification data already available to the app layer.
