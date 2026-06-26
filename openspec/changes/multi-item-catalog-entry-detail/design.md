## Context

The DriveThruRPG library can contain catalog entries that bundle more than one deliverable item. A classic example is a tabletop RPG product like Moria, which includes both a core rulebook PDF and a separate map sheet. The current app architecture, defined by `main-window-library-layout`, establishes the browsing surface but does not specify what happens when a user selects a catalog entry — and it says nothing about entries that carry multiple items.

Users who have purchased multi-item products need to be able to identify which items belong to an entry, inspect per-item metadata (format, size, individual download state), and initiate actions (download, view) on specific items rather than the entry as a whole.

This design covers the top-level umbrella contract. Platform-specific SwiftUI and Rust/GPUI implementations are delegated to `dtrpg-app/swift` and `dtrpg-app/rust` child proposals.

## Goals / Non-Goals

**Goals:**

- Define a catalog entry detail view that serves both single-item and multi-item entries without bifurcating the navigation model.
- Establish a two-tier metadata presentation: catalog-entry-level data in the primary content area, per-item data in a secondary panel or inline expansion zone.
- Define the item-selection affordance for multi-item entries: a persistent item list panel within the detail view, not a modal or separate navigation push.
- Specify how the detail view anchors to the main window layout established by `main-window-library-layout`.
- Delegate toolkit-specific layout and animation details to child app proposals.

**Non-Goals:**

- Defining download mechanics, file management, or post-download behavior.
- Specifying precise typography, spacing, iconography, or animation timing.
- Defining a new DriveThruRPG API contract (item-level data should already be present in existing API responses).
- Implementing batch selection or multi-item bulk actions.
- Defining behavior for entries with zero items (treated as a degenerate case surfaced as a fallback state, not a first-class pattern).

## Decisions

### 1. Single detail view surface for both single-item and multi-item entries

The app uses one detail view layout for all catalog entries. For single-item entries, the item section collapses to show item metadata inline without requiring user interaction. For multi-item entries, the item section expands to a selectable item list.

**Rationale:** Using a single layout avoids a conditional navigation model that would require the app to branch on item count at selection time. Users also benefit from a predictable structure: catalog metadata is always in the same position regardless of item count.

**Alternative considered:** Navigate to a picker sheet first for multi-item entries, then show the item detail. This is a common mobile pattern but on desktop it is unnecessarily disruptive — it hides entry-level metadata and adds a navigation step.

### 2. Persistent item list as a secondary panel within the detail view

Multi-item entries display a vertical item list in a secondary panel attached to the right side of the detail view, or as a dedicated section below the catalog entry header depending on window width. The item list remains visible while an item is selected; selecting an item updates the item metadata area in place rather than replacing the entire view.

**Rationale:** Users need to compare items within an entry (e.g., check whether the map sheet is a different format than the book). Keeping the item list visible at all times while showing per-item detail avoids the need to navigate back and forth. A persistent panel mirrors established patterns in reference and document management apps.

**Alternative considered:** A tab strip with one tab per item plus an "Overview" tab. Tabs work for small item counts but become unwieldy for entries with more than four or five items. A list panel scales better and does not require upfront knowledge of item count to size the tab bar.

### 3. Two-tier metadata layout within the detail view

The detail view is divided into two tiers:

- **Entry tier** (always visible): Title, publisher, description or summary, purchase/download status, tags, and entry-level cover art.
- **Item tier** (contextual): When the item list is present (multi-item), selecting an item shows item name, type, format, file size, and item-level download/availability state. For single-item entries, item tier metadata is collapsed into the entry tier area without a selector.

**Rationale:** Entry metadata (what the user purchased) is distinct from item metadata (what files make up that purchase). Conflating them in a flat list makes it harder to answer "what is this?" vs "what do I download?" Separating them into tiers mirrors the mental model users bring from reading the DriveThruRPG product page.

**Alternative considered:** Flat metadata card with all fields merged. This works when item count is 1 but breaks down for multi-item entries because fields like "format" and "file size" are ambiguous without a per-item anchor.

### 4. Item-count indicator on catalog entries in the library browsing surface

Library browsing entries (list rows and grid tiles) SHALL carry a visible item-count badge or indicator when the entry contains more than one item. This prevents users from being surprised by the item picker when they open the detail view.

**Rationale:** Discovery and predictability. If the user cannot see from the browsing surface that an entry has multiple items, the secondary panel in the detail view feels unexpected. An indicator in the library surface sets the expectation before the user commits to opening the detail view.

**Alternative considered:** Reveal multi-item structure only in the detail view. This is acceptable on mobile where screen space is tight, but on a desktop app where the library list or grid is already visible alongside the detail surface, adding an indicator costs nothing and improves legibility.

### 5. Item selection state is ephemeral (not persisted across sessions)

The selected item within a multi-item entry is not persisted. When the user returns to a catalog entry, the item list defaults to showing entry-tier metadata with no item pre-selected (or with the first item auto-selected as a no-op affordance).

**Rationale:** Per-item selection is a navigation state, not a user preference. Persisting it would require storage and a migration path. The cost of re-selecting an item is trivial.

**Alternative considered:** Persist last-selected item. This would be convenient for users who frequently return to a specific item within an entry but adds storage, sync, and migration complexity for minimal benefit at this stage.

## Risks / Trade-offs

- **Risk: API does not expose per-item metadata fields** → Mitigation: Audit `dtrpg-api` response schema for item arrays before implementation begins; if fields are missing, file a companion `dtrpg-api` change.
- **Risk: SDK models do not map item arrays to typed structs** → Mitigation: Confirm SDK model coverage in `dtrpg-sdk` before writing app-layer code; add a companion SDK change if needed.
- **Risk: Item count badge clutters the library grid tile at small sizes** → Mitigation: Child app proposals should define a compact badge treatment (e.g., a small numeral overlay on the cover thumbnail) and test at minimum grid tile size.
- **Risk: Secondary item panel collapses available width for entry metadata on narrow windows** → Mitigation: Define a minimum window width threshold below which the item panel stacks below the entry tier rather than appearing beside it; delegate exact breakpoint to child app proposals.
- **Risk: Entries with very large item counts (10+) make the item list unwieldy** → Mitigation: The item list should be scrollable; the spec does not cap item count. If large counts emerge in practice, a search or filter affordance within the panel can be added in a follow-on change.

## Migration Plan

1. Land this umbrella OpenSpec change to establish the cross-app contract.
2. Audit `dtrpg-api` to confirm item-level metadata is available; file a companion API change if not.
3. Audit `dtrpg-sdk` to confirm typed per-item model structs exist; file a companion SDK change if not.
4. Add child implementation proposals in `dtrpg-app`, `dtrpg-app/swift`, and `dtrpg-app/rust`.
5. Implement behind the existing detail view surface in each app, preserving current behavior until the new layout is complete.
6. Update submodule references in the parent repos once each child change is verified.

## Open Questions

- Does the DriveThruRPG API currently return item-level metadata (format, size, per-item download URL) as a structured array within the catalog entry response, or is it inferred from the download list?
- Should item-level cover art or thumbnail be shown for each item in the list, or only the entry-level cover art?
- Is there a meaningful difference between "item types" (e.g., PDF vs. map sheet vs. audio file) that should drive visual differentiation in the item list, or are they rendered uniformly?
- For single-item entries, should item-tier metadata (format, file size) be shown at all in the entry tier, or omitted in favor of a cleaner summary?
