## Context

The workspace `Cargo.toml` currently pins:

```
gpui = { git = "https://github.com/zed-industries/zed", rev = "1d217ee39d381ac101b7cf49d3d22451ac1093fe" }
gpui_platform = { git = "https://github.com/zed-industries/zed", rev = "...", features = ["font-kit"] }
gpui-component = { git = "https://github.com/longbridge/gpui-component" }
gpui-component-assets = { git = "https://github.com/longbridge/gpui-component" }
```

`gpui-component` is already sourced from the `longbridge/gpui-component` fork rather than upstream Zed,
so the app already depends on non-Zed-maintained `gpui`-ecosystem code. Moving the base `gpui` crate
itself to `gpui-ce` is a natural continuation of that direction, but is a foundational dependency swap that
touches every view in the app.

## Goals / Non-Goals

**Goals:**

- The app builds and runs unchanged (from a user-visible standpoint) against `gpui-ce`.
- Any API surface differences between the pinned upstream revision and `gpui-ce` are resolved without
  behavior regressions.

**Non-Goals:**

- Shipping the dock/tiled layout in this change — that's a distinct, larger UI change; this change only
  confirms `gpui-ce` is a viable dependency and gets the build green.
- Migrating `gpui-component`/`gpui-component-assets` sources — those already point at a community fork and
  are out of scope here unless `gpui-ce` requires a compatible fork of them.

## Decisions

**Land the dependency swap as its own change, with no functional UI changes bundled in.**

Rationale: a dependency migration this foundational should be reviewable and revertible independent of
any feature work. Bundling functional changes would make a regression hard to bisect.

**Confirm `gpui-component` compatibility with `gpui-ce` before starting the swap.**

Rationale: `gpui-component` (the `longbridge` fork) is built against a specific `gpui` API surface; if it
assumes the upstream Zed `gpui` crate rather than `gpui-ce`, this change may need to also swap or fork
`gpui-component` to a `gpui-ce`-compatible variant, which changes the scope significantly.

## Risks / Trade-offs

- `gpui-ce` may not track upstream Zed `gpui` API 1:1 — every view (`ui/views/*.rs`) and controller needs a
  compile pass to catch breaking changes.
- If `gpui-component` is incompatible with `gpui-ce`, this change blocks on either a compatible
  `gpui-component` fork appearing or forking it in-house — flagged as an open question below.
- Community forks carry their own maintenance risk (fork drift, smaller contributor base) — worth an
  explicit note in the PR description for future maintainers.

## Open Questions

- Does `gpui-ce` provide dock/tiled window layout primitives suitable for the sidebar-note item ("Dock/Tiles
  layout?")? If yes, that becomes its own follow-up change once this migration lands.
- Is there a `gpui-component` release/branch that targets `gpui-ce` specifically, or does the existing
  `longbridge/gpui-component` main branch already work against it?
