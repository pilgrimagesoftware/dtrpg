## 0. Status: Deferred

Blocked on confirmed `gpui-component` / `gpui-ce` API incompatibility (10 broken `Styled` call sites in
`gpui-component`'s `main` branch — see Findings in `design.md`). Deferred until `gpui-component` (or a
fork) targets `gpui-ce`, or a decision is made to maintain a private `gpui-component` fork. Do not resume
without re-checking whether upstream `gpui-component` has moved.

## 1. Feasibility

- [x] 1.1 Confirm `gpui-ce` repository/crate coordinates and current API surface
- [x] 1.2 Confirm `gpui-component` (`longbridge/gpui-component`) compatibility with `gpui-ce`; identify a
  fork or branch if the current source is upstream-`gpui`-specific — **confirmed incompatible**, see
  `design.md` Findings

## 2. Dependency Swap

- [ ] 2.1 Update `gpui` and `gpui_platform` entries in the workspace `Cargo.toml` to `gpui-ce` sources
- [ ] 2.2 Update `gpui-component` / `gpui-component-assets` sources if a compatible fork/branch is
  required
- [ ] 2.3 Regenerate `Cargo.lock` in its own commit, per project convention (never bundled with feature
  work)

## 3. Compile Fixes

- [ ] 3.1 Run `cargo check --all-targets` and resolve any API differences in `dtrpg-core`
- [ ] 3.2 Run `cargo check --all-targets` and resolve any API differences in `dtrpg-ui`

## 4. Build and Verify

- [ ] 4.1 Run `cargo check --all-targets`
- [ ] 4.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 4.3 Run `cargo test --all-features --workspace`
- [ ] 4.4 Manually launch the app and verify sidebar, catalog, detail panel, settings, and activity panel
  render and behave as before
