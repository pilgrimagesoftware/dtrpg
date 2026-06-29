## Context

The commented-out code tells the full story: an engineer designed a layered architecture (`LibraryService` trait → `RustSdkLibraryService` → `HttpSdkLibraryGateway` → SDK `LibraryClient`) and wrote most of it before the UI layer caught up. Rather than leave half-integrated code in the live build, everything was commented out and the controller was wired to a stub. The architecture is sound; the work is to restore it, fix the two concrete problems that caused the comment-out (model mismatch and async bridge), and connect the dots.

**Current state summary:**
- `dtrpg-core/src/services/mod.rs` — entirely commented out; defines `LibraryItem`, `LibraryService`, `LibraryServiceError`
- `dtrpg-core/src/services/sdk.rs` — entirely commented out; `RustSdkLibraryService`, `HttpSdkLibraryGateway`, test helpers
- `dtrpg-ui/src/view_models/library.rs` — entirely commented out; `LibraryViewModel`, `LibraryPaneState`
- `dtrpg-ui/src/controllers/library.rs` — active; calls `stub_catalog()`; needs to accept `Box<dyn LibraryService>`
- `dtrpg-ui/src/data/library.rs` — active; defines a richer `LibraryItem` with fields the API doesn't supply
- `dtrpg-ui/src/models/library_data.rs` — imports `crate::services::LibraryItem` (currently broken; will be resolved when the service module is uncommented)

## Goals / Non-Goals

**Goals:**
- Uncomment the service layer and view model, fixing compilation errors.
- Reconcile the two `LibraryItem` types — the commented-out `dtrpg-core` version and the active `dtrpg-ui` version — into a single canonical type.
- Implement the `OrderProductItem` → `LibraryItem` mapping with publisher lookup, filter-based kind derivation, and file-format derivation.
- Add full pagination so the entire library is fetched.
- Wire `LibraryController::new()` to accept a `Box<dyn LibraryService>` and gate stub data behind `#[cfg(test)]`.
- Ensure all existing tests (which already use `StubLibraryService`) pass unchanged.

**Non-Goals:**
- Replacing the environment-variable credential approach with Keychain storage (that is `secure-credential-storage`).
- Implementing async loading with progress indicators (the service is sync via `block_on`; async UI loading is a follow-up).
- Fetching product detail on-demand from the API (the commented-out `get_item` implementation suffices; detail fields missing from the list response can be filled from what the list provides).
- Cover art / thumbnail fetching.

## Decisions

### Decision 1: Canonicalize on the dtrpg-ui LibraryItem, augmented with a numeric id

**Problem**: Two `LibraryItem` types exist. The `dtrpg-core` version has `id: u64` and minimal fields. The `dtrpg-ui` version has `id: Arc<str>` and richer UI fields. `library_data.rs` already imports from `crate::services::LibraryItem`, which will point to whichever type the services module exposes.

**Choice**: Keep the `dtrpg-ui/src/data/library.rs` type as the canonical `LibraryItem`, adding a `numeric_id: u64` field so selection and detail loading can use the stable API identifier. Move or re-export it so `dtrpg-core/services` can reference it — or have `dtrpg-core` define a minimal `CoreLibraryItem` that the UI maps to its richer type inside the controller.

The cleanest approach: `dtrpg-core` defines a minimal `LibraryItem` (as originally designed), and the `LibraryController` maps `CoreLibraryItem → dtrpg_ui::data::library::LibraryItem` before populating its catalog. This keeps the crate boundary clean: core does not depend on UI types.

**Rationale**: Core crates must not depend on UI crates. The extra mapping step is small and localized.

### Decision 2: The async bridge stays in HttpSdkLibraryGateway via tokio block_on

The SDK's `LibraryClient` methods are `async`. The `LibraryService` trait is sync (called from a non-async controller). The commented-out code already used `tokio::runtime::Builder::new_multi_thread().enable_all().build()` and `runtime.block_on(...)` to bridge async to sync inside `HttpSdkLibraryGateway`.

This approach is correct for a first pass: the runtime is created once when the gateway is constructed and reused for all calls. It does block the calling thread while the request is in flight, which is acceptable because the controller is not called from the main render loop directly — the gpui event system dispatches controller actions on a background thread or via deferred tasks.

**Alternative considered**: Make `LibraryService` async. This would require async-aware gpui event handling throughout the controller and view model, a larger change. Defer until there's a concrete need for async UI loading.

### Decision 3: Pagination via recursive next-page fetching until exhausted

`list_order_products` returns a `PaginationLinks` with a `next` field. The gateway accumulates pages in a loop until `next` is `None`. All `data` arrays are concatenated before mapping. `included` publishers are merged across pages (deduplicating by id) since the API may return publishers in any page response.

**Alternative considered**: Fetch only the first page and show a "Load more" button. Rejected for now — the existing UI has no pagination affordance, and typical library sizes (tens to low hundreds of items) fit in a few pages with minimal latency.

### Decision 4: Field mapping defaults for unrepresented fields

| LibraryItem field | SDK source | Default when absent |
|---|---|---|
| `id` | `Arc<str>` from `OrderProductItem.attributes.product_id.to_string()` | — (always present) |
| `numeric_id` | `OrderProductItem.attributes.product_id` | — |
| `title` | `OrderProductItem.attributes.name` | — |
| `publisher` | Publisher lookup by `royalty_publisher_id` from `included` | `""` |
| `line` | Not in API | `""` |
| `kind` | First filter `parent_name` where `parent_filter_id == 0` | `"Other"` |
| `format` | Unique file titles joined with ` + ` | `""` |
| `pages` | Not in API | `0` |
| `size_mb` | Sum of `OrderProductFile.size` in bytes ÷ 1 048 576 | `0.0` |
| `year` | Year parsed from `file_last_modified` or `date_purchased` | `0` |
| `added_order` | Enumeration index in list response (0 = most recently purchased if API returns newest-first) | list index |
| `status` | `ItemStatus::Cloud` (no download state yet) | — |
| `color` | Not in API | `"#2E3A45"` (neutral dark) |
| `desc` | Not in API | `""` |
| `cover_url` | Not in API | `None` |

### Decision 5: Stub data is test-only, not feature-flagged

`util/stubs.rs` is moved behind `#[cfg(test)]` (or into a `tests/` module). It is not kept as a "demo mode" behind a feature flag. If offline development is needed in future, a fixture-file approach is preferable to hardcoded stubs.

## Risks / Trade-offs

**[Risk] Blocking the gpui thread during API calls** → Mitigation: Confirm that `LibraryController::new()` and `load_list()` are called off the main render thread in gpui (e.g., via `cx.spawn` or a deferred task). If not, the HTTP request will freeze the UI. Verify during implementation and add a `cx.spawn` wrapper if needed.

**[Risk] Publisher lookup misses if the API does not include all publishers in `included`** → Mitigation: The `included` field is populated when `get_filters=true` is passed in `LibraryItemsParams`. The commented-out gateway already sets this flag. If a publisher is still missing, fall back to `""` rather than panicking.

**[Risk] Environment variable credentials are not suitable for long-term use** → Mitigation: This is an explicitly temporary approach, documented in the spec and tracked by the `secure-credential-storage` change. The `HttpSdkLibraryGateway` is the only place that reads env vars, making it easy to replace later.

**[Risk] Commented-out code has not been compiled since it was commented out; there may be API drift** → Mitigation: The first task is to uncomment and run `cargo check`. Any drift from SDK changes will surface as compiler errors and can be fixed before proceeding.

## Migration Plan

1. Uncomment `dtrpg-core/src/services/mod.rs` and `sdk.rs`; run `cargo check --workspace` and fix any compilation errors.
2. Uncomment `dtrpg-ui/src/view_models/library.rs`; run `cargo check --workspace`.
3. Add `numeric_id: u64` to the UI `LibraryItem` and update all construction sites.
4. Implement the `CoreLibraryItem → LibraryItem` mapping function in the controller crate.
5. Update `LibraryController::new()` to accept `Box<dyn LibraryService>` and map items through the new function.
6. Add pagination loop to `HttpSdkLibraryGateway::list_order_products`.
7. Move `stub_catalog()` to `#[cfg(test)]`.
8. Update `main.rs` / `app::setup` to construct `RustSdkLibraryService::from_environment()` and inject it into the controller.
9. Run `cargo test --workspace` — all existing tests must pass.
10. Manual smoke test with real credentials set in the environment.

## Open Questions

- **gpui dispatch**: Does `LibraryController::load` get called from within a gpui task/spawn, or directly on the main thread? This determines whether the `block_on` bridge is safe or will deadlock.
- **Detail fetch**: The `get_item` path (detail view) is also commented out. Should it be uncommented as part of this change, or is the detail view populated entirely from list data? If the detail view needs fields not in the list response, a separate API call is required.
- **added_order semantics**: The API does not document whether order products are returned newest-first or oldest-first. Confirm the ordering before using the enumeration index as `added_order`.
