## Why

Libri's twelve product goals divide cleanly into ones the current architecture can absorb and ones it
cannot. Six are implemented, three are partial, and three are absent or spec-only. The three that are
missing - OS-native integration, an agent/MCP surface, and content summaries - all fail against the same
two structural facts:

1. **Domain logic lives in the UI crate.** `dtrpg-ui` is 29,212 lines and holds the domain models
   (`data/library.rs`), persistence (`data/catalog_cache.rs`, `data/storage.rs`), the service traits
   (`services/mod.rs`), and the credential store. `dtrpg-core` is 3,489 lines of SDK adapter and GPUI
   bootstrap, and it depends on `dtrpg-ui`, not the other way round. Library state is held inside
   `LibraryController`, a GPUI `Entity`. Nothing headless can reach the library without linking a UI
   framework, so an MCP server cannot be built without either duplicating the logic or booting GPUI.
2. **Persistence is a set of hand-rolled JSON caches.** Catalog, collections, grouped items, and covers
   each have their own file-backed cache with its own schema version. Search is a linear scan over an
   in-memory `Vec` in `controllers/library/filtering.rs`. Five of the twelve goals - search, tags,
   multi-root placement, summaries, and stats - each want an index. Adding five more bespoke indices is
   strictly worse than adopting one database.

Neither problem is urgent on its own, and neither is visible to users today. Both become blocking the
moment the remaining goals are attempted, and both get more expensive to fix as the UI crate grows. This
change does the structural work once, so the feature changes that follow are additive.

A `claude-2` design prototype in the `dtrpg-design` repo shows the target UI these capabilities support.

## What Changes

Structural only. No user-visible feature ships in this change; every feature goal becomes a child change
that depends on it.

- **Invert the crate graph.** Move domain models, persistence, service traits, and the credential store
  out of `dtrpg-ui` into a `dtrpg-core` that has no GPUI dependency. `dtrpg-ui` depends on `dtrpg-core`.
  Two thin binary crates (`dtrpg-desktop`, `dtrpg-mcp`) replace the current single binary, so the MCP
  server never links a UI framework.
- **Add a command/query facade.** `dtrpg_core::api::LibraryApi` becomes the only way into the library for
  callers outside the core. The desktop UI and the MCP server both go through it, which is what keeps the
  two from drifting apart. Everything else in the core becomes `pub(crate)`, so the boundary is enforced
  by the compiler rather than by convention.
- **Replace the JSON caches with one SQLite index** (`rusqlite`, bundled) with an FTS5 table over
  searchable text. Supersedes the catalog, collections, and grouped-item caches. Cover and thumbnail bytes
  stay as files on disk, which already works. Existing caches become a one-way migration on first launch.
- **Introduce a platform integration layer.** `dtrpg_core::platform` exposes one trait with per-OS
  implementations behind `[target.'cfg(...)'.dependencies]`, plus a capability struct the UI queries so it
  can hide what a platform cannot do. Collects the `cfg(target_os)` blocks currently scattered across ten
  files in the UI crate.
- **Share one async runtime.** `services/sdk/connection.rs` builds a fresh multi-threaded Tokio runtime
  per service construction. Build one, hold it, hand out handles.
- **Replace the three hand-rolled queues** in `LibraryController` (thumbnails, downloads, availability
  checks, each a `VecDeque` with its own concurrency-slot bookkeeping) with one bounded priority queue in
  the core.
- **Decompose `LibraryController`.** Catalog data and queue state move to the core; the controller keeps
  only per-pane view state and becomes a view-model over `LibraryApi`.
- **Close the network boundary leak.** `controllers/library/thumbnails.rs` and `data/avatar.rs` call
  `reqwest` directly from the UI crate, bypassing the service traits used for every other network path and
  leaving no test seam. Move both behind a core service.

## Capabilities

### New Capabilities

- `libri-library-index`: A SQLite-backed library index with an FTS5 full-text table is the single source
  of truth for catalog, collection, tag, placement, and summary data, and the sole origin of facet and
  aggregate counts.
- `libri-api-facade`: A headless `LibraryApi` command/query surface in `dtrpg-core` is the only supported
  entry point to library state for callers outside the core, and carries no UI-framework dependency.
- `libri-platform-integration`: A single platform-integration trait with per-OS implementations reports a
  capability set the UI consults before offering any OS-native affordance.
- `libri-work-queue`: One bounded priority work queue serves every background concern (thumbnails,
  downloads, verification) with shared concurrency accounting.

### Modified Capabilities

- `catalog-disk-cache`, `catalog-cache-checkpointing`, `grouped-item-cache`: superseded by
  `libri-library-index`; retained only as a migration source.
- `credential-store`: moves to `dtrpg-core` unchanged in behavior.
- `rust-resource-work-queue-topology`: restated against `libri-work-queue`.

## Impact

- `dtrpg-app/rust/Cargo.toml`: workspace grows from two crates to four (`dtrpg-core`, `dtrpg-ui`,
  `dtrpg-desktop`, `dtrpg-mcp`). One new dependency: `rusqlite` 0.40 with the `bundled` and `fts5`
  features. Per-target dependencies for the platform layer.
- `dtrpg-app/rust/crates/dtrpg-ui/src/{data,services,credentials,models}/`: moves to `dtrpg-core`. This is
  the bulk of the diff and is mostly mechanical relocation.
- `dtrpg-app/rust/crates/dtrpg-ui/src/controllers/library/`: 17 files reduced to view-state only; queue and
  catalog ownership moves out.
- `dtrpg-app/rust/crates/dtrpg-core/src/services/sdk/`: unchanged in behavior, re-homed under the new core
  and reached through `LibraryApi`.
- `dtrpg-app/rust/.github/workflows/ci.yml`: currently builds macOS and Linux only; Windows exists as a
  `workflow_dispatch` spike and a `continue-on-error` packaging leg. Goal 1 needs Windows promoted to a
  first-class CI target, which this change is a prerequisite for but does not itself do.
- Five decisions warrant ADRs in `dtrpg-app/rust/docs/adr/`: the crate inversion and facade boundary,
  SQLite as the index, the platform-integration abstraction, themes as data files, and the container-format
  abstraction. The container trait itself ships with the `container-browse-and-extract` child change; only
  the decision is recorded here.
- `dtrpg-app/rust/AGENTS.md` and a new `Makefile`: the documented 500-line file limit has no `size-check`
  target and no CI step, and fourteen files exceed it. Gate and splits are scoped in `design.md` and
  sequenced after the in-flight view changes land.
- `dtrpg-design/claude-2/`: the design prototype this change enables. No code dependency.

## Non-Goals

- No user-visible feature. MCP, summaries, multi-root storage, themes-as-data, tags, archive browsing, and
  insights are each a separate child change.
- No change to the DriveThruRPG API contract or to `dtrpg-sdk`.
- No UI redesign. The target design is recorded in `claude-2` and lands incrementally afterwards.
- Not a rewrite. Every move is a relocation or a swap of one mechanism for another, with behavior held
  constant and the existing specs as the regression bar.
