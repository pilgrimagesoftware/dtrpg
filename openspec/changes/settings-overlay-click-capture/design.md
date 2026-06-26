## Context

The settings panel overlay is rendered in `render_settings_panel` as an absolute-positioned `div` covering the main content area (`.absolute().inset_0()`). In gpui, a `div` element only participates in hit-testing — and therefore only intercepts pointer events — if it has either an `id()` or at least one interactive handler registered. The backdrop `div` currently has neither, so gpui's event dispatch system treats it as non-interactive. Mouse events are dispatched to the first interactive element found at the cursor position regardless of visual z-order, which is the catalog row or toolbar button underneath.

gpui provides a first-class mechanism for blocking overlays via the `InteractiveElement::occlude()` fluent method (and its imperative equivalent `Interactivity::occlude_mouse()`). This sets `HitboxBehavior::BlockMouse` on the element's hitbox. When a hitbox with `BlockMouse` behavior exists at a given screen position, all hitboxes painted behind it have `hitbox.is_hovered()` return `false`, which causes gpui to skip their mouse handlers, hover styles, and tooltips entirely.

## Goals / Non-Goals

**Goals:**
- The backdrop `div` acquires a proper hitbox so gpui's event dispatch can see it.
- `HitboxBehavior::BlockMouse` is set on the backdrop so all elements behind it are treated as non-interactive while the panel is open.
- The fix is limited to `settings_view.rs` with no API or architectural changes.

**Non-Goals:**
- Implementing Escape-key dismissal (tracked separately in `add-settings-view` task 1.5).
- Allowing scroll events to reach the catalog through the overlay (the overlay fully covers the content area; there is no visible scroll target, and the gpui `BlockMouse` behavior correctly blocks scroll as well).
- Retrofitting similar protection to the detail panel sidebar (it does not overlap the catalog).

## Decisions

### Decision 1: Use `.occlude()` rather than explicit `on_mouse_down` + `cx.stop_propagation()`

`.occlude()` is the idiomatic gpui mechanism. It sets `HitboxBehavior::BlockMouse` which suppresses `is_hovered()` for all hitboxes behind it, preventing not just event handler invocation but also hover styles and tooltip triggers — the full set of pointer interaction behaviors. An explicit `on_mouse_down` handler with `cx.stop_propagation()` would only stop the specific event phase it is registered for and would not suppress hover highlights on underlying elements.

**Alternative considered**: Add `on_mouse_down(MouseButton::Left, |_, _, cx| cx.stop_propagation())` to the backdrop. This fixes the click passthrough but leaves hover styles on catalog rows active when the mouse moves over the overlay. Rejected in favor of `occlude()`.

### Decision 2: Add `.id("settings-backdrop")` to the backdrop div

The gpui `occlude()` / `block_mouse_except_scroll()` hitbox behaviors require the element to have a hitbox. A `div` without `id()` or handlers may not be added to the hitbox tree, making the behavior setting a no-op. Adding `.id("settings-backdrop")` guarantees the backdrop is registered as an interactive element and its hitbox is created during painting.

The string ID is stable across renders (it is a literal, not derived from dynamic data) so gpui can match it across render cycles without churn.

## Risks / Trade-offs

**[Risk] The change is trivially small and may mask a deeper problem** → The root cause is clear and confirmed by the gpui documentation: no hitbox, no event blocking. Two-property fix is correct and complete.

**[Risk] `.occlude()` also blocks scroll events over the backdrop** → This is acceptable: when the settings panel is open, the catalog below is fully obscured and there is nothing meaningful to scroll. If a future change introduces a scrollable area visible alongside the settings panel, `block_mouse_except_scroll()` can be used instead.

## Migration Plan

Single-file change: add `.id("settings-backdrop")` and `.occlude()` to the backdrop `div` in `render_settings_panel` in `dtrpg-ui/src/ui/views/settings_view.rs`. No other files change. Verify with `cargo check -p dtrpg-ui`.
