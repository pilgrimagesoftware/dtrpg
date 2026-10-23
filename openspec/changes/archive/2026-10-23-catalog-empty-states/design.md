## Context

`render_catalog` receives `items: Vec<LibraryItem>` — the already-filtered result set. When `items` is empty it calls `render_empty_state`, which always shows "No titles match." The `LibrarySnapshot` already carries both `total_count` (unfiltered catalog size) and `matched_count` / `items` (filtered). The `LibraryPaneState` on the view model tracks `Loading` / `Loaded` / `Empty` / `Error`, but loading/error states are rendered elsewhere; the catalog view only needs to distinguish the two non-error empty cases.

## Goals / Non-Goals

**Goals:**

- Show "Your library is empty." when `total_count == 0` (the catalog itself is empty, not just filtered to nothing).
- Show "No titles match." plus a contextual hint when `total_count > 0` but the filtered `items` list is empty.
- Keep the hint actionable: tell the user what to do (clear search, change filter).

**Non-Goals:**

- Changing the loading or error states.
- Adding buttons or interactive controls inside the empty state (a follow-up can do that).
- Persisting any new state beyond what is already in the snapshot.

## Decisions

### 1. Pass `total_count: usize` to `render_catalog` rather than a pre-computed enum

`render_catalog` already receives `items` and can compare `items.is_empty()` against `total_count`. Adding one `usize` parameter is simpler than introducing a new enum at the call site. The enum lives only inside `catalog_view.rs` as a local helper.

*Alternative considered*: Add a `CatalogEmptyReason` to `LibrarySnapshot` and pass it in. Rejected: it is purely a rendering concern and can be fully derived from `total_count` + `items.len()`.

### 2. Derive the reason at the top of `render_catalog`

```rust
let empty_reason = if items.is_empty() {
    Some(if total_count == 0 { EmptyReason::LibraryEmpty } else { EmptyReason::NoMatches })
} else {
    None
};
```

If `empty_reason.is_some()`, branch to the appropriate renderer and return early. Otherwise proceed with the existing layout code.

### 3. "No matches" hint copy varies by context

When `search_query` is non-empty: "Try clearing your search." When `search_query` is empty (filter-only): "Try selecting a different section." Both variants use `text_tertiary` color at small size below the main message.

This requires passing `search_query: &str` into `render_catalog`. It is already on the snapshot so the call site change is trivial.

## Risks / Trade-offs

- **One additional parameter on `render_catalog`**: `total_count: usize` and `search_query: &str`. The function already has 7 parameters; this adds 2 more. The function is private-to-the-view and called from one place (`root_view.rs`), so the blast radius is small.
- **`total_count` can be 0 during `Loading` state**: If the catalog load is in flight, `total_count == 0` would show "Your library is empty." briefly. Mitigation: the loading state is already handled above `render_catalog` in `root_view.rs` (or will be when `LibraryPaneState::Loading` is surfaced); for now, the `Loading` pane state shows a spinner before `render_catalog` is reached.
