---
paths:
  - "dtrpg-app/**"
---

# UI Performance

Main-window framerate is a hard requirement. Changes to anything rendered in the main window have repeatedly caused sluggishness (most recently after the smart collection editor work).

- Treat every change that touches the main window's render path, state, or observers as performance-sensitive.
- Keep `render` functions cheap: no allocation-heavy work, sorting, filtering, or I/O per frame. Compute once, cache, and invalidate on change.
- Notify/redraw only the views whose data changed. Avoid broad `cx.notify()` on root views or on high-frequency events.
- Virtualize or paginate large lists and tables; never build every row eagerly.
- Move blocking or slow work off the UI thread and update state when it completes.
- State in the PR description what you checked for frame cost (render frequency, notify scope, list sizes). If a change adds per-frame work, justify it.
- Reviewers: flag new per-frame work and over-broad notifications as blocking.
