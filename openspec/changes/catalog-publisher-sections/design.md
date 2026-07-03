## Context

Project feedback already flags that the grouped list view hand-rolls its own rows instead of using the
virtualized `DataTable` used by the ungrouped branch, and calls this out as the largest remaining item —
a real refactor, not a small fix, and the likely cause of laggy scrolling in grouped mode. This change
should not add a second hand-rolled grouping path on top of that; it should be sequenced after (or as
part of) fixing the grouped list to use `DataTable`.

## Goals / Non-Goals

**Goals:**

- Publisher-grouped list rendering uses the same virtualized `DataTable` path as the ungrouped list, with
  `gpui-component`'s sections capability providing the header/group structure.
- Sort order is preserved within each publisher section.

**Non-Goals:**

- Grouping in grid or thumb layouts — list layout only.
- Grouping by dimensions other than publisher (document type, collection) — publisher only, per the
  specific request.

## Decisions

**Fix the grouped list's `DataTable` gap as a prerequisite, not a parallel path.**

Rationale: adding publisher sections on top of the current hand-rolled grouped rows would compound the
existing scrolling-performance problem rather than fix it. `gpui-component`'s sections capability is
designed to work with the virtualized list/table, so migrating the grouped branch to `DataTable` and
adding sections are effectively the same piece of work.

**Sort order composes with grouping by sorting within each publisher group, not across the whole flat
list.**

Rationale: matches user expectation that grouping doesn't override their chosen sort — it partitions the
already-sorted view into sections.

## Risks / Trade-offs

- This change has a larger blast radius than its proposal title suggests, since it's coupled to the
  existing `DataTable` migration debt on the grouped branch — sequencing and scope should be confirmed
  with the user before implementation starts.
- Virtualization across section boundaries (sticky headers, correct scroll offsets) is the main technical
  risk; `gpui-component`'s sections API needs verification that it handles this correctly at scale.
