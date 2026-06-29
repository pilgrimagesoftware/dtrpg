## ADDED Requirements

### Requirement: Completed items expire from the recent list after 15 seconds

The system SHALL automatically remove an item from the `recent` list 15 seconds after it is resolved (via `complete` or `error`). Removal SHALL emit `ActivityChanged` so the button and panel re-render.

#### Scenario: Item expires after timeout

- **WHEN** an item is resolved (complete or error) and 15 seconds elapse
- **THEN** the item is removed from `recent` and `ActivityChanged` is emitted

#### Scenario: All items expire — button returns to idle

- **WHEN** all items in `recent` expire and `in_progress` is empty
- **THEN** the button transitions to the Idle state (hollow icon)

#### Scenario: Item evicted by cap before timer fires

- **WHEN** the recent cap (25) is reached and an older item is evicted before its 15-second timer fires
- **THEN** the timer fires, finds no item with that id, and is a no-op (no error, no extra emit)

### Requirement: Expiry timer is per-item and fires exactly once

The system SHALL spawn one background timer per resolved item. The timer fires once and is discarded regardless of whether the item is still present in `recent`.

#### Scenario: Timer fires on a dropped controller

- **WHEN** `ActivityController` is dropped before a pending expiry timer fires
- **THEN** the timer fires, finds the entity gone, and discards the result cleanly without panicking

### Requirement: Panel reflects expired items immediately

The system SHALL re-render the activity panel (and button) when an item expires, showing the updated list without the expired item.

#### Scenario: Panel open when item expires

- **WHEN** the activity panel is open and an item's 15-second timer fires
- **THEN** the panel immediately stops showing that item in its list
