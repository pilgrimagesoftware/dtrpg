## Context

`gpui-component` (git dependency of `dtrpg-app/rust`, from `github.com/longbridge/gpui-component`) provides
`Sidebar`/`SidebarMenu`/`SidebarMenuItem` for building sidebar navigation. `SidebarMenuItem` is a builder
struct (`crates/ui/src/sidebar/menu.rs`): callers configure it via chained methods (`.icon(...)`,
`.on_click(...)`, `.suffix(...)`, `.context_menu(...)`, `.children(...)`), and only when
`SidebarItem::render(self, id, window, cx)` is called (by `SidebarMenu`'s own internal traversal) does it
build the actual `div`/`h_flex` element tree. That `render` method is private to the crate — callers never
see or touch the constructed element, so there is no way to attach `on_drag`/`drag_over`/`on_drop` (which
are methods on `gpui`'s `Div`/`InteractiveElement`) to a `SidebarMenuItem`'s row from outside the crate.

`gpui-component` already implements drag-and-drop elsewhere — `crates/ui/src/dock/tab_panel.rs`'s
`DragPanel` uses exactly the pattern needed here: `.on_drag(payload, |drag, _, _, cx| cx.new(|_| drag.clone()))`
for the source, `.drag_over::<DragPanel>(|style, _, _, cx| ...)` for hover feedback, and
`.on_drop(cx.listener(...))` for the handler. This proves the underlying `gpui` primitives are suitable;
`SidebarMenuItem` just doesn't expose them.

`dtrpg-app/rust`'s `collection-membership-editing` and `catalog-drag-drop-to-collection` changes already
landed with a stopgap: `sidebar_view.rs`'s Collections section was hand-rolled as plain `div`s
(`CollectionsSection`, `CollectionRow`, `render_collection_row`) that copy `SidebarMenuItem`'s exact
styling constants (hover/active background and text color, `p_2`/`gap_x_2`/`h_7`/`rounded` spacing, and the
submenu wrapper's `border_l_1`/`ml_3p5`/`pl_2p5`/`py_0p5` indentation) so the section could support
`on_drop`. This works today, but means the Collections section silently drifts from
`SidebarMenuItem`'s actual behavior/styling (e.g. any future `gpui-component` sidebar theming or interaction
change) since it duplicates rather than reuses.

## Goals / Non-Goals

**Goals:**

- `SidebarMenuItem` gains a way for callers to make a row a drop target for an arbitrary payload type, with
  hover-state styling and an `on_drop` callback, without needing access to its internal `render` method.
- `dtrpg-app/rust`'s Collections section goes back to using `SidebarMenu`/`SidebarMenuItem`, deleting the
  hand-rolled duplication.
- No change to user-visible behavior — this is a pure implementation refactor of an already-shipped
  feature.

**Non-Goals:**

- Changing `catalog-drag-drop-to-collection`'s or `collection-membership-editing`'s user-facing behavior.
- Making `SidebarMenuItem`'s children (submenu rows) themselves draggable/reorderable — only drop-target
  support is in scope.
- Migrating from `gpui` to `gpui-ce` (tracked separately per this repo's `AGENTS.md`; that migration would
  make this fork moot or need to be redone against `gpui-ce`'s own component library).

## Decisions

**Add a `droppable::<T>(style_fn, on_drop_fn)` builder method to `SidebarMenuItem`, rather than exposing
its internal `render`/element type.**

Rationale: matches `SidebarMenuItem`'s existing builder pattern (`.suffix(...)`, `.context_menu(...)`) —
callers configure behavior via a method, the crate still owns the actual rendering. Exposing the internal
`Div` (or making `render` `pub`) would leak implementation detail and let callers break invariants
`SidebarMenuItem` currently protects (e.g. the collapse/indentation logic).

- Alternative considered: generic "extend with arbitrary element modifier" hook (`fn modify(self, f: impl
  FnOnce(Div) -> Div))`). Rejected: more powerful than needed, and 	harder to keep `SidebarMenuItem`'s own
  internal state (active/hover styling) consistent if callers can arbitrarily rewrite the row.

**Maintain the addition as a fork initially; open an upstream PR to `longbridge/gpui-component` in
parallel rather than only after the fork is stable.**

Rationale: this feature (drop targets on sidebar rows) is generically useful, not `dtrpg`-specific — likely
to be accepted upstream, and upstreaming avoids permanently maintaining a diverging fork. Opening the PR
early (not waiting for it to be "perfect") gets maintainer feedback on the API shape before
`dtrpg-app/rust` depends on it long-term.

**Keep `DraggedLibraryItem` and `LibraryController::add_item_to_collection` unchanged.**

Rationale: those live in `dtrpg-app/rust`, not `gpui-component`, and already work correctly; this change is
scoped to the sidebar rendering layer only.

## Risks / Trade-offs

- [Risk] Upstream may reject or want a different API shape than `droppable::<T>(...)`, requiring rework of
  the `dtrpg-app/rust` call sites a second time. → Mitigation: keep the `dtrpg-app/rust`-side usage
  (`sidebar_view.rs`) isolated to the Collections section construction, same as today, so a shape change
  only touches one file.
- [Risk] Depending on a fork (even temporarily) means `dtrpg-app/rust`'s `gpui-component` version is pinned
  to a branch that can silently diverge from upstream `main`, risking a harder merge later. → Mitigation:
  rebase the fork branch on upstream `main` periodically until the PR merges or is closed.
- [Risk] This is a larger-footprint change than the app-side drag-and-drop work already shipped — it
  touches a dependency slated for eventual `gpui`→`gpui-ce` migration (see this repo's `AGENTS.md`), so time
  spent here could be partially redone if that migration lands first. → Mitigation: treat this as low
  priority relative to the migration; re-evaluate whether `gpui-ce`'s own sidebar component (if any) has the
  same limitation before starting implementation.

## Open Questions

- Where does the fork live? Options: a `pilgrimagesoftware` GitHub org fork of `longbridge/gpui-component`
  (visible, reviewable alongside this project's other repos), or a personal fork. Needs an owner decision
  before `Cargo.toml` can be updated.
- Should this wait until after the `gpui`→`gpui-ce` migration (per `AGENTS.md`), given `gpui-ce` may ship a
  different (or already-droppable) sidebar component? If so, this change should stay unimplemented/on hold
  until that migration's own OpenSpec change (not yet drafted) lands or is scoped.
