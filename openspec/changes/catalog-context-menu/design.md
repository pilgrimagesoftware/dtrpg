## Context

The catalog view (`catalog_view.rs`) renders items in list, thumbs, and grid layouts. Primary actions (download, reveal) are currently surfaced only via the detail panel (requires selecting an item) and as inline buttons on downloaded rows. A context menu on right-click is the standard desktop pattern for exposing per-item actions without changing the selection.

`gpui-component` is already a dependency and already provides `ContextMenuExt` (in `gpui_component::menu::context_menu`) and `PopupMenuItem` (used in `toolbar_view.rs` for the sort dropdown). This gives us a right-click popover for free without new dependencies.

## Goals / Non-Goals

**Goals:**

- Right-clicking any catalog item (list row, thumb row, grid card) shows a context menu.
- Initial menu items: "Show in Finder/Explorer/Files" and "Download" / "Remove Download", gated on download state.
- Dismissal follows platform conventions (click-away, Escape) — handled by `ContextMenuExt` automatically.
- No change to left-click selection behavior.

**Non-Goals:**

- Keyboard-driven menu navigation beyond what `gpui-component` provides out of the box.
- Menu items beyond the three listed above (open in app, share, copy link, etc.) — deferred.
- macOS native `NSMenu` — the gpui-component popover is used for cross-platform consistency.

## Decisions

### Use `ContextMenuExt` from `gpui-component`

**Decision**: Wrap each catalog item div with `.context_menu(|menu, _, _| ...)` from `gpui_component::menu::ContextMenuExt`.

**Rationale**: Already a dependency, already used in the codebase (`toolbar_view.rs`), provides right-click detection + position-aware popover + dismiss-on-click-away automatically. The alternative — a custom `on_click` handler checking `event.is_right_click()` with a manually managed overlay — would require per-item open/position state in the controller and a custom overlay render pass.

**How it works**: `.context_menu()` wraps the inner element (the row/card div), intercepts `MouseButton::Right` down events, creates a `PopupMenu` entity at the cursor position, and dismisses it on `DismissEvent` or click-away.

### Conditional menu items (not disabled items)

**Decision**: Build the `PopupMenu` with only the contextually appropriate items rather than showing all items some of which are disabled.

**Rationale**: Disabled items add visual noise for actions that are never applicable in a given context. Since download state is known at render time, conditional construction is straightforward.

**Menu content per state:**

| Download state | Items shown |
|---|---|
| `Downloaded` | "Show in Finder / Explorer / Files", "Remove Download" |
| `Cloud` | "Download" |

### `toggle_download` serves as both download and remove-download

**Decision**: Reuse the existing `LibraryController::toggle_download` for both "Download" and "Remove Download" menu items rather than adding a separate action.

**Rationale**: `toggle_download` already flips the state bidirectionally. Adding named `start_download` / `remove_download` actions would be cleaner long-term but is a refactor beyond this change's scope.

### Storage path threading

`storage_root_path` is already threaded through `render_catalog` → `render_list_row` / `render_grid_card` from the `catalog-storage-location` change. The `render_thumb_row` function does not currently receive it; this change adds it so the thumb row context menu can also offer reveal.

## Risks / Trade-offs

- **`ContextMenuExt` wraps the element**: The `.context_menu()` call returns a `ContextMenu<E>` wrapper, not the original `E`. This is compatible with the existing `impl IntoElement + 'static + use<>` return types on the render functions only if `ContextMenu<E>` also implements `IntoElement`. It does — verified in the gpui-component source. The return type changes from `impl IntoElement + 'static + use<>` to the concrete `ContextMenu<Div>`, which is acceptable.

- **Closure capture complexity**: The context menu builder closure `|menu, window, cx|` captures item state (id, status, storage path). These must be cloned before the outer row closure captures them. Care is needed to avoid double-move conflicts with existing `on_click` captures.

- **`use<>` bound**: The existing row functions carry `use<>` (precise capturing) on their return type opaque bounds. `ContextMenu<Div>` is a named type, so the return type changes to a concrete type — removing the `impl IntoElement + 'static + use<>` bound entirely, which is fine.

## Migration Plan

1. Add `storage_root_path: PathBuf` to `render_thumb_row` (currently missing).
2. Add `.context_menu(...)` wrapping to `render_list_row`, `render_thumb_row`, and `render_grid_card`.
3. Adjust return types from `impl IntoElement + 'static + use<>` to `impl IntoElement + 'static` (or a concrete type alias) as needed.
4. `cargo check` and `cargo clippy` pass; manual right-click test confirms menu appears.

## Open Questions

- Should "Show in Finder/Explorer/Files" also appear in the Cloud state (pointing to the storage root, since the file doesn't exist)? For now: no — it only appears when the file is present.
- Should the `platform_reveal_label()` helper be lifted to a shared location (currently duplicated across `detail_panel_view`, `catalog_view`, `settings_storage_view`)? Deferred — out of scope for this change.
