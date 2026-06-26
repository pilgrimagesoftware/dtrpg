## 1. Uncomment and Compile the Service Layer

- [ ] 1.1 Uncomment all code in `dtrpg-core/src/services/mod.rs`; run `cargo check -p dtrpg-core` and fix any compilation errors (SDK API drift, missing imports, etc.)
- [ ] 1.2 Uncomment all code in `dtrpg-core/src/services/sdk.rs`; run `cargo check -p dtrpg-core` and fix any compilation errors
- [ ] 1.3 Uncomment all code in `dtrpg-ui/src/view_models/library.rs`; run `cargo check -p dtrpg-ui` and fix any compilation errors
- [ ] 1.4 Run `cargo test -p dtrpg-core` and `cargo test -p dtrpg-ui`; confirm all previously passing tests still pass
- [ ] 1.5 Resolve any import errors in `dtrpg-ui/src/models/library_data.rs` (it imports `crate::services::LibraryItem` which requires the service module to be active)

## 2. Reconcile the LibraryItem Model

- [ ] 2.1 Add `numeric_id: u64` to `dtrpg-ui/src/data/library.rs` `LibraryItem` struct
- [ ] 2.2 Update `LibraryItem::new()` or add a secondary constructor that accepts `numeric_id`
- [ ] 2.3 Update all `LibraryItem` construction sites in `util/stubs.rs` and test helpers to supply a `numeric_id` (can be `0` for stubs)
- [ ] 2.4 Update `LibraryController::select_item` and any ID-comparison logic to use `numeric_id` instead of the string `id` field when calling `service.get_item(id)`
- [ ] 2.5 Confirm `cargo check --workspace` is clean after model changes

## 3. Implement the OrderProductItem Mapping

- [ ] 3.1 Write `fn map_order_product(item: &OrderProductItem, publishers: &HashMap<u64, &str>, index: u32) -> dtrpg_ui::data::library::LibraryItem` in `dtrpg-core/src/services/sdk.rs` (or a dedicated `mapping.rs` submodule)
- [ ] 3.2 Implement publisher name lookup: build a `HashMap<u64, &str>` from the `included` publishers list; use `royalty_publisher_id` as the key; fall back to `""`
- [ ] 3.3 Implement kind derivation: take the first filter entry where `parent_filter_id == 0` and use `parent_name`; fall back to `"Other"`
- [ ] 3.4 Implement format derivation: collect unique file `title` values, sort, and join with `" + "`; fall back to `""`
- [ ] 3.5 Implement `size_mb` derivation: sum `OrderProductFile.size` in bytes across all files and convert to `f64` megabytes
- [ ] 3.6 Implement `year` derivation: parse the year from `file_last_modified`, falling back to `date_purchased`, then `0` if both are absent
- [ ] 3.7 Set `line = ""`, `color = "#2E3A45"`, `cover_url = None`, `pages = 0`, `status = ItemStatus::Cloud` as documented defaults
- [ ] 3.8 Write unit tests for the mapping function using the `FakeSdkGateway` fixture data already present in the commented-out test block

## 4. Add Pagination to HttpSdkLibraryGateway

- [ ] 4.1 Replace the single `list_order_products` call in `HttpSdkLibraryGateway` with a loop that follows `PaginationLinks.next` until it is `None`
- [ ] 4.2 Accumulate all `data` arrays across pages into a single `Vec<OrderProductItem>`
- [ ] 4.3 Merge `included` publishers across pages, deduplicating by publisher `id`
- [ ] 4.4 Write a unit test (using a fake gateway) that verifies items from two pages are both present in the `list_items()` output

## 5. Wire LibraryController to the Service

- [ ] 5.1 Change `LibraryController::new()` signature to accept `Box<dyn LibraryService>` instead of calling `stub_catalog()` directly
- [ ] 5.2 Update the `load_list()` call inside the controller (or add one) to populate `catalog` from `service.list_items()`, mapping `CoreLibraryItem` to the UI `LibraryItem`
- [ ] 5.3 Confirm `LibraryController::select_item(id: u64)` calls `service.get_item(id)` and maps the result; uncomment and fix as needed
- [ ] 5.4 Confirm `LibraryController` propagates `LibraryServiceError` into `LibraryViewModel` pane state (Error, Empty, Loaded)

## 6. Gate Stub Data Behind #[cfg(test)]

- [ ] 6.1 Add `#[cfg(test)]` to the `stub_catalog()` function in `util/stubs.rs` (or move the function into a `#[cfg(test)] mod stubs` block)
- [ ] 6.2 Confirm no production code path imports or calls `stub_catalog()` after the change
- [ ] 6.3 Run `cargo build --workspace` (without test cfg) and confirm it succeeds without stub references

## 7. Wire App Entry Point to RustSdkLibraryService

- [ ] 7.1 In `dtrpg-core/src/app/mod.rs` (or `main.rs`), replace any stub-based controller construction with `RustSdkLibraryService::from_environment()`
- [ ] 7.2 Confirm gpui dispatches the `load_list()` call off the main render thread (e.g., via `cx.spawn` or a deferred task); add a spawn wrapper if `block_on` would otherwise block the UI thread
- [ ] 7.3 Confirm that if `from_environment()` returns an `UnavailableSdkGateway` (missing env vars), the app starts successfully and displays a `LibraryPaneState::Error` message rather than crashing

## 8. Verification

- [ ] 8.1 Run `cargo test --workspace` and confirm all tests pass
- [ ] 8.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings
- [ ] 8.3 Set `DTRPG_APPLICATION_KEY`, `DTRPG_ACCESS_TOKEN`, `DTRPG_REFRESH_TOKEN`, and `DTRPG_REFRESH_TOKEN_TTL` in the environment and launch the app; confirm the catalog view populates with real titles
- [ ] 8.4 Launch the app without any environment variables set; confirm the catalog shows an error state and does not crash
- [ ] 8.5 Select an item in the catalog and confirm the detail view populates from real data (not stub data)
- [ ] 8.6 Confirm the API ordering semantics (newest-first vs. oldest-first) and adjust `added_order` derivation if the assumption was wrong
