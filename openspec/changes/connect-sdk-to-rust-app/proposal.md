## Why

The Rust desktop app currently displays a hardcoded stub catalog of fictitious RPG titles (`util/stubs.rs`). A complete service abstraction layer (`dtrpg-core/services`), SDK gateway adapter, and library view model were previously designed and implemented — but the entire body of code was commented out before it could be connected to the UI. The SDK is already a workspace dependency. The work is to uncomment, reconcile the data model, and wire the controller to live data.

## What Changes

- `dtrpg-core/src/services/mod.rs` is uncommented: restores `LibraryItem`, `LibraryService` trait, `LibraryServiceError`, and `LibraryServiceErrorKind`.
- `dtrpg-core/src/services/sdk.rs` is uncommented and completed: restores `SdkLibraryGateway`, `RustSdkLibraryService`, `HttpSdkLibraryGateway` (async → sync bridge via Tokio block-on), and the `UnavailableSdkGateway` fallback.
- `dtrpg-ui/src/view_models/library.rs` is uncommented: restores `LibraryViewModel` and `LibraryPaneState`.
- The UI-layer `LibraryItem` (`dtrpg-ui/src/data/library.rs`) is reconciled with what the SDK provides — fields the API does not supply (`line`, `color`, `cover_url`) get sensible defaults; the `id` field moves from `Arc<str>` to `u64` or a newtype wrapper.
- `LibraryController::new()` is updated to call the SDK service instead of `stub_catalog()`; stub data is removed from production code paths (retained in a `#[cfg(test)]` module only).
- The credential/config wiring is updated to read the application key and auth session from wherever the app currently stores them (environment variables in the first pass, later replaced by the `secure-credential-storage` change).

## Capabilities

### New Capabilities

- `sdk-library-service`: The live `RustSdkLibraryService` replaces the stub catalog; the `LibraryService` trait and `LibraryViewModel` are active, tested, and wired to the `LibraryController`.

### Modified Capabilities

<!-- No existing OpenSpec specs have requirement-level changes from this work. -->

## Impact

- **dtrpg-app/rust / dtrpg-core**: `services/mod.rs` and `services/sdk.rs` uncommented and completed. `dtrpg-sdk` already listed in workspace dependencies.
- **dtrpg-app/rust / dtrpg-ui**: `view_models/library.rs` uncommented. `data/library.rs` `LibraryItem` struct reconciled with SDK output. `controllers/library.rs` wired to `LibraryViewModel` instead of `stub_catalog()`. `util/stubs.rs` restricted to test-only usage.
- **Model mapping**: `OrderProductItem` → `LibraryItem` requires publisher lookup (from `included`), filter-based `kind` derivation, and file-list-based `format` derivation. Fields with no SDK counterpart (`line`, `color`, `cover_url`) are defaulted.
- **Auth/config**: First pass reads application key and tokens from environment variables (the same approach already in the commented-out `HttpSdkLibraryGateway`). This is a temporary bridge until `secure-credential-storage` is live.
- **No API or SDK changes**: All required SDK types (`LibraryClient`, `list_order_products`, `get_order_product`) already exist.
