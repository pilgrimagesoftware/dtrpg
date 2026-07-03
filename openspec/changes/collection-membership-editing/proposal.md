## Why

Collections currently support create and delete but have no way to add or remove individual catalog items
from a collection short of external API calls. Users need to manage collection membership directly from
the catalog view.

## What Changes

- Add `add_member` and `remove_member` operations to the `CollectionsService` trait (and its stub
  implementation) for adding/removing a single item to/from a collection.
- Add a catalog item context menu entry:
  - "Add to…" with a submenu listing the user's collections (checked if the item is already a member);
    selecting an unchecked collection adds the item, selecting a checked one removes it.
  - When the currently viewed catalog is itself a collection, add a direct "Remove from this collection"
    item (no submenu) instead of the general add/remove submenu for that collection.
- Membership changes update the collections cache and the current view's item list immediately
  (optimistic update), reconciled against the service response.

## Capabilities

### New Capabilities

- `collection-membership-editing`: Catalog items can be added to or removed from collections via a
  context menu, backed by new service operations.

### Modified Capabilities

<!-- none -->

## Impact

- `dtrpg-app/rust/crates/dtrpg-ui/src/services/collections.rs`: new `add_member` / `remove_member` trait
  methods and stub implementations.
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/collection.rs`: no shape change expected — `member_ids`
  already exists.
- `dtrpg-app/rust/crates/dtrpg-ui/src/data/collections_cache.rs`: optimistic update on membership change.
- `dtrpg-app/rust/crates/dtrpg-ui/src/controllers/library.rs`: new controller actions to invoke
  add/remove and update state.
- `dtrpg-app/rust/crates/dtrpg-ui/src/ui/views/catalog_view.rs`: context menu submenu built on the
  existing `.context_menu(...)` pattern from `catalog-context-menu`.
- `dtrpg-sdk/rust`: verify the underlying DriveThruRPG API exposes an add/remove-member endpoint for
  product lists; if not, this change is blocked on an SDK/API addition (see `dtrpg-api` for the contract).
