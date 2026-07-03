## ADDED Requirements

### Requirement: App builds against gpui-ce

The `dtrpg-app/rust` workspace SHALL build with `gpui` and `gpui_platform` sourced from `gpui-ce` instead
of the pinned upstream Zed revision, with no compile errors across `dtrpg-core` and `dtrpg-ui`.

#### Scenario: Workspace builds against gpui-ce

- **WHEN** `cargo check --all-targets` is run against the updated `Cargo.toml`
- **THEN** the build SHALL succeed with `gpui`/`gpui_platform` sourced from `gpui-ce`

### Requirement: Existing views and controllers function unchanged

All existing views and controllers SHALL retain their current user-visible behavior after the `gpui-ce`
migration — no new UI capabilities are introduced by this change.

#### Scenario: App launches and existing views render correctly

- **WHEN** the app is launched after the `gpui-ce` migration
- **THEN** the sidebar, catalog view, detail panel, settings views, and activity panel SHALL render and
  behave identically to before the migration
