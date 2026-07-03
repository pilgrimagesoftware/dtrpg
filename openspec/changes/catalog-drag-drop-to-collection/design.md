## Context

`gpui` supports drag-and-drop via a payload type passed to `on_drag`/`on_drop` handlers on elements. No
drag source or drop target currently exists anywhere in the app. This change introduces the first use of
that API, so the drag payload type and rendering (drag preview) need to be established from scratch.

## Goals / Non-Goals

**Goals:**

- Dragging a catalog item onto a sidebar collection adds it as a member, using the same `add_member`
  operation as the context-menu path.
- Clear visual feedback: hover highlight on valid drop targets, no-op on invalid ones.

**Non-Goals:**

- Dragging to reorder items within a collection.
- Dragging multiple selected items at once — single-item drag only for this change.
- Dragging collections onto other collections (nesting) — out of scope.

## Decisions

**Drag payload carries the item's identifier only (not the full catalog entry).**

Rationale: keeps the payload small and avoids stale-data issues if the catalog updates mid-drag; the drop
handler looks up current item state from the controller by ID.

**Drop handler calls the same controller action as the context menu's "Add to…" item.**

Rationale: `collection-membership-editing` already defines the optimistic-update-with-rollback behavior
for adding a member; drag-and-drop is just a second UI entry point into that same action, not a new code
path.

**Drag preview reuses the existing thumb/list row visual, dimmed, rather than a custom drag ghost.**

Rationale: avoids building a second rendering path for the same item just for the drag preview; `gpui`'s
drag API allows reusing an existing element as the preview.

## Risks / Trade-offs

- First use of `gpui`'s drag-and-drop primitives in this codebase — expect some iteration on exact API
  shape (`on_drag` closure signature, drop payload downcasting) during implementation.
- Dropping onto a collection the item is already a member of should be a no-op (not an error) — needs an
  explicit check before calling `add_member`.
