## 1. Rust App — Prerequisite: Storage Path in Thumb Row

- [x] 1.1 Add `storage_root_path: PathBuf` parameter to `render_thumb_row` in `catalog_view.rs`
- [x] 1.2 Thread `storage_root_path` through all `render_thumb_row` call sites in `render_catalog`

## 2. Rust App — Context Menu: List Row

- [x] 2.1 Import `gpui_component::menu::ContextMenuExt` and `PopupMenuItem` in `catalog_view.rs`
- [x] 2.2 Wrap the `render_list_row` return div with `.context_menu(...)` using `ContextMenuExt`
- [x] 2.3 Add "Download" item (visible when `Cloud`) that calls `entity.update(|ctrl, cx| ctrl.toggle_download(&id, cx))`
- [x] 2.4 Add "Remove Download" item (visible when `Downloaded`) that calls `toggle_download`
- [x] 2.5 Add "Show in Finder / Explorer / Files" item (visible when `Downloaded`) that calls `reveal_in_file_manager`
- [x] 2.6 Adjust `render_list_row` return type as needed (remove `use<>` precise-capture bound if incompatible with `ContextMenu<Div>`)

## 3. Rust App — Context Menu: Thumb Row

- [x] 3.1 Wrap the `render_thumb_row` return div with `.context_menu(...)` using the same item logic as the list row
- [x] 3.2 Adjust `render_thumb_row` return type as needed

## 4. Rust App — Context Menu: Grid Card

- [x] 4.1 Wrap the `render_grid_card` return div with `.context_menu(...)` using the same item logic
- [x] 4.2 Adjust `render_grid_card` return type as needed

## 5. Rust App — Build and Lint

- [x] 5.1 Run `cargo check --workspace` — no errors
- [x] 5.2 Run `cargo clippy --all-targets --all-features -- -D warnings` — no warnings

## 6. Manual Verification

- [ ] 6.1 Right-click a `Cloud` item in list view — menu shows "Download" only
- [ ] 6.2 Right-click a `Downloaded` item in list view — menu shows "Show in Finder/Explorer/Files" and "Remove Download"
- [ ] 6.3 Click "Download" from context menu — item transitions to downloaded state
- [ ] 6.4 Click "Remove Download" from context menu — item transitions to cloud state
- [ ] 6.5 Click "Show in Finder/Explorer/Files" from context menu — file manager opens at the item path
- [ ] 6.6 Right-click in thumbs layout — menu works correctly
- [ ] 6.7 Right-click in grid layout — menu works correctly
- [ ] 6.8 Click outside the open menu — menu dismisses, no action fires
- [ ] 6.9 Press Escape while menu is open — menu dismisses
- [ ] 6.10 Left-click any item — selection works normally, no context menu appears
