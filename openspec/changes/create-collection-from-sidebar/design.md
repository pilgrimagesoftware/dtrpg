## Context

The `add-collections-support` change introduced `CollectionsService` (read-only: `list_collections`) and `CollectionsServiceFactory`. The sidebar now shows collections fetched at startup. This change extends that foundation with write support.

The SDK has `LibraryClient::list_product_lists` and `list_product_list_items` but no create method. The DTRPG API exposes `POST /product_lists` with a JSON body `{ "name": "<name>" }`.

The activity panel is already wired to the library's background load; we can use the same `ActivityController::start` / `complete` / `error` pattern for collection creation.

## Goals / Non-Goals

**Goals:**
- Add `create_collection(name)` to the `CollectionsService` trait and SDK gateway.
- Add an "+" icon button to the Collections sidebar header.
- Modal dialog: single name field, Cancel/Create, Create disabled when blank.
- Background task creates the collection, writes to the activity panel, and on failure pushes an error `Notification`.
- On success the new `CollectionEntry` is appended to `LibraryController::collections` and a `LibraryChanged` event is emitted.

**Non-Goals:**
- Deleting or renaming collections.
- Adding items to a collection (separate change).
- Offline queuing or retry logic.
- SDK crate changes for `list_product_list_items` write operations.

## Decisions

### Create vs. refresh collections after creation

**Decision**: After the API call succeeds, construct a `CollectionEntry` locally from the API response rather than re-fetching the entire collection list.

The create API returns the new product list object. We can build the entry directly and `push` it into `LibraryController::collections`. This avoids a redundant full list fetch and keeps the UX snappy.

### Dialog as a transient GPUI entity

**Decision**: Implement the dialog as a `Modal` using `gpui-component`'s `Modal` or `Dialog` component rather than a bare `div` overlay.

Consistent with how other modals in the app are structured. The dialog state (name draft, in-flight flag) lives in a small `CreateCollectionDialogState` struct owned by the `LibraryRootView`. The dialog is conditionally rendered when a `show_create_collection_dialog: bool` flag is true.

Alternative considered: a separate GPUI window. Rejected - overkill for a single input.

### SDK `create_product_list` method location

**Decision**: Add `create_product_list(name: &str)` to `LibraryClient` in `dtrpg-sdk`. The endpoint is `POST /product_lists`.

This keeps all DTRPG API calls behind the SDK boundary. The returned type should be `ProductListItem` (same shape as what `list_product_lists` returns for each item).

### Where create logic lives in dtrpg-core

**Decision**: Add `create_product_list(name: &str)` to `SdkCollectionsGateway` and implement it on `HttpSdkCollectionsGateway` and `UnavailableCollectionsGateway`. Add `create_collection(name: &str)` to `CollectionsService` trait and implement it on `RustSdkCollectionsService`.

Mirrors the existing gateway pattern exactly.

### Activity tracking

**Decision**: Thread `Entity<ActivityController>` through to the background create task the same way the library load does it - via a `downgrade()` weak reference captured in a `cx.spawn` closure. `LibraryController` exposes a new `create_collection(name, cx)` method that owns this flow.

## Risks / Trade-offs

- **API shape unknown for POST /product_lists response**: The DTRPG API may not return a full `ProductListItem` on creation, or may return a different structure. Mitigation: treat the response as `serde_json::Value` first if needed, or define a minimal `CreateProductListResponse` type. If the API returns the list object, map it to `CollectionEntry` with empty `member_ids`.
- **Stub service for tests**: `CollectionsStubService` needs a `create_collection` arm. Seeded mode can return a fixed `CollectionEntry`; Error mode returns a `CollectionsServiceError`. Low risk.
- **Dialog input focus on open**: GPUI focus handling can be tricky on modal open. Mitigation: use `window.focus(&input_handle)` in the dialog's `on_open` or after the entity is registered.

## Open Questions

- Does `POST /product_lists` return the created list object in the response body? If yes, does it match the `ProductListItem` schema? (Need to verify against API or test account.)
- Does the API enforce a unique name constraint per customer, or are duplicate names allowed?
