## Context

`sidebar_view.rs` renders `collections_count` from `collections.len()`, where `collections` is whatever
the collections cache currently holds. Before the first successful collections fetch, that cache is an
empty `Vec`, which is indistinguishable from "user has zero collections" at render time.

## Goals / Non-Goals

**Goals:**

- The sidebar badge shows `?` only during the window before collections have loaded for the first time in
  the session.
- After the first successful load, `0` means what it says — the user has no collections.

**Non-Goals:**

- A general-purpose "loading" state for every sidebar count (publishers, on-device, in-cloud) — scoped to
  the collections count specifically, since it's the one explicitly reported as showing `0` prematurely.
  (See `content-view-loading-state` for the broader loading-state capability.)

## Decisions

**Track a `loaded: bool` (or equivalent `Option<Vec<Collection>>`) alongside the collections cache rather
than inferring "loaded" from a non-empty list.**

Rationale: an empty list is a valid, permanent state (user really has no collections); it must not be
conflated with "not fetched yet." The cache needs an explicit tri-state: not-yet-loaded / loaded-empty /
loaded-with-items.

**Render `?` at the sidebar layer based on that flag, not by special-casing `count == 0`.**

Rationale: special-casing `0` would incorrectly show `?` forever for a user who genuinely has no
collections.

## Risks / Trade-offs

- If the collections cache is later refactored to always eagerly initialize with a default `Vec`, the
  loaded flag must be threaded through that refactor or the placeholder regresses to always-loaded.
