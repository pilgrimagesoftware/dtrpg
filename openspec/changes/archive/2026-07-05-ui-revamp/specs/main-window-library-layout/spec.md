## REMOVED Requirements

### Requirement: Main window MUST define a low-profile search and filter area
**Reason**: Search, sort, and view mode controls move into the catalog tab's own header, defined by `main-window-tabs`; navigation by collection and publisher moves into the collapsible sidebar, defined by `main-window-sidebar-navigation`.
**Migration**: Child app implementations move their existing search/filter/view-mode controls from the standalone disclosable strip into the catalog tab header, and move collection/publisher navigation into the sidebar sections.

### Requirement: Main window MUST expose account actions through an account menu
**Reason**: The account button and its menu move from the content area into the title bar, defined by `main-window-title-bar`.
**Migration**: Child app implementations relocate the account button and its menu contents (identity, token actions, settings) to the title bar; the title bar's account menu additionally exposes sign-out directly.

### Requirement: Main window MUST summarize the visible library contents
**Reason**: Library and content-area summary counts move into the status bar, defined by `main-window-status-bar`.
**Migration**: Child app implementations move total, filtered, and section count displays from the content area into the status bar's active content area summary.

### Requirement: Main window MUST show non-blocking sync and update status
**Reason**: Sync/update status is superseded by the status bar's activity indicator, defined by `main-window-status-bar`, which covers general operation progress rather than sync specifically.
**Migration**: Child app implementations report sync/update operations through the activity indicator's in-progress/completed counts and detail surface instead of a dedicated sync status element.
