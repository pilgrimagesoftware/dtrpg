## Context

`gpui-component` list-style primitives support a loading state (spinner/skeleton overlay) that the app
does not currently use anywhere. Content views instead either render nothing until data arrives or briefly
flash an empty state, which the `catalog-empty-states` change already addresses for the catalog's
zero-item case — but there is still no visual signal that the app is actively fetching versus genuinely
having no data.

## Goals / Non-Goals

**Goals:**

- Every list/content view that fetches data on open shows a loading indicator until that fetch resolves.
- Loading state is visually distinct from both "has content" and "genuinely empty."

**Non-Goals:**

- Per-row skeleton placeholders matching final row layout — a single loading indicator for the whole view
  is sufficient for this change.
- Changing what counts as "loaded" for the sidebar collection count badge — that's
  `collection-count-placeholder`, a separate, narrower change.

## Decisions

**Use the loading capability already exposed by `gpui-component`'s list view rather than a custom
overlay.**

Rationale: consistent with the project's general lean toward `gpui-component` primitives over hand-rolled
UI (see `HoverCard`, `DataTable`/`Table` preference noted in project feedback); avoids maintaining a
second loading-indicator implementation.

**Loading state is driven by the same loaded/not-loaded signal each view's backing cache already has (or
gains, per `collection-count-placeholder`).**

Rationale: reuses the tri-state loading model rather than inventing a separate loading flag per view.

## Risks / Trade-offs

- If a view's backing cache has no loaded/not-loaded distinction yet, this change needs to add one (same
  pattern as `collection-count-placeholder`) before the loading indicator can be driven correctly.
