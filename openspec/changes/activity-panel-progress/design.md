## Context

The activity panel currently uses three types in `dtrpg-ui`:
- `ActivityItem` (`data/activity.rs`): `{ id, label, status }`
- `ActivityStatus`: `InProgress | Complete | Error(String)`
- `ActivityController` (`controllers/activity.rs`): owns `in_progress: Vec<ActivityItem>` and `recent: VecDeque<ActivityItem>`

The panel view (`ui/views/activity_panel_view.rs`) renders rows from `ActivitySnapshot`. Row layout is a flex row with a small icon and a text column — there is no space for timing or a progress bar.

All callers of `ActivityController::start()` are internal to `dtrpg-core` or `dtrpg-ui`, so the signature change is fully within this repo.

## Goals / Non-Goals

**Goals:**
- Add elapsed/duration display and a progress bar to `ActivityItem` and its rendering
- Support optional cancellation via a caller-provided function
- Widen and deepen the panel to fit the new row content
- Keep all changes within the `dtrpg-app/rust` workspace; no SDK or API contract changes needed

**Non-Goals:**
- Persisting activity history across app restarts
- Animated indeterminate bars (a static "indeterminate" appearance is acceptable for now)
- Sub-operation progress (nested items, tree structure)
- Progress reporting from the SDK — callers decide whether to call `update_progress`

## Decisions

### Decision 1: `started_at` is `std::time::Instant`, duration frozen at transition

`Instant` is the correct type for monotonically-increasing elapsed time. When an item completes or errors, `elapsed_secs: Option<u64>` is computed once and stored in the item so the displayed time does not drift after the operation ends. In-progress items recompute at each render pass from `started_at.elapsed()`.

**Alternative considered:** Store a `Duration` at transition time. Rejected because `Instant` is already available and `.elapsed()` is the idiomatic approach.

### Decision 2: Progress stored as `Option<f32>` in `ActivityItem`, clamped to [0.0, 1.0]

`None` = indeterminate; `Some(f)` = determinate. This is the minimal data needed; the view decides the visual representation. Clamping in `update_progress` prevents bad callers from producing corrupt bars.

Indeterminate bars are rendered as a 30% filled bar (static, no animation) to keep the implementation simple. Animated bars require a timer or re-render loop which adds complexity disproportionate to the value.

**Alternative considered:** A `Progress` enum (`Indeterminate | Determinate(f32)`). Rejected — `Option<f32>` is equivalent and avoids a new type for a small distinction.

### Decision 3: Cancel fn is `Option<Arc<dyn Fn() + Send + Sync + 'static>>`

The cancel fn is called on the main thread from the click handler. Callers that need cross-thread signaling (e.g., setting an `Arc<AtomicBool>`) wrap the flag set inside this closure. `Arc` allows the caller to clone the pointer for their own use.

`cancel_activity` calls the fn then immediately transitions the item to `Error("Cancelled")` — it does not wait for the background work to acknowledge the signal. This keeps the UI responsive and consistent with the error expiry flow already in place.

**Alternative considered:** Return a `CancellationToken` (tokio) from `start()`. Rejected — it introduces a tokio dependency into `dtrpg-ui` and adds complexity; the fn-pointer approach keeps callers flexible.

### Decision 4: `start()` signature change — add `cancel_fn: Option<Arc<dyn Fn() + Send + Sync>>`

All existing callers pass `None`. The compiler enforces the update at every call site, making the change safe. No default or builder pattern is introduced to keep the API surface minimal.

### Decision 5: Row layout — two-line design with time in the header line

Each row header line: `[icon] [label]   [elapsed]   [✕ cancel]`
Second line (in-progress only): `[progress bar spanning full row width]`
Error rows get a third line for the error message.

The cancel button is right-aligned in the header line. It only appears for in-progress items with a cancel fn.

### Decision 6: Panel width 340 px, list max-height 400 px

The extra 90 px width accommodates the elapsed time + cancel button on the same line as the label without truncation. 400 px height provides room for approximately 6-7 expanded in-progress rows before scrolling.

## Risks / Trade-offs

**[Risk] `Instant` is not available on WASM targets** → Mitigation: The Rust app targets macOS/Linux/Windows only; WASM is not a current build target. No action needed.

**[Risk] Elapsed time display does not update while the panel is open unless the parent re-renders** → Mitigation: The `ActivityController` emits `ActivityChanged` only on state transitions, not on a timer. Elapsed time is therefore only refreshed when something else changes (e.g., another activity starts or completes). A periodic timer could be added later if live-updating time becomes important; for now, "approximately correct" is sufficient.

**[Risk] Cancel fn is called on the main (UI) thread** → Mitigation: Callers are responsible for ensuring the fn is cheap (e.g., sets an atomic flag, sends on an unbounded channel). This is documented in the API.

## Migration Plan

1. Update `ActivityItem` to add `started_at`, `elapsed_secs`, `progress`, `cancel_fn`
2. Update `ActivityStatus` if needed (no new variants required; `Error("Cancelled")` reuses `Error`)
3. Update `ActivityController::start()` signature; fix all call sites
4. Add `update_progress` and `cancel_activity` methods
5. Update `ActivitySnapshot` to pass through any new fields needed by the view
6. Update `activity_panel_view.rs` with new row layout and panel dimensions
7. Run `cargo check --workspace`

## Open Questions

- Should the indeterminate bar pulse/animate in a future pass? The spec leaves it static for now.
- Should "Cancelled" be a distinct `ActivityStatus` variant rather than reusing `Error("Cancelled")`? A distinct variant would allow different visual treatment. Deferred — `Error("Cancelled")` is sufficient for now and can be refactored later.
