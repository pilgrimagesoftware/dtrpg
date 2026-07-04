## 1. New repository setup

- [ ] 1.1 Confirm crate name availability on crates.io (`duration-i18n`, fallback `duration-fmt-i18n`); reserve the name
- [ ] 1.2 Create new GitHub repository for the crate with MIT/Apache-2.0 dual license, `README.md`, `CHANGELOG.md`, `.gitignore`, and `LICENSE-MIT`/`LICENSE-APACHE`
- [ ] 1.3 Scaffold crate with `cargo init --lib`, set `edition`, `rust-version`, and workspace lint defaults consistent with `docs/rust.md` (deny `unsafe_code`, no `unwrap`/`expect` in library code)
- [ ] 1.4 Add `rust_i18n` dependency and `i18n!` macro setup with `en`, `de`, `fr` locale files under a `locales/` directory

## 2. Core implementation

- [ ] 2.1 Implement `format_duration(secs: u64) -> String` using `rust_i18n::locale()` to resolve active locale and render "Xs" / "Xm Ys" style output
- [ ] 2.2 Implement lower-level `format_duration_with(secs: u64, labels: &UnitLabels) -> String` (or equivalent) for callers supplying custom unit labels without `rust_i18n`
- [ ] 2.3 Write unit tests covering sub-minute, minute-and-second, zero-second, and large-duration inputs for each supported locale
- [ ] 2.4 Add doc comments with `# Examples` on all public items; ensure `cargo test --doc` passes
- [ ] 2.5 Add property-based tests (`proptest`) verifying output is always parseable/non-empty across the `u64` input space

## 3. CI and publishing

- [ ] 3.1 Add CI workflow running `cargo check`, `cargo clippy --all-targets --all-features -- -D warnings`, `cargo fmt --all -- --check`, `cargo test --all-features`, and `cargo test --doc`
- [ ] 3.2 Add `cargo audit` and `cargo deny check` CI jobs (weekly + on `Cargo.lock` changes)
- [ ] 3.3 Tag and publish `0.1.0` to crates.io
- [ ] 3.4 Verify the published crate installs and builds cleanly in a throwaway project with no access to any DriveThruRPG-internal repository

## 4. Integration into dtrpg-app

- [ ] 4.1 Add `duration-i18n = "0.1"` to `dtrpg-app/rust/Cargo.toml` `[workspace.dependencies]` and to `crates/dtrpg-ui/Cargo.toml`
- [ ] 4.2 Replace the private `format_duration` function and its call sites in `crates/dtrpg-ui/src/ui/views/activity_panel_view.rs` with calls to the published crate
- [ ] 4.3 Remove the now-dead private `format_duration` function and any test coverage that only exercised it
- [ ] 4.4 Verify activity panel elapsed-time and total-duration display for `en`, `de`, `fr` matches expected output (manual check plus a regression test in `dtrpg-ui`)
- [ ] 4.5 Update `dtrpg-app/rust` CI/build to confirm the workspace builds and tests pass with the new external dependency

## 5. Documentation and close-out

- [ ] 5.1 Update `dtrpg-app/rust/crates/dtrpg-ui` module docs or README noting the duration formatting dependency and link to the new open source repository
- [ ] 5.2 Record the new repository location in this umbrella change's proposal/design as a permanent reference (or in top-level `dtrpg` docs if a cross-repo reference registry exists)
- [ ] 5.3 Archive this OpenSpec change once integration is verified and merged
