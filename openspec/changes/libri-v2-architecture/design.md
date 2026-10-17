## Context

This document records a design review of Libri against its twelve product goals, the target architecture
those goals imply, and the gap between that target and what exists today. The UI side of the target is
prototyped in `dtrpg-design/claude-2`, which can be opened in a browser and stepped through screen by
screen.

The review covered the Rust app's two crates, its roughly 130 OpenSpec specs across four OpenSpec roots,
its ADRs, its CI workflows, and the earlier `claude-1` design prototype the shipped UI was built from.

The short version: the app is further along than the goal list suggests. Six goals are done, and the
catalog, collections, file-opener, and zip-preview work is solid. What's missing isn't spread evenly
across the twelve. It clusters in three goals that all depend on the same two structural facts, which is
why this change exists and why it's structural rather than user-facing.

## Goals / Non-Goals

**Goals:**

- A library core that runs headless, so the same logic serves the desktop UI and an agent server.
- One queryable index, so search, facets, tags, placement, summaries, and stats stop needing bespoke
  caches.
- Platform-specific behavior isolated behind one trait with a capability set the UI can interrogate.
- Behavior held constant. The existing specs are the regression bar.

**Non-Goals:**

- Shipping any of the twelve goals. Each becomes a child change.
- Redesigning the UI. `claude-2` is the target, applied incrementally later.
- Touching `dtrpg-sdk` or the API contract.
- Replacing gpui or revisiting the gpui-kit migration recorded in ADR 0001.

## Current state, measured

**Crate split is inverted.** `dtrpg-ui` is 29,212 lines. `dtrpg-core` is 3,489 and depends on `dtrpg-ui`,
not the reverse. The domain models, persistence, service traits, and credential store all live in
`dtrpg-ui/src/{data,services,credentials}`. What's named "core" is an SDK adapter plus GPUI bootstrap.
`dtrpg_sdk` imports stay confined to `dtrpg-core/src/services/sdk`, so the service-trait seam itself is
sound. The crate names just describe the opposite of the dependency direction.

**Library state is a GPUI entity.** `LibraryController`, implemented across 17 files under
`controllers/library/`, owns the catalog, three independent work queues with duplicated concurrency-slot
bookkeeping, sort and filter and selection state, several ephemeral-UI `HashMap`s, and pending-download
confirmation state. Splitting it across files has kept per-file size down without narrowing what the type
is responsible for. More to the point here, it's a `gpui::Entity`, so library state can't be reached
without a UI framework.

**Persistence is four hand-rolled caches.** Catalog and collections caches are schema-versioned JSON
(`CACHE_SCHEMA_VERSION` is at 3), settings and window state are TOML, covers and avatars are raw bytes on
disk, credentials are in the platform keyring. Search is a linear scan in `controllers/library/filtering.rs`.

**One real boundary leak.** `controllers/library/thumbnails.rs` and `data/avatar.rs` call `reqwest`
directly from the UI crate. Every other network path goes through a service trait, so these two are also
the two with no test seam.

**One Tokio runtime per service construction.** `services/sdk/connection.rs` builds a fresh
`new_multi_thread` runtime each time a service is constructed.

**Themes are a closed enum.** `data/theme.rs` is 718 lines with a `ThemeKey` enum of six variants
(Parchment, Slate, Sage, Ink, Moss, Rosewood). The first four carry `claude-1`'s hex values exactly.
Adding a theme means editing Rust and recompiling.

**Platform code is scattered.** `cfg(target_os)` blocks sit in ten files, most of them views
(`catalog_view.rs`, `detail_panel_view.rs`, `settings_storage_view.rs`) rather than a platform module.

**Two documentation problems worth fixing alongside.** `dtrpg-app/rust/CLAUDE.md` states a hard rule of no
`.rs` file over 500 lines enforced by `make size-check` in CI. At least nine files exceed it, several by
three to four times, with `catalog_view.rs` at 2,282. The same file's examples reference a different
product (`Knot.app`, `knot_core::l10n`, `parking_lot::Mutex`) that doesn't match this codebase's actual
stack. It reads as copied from another project and never reconciled. Either the rule is real and CI should
enforce it, or it should be removed; right now it's neither.

Also worth noting: `Density::Comfortable/Compact` exists in the theme model but no settings page exposes
it. It's a `claude-1` tweak-panel concept that was modeled and then never surfaced.

## Target architecture

Four crates. Each new one exists for a reason the compiler enforces, not for tidiness.

| Crate | Depends on | Why it's separate |
|---|---|---|
| `dtrpg-core` | sdk, platform deps | No GPUI. Makes headless use possible. |
| `dtrpg-ui` | core | Needs GPUI. |
| `dtrpg-desktop` | core, ui | Binary. Wires DI and globals. |
| `dtrpg-mcp` | core | Binary that must not link GPUI. |

`platform`, `api`, `archive`, and `insight` are modules inside `dtrpg-core`, not crates. Cargo's
`[target.'cfg(...)'.dependencies]` already keeps `objc2` and `windows-rs` off the wrong platforms, so a
separate platform crate would buy isolation Cargo gives for free.

**The facade.** `dtrpg_core::api::LibraryApi` is the only `pub` way into library state. Everything else in
the core becomes `pub(crate)`. Both binaries go through it. This is the part that keeps the UI and the
agent surface from drifting, and making it the only public path is what stops the next contributor from
quietly reaching around it.

**The index.** One SQLite file. Tables for items, files, collections, collection membership, tags, item
tags, storage roots, item placement, summaries, and an audit log, plus an FTS5 virtual table over title,
publisher, authors, description, tags, file names, and summary text. Facet counts and the Insights
aggregates are both `GROUP BY` over the same `WHERE` clause as the current view, which is what makes the
facet numbers in the prototype trustworthy rather than decorative. Cover and thumbnail bytes stay as files.

**The platform trait.** One trait returning a `Capabilities` struct the UI queries before offering any
OS-native affordance, so Linux doesn't show a materialize button and Windows doesn't show Finder tags.

| Operation | macOS | Windows | Linux |
|---|---|---|---|
| File state | `NSURLUbiquitousItemDownloadingStatusKey` | `FILE_ATTRIBUTE_RECALL_ON_DATA_ACCESS` | present only |
| Tags | `_kMDItemUserTags` xattr | index only | `user.xdg.tags` xattr |
| Materialize | `startDownloadingUbiquitousItem` | open to trigger recall | not applicable |
| Reveal | `NSWorkspace` | `explorer /select,` | `xdg-open` |

Tags follow one rule: the index is the source of truth and the file system is a projection, reconciled on
launch. Doing it the other way round loses tags on platforms that can't store them.

## Decisions

**SQLite with FTS5, not more JSON caches.** Five goals each want an index. Writing five more bespoke ones
is more code and more invariants than adopting one database, and FTS5 gives goal 3's search for close to
nothing. Rejected: keeping JSON and adding an in-memory inverted index, which is a search engine nobody
asked us to maintain.

**`rusqlite` 0.40 with the `bundled` and `fts5` features, not `sqlx`.** Paul had no preference, so this
is a judgment call with reasons. The index is a local single-writer file, so `sqlx`'s async story buys
nothing here and costs a connection pool, a runtime dependency in the query path, and compile-time macro
setup. `bundled` compiles SQLite from source, which matters for goal 1: no system SQLite version to
differ across macOS, Windows, and Linux, and nothing to install on a build agent. Reconsider only if the
index ever moves off-device.

**A facade module, not a facade crate.** A crate would make the boundary visible in `Cargo.toml`.
`pub(crate)` on everything else makes it a compile error to bypass, which is stronger and costs one crate
fewer.

**Themes as TOML files, not an enum.** Goal 7 asks users to add themes. A closed enum can't do that at
any size. Read a themes directory at startup, hot-reload on change, fall back per-key to a built-in light
or dark base so an old theme file still loads. Semantic state colors (ok, warn, error, cloud) stay outside
the themeable set, so a theme can't make a failed download look healthy.

**MCP off by default, loopback only, three scopes.** Scopes are graded by consequence rather than by CRUD
verb: read changes nothing and spends nothing; write edits user data reversibly; download spends bandwidth,
disk, and money. Summary generation sits in the download scope for that reason, not because it writes.
Every call is audited and surfaced in the existing activity panel. There's deliberately no option to bind
to a non-loopback address.

**Summaries opt-in with visible provenance and a token ceiling.** Model, date, and token count shown on
every summary. Extracted themes feed the FTS index, which is what makes the feature earn its place beyond
being a text blob: it makes the library searchable by what books are about.

**Keep gpui-kit and hand-rolled charts.** Consistent with ADR 0001 and with the `library-analytics-charts`
design note. Inline paths over a charting dependency for this chart set.

**Containers behind a trait, zip and tar first.** Goal 9 ships zip and tar now, but Paul's intent is that
any container format should be supportable, so the format list must not be baked into the UI or the
index. `dtrpg_core::container` defines one trait over the three operations the UI needs (list entries
lazily, read one entry, extract a subset) and a registry that resolves a file to a reader by extension
and magic bytes. The inspector's Contents tab, the index's file-name text rows, and the MCP
`list_archive_entries` tool all talk to the trait, never to a concrete format.

Adding a format is then one implementation plus one registry line, with no change to callers. Compressed
tar variants (`.tar.gz`, `.tar.bz2`, `.tar.xz`) are the first test of that claim, since they compose a
decompressor with the tar reader rather than being separate formats. Candidates after that, in rough order
of demand for this library: 7z, rar, and `.cbz`/`.cbr` comic archives, which are zip and rar underneath
and so mostly need recognition rather than new reading code.

Entry listing is lazy by contract. Reading a directory of a 200 MB archive to show a tree must not
materialize the archive, which also keeps the tab usable on a cloud placeholder.

**Manual collections are DriveThruRPG product lists. There is no separate local model.** Checked against
the current code, not assumed: `dtrpg-core/services/sdk/collections/gateway.rs`'s list, create, delete,
add-item, and remove-item calls are all direct calls to the API's `product_lists` and
`product_list_items` endpoints, and the local `CollectionEntry` cache's own doc comment says plainly that
it is "a startup-speed optimization, not a source of truth." Goal 4's manual half is already seamless by
construction, because there is only one object, not two to reconcile.

**Smart collections cannot write back to DriveThruRPG, but a product list is one predicate in their query,
not a separate kind of thing.** DriveThruRPG has no dynamic-list primitive, so a saved query can never
become a live product list without freezing into a fixed snapshot the moment it is pushed, which is a
different feature (manual export) and not this one. Rejected: two visually and structurally distinct
collection types in the sidebar. Decided instead, per Paul (2026-10-17): `collection: <name>` is a facet
in the smart-collection query language, alongside `tag`, `publisher`, `system`, and the rest, so a manual
collection can seed a smart one rather than sit in a separate category from it. An "Upgrade to smart
collection" action on any manual collection opens the smart-collection editor pre-seeded with
`collection: <name>`; the server-synced membership stays one clause, and any further clauses the user adds
apply locally on top. Upgrading does not fork or modify the underlying product list, it only adds a local
filter in front of its live membership. One sidebar section lists both kinds together, with a small sync
glyph marking entries backed by a real DriveThruRPG list.

## Gap analysis: the twelve goals

| # | Goal | Status | What's missing |
|---|---|---|---|
| 1 | Cross-platform | Partial | Windows is a `workflow_dispatch` spike and a `continue-on-error` packaging leg, not a CI target |
| 2 | SDK library access | Done | Nothing |
| 3 | Browse, search, manage | Partial | Linear-scan search, no facets, no scoped query syntax |
| 4 | Collections | Partial | Manual (= DriveThruRPG product lists) only; no smart collections, no upgrade path |
| 5 | Downloads, partial and multi-location | Partial | Single `storage_root_path`; no placement rules |
| 6 | OS-native integration | Mostly absent | iCloud is spec-only with no code; tags and xattrs absent everywhere |
| 7 | Themes | Partial | Closed six-variant enum; users can't add themes |
| 8 | File openers by type | Done | Nothing |
| 9 | Container contents | Partial | Zip only, popover only; no tree, no single-entry extract, no format abstraction |
| 10 | Agent integration | Absent | No MCP server, no summarization, no spec for either |
| 11 | Customize presentation | Partial | Columns and view state persist; density modeled but unexposed; not per-view |
| 12 | Charts and stats | Spec-only | Umbrella change exists; `library_analytics_view.rs` does not |

Three notes on that table.

Goal 6 is the one most likely to be underestimated. The in-flight `icloud-offloaded-file-awareness`
proposal covers reading download status via `objc2`, which is the easy half. Tags are the half with the
design problem, because Windows has no equivalent and a naive implementation either loses data there or
diverges per platform. Hence the index-as-source-of-truth rule above.

Goal 10 is absent in a specific way worth stating plainly: there's no MCP code, no MCP spec, and no
summarization anywhere. The `summary` identifiers in the tree are the DriveThruRPG API's
product-description field and an unrelated icon asset. This goal is also the only one that can't be built
incrementally on the current structure, which is what makes it the forcing function for this change.

Goal 3's search and goal 12's charts both collapse into roughly one query each once the index exists. They
look like separate features and share a single prerequisite.

## UI changes against today

Comparing `claude-2` to the shipped UI. Carried forward unchanged: the token system and the four shared
theme palettes, the three catalog layouts, the sidebar section model, the resizable split, the status bar
and activity panel, virtualized tables, loading and error states, and the localization pass. The shipped
app is already ahead of `claude-1` on several of these.

| Area | Today | Target |
|---|---|---|
| Search | Toolbar input, linear scan | Omnibox with removable scoped tokens |
| Filtering | Sidebar section plus sort | Facet rail with live counts from the same query |
| Collections | Manual (= DriveThruRPG product lists) | Manual and smart unified in one section; any manual collection can be upgraded, its product list membership becoming one predicate in the smart query |
| Detail | Tabbed view with file list | Inspector with Info, Files, Contents, Summary |
| Containers | Zip popover | Lazy tree, per-entry preview, selective extract, pluggable formats |
| Downloads | Button plus queue | Sheet: which files, which root, space check, optional rule |
| Storage | One path in settings | Many roots with capacity, plus placement rules |
| Themes | Six-swatch picker | Gallery, duplicate and edit, import, hot reload |
| Presentation | Global, columns persisted | Per-view density, cover style, grouping, columns |
| Stats | None | Insights view |
| Agent | None | Settings page with scopes, tool list, audit log |
| Tags | None | Sidebar section, inline chips, inspector editor |
| Chrome | macOS traffic lights | Platform-appropriate caption and menu placement |

The one explicit promotion: `claude-1`'s floating Tweaks panel was a debug overlay. Goal 11 is that panel
turned into a real View Options popover, scoped per view and persisted, which is why density finally gets
a control.

## Child changes and sequencing

This change is the only prerequisite-heavy one. After it, the rest are mostly parallel.

| Order | Change | Repo | Depends on |
|---|---|---|---|
| 0 | `libri-v2-architecture` (this) | app/rust | none |
| 1 | `library-index-search-and-facets` | app/rust | 0 |
| 2 | `platform-native-file-state` | app/rust | 0 |
| 2 | `themes-as-data` | app/rust | 0 |
| 2 | `multi-root-storage-and-placement` | app/rust | 0 |
| 2 | `windows-ci-and-packaging` | app/rust | 0 |
| 3 | `tags-and-os-projection` | app/rust | 1, 2 |
| 3 | `smart-collections` | app/rust | 1 |
| 3 | `per-view-presentation` | app/rust | 0 |
| 3 | `container-browse-and-extract` | app/rust | 0 |
| 3 | `library-analytics-charts` (exists) | umbrella | 1 |
| 4 | `mcp-server` | app/rust | 0, 1 |
| 4 | `content-summaries` | app/rust | 1 |
| see below | `enforce-file-size-limit` | app/rust | none |

Five ADRs belong in `dtrpg-app/rust/docs/adr/`: the crate inversion and facade boundary, SQLite as the
index, the platform-integration abstraction, themes as data, and the container-format abstraction. The
existing `openspec/changes/library-analytics-charts` change stays as written and gains a dependency on the
index.

### The file size limit

`dtrpg-app/rust/AGENTS.md` states "No `.rs` file over 500 lines. Enforced by `make size-check` in CI."
Paul confirmed the rule is real and wants the violations remedied. Current state of that claim:

- There is no `Makefile` in `dtrpg-app/rust`, so there is no `size-check` target.
- No CI workflow checks file length. `ci.yml` runs fmt, clippy, test, and build only.
- Fourteen files exceed 500 lines, not the nine a top-ten listing suggested.

| Lines | File |
|---|---|
| 2282 | `crates/dtrpg-ui/src/ui/views/catalog_view.rs` |
| 1447 | `crates/dtrpg-ui/src/ui/views/root_view.rs` |
| 1387 | `crates/dtrpg-ui/src/ui/views/detail_panel_view.rs` |
| 1017 | `crates/dtrpg-ui/src/controllers/settings.rs` |
| 855 | `crates/dtrpg-core/src/services/sdk/library/mapping.rs` |
| 802 | `crates/dtrpg-ui/src/ui/views/sidebar_view.rs` |
| 718 | `crates/dtrpg-ui/src/data/theme.rs` |
| 702 | `crates/dtrpg-ui/src/controllers/library/catalog_sync.rs` |
| 681 | `crates/dtrpg-ui/src/util/stubs.rs` |
| 625 | `crates/dtrpg-ui/src/ui/app/mod.rs` |
| 598 | `crates/dtrpg-ui/src/data/storage.rs` |
| 553 | `crates/dtrpg-ui/src/data/catalog_cache.rs` |
| 532 | `crates/dtrpg-core/src/services/sdk/library/mod.rs` |
| 511 | `crates/dtrpg-ui/src/data/library.rs` |

Order the work gate-first: add the `Makefile` with a `size-check` target and wire it into `ci.yml` as a
warning, split the files, then flip the gate to failing. Adding a failing gate before the splits blocks
every other change in flight.

Six of the fourteen (`theme.rs`, `storage.rs`, `catalog_cache.rs`, `library.rs`, `catalog_sync.rs`,
`mapping.rs`) are files this change already moves or rewrites, so they should be split as part of it
rather than twice. The remaining view files are better split on their own, and that work collides with
four in-flight changes currently touching `catalog_view.rs` and `sidebar_view.rs`
(`263-download-from-sidebar`, `264-bug-feature-dialog`, `265-activity-scroll`, `migrate-to-gpui-kit`).
Sequence the view splits after those land.

AGENTS.md also carries examples from Knot, which Paul confirmed was the source and inspiration for these
conventions. The rule stands; the examples still reference `knot_core::l10n` and `parking_lot::Mutex`,
neither of which is in this codebase's dependency graph, so they should be restated against Libri's own
stack (`rust_i18n`, gpui entities) to stop sending readers after the wrong pattern.

## Risks / Trade-offs

**The relocation diff is large and mostly mechanical.** Moving `data/`, `services/`, `credentials/`, and
`models/` out of a 29k-line crate touches a lot of files at once and can't be split cleanly, because the
dependency direction has to flip in one commit to keep the workspace compiling. Mitigation: do the move
with no behavior change and no reformatting, so the diff reviews as a rename; land the queue, runtime, and
controller decomposition as separate follow-up commits on the same branch.

**Behavior drift during the move.** 130 specs describe current behavior, which is the asset here. Run the
full suite against each commit rather than at the end.

**SQLite migration is one-way.** First launch reads the JSON caches and writes the index. Keep the JSON
files in place rather than deleting them, so a downgrade still has data to read. Caches are rebuildable
from the API in the worst case, which bounds this risk.

**`unwrap` policy.** The Rust guidance bans `unwrap` and `expect` in production paths with a CI grep.
Database and FTS code is a common place for those to creep in. Worth watching in review.

**Scope creep into the UI.** The temptation during a move this size is to fix views while passing through.
Views should be touched only where the dependency direction forces it.

## Open questions

1. Is `rusqlite` acceptable, or is `sqlx` preferred for the async story? `rusqlite` is simpler and the
   index is local, so the async case is weak; worth confirming.
2. Should `dtrpg-mcp` ship as a second binary in the same package, or as its own crate? Packaging and
   signing probably decide this more than the code does.
3. Which model providers for summaries at launch? Anthropic plus a local Ollama option covers the range
   without much surface area.
## Resolved (2026-10-16)

- **SQLite library:** Paul had no preference and delegated the choice. `rusqlite` 0.40 with `bundled` and
  `fts5`. Reasoning in Decisions above.
- **Container formats:** zip and tar now, behind a trait, with any container format supportable later.
  Drove the container-abstraction decision above and renamed the child change to
  `container-browse-and-extract`.
- **File size limit:** the rule is real and the violations are an oversight to be remedied. Knot was the
  source and inspiration for the convention. Scope and sequencing in the section above.

## Resolved (2026-10-17)

- **Collections model:** confirmed manual collections already are DriveThruRPG product lists with no
  separate local model, and decided smart collections unify with them in the sidebar via a `collection`
  facet rather than sitting in a visually separate category. Reasoning and the upgrade flow are in the
  Decisions section above.
