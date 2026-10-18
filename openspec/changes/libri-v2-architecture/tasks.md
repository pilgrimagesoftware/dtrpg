## 0. Status and staging

Status below was checked against `dtrpg-app.rs` `develop` on 2026-10-18, and updated as stage 3 landed.
The work is split into four stages. Stages 1, 2 and 3 are essentially done; stage 4 holds the remaining
work.
Each stage is a separate issue and PR in `dtrpg-app/rust`, in this order:

| Stage | Scope | Status | Capability / ADR |
|---|---|---|---|
| 1 | Crate inversion and `LibraryApi` facade | Done | `libri-api-facade`, ADR 0002 |
| 2 | SQLite library index | Done | `libri-library-index`, ADR 0003 |
| 3 | Shared runtime and unified work queue | Done (`dtrpg-app.rs#318`, merged) | `libri-work-queue`, ADR 0007 |
| 4 | Platform integration layer | In progress (`dtrpg-app.rs#325`) | `libri-platform-integration`, ADR 0004 |

Stages 3 and 4 were independent of each other. Per `design.md`, the interactive
catalog keeps its synchronous in-memory render model: the index is not read on the render path, so no
"controller decomposition" stage exists.

## 1. Stage 1: Crate inversion and facade

- [x] 1.1 Move domain models, persistence, service traits, and the credential store out of `dtrpg-ui` into
      `dtrpg-core`, with no GPUI dependency
- [x] 1.2 Split the binary into `dtrpg-desktop` and `dtrpg-mcp`; `dtrpg-mcp` depends on `dtrpg-core` only
- [x] 1.3 Add `dtrpg_core::api::LibraryApi` as the supported entry point for both binaries
- [x] 1.4 Record the decision in ADR 0002 (accepted 2026-10-17)
- [ ] 1.5 Confirm the "everything else is `pub(crate)`" boundary: list the `pub` items in `dtrpg-core` that
      are not reachable through `LibraryApi` and either narrow them or justify them in the ADR

## 2. Stage 2: SQLite library index

- [x] 2.1 Add the `rusqlite` (bundled) index with an FTS5 table over searchable text
      (`dtrpg-core/src/data/index/`)
- [x] 2.2 One-way migration of the JSON catalog and collections caches on first launch
      (`data/index/migrate.rs`); the JSON files are left in place for downgrade
- [x] 2.3 Index-backed read methods on `LibraryApi` (`index_list_items`, `index_get_item`, `search`, and
      the count methods)
- [x] 2.4 Record the decision in ADR 0003
- [ ] 2.5 Confirm the `fts5` feature is not needed explicitly: `design.md` and the proposal name
      `bundled` and `fts5`, but `dtrpg-core/Cargo.toml` enables only `bundled`. Add a test that creates
      the FTS5 table on a clean database, or enable the feature
- [ ] 2.6 Decide the fate of the JSON cache readers (`data/catalog_cache.rs`, `collections_cache.rs`) now
      that the index exists: keep only as the migration source, or retire after one release

## 3. Stage 3: Shared runtime and unified work queue

Work-queue requirements are in `specs/libri-work-queue`. Implemented in `dtrpg-app.rs` pull request #318 (merged);
the design is ADR 0007 there, and the app's own specs are restated by its `adopt-core-work-queue` change.

- [x] 3.1 Add one shared Tokio runtime to `dtrpg-core` and hand it out as handles. (`dtrpg_core::runtime`,
      a process-wide runtime built on first use; not owned by the facade, because the services that need
      it are built before any facade exists.)
- [x] 3.2 Replace the three per-site runtimes with that handle: `services/sdk/connection.rs` (two sites,
      one in test code) and `services/login.rs`
- [x] 3.3 Add a bounded priority queue to `dtrpg-core` with shared concurrency accounting, cancellation of
      pending and running work, and progress reporting (`dtrpg_core::work`)
- [x] 3.4 Move thumbnail fetching onto the queue (replaces `thumbnail_queue` in
      `dtrpg-ui/src/controllers/library/mod.rs`)
- [x] 3.5 Move downloads onto the queue (replaces `download_queue`); user-initiated downloads outrank
      thumbnails
- [x] 3.6 Move availability checks onto the queue (replaces `check_queue`). Checks are their own lane: one
      at a time, outside the shared limit. On-disk verification of a selected item is deliberately not
      queued (a handful of `exists` calls the user is waiting on).
- [x] 3.7 Report download progress to the activity panel. Downloads never reported progress before, so
      this added a progress callback to `LibraryService::download_item` (`DownloadControl`) and the
      activity panel's progress bar. Not done through `LibraryApi`: the queue still belongs to the desktop
      controller, and the MCP server has no download tool yet (see 3.12).
- [x] 3.8 Close the network boundary leak: cover fetching (`services::covers`) and avatar fetching
      (`services::avatar`) sit behind transport traits with a test seam, and the UI crate no longer depends
      on `reqwest`
- [x] 3.9 Tests: concurrency limit honored, priority order, cancel pending, cancel running releases its
      slot, and the queue runs with no window (the queue's own tests run in `dtrpg-core` with no GPUI)
- [x] 3.10 Restate `rust-resource-work-queue-topology` against `libri-work-queue` (the app's
      `adopt-core-work-queue` change, which also restates the thumbnail and download specs and adds
      `availability-check-scheduling`), and bring `specs/libri-work-queue` into line with what was built
- [x] 3.11 Record the decision in an ADR (ADR 0007, `dtrpg-app/rust/docs/adr/0007-core-work-queue.md`)
- [ ] 3.12 Expose the queue and its events through `LibraryApi`, when the MCP server gets tools that
      download. Nothing needs it yet.

## 4. Stage 4: Platform integration layer

Requirements are in `specs/libri-platform-integration`.

- [x] 4.1 Add `dtrpg_core::platform` with the `PlatformIntegration` trait, `Capabilities`, `PlatformKind`,
      and `FileState`
- [x] 4.2 Route reveal, iCloud status, and view-level platform text through the trait
      (`util/reveal.rs`, `util/icloud_status.rs`, `catalog_view.rs`, `detail_panel_view.rs`,
      `settings_storage_view.rs`, `title_bar_view.rs`)
- [x] 4.3 Record the decision in ADR 0004
- [x] 4.4 Audit the remaining `cfg(target_os)` blocks. All are paths, build constants, or one standard-library
      call in a util, so none moves behind the trait; the audit table is in ADR 0004
- [x] 4.5 Verify each per-OS implementation against the table in ADR 0004. Fixed: Windows file state, the
      Windows reveal exit status, and macOS offload detection (now `st_flags`). Reading a real placeholder on
      macOS or Windows is not covered by an automated test
- [x] 4.6 Capability gating and materialization. Opening an offloaded file now requests and waits for it in the
      background (`materialize_and_wait`). No control depends on a capability that is `false` today, so there
      was nothing to hide; ADR 0004 says a later control must read `Capabilities` first
- [ ] 4.7 Tags: implement the index-as-source-of-truth projection (macOS `_kMDItemUserTags`, Linux
      `user.xdg.tags`, Windows index only) with reconciliation on launch. This may split into the
      `tags-and-os-projection` child change, which depends on `library-index-search-and-facets`
- [x] 4.8 Reconcile `icloud-offloaded-file-awareness` with the trait. It was already built behind
      `dtrpg_core::platform`; its tasks are ticked and its spec restated. Left open, not archived, for its
      manual check on a real Mac (its task 5.6)

## 5. Cross-cutting

- [ ] 5.1 Wire `make size-check` into CI. `design.md` records the gate as landed, but `dtrpg-app/rust`
      `develop` has no `Makefile` and `ci.yml` has no size check. Sixteen files exceed 500 lines.
      Add the gate as a warning, split the files, then make it fail. Tracked as the separate
      `enforce-file-size-limit` change; sequence the view splits after the in-flight view work lands
- [ ] 5.2 Correct `dtrpg-app/rust/AGENTS.md` examples that reference Knot (`knot_core::l10n`,
      `parking_lot::Mutex`) so they match Libri's stack
- [ ] 5.3 ADR for the container-format abstraction exists (0006); confirm 0005 (themes) and 0006 match
      what was built, since `container-browse-and-extract` and `mcp list_archive_entries` have shipped
- [ ] 5.4 Windows CI promotion stays in the separate `windows-ci-and-packaging` change
- [ ] 5.5 When all four stages are complete, archive this change with `openspec-archive-change`
