## Context

`dtrpg-app/rust/crates/dtrpg-ui` has a private `format_duration(secs: u64) -> String` function used only in `activity_panel_view.rs` to show elapsed time in the activity panel ("12s", "3m 45s"). It hardcodes English unit suffixes and has no locale awareness, even though the surrounding app already depends on `rust-i18n` and ships `en`, `de`, `fr` locale files (`crates/dtrpg-ui/i18n/*.yaml`) using `t!("module.key")`.

The app is one of several planned consumers of a duration formatter (the pattern is generic and not specific to activity tracking), so this design extracts the logic into a standalone open source crate rather than a private internal module. The new crate is a new repository, published independently, and pulled back into `dtrpg-app/rust` as a normal `crates.io` dependency once released. It does not have its own OpenSpec instance managed from this repo; the umbrella change here tracks the extraction and integration only, not the new crate's internal development process.

## Goals / Non-Goals

**Goals:**
- Ship a crate that formats a `Duration` (or seconds count) as a short, human-readable string with correct locale-aware pluralization and unit ordering for at least `en`, `de`, `fr` to match the app's existing locales.
- Give the crate a clean, minimal public API with no dependency on `gpui`, `dtrpg-ui`, or any DriveThruRPG-specific type.
- Integrate `rust-i18n` in a way that lets a consuming crate supply its own locale files (the crate ships default translations but does not force consumers into its own i18n instance if avoidable).
- Publish to crates.io with CI (build, test, clippy, fmt) and semantic versioning starting at `0.1.0`.
- Replace the existing `format_duration` call sites in `dtrpg-ui` with the new crate, preserving current display behavior for `en`.

**Non-Goals:**
- Rewriting the activity panel's elapsed-time display logic or introducing new units (days, hours) beyond what facilitates the extraction, unless trivial.
- Building a general-purpose date/time library (no calendar arithmetic, no timezones) — scope is strictly "seconds/duration to short display string."
- Managing the new crate's long-term roadmap or community process from this repo's OpenSpec instance.

## Decisions

- **New repository, not a path/git submodule under `dtrpg`**: the crate is intended for external reuse and open source release, so it lives in its own GitHub repository (e.g. `pilgrimagesoftware/duration-i18n`) with its own license, README, and CI, independent of the DriveThruRPG submodule tree. `dtrpg-app/rust` depends on it via crates.io version, not a path or git dependency, once published. Rationale: keeps release cadence and audience (general Rust community) decoupled from the app's own versioning and avoids DriveThruRPG-specific naming or history in the OSS repo.
- **Crate name**: propose `duration-i18n`. Alternatives considered: `humantime-i18n` (rejected — collides conceptually with the existing `humantime` crate and implies broader scope), `fmt-duration` (rejected — less discoverable, doesn't signal i18n support). Confirm final name is available on crates.io before implementation.
- **i18n integration approach**: the crate depends on `rust-i18n` directly and ships its own minimal locale files (`en`, `de`, `fr`) with only the unit-label keys it needs (e.g. `duration.seconds_short`, `duration.minutes_seconds_short`). Alternative considered: accepting a caller-supplied formatting closure/trait instead of depending on `rust-i18n` (rejected as the primary API — it would drop the "with support for rust_i18n" requirement — but expose a lower-level `format_duration_with(secs, labels: &UnitLabels)` escape hatch for callers who don't use `rust-i18n` or want custom labels).
- **Public API surface**: keep it small — a single primary function (`format_duration(secs: u64) -> String`, locale resolved via `rust_i18n::locale()`) plus the lower-level customizable variant. No struct/builder API for v0.1.0; add one later only if real usage demands it (YAGNI).
- **Locale file ownership at the integration boundary**: `dtrpg-app/rust` keeps its own `activity.*` translation keys for surrounding UI text, but removes its ad hoc duration-suffix strings (there are none today — the format was hardcoded in Rust, not translated) and instead relies on the new crate's built-in locale bundle for the unit suffixes themselves. If the crate's bundled `de`/`fr` translations don't match the app's tone, the app can override individual keys via `rust_i18n`'s standard locale-merging file lookup (final mechanism confirmed during implementation against the installed `rust_i18n` version's merge behavior).
- **Versioning/dependency pinning**: `dtrpg-app/rust/Cargo.toml` pins to a caret version (`duration-i18n = "0.1"`) under `[workspace.dependencies]`, consistent with how other external crates are declared in that file.

## Risks / Trade-offs

- [Two `rust-i18n` instances in one binary (app's own `i18n!("i18n", ...)` plus the crate's internal locale bundle) could behave unexpectedly if `rust_i18n::locale()` is process-global] → Mitigation: verify during implementation that `rust_i18n::locale()` is a single global setting (it is, per `rust-i18n` design) so both the app and the crate resolve to the same active locale without extra wiring; add an integration test that switches locale and asserts both app strings and duration strings update together.
- [Crate name `duration-i18n` may already be taken on crates.io] → Mitigation: check availability before implementation; have `duration-fmt-i18n` as a fallback name.
- [Publishing and maintaining an open source crate adds ongoing maintenance surface unrelated to the app] → Mitigation: keep scope minimal (single function + escape hatch), document a clear contribution/maintenance expectation in the new repo's README, accept this as an explicit trade-off of the "release as open source" goal.
- [Locale-specific pluralization for "minutes/seconds" combined strings may need more than simple key substitution for languages with complex plural rules] → Mitigation: use `rust-i18n`'s pluralization support if available for the target `en`/`de`/`fr` set at v0.1.0; document that additional languages may need contributor review of plural forms before merging.

## Migration Plan

1. Create and publish the new open source crate to its own repository, reach `0.1.0` on crates.io.
2. Add `duration-i18n = "0.1"` to `dtrpg-app/rust/Cargo.toml` workspace dependencies and to `crates/dtrpg-ui/Cargo.toml`.
3. Replace the private `format_duration` function and its call sites in `activity_panel_view.rs` with the crate's public function; remove the now-dead private function.
4. Verify `en`, `de`, `fr` locale output for the activity panel matches (or intentionally improves on) current behavior via manual check and a regression test.
5. Remove any now-unused local test coverage for the old private function; confirm crate-level tests cover the same cases.

Rollback: revert the `dtrpg-ui` call-site change and dependency addition; the old private function had no other dependents so reverting is a clean, single-crate change with no data migration involved.

## Open Questions

- Final crate name (`duration-i18n` vs fallback) — confirm crates.io availability before implementation.
- Whether to bundle `de`/`fr` translations that exactly match the app's existing tone, or let the app override them locally — decide during implementation once the crate's default translations are drafted.
- License choice for the new repository: MIT only vs dual MIT/Apache-2.0 — default to dual MIT/Apache-2.0 (common Rust ecosystem convention) unless the user specifies otherwise.
