## Why

Users can view their DTRPG product lists in the sidebar but cannot create new ones without leaving the app. Adding a creation affordance directly in the sidebar closes the loop and makes collections useful without a context switch.

## What Changes

- Add an "Add Collection" button (or inline action) to the Collections section header in the sidebar.
- Tapping it opens a modal dialog with a single text field for the collection name and Cancel/Create actions.
- Submitting fires a background `CollectionsService::create_collection(name)` call that is tracked in the activity panel.
- On success the new collection appears in the sidebar immediately.
- On failure an error `Notification` is pushed to the window; the activity item is marked as an error.

## Capabilities

### New Capabilities

- `collection-create`: In-app creation of a DTRPG product list: sidebar trigger, name-prompt dialog, background API call, activity tracking, and error notification.

### Modified Capabilities

- `activity-panel`: Activity entries now originate from the collections service in addition to downloads; no behavioral requirement change, just an additional call site.

## Impact

- `dtrpg-ui`: new dialog view, new `CollectionsService::create_collection` trait method, `CollectionsServiceFactory` change propagated.
- `dtrpg-core`: new `HttpSdkCollectionsGateway::create_product_list` implementation.
- `dtrpg-sdk`: may require a new `LibraryClient::create_product_list` method.
- Sidebar layout: Collections header gains an icon button; no change to existing nav items.
