## 1. Extend CollectionsService Trait

- [ ] 1.1 Add `create_collection(&self, name: &str) -> Result<CollectionEntry, CollectionsServiceError>` to the `CollectionsService` trait in `dtrpg-ui/src/services/collections.rs`
- [ ] 1.2 Add `create_collection` to `CollectionsStubService` in the `#[cfg(test)]` block: `Seeded` mode returns a fixed `CollectionEntry` with `id: 1`, the given name, and empty `member_ids`; `Error` mode returns a `CollectionsServiceError`; `Empty` mode behaves like `Seeded`
- [ ] 1.3 Run `cargo check -p dtrpg-ui` and fix any errors

## 2. SDK: Add create_product_list

- [ ] 2.1 Add `pub async fn create_product_list(&self, name: &str) -> Result<ProductListItem, ClientError>` to `LibraryClient` in `dtrpg-sdk/rust/src/client.rs`; send `POST /product_lists` with JSON body `{"name": name}`; decode the response as `ProductListItem`
- [ ] 2.2 Re-export `create_product_list` (or verify `LibraryClient` is already exported) from `dtrpg-sdk/rust/src/lib.rs`
- [ ] 2.3 Run `cargo check -p dtrpg-sdk` and fix any errors

## 3. SDK-Backed CollectionsService: create_collection

- [ ] 3.1 Add `create_product_list(&self, name: &str) -> Result<ProductListItem, CollectionsServiceError>` to the `SdkCollectionsGateway` trait in `dtrpg-core/src/services/collections_sdk.rs`
- [ ] 3.2 Implement `HttpSdkCollectionsGateway::create_product_list`: call `self.runtime.block_on(self.client.create_product_list(name)).map_err(map_client_error)`
- [ ] 3.3 Implement `UnavailableCollectionsGateway::create_product_list`: return `Err(self.error.clone())`
- [ ] 3.4 Implement `RustSdkCollectionsService::create_collection`: call `self.gateway.create_product_list(name.trim())`, map the returned `ProductListItem` to a `CollectionEntry` with `id = item.attributes.product_list_id`, `name = item.attributes.name.into()`, `member_ids = Arc::from(&[][..])`, return `Ok(entry)`
- [ ] 3.5 Add unit test in `collections_sdk.rs` `tests` block: `FakeCollectionsGateway` gains a `create_result` field; test `create_collection` with a seeded result returns the correct `CollectionEntry`; test with an error result propagates the error
- [ ] 3.6 Run `cargo test -p dtrpg-core` and confirm tests pass

## 4. LibraryController: create_collection command

- [ ] 4.1 Add `pub fn create_collection(&mut self, name: String, cx: &mut Context<Self>)` to `LibraryController` in `dtrpg-ui/src/controllers/library.rs`
- [ ] 4.2 Inside `create_collection`: start an activity item via `self.activity.update(cx, |a, cx| a.start("Creating collection '<name>'...", None, cx))`, clone `Arc<dyn CollectionsService>`, and spawn a background task
- [ ] 4.3 On success in the background task: call `this.update(async_cx, |ctrl, cx| { ctrl.collections.push(entry); cx.emit(LibraryChanged); })` and complete the activity item
- [ ] 4.4 On error: push an error `Notification` via `window.push_notification(Notification::new().message(e.to_string()).with_type(NotificationType::Error).autohide(false), cx)` and mark the activity item as an error; note `window` is not available in `cx.spawn` - use a GPUI `AsyncWindowContext` or emit a custom event that `LibraryRootView` handles to push the notification
- [ ] 4.5 Run `cargo check -p dtrpg-ui` and fix any errors

## 5. Create Collection Dialog

- [ ] 5.1 Create `dtrpg-ui/src/ui/views/create_collection_dialog.rs` with a `CreateCollectionDialog` struct holding `name_draft: String` and an `InputState` entity
- [ ] 5.2 Implement `Render` for `CreateCollectionDialog` using `gpui-component` `Modal` (or equivalent overlay): title "New Collection", a labeled text input bound to `name_draft`, a Cancel button and a Create button (Create disabled when `name_draft.trim().is_empty()`)
- [ ] 5.3 Add `show_create_collection_dialog: bool` to `LibraryRootView`; add the dialog import to `mod.rs`
- [ ] 5.4 Wire Cancel: closes the dialog by setting `show_create_collection_dialog = false` and calling `cx.notify()`
- [ ] 5.5 Wire Create: calls `controller.update(cx, |ctrl, cx| ctrl.create_collection(name.trim().to_string(), cx))`, then closes the dialog
- [ ] 5.6 Run `cargo check -p dtrpg-ui` and fix any errors

## 6. Sidebar: Add button in Collections header

- [ ] 6.1 In `sidebar_view.rs`, replace `SidebarMenuItem::new("Collections")` with a version that includes an action icon on the right side; use `gpui-component`'s `SidebarMenuItem` suffix/icon API (check existing pattern used by activity or publisher headers) to add a `+` or `PlusCircle` icon button
- [ ] 6.2 The icon button's click handler should emit a custom GPUI action `OpenCreateCollectionDialog`; define this action in `dtrpg-ui/src/ui/actions.rs`
- [ ] 6.3 In `LibraryRootView`, register an `on_action::<OpenCreateCollectionDialog>` handler that sets `show_create_collection_dialog = true` and calls `cx.notify()`
- [ ] 6.4 Conditionally render the `CreateCollectionDialog` in `LibraryRootView::render` when `show_create_collection_dialog` is true
- [ ] 6.5 Run `cargo check --workspace` and fix any errors

## 7. Notification on error

- [ ] 7.1 Define a `CollectionCreateFailed { message: String }` event on `LibraryController` (or reuse the existing error notification pattern from download errors in root_view.rs)
- [ ] 7.2 In `LibraryRootView::new`, subscribe to `CollectionCreateFailed` (or equivalent) and push an error `Notification` to the window
- [ ] 7.3 Emit the event from the error branch of `create_collection`'s background task instead of trying to push directly

## 8. Verification

- [ ] 8.1 Run `cargo test --workspace` and confirm all tests pass
- [ ] 8.2 Run `cargo clippy --all-targets --all-features -- -D warnings` and fix any warnings
- [ ] 8.3 Launch the app; confirm the "+" button appears in the Collections header
- [ ] 8.4 Click "+"; confirm the dialog opens with focus on the name field
- [ ] 8.5 Type a name and click Create; confirm the activity panel shows "Creating collection..." and the new collection appears in the sidebar on success
- [ ] 8.6 Trigger a failure (invalid credentials); confirm an error notification appears and the activity item is marked as an error
- [ ] 8.7 Click Cancel; confirm the dialog closes without any API call
