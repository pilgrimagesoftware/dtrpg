## Context

`ActivityController` holds `in_progress: Vec<ActivityItem>` and `recent: VecDeque<ActivityItem>` (cap 25). Items move from `in_progress` to `recent` on `complete` or `error`. `ActivitySnapshot` exposes `in_progress_count` and `recent_error_count`. The sidebar button currently derives a binary state (`in_progress_count > 0` → "↻", else "✓") and renders in `render_activity_button` in `sidebar_view.rs`.

## Goals / Non-Goals

**Goals:**

- Surface three visually distinct button states without adding persistent state to the model.
- Auto-remove recent items 15 seconds after resolution using a lightweight per-item timer.
- Keep the timer mechanism simple — no cancellation, no persistence.

**Non-Goals:**

- Configurable expiry duration (hard-coded to 15 seconds).
- Visual countdown or progress indicator on individual items.
- Animating the button icon transition.

## Decisions

### 1. Three button states derived at render time

Add `recent_count: usize` to `ActivitySnapshot` (count of non-empty `recent` vec). The button renderer derives state purely from snapshot fields — no new enum in the model layer:

```
in_progress_count > 0             → Active    "↻ (N)"
in_progress_count == 0
  && recent_count > 0             → Done      "●"
in_progress_count == 0
  && recent_count == 0            → Idle      "○"
```

*Alternative considered*: Add an `ActivityButtonState` enum to `ActivitySnapshot`. Rejected: the derivation is a two-line match; adding a type for it is premature.

### 2. Per-item gpui timer for expiry

When `complete(id)` or `error(id, _)` moves an item to `recent`, immediately spawn a detached gpui task:

```rust
let weak = cx.weak_entity();   // WeakEntity<ActivityController>
cx.spawn(async move |_, async_cx| {
    async_cx.background_executor()
        .timer(Duration::from_secs(EXPIRY_SECS))
        .await;
    weak.update(async_cx, |a, cx| a.expire_item(id, cx)).ok();
})
.detach();
```

`expire_item(id)` removes the item from `recent` by id (no-op if already gone due to cap eviction) and emits `ActivityChanged`.

*Alternative considered*: Store `completed_at: Instant` on each item and filter at render time using a periodic refresh timer. Rejected: requires either a polling timer waking the UI every second or stale state in the panel until the next unrelated re-render; per-item timers fire exactly once and are forgotten.

*Alternative considered*: Use `cx.spawn_in(Duration)`. gpui has `background_executor().timer(d)` as the preferred async sleep. `cx.spawn` detach is the standard pattern in this codebase.

### 3. `EXPIRY_SECS = 15` constant

Hard-coded in `activity.rs` as `const EXPIRY_SECS: u64 = 15`. Easy to tune later.

### 4. Cap eviction and expiry interact safely

If the cap (25 items) evicts an item before its 15-second timer fires, `expire_item` finds no item with that id in `recent` and is a no-op. No bookkeeping needed to cancel timers.

## Risks / Trade-offs

- **Ghost timer overhead**: Each resolved item spawns one async task that sleeps for 15 seconds. At realistic usage (dozens of operations per session), this is negligible overhead. gpui's background executor handles sleeping tasks efficiently.
- **Items disappear while panel is open**: If the user has the panel open, items will vanish 15 seconds after completion. This is expected and desirable — stale items should not linger. The empty state will be shown if all items expire.
- **Timer survives controller drop**: If `ActivityController` is dropped before the timer fires, `WeakEntity::update` returns `Err` and the `.ok()` call discards it cleanly.
