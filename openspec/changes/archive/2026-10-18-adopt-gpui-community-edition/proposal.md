## Why

The app currently pins `gpui`/`gpui_platform` to a specific Zed upstream revision
(`rev = "1d217ee39d381ac101b7cf49d3d22451ac1093fe"`). The community edition (`gpui-ce`) tracks a more
actively maintained fork intended for use outside Zed itself, and may unlock layout capabilities (e.g.
dock/tiled panel layout) not available in the pinned upstream revision.

## What Changes

- Replace the `gpui` and `gpui_platform` git dependencies with `gpui-ce` equivalents in the workspace
  `Cargo.toml`.
- Resolve any API differences between the pinned upstream `gpui` revision and `gpui-ce` across
  `dtrpg-core` and `dtrpg-ui`.
- Evaluate `gpui-ce`'s dock/tiled window layout primitives as a candidate for the app's window layout (see
  Open Questions in `design.md` — this may be split into a separate follow-up change once feasibility is
  confirmed).

## Capabilities

### New Capabilities

- `adopt-gpui-community-edition`: The app builds against `gpui-ce` instead of the pinned upstream `gpui`
  revision, with all existing views and controllers functioning unchanged.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/Cargo.toml`: `gpui`, `gpui_platform`, `gpui-component`, `gpui-component-assets`
  dependency sources and versions.
- `dtrpg-app/rust/crates/dtrpg-ui`, `dtrpg-app/rust/crates/dtrpg-core`: any call sites relying on
  upstream-`gpui`-specific APIs not present (or renamed) in `gpui-ce`.
- Build/CI: pinned revision changes affect reproducible builds; `Cargo.lock` update is a deliberate,
  isolated change per project convention.
- This is a foundational/infrastructure change — other in-flight UI changes in this repo (context menus,
  drag-and-drop, charts) should land before or be rebased carefully against this migration to avoid merge
  churn.
