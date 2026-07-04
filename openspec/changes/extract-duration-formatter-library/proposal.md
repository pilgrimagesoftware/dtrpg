## Why

The `dtrpg-app/rust` activity panel contains a small, self-contained duration formatter (`format_duration` in `activity_panel_view.rs`) that turns a `u64` seconds count into a localized display string ("Xs" / "Xm Ys"). This kind of formatter is generic, has no dependency on gpui or the app's domain types, and is useful to any Rust project that needs to render elapsed or remaining time with `rust-i18n` locale support. Extracting it into its own open source crate lets it be reused, tested, and versioned independently, and gives back a small utility to the Rust community instead of leaving it buried in an application crate.

## What Changes

- Create a new standalone Rust library crate (new repository) that implements a duration formatter with `rust-i18n` locale support (pluralization, unit labels, locale-specific ordering of "Xm Ys" style output).
- Publish the new crate as an MIT (or Apache-2.0/MIT dual) licensed open source project, with its own README, CI, tests, and a `CHANGELOG.md`.
- Publish the crate to crates.io under a new name (proposed: `duration-i18n` or `humantime-i18n`, finalized in design.md).
- **BREAKING** (internal only): Remove the private `format_duration` function from `dtrpg-app/rust/crates/dtrpg-ui` and replace its call sites with the new published crate.
- Add the new crate as a workspace dependency in `dtrpg-app/rust/Cargo.toml` and wire it into the existing `rust-i18n` locale files used by the app.

## Capabilities

### New Capabilities
- `duration-formatting-library`: standalone open source crate providing locale-aware duration formatting via `rust-i18n`, independently versioned and published to crates.io.

### Modified Capabilities
- `activity-panel`: elapsed/duration time in the activity list and detail view is now rendered using the extracted external crate instead of an internal private function; user-visible formatting behavior is preserved (or improved with locale awareness beyond the current hardcoded "s" / "m Ys" suffixes).

## Impact

- Affected code: `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/activity_panel_view.rs` (removes private `format_duration`, adds dependency import and call-site updates).
- Affected config: `dtrpg-app/rust/Cargo.toml` workspace dependencies (new external crate entry), `dtrpg-app/rust` locale resource files (new translation keys for duration units, if the extracted crate expects consumer-supplied locale strings).
- New repository: a new standalone GitHub repository for the duration formatting crate, with its own OpenSpec instance, CI pipeline, and crates.io publishing workflow.
- Downstream: any other DriveThruRPG SDK/app repos that later need duration formatting can depend on the same published crate instead of duplicating logic.
