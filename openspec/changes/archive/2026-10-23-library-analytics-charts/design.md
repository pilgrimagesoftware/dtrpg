## Context

The catalog and collections caches already hold everything needed for these charts: each catalog item has
a publisher and a kind/document-type field, and each collection has a `member_ids` list whose length gives
a per-collection count. No new data fetching is required — this is purely a presentation layer on top of
existing state.

## Goals / Non-Goals

**Goals:**

- Three charts (publishers, collection counts, document types) computed from data already in memory.
- Charts stay current as the underlying catalog/collections data changes, without a manual refresh action.

**Non-Goals:**

- Historical/time-series charts (e.g. library growth over time) — only current-state snapshots.
- Interactive drill-down (clicking a bar to filter the catalog) — deferred to a follow-up change if
  wanted.
- A general-purpose charting library adopted app-wide — scoped to these three charts only for now.

## Decisions

**Evaluate `gpui-component`'s built-in chart support first; fall back to hand-rolled bars only if none
exists.**

Rationale: `gpui-component` is already a dependency and the project's stated direction
(`adopt-gpui-community-edition`) leans further into it; adding a separate charting crate would be a new
dependency for three simple bar/pie charts that `gpui` primitives (`div` with computed widths/heights) can
render directly.

**Aggregation computed on render, not cached separately.**

Rationale: publisher counts, collection counts, and document-type counts are cheap `O(n)` aggregations
over data already in memory (typical library sizes are in the hundreds to low thousands of items) — no
need for a separate incrementally-maintained aggregate cache, which would add complexity for negligible
performance gain at this data size.

## Risks / Trade-offs

- If `gpui-component` has no chart primitive, hand-rolled bar rendering (fixed-height container, bar width
  proportional to max count) is straightforward but a pie chart is not — pie/donut may be deferred to a bar
  chart alternative if no simple `gpui` path exists for arcs.
- Recomputing aggregates on every render is fine at expected library sizes; if a user's library grows
  large enough to make this a jank source, revisit with a memoized aggregate.
