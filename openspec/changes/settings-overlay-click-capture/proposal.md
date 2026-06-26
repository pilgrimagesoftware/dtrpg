## Why

The settings panel overlay renders on top of the catalog view but does not block pointer events from reaching elements behind it. Clicking any interactive control in the settings panel (tabs, buttons, close button) simultaneously fires the click handler on whatever catalog entry, sidebar filter, or toolbar control occupies that same pixel position underneath, causing unintended selection state changes.

## What Changes

- The settings panel backdrop div acquires a hitbox via `.id()` and is marked as a mouse-blocking overlay via `.occlude()`, which is the idiomatic gpui mechanism (`HitboxBehavior::BlockMouse`) for preventing pointer events from reaching elements behind an overlay.
- No other behavior changes: the overlay still dismisses on close-button click, tabs still switch sections, and the catalog remains fully functional when the settings panel is closed.

## Capabilities

### New Capabilities

- `settings-input-isolation`: The settings panel overlay SHALL intercept and consume all pointer events within its bounds when open, preventing any interaction with the catalog, sidebar, or toolbar beneath it.

### Modified Capabilities

- None.

## Impact

- **`dtrpg-ui/src/ui/views/settings_view.rs`**: Single-line change to the backdrop div — add `.id("settings-backdrop")` and `.occlude()`.
- No other files affected.
- No new dependencies.
