# sdk-library-service Specification

## Purpose
TBD - created by archiving change connect-sdk-to-rust-app. Update Purpose after archive.
## Requirements
### Requirement: Catalog list is populated from the DriveThruRPG API
The application SHALL load the user's purchased product list from the DriveThruRPG API via the Rust SDK when the library view is displayed. The stub catalog SHALL NOT be shown in production builds.

#### Scenario: Catalog loads real titles on launch
- **WHEN** the application launches with valid SDK credentials
- **THEN** the library view displays titles from the user's DriveThruRPG order history, not hardcoded stub data

#### Scenario: Stub catalog is absent from production code paths
- **WHEN** the application is compiled without the `test` cfg flag
- **THEN** `stub_catalog()` is not callable from any production code path and `util/stubs.rs` is gated behind `#[cfg(test)]`

### Requirement: LibraryService trait mediates all catalog data access
The application SHALL access catalog data exclusively through the `LibraryService` trait. No view, controller, or view model SHALL call SDK types directly; all SDK interaction is encapsulated behind the trait boundary.

#### Scenario: LibraryController uses LibraryService, not stub_catalog
- **WHEN** `LibraryController::new()` is called
- **THEN** it receives a `Box<dyn LibraryService>` rather than calling `stub_catalog()` directly

#### Scenario: Tests inject a stub service through the LibraryService trait
- **WHEN** a unit test exercises `LibraryController` or `LibraryViewModel`
- **THEN** it injects a `StubLibraryService` through the `LibraryService` trait without requiring network access

### Requirement: OrderProductItem fields are mapped to LibraryItem
The SDK's `OrderProductItem` SHALL be mapped to the UI-layer `LibraryItem` according to a defined field mapping. Fields the API does not supply SHALL receive documented default values.

#### Scenario: Title and ID map directly
- **WHEN** an `OrderProductItem` with `attributes.name = "Player's Handbook"` and `id = "12345"` is mapped
- **THEN** the resulting `LibraryItem` has `title = "Player's Handbook"` and `id` derived from the numeric product ID

#### Scenario: Publisher name is resolved from included publishers
- **WHEN** an `OrderProductListResponse` includes a publisher with `id = "7"` and `name = "Paizo"` and a product with `royalty_publisher_id = 7`
- **THEN** the mapped `LibraryItem` has `publisher = "Paizo"`

#### Scenario: Product kind is derived from filters
- **WHEN** an `OrderProductItem` has a filter entry with `parent_name = "Adventure"`
- **THEN** the mapped `LibraryItem` has `kind = "Adventure"`; if no filter is present, `kind` defaults to an empty string or `"Other"`

#### Scenario: File format is derived from the files list
- **WHEN** an `OrderProductItem` has files with titles `["PDF", "EPUB"]`
- **THEN** the mapped `LibraryItem` has `format = "PDF + EPUB"`; if files is empty, `format` defaults to `""`

#### Scenario: Fields with no SDK counterpart receive defaults
- **WHEN** an `OrderProductItem` is mapped
- **THEN** `line` defaults to `""`, `color` defaults to a fixed neutral hex value, and `cover_url` defaults to `None`

### Requirement: Catalog list supports pagination
The SDK service SHALL fetch all pages of order products, not just the first page, assembling the full library before returning.

#### Scenario: Multi-page library is fully loaded
- **WHEN** the user's library spans more than one API page (e.g., `items_per_page = 100` and the user owns 150 products)
- **THEN** all 150 products are returned by `list_items()`; no page is silently dropped

#### Scenario: Single-page library is returned without extra requests
- **WHEN** the user's library fits on the first page
- **THEN** only one API request is made and the full list is returned

### Requirement: Service errors are classified and surfaced
The `LibraryService` SHALL classify failures into `Network`, `Session`, and `NotFound` kinds. The `LibraryViewModel` SHALL translate each kind into the appropriate pane state so the UI can display a relevant error message.

#### Scenario: Network error produces Error pane state
- **WHEN** `list_items()` returns a `LibraryServiceError` with kind `Network`
- **THEN** the `LibraryViewModel` transitions to `LibraryPaneState::Error` and stores the error for display

#### Scenario: Session error prompts re-authentication
- **WHEN** `list_items()` returns a `LibraryServiceError` with kind `Session`
- **THEN** the `LibraryViewModel` transitions to `LibraryPaneState::Error` with a message indicating the session has expired

#### Scenario: Empty library produces Empty pane state
- **WHEN** `list_items()` succeeds but returns zero items
- **THEN** the `LibraryViewModel` transitions to `LibraryPaneState::Empty`

### Requirement: SDK credentials sourced from environment variables in the first pass
Until `secure-credential-storage` is implemented, the `HttpSdkLibraryGateway` SHALL read the application key and auth tokens from well-known environment variables. The application SHALL fail gracefully with a clear error if required variables are absent.

#### Scenario: Application loads with all required environment variables set
- **WHEN** `DTRPG_APPLICATION_KEY`, `DTRPG_ACCESS_TOKEN`, and `DTRPG_REFRESH_TOKEN_TTL` are set in the environment
- **THEN** the SDK is configured and authenticated and `list_items()` makes live API requests

#### Scenario: Missing application key produces a Session error
- **WHEN** `DTRPG_APPLICATION_KEY` is not set
- **THEN** `HttpSdkLibraryGateway::from_environment()` returns a `LibraryServiceError` with kind `Session` and a message naming the missing variable

