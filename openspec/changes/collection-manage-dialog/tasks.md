## 1. Controller Action

- [ ] 1.1 Add `LibraryController::create_collection_and_add_member(&mut self, name: String, item_id: u64,
  cx: &mut Context<Self>)`, awaiting the create-collection service call itself and, only on success,
  invoking the existing add-member logic against the newly created collection's id. On failure, emit only
  `CollectionCreateFailed` (no add attempted).

## 2. Manage Collections Dialog

- [ ] 2.1 Build the dialog view using `gpui-component`'s `Dialog` (`crates/ui/src/dialog/dialog.rs`),
  opened via `Window::open_dialog`, scoped to a single target item (`member_id`/display title).
- [ ] 2.2 List every entry in `LibraryController::collections` as a row with a checkbox reflecting
  `collection.member_ids.contains(&member_id)`.
- [ ] 2.3 Wire checkbox toggle to call `LibraryController::add_item_to_collection` /
  `::remove_item_from_collection` (unchanged from `collection-membership-editing`).
- [ ] 2.4 Add a "New collection…" affordance (inline text input + confirm) that calls
  `create_collection_and_add_member` (task 1.1) and appends the resulting row to the list once the
  collection appears in `collections`.
- [ ] 2.5 Subscribe to `CollectionMemberAddFailed`, `CollectionMemberRemoveFailed`, and
  `CollectionCreateFailed` while the dialog is open; on any of them, revert the affected checkbox (or
  reject the pending new-collection row) and show an inline error message in the dialog. Do not remove or
  alter `root_view.rs`'s existing toast subscriptions for these events.

## 3. Context Menu

- [ ] 3.1 Remove `append_collection_menu_items`'s "Add to…" submenu and "Remove from this collection" item
  (added by `collection-membership-editing`) from `catalog_view.rs`.
- [ ] 3.2 Add a single "Manage collections…" item in their place, at all four catalog item context-menu
  sites (list ungrouped/grouped `TableDelegate::context_menu`, thumb row, grid card), opening the dialog
  from task 2.1 scoped to that row's item.

## 4. Detail View

- [ ] 4.1 Add a "Collections" summary section to the catalog entry detail view listing the names of
  collections the entry currently belongs to (via `collection_member_id` + `LibraryController::
  collections`), with an empty-state message when it belongs to none.
- [ ] 4.2 Add a "Manage…" button in that section opening the dialog from task 2.1, scoped to the entry
  being viewed.
- [ ] 4.3 Confirm the summary updates after the dialog closes (relies on existing `LibraryChanged`
  re-render, per design.md — no new subscription expected, but verify).

## 5. Cross-Change Bookkeeping

- [ ] 5.1 Update `collection-membership-editing`'s `tasks.md` 3.1/3.2 to note they are superseded by this
  change, rather than leaving them as open/blocked work in that change.

## 6. Build and Verify

- [ ] 6.1 Run `cargo check --workspace`
- [ ] 6.2 Run `cargo clippy --all-targets --all-features -- -D warnings`
- [ ] 6.3 Manually verify: right-click a catalog item, open "Manage collections…", toggle a checkbox on
  and off, confirm inline error state appears (add/remove currently always fails against the live API —
  see `collection-membership-editing` task 1.4) and the checkbox reverts.
- [ ] 6.4 Manually verify: create a new collection from within the dialog, confirm it appears checked and
  the item is added (or an inline error appears on failure).
- [ ] 6.5 Manually verify: dialog dismisses correctly on outside click and Escape (regression check for
  the bug this change fixes).
- [ ] 6.6 Manually verify: detail view's Collections summary and "Manage…" button, including the
  empty-state message.
