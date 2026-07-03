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
- ~~Is there a `gpui-component` release/branch that targets `gpui-ce` specifically, or does the existing
  `longbridge/gpui-component` main branch already work against it?~~ Resolved — see Findings below.

## Findings (feasibility check, tasks 1.1/1.2)

- `gpui-ce/gpui-ce` exists on GitHub (Apache-2.0, active, `main` branch, no tagged releases yet). It
  publishes a `gpui` crate at `crates/gpui/` and a `gpui_platform` crate at `crates/gpui_platform/` —
  matching crate names to what the workspace already depends on, so a source swap is mechanically
  possible on the `gpui`/`gpui_platform` side alone.
- `longbridge/gpui-component`'s `main` branch (what this workspace currently depends on via
  `gpui-component = { git = "https://github.com/longbridge/gpui-component" }`) hard-pins its own `gpui`,
  `gpui_platform`, `gpui_web`, and `gpui_macros` dependencies to
  `git = "https://github.com/zed-industries/zed", rev = "1d217ee39d381ac101b7cf49d3d22451ac1093fe"` — the
  exact same upstream Zed revision this app's own `Cargo.toml` pins directly. It does not depend on
  `gpui-ce` in any branch found (checked `main`, `gpui2`, and all other branches on the repo; `gpui2`
  points at a different personal fork, `huacnlee/zed.git`, not `gpui-ce`).
- No fork of `longbridge/gpui-component` was found that targets `gpui-ce`.
- **Cargo `[patch]` redirect tried and confirmed non-viable.** `gpui-ce`'s own site documents redirecting
  every consumer of the `zed-industries/zed` git source onto `gpui-ce` via:
  ```
  [patch."https://github.com/zed-industries/zed.git"]
  gpui = { git = "https://github.com/gpui-ce/gpui-ce" }
  ```
  This avoids needing a `gpui-component` fork — Cargo transparently substitutes `gpui-ce`'s `gpui` (and,
  added here, `gpui_platform`/`gpui_web`/`gpui_macros`, all four of which `gpui-component`'s `main` branch
  sources from that same URL) wherever anything in the graph depends on them. The patch resolves and
  fetches correctly, but **`cargo check --all-targets` fails inside `gpui-component` itself**, not in this
  app's own code: `gpui-component`'s `main` branch (pinned to Zed rev `1d217ee...`) calls `Styled` trait
  methods that no longer exist or have a different signature on `gpui-ce`'s `Styled` — e.g.
  `flex_grow_1()`/`flex_shrink_1()` are absent, and `flex_grow(width: f32)` is now a zero-argument
  `flex_grow()`. Ten such call sites fail across `crates/ui/src/{input,list,resizable,table,text,tree}`.
  This confirms real API divergence between `gpui-ce` and the exact upstream Zed revision
  `gpui-component`'s `main` branch was written against — not just a hypothetical risk.
- **Conclusion: this change is blocked**, confirmed by an actual build attempt, not just repo metadata.
  Proceeding requires one of:
  1. A `gpui-component` fork/branch that has already been ported to `gpui-ce`'s current API (none found).
  2. Forking `gpui-component` in-house and fixing the (currently) ten broken call sites to match
     `gpui-ce`'s `Styled` API — a bounded, mechanical fix by the error list above, but it creates and
     commits this app to maintaining a private `gpui-component` fork indefinitely, since upstream
     `longbridge/gpui-component` continuing to track Zed's `gpui` would require re-fixing on every pull.
  3. Deferring this change until the `gpui-component` ecosystem adopts `gpui-ce` upstream (or a
     community-maintained `gpui-ce`-compatible branch appears).
