## Context

`gpui`'s base `div().child(text)` renders a fixed text shape with no built-in text-selection
interaction — text is drawn, not made selectable, unlike a native text field. `gpui-component` provides
`TextView` (used elsewhere in the ecosystem for rendering selectable/copyable text and markdown) as a
drop-in replacement that adds click-drag selection and copy-on-select without turning the field into an
editable input.

## Goals / Non-Goals

**Goals:**

- Every field that holds user/catalog data (titles, descriptions, publisher names, IDs, error text) is
  selectable and copyable with the mouse and standard OS copy shortcut.
- No change to visual layout, font, or color — `TextView` must be styled to match existing `div` output.

**Non-Goals:**

- Making fields editable — this change is read-only selection, not inline editing.
- Rich text / markdown rendering — plain text only, `TextView` is used purely for its selection behavior.

## Decisions

**Use `gpui_component::text::TextView` in place of `div().child(text)` for data fields.**

Rationale: `TextView` is already a dependency (bundled with `gpui-component`), avoids hand-rolling a
selection gesture handler, and matches the pattern other `gpui-component` consumers use for copyable
text.

**Audit fields case by case rather than a blanket find-replace.**

Rationale: many `div().child(text)` calls render labels, icons, or button text that should not be
selectable (selection cursor on a button label reads as a bug, not a feature). Each call site is
reviewed against "would a user want to copy this value" before converting.

## Risks / Trade-offs

- `TextView` may have different default padding/line-height than `div` — each converted call site needs a
  visual diff pass to confirm no layout shift.
- Overuse (converting structural/button text) degrades UX by making labels look like data. Mitigated by
  the case-by-case audit.
