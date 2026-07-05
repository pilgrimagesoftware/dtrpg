## Context

`main-window-library-layout` defined the current baseline: a disclosable search/filter strip, account button menu, list/tree/grid content, a summary line, and a low-profile sync indicator. That baseline predates collection/publisher navigation and multi-tab browsing, both of which the app now needs. This change restructures the window around a title bar, a persistent navigation sidebar, tabbed content, and a consolidated status bar, using the gpui-components gallery demo as the reference interaction model for the Rust app.

## Goals / Non-Goals

**Goals:**

- Give the window a conventional title bar with the account menu, separated from content by a horizontal rule.
- Make collection and publisher navigation persistent and collapsible instead of living inside a disclosable filter strip.
- Support browsing more than one catalog entry at a time via closable tabs, while keeping the catalog itself always reachable through a non-closable first tab.
- Distinguish a lightweight popover inspection (single click) from a full expanded detail view (double click) without forcing every inspection into a new tab.
- Consolidate library counts, sync/activity status, notifications, and theme selection into a single status bar.
- Preserve the list/tree/grid presentation and summary-state requirements already defined by `main-window-library-layout`.

**Non-Goals:**

- Define a new DriveThruRPG API contract or SDK model.
- Mandate exact pixel dimensions, animation timing, or theme palette values.
- Define the notification panel's or activity panel's internal content beyond what `notification-banner` and `activity-panel` already specify.
- Replace or duplicate the multi-item entry detail contract already defined by `multi-item-catalog-entry-detail`; the tabbed expanded detail view reuses that contract.

## Decisions

### 1. Title bar as a distinct region, not part of the content area

The title bar sits above a horizontal separator and contains only the window title and the account button/menu. It does not host search, filter, or view controls.

**Rationale:** Keeps window-level chrome (title, account) separate from content-level chrome (search, sort, tabs), so each region has a single responsibility.

**Alternative considered:** Keep the account button inside the content area as before. Rejected because it conflated window identity/account concerns with catalog browsing controls.

### 2. Sidebar replaces the disclosable filter strip as the primary navigation surface

The collapsible left sidebar shows default sections with counts, then Collections and Publishers sections, each with their own count/search/collapse affordances (carried over unchanged from the current sidebar implementation).

**Rationale:** Collection and publisher navigation are frequent, persistent tasks; a collapsible sidebar keeps them one click away without competing for the same disclosure affordance as catalog search/sort/view controls.

**Alternative considered:** Keep collections/publishers inside the disclosable filter strip. Rejected because it mixed navigation (which library subset am I browsing) with query refinement (search, sort, view mode) in one control.

### 3. Tabs separate persistent catalog browsing from transient item inspection

The catalog tab is always present and non-closable. Search, sort, and view mode controls move into this tab's own header. Double-clicking an item opens its expanded detail as a new closable tab; single-clicking opens a popover that does not consume a tab.

**Rationale:** Users need to keep browsing the catalog while comparing multiple items' full detail, without losing their place or accumulating unwanted tabs for quick look-ups.

**Alternative considered:** Always show item detail as a popover. Rejected because a popover does not support side-by-side comparison of multiple items' full attributes and file lists.

### 4. Status bar consolidates cross-cutting indicators

Library totals, current-tab summary, theme picker, activity indicator, and notification indicator all live in the status bar, each exposing detail through hover (a lightweight summary) and click (a detail surface).

**Rationale:** These are all low-profile, always-relevant signals that should not compete with the tab strip or sidebar for attention, and a single status bar row gives them a consistent interaction pattern (hover for summary, click for detail).

**Alternative considered:** Keep sync/activity status as a standalone element in the content area, as in the original layout. Rejected because it left theme, notification, and count summaries with no consistent home.

## Risks / Trade-offs

- **Risk: Retiring the filter strip breaks existing child app behavior** -> Mitigation: List/tree/grid presentation and summary-state requirements from `main-window-library-layout` carry forward; only the container for search/sort/view controls moves to the catalog tab header.
- **Risk: Tab proliferation from double-clicking many items** -> Mitigation: Child app proposals should define tab overflow behavior via the "more" menu; this change does not cap tab count but requires the overflow affordance to exist.
- **Risk: Status bar becomes cluttered on narrow windows** -> Mitigation: Child implementations should define a minimum window width or a status bar overflow strategy; the umbrella requirement fixes content, not exact layout at small sizes.
- **Risk: Popover vs. tab distinction is not discoverable** -> Mitigation: Child app proposals should provide a visible affordance (e.g., an "Open in tab" action) as an alternative to double-click for accessibility and discoverability.

## Migration Plan

1. Land this top-level OpenSpec change to establish the revised window structure and retire the superseded parts of `main-window-library-layout`.
2. Add or update a `dtrpg-app` child proposal coordinating the shared title bar, sidebar, tabs, and status bar across app implementations.
3. Add or update `dtrpg-app/rust` and `dtrpg-app/swift` child proposals mapping the structure to gpui-components and SwiftUI/AppKit respectively.
4. Implement behind the existing sidebar, activity panel, and notification banner behavior, extending rather than replacing those app-level capabilities.
5. Advance parent submodule references only after child app changes are complete and verified.

## Open Questions

- Should popover detail views support a keyboard or menu-driven path to "promote" into a tab without requiring a second double-click?
- What is the maximum number of open detail tabs before the overflow menu becomes the primary access path?
- Should the theme picker's click-menu list themes by name only, or also show a live preview swatch?
