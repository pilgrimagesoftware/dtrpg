## 1. Decide fork ownership and open the upstream conversation first

- [x] 1.1 Decide where the fork lives (org fork vs. personal fork) — see design.md's open question
- [x] 1.2 Open an issue or draft PR on `longbridge/gpui-component` describing the proposed
  `droppable::<T>(...)` API shape, before investing in a full implementation, to get early maintainer
  feedback

## 2. Implement `droppable` on `SidebarMenuItem` in the fork

- [x] 2.1 Fork `github.com/longbridge/gpui-component`; create a working branch
- [x] 2.2 Add a `droppable::<T>(style_fn, on_drop_fn)` builder method to `SidebarMenuItem` in
  `crates/ui/src/sidebar/menu.rs`, storing the drop-target config similarly to how `context_menu` is
  stored today
- [x] 2.3 In `SidebarMenuItem::render`, apply the stored `drag_over`/`on_drop` behavior to the row's `div`,
  mirroring `DragPanel`'s usage in `crates/ui/src/dock/tab_panel.rs`
- [x] 2.4 Add/update `gpui-component`'s own story/example for `Sidebar` (if one exists) demonstrating a
  droppable row, so the addition has a manual test surface independent of `dtrpg-app/rust`

## 3. Adopt the fork in dtrpg-app/rust

- [x] 3.1 Update `dtrpg-app/rust/Cargo.toml`'s `gpui-component` git dependency to the fork/branch from task
  2.1
- [x] 3.2 Run `cargo check --workspace` and `cargo clippy --all-targets --all-features -- -D warnings` to
  confirm the dependency bump alone doesn't break anything before touching `sidebar_view.rs`

## 4. Replace the hand-rolled Collections section

- [x] 4.1 Remove `CollectionsSection`, `CollectionRow`, `CollectionsSuffixFn`, `CollectionsToggleFn`, and
  `render_collection_row` from `crates/dtrpg-ui/src/ui/views/sidebar_view.rs`
- [x] 4.2 Rebuild the Collections section using `SidebarMenu`/`SidebarMenuItem`, matching how the Publishers
  section (`pub_menu`) is already built, adding `.droppable::<DraggedLibraryItem>(...)` to each collection
  row to call `LibraryController::add_item_to_collection` on drop
- [x] 4.3 Confirm the `SidebarContent` enum's `Collections` variant (added for the hand-rolled
  implementation) can be removed, folding the Collections section back into the existing `Menu` variant

## 5. Verify and upstream

- [x] 5.1 Run `cargo check --workspace`, `cargo clippy --all-targets --all-features -- -D warnings`, and the
  existing test suite
- [x] 5.2 Manually verify: dragging a catalog item onto a collection still adds it as a member; hover
  highlight still appears only over collection rows; Collections section visually matches the Publishers
  section's spacing/styling now that both use `SidebarMenuItem`
- [x] 5.3 Open (or update) the upstream PR to `longbridge/gpui-component` with the finished implementation
  from task 2
- [x] 5.4 Once upstream merges (or a decision is made not to pursue it further), revisit whether
  `dtrpg-app/rust`'s `Cargo.toml` should point back at upstream `main` instead of the fork
