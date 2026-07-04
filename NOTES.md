# Notes

A place to keep track of things to tell the robot when limits are reached

Prompt for the robot

```
identify changes or create them, work through the list; some items might already be complete; some changes have been completed in the interim, archive if so
```

- Catalog items may bleed off the right edge instead of reflowing — needs visual
  re-verification against current layout before treating as a bug.
- Localizations still missing: autofill/dictation/emoji menu items (OS-provided, may not
  be controllable).
- Grouped list view does not use `DataTable` — hand-rolls its own rows instead of the
  virtualized `DataTable` used by the ungrouped branch. Likely cause of laggy scrolling.
  Largest remaining item — a real refactor, not a small fix.
- If a catalog item's kind is a "badge" type, render as icon + tooltip; otherwise render
  as a plain text label in a separate column — needs a product decision on which kinds
  get icon+tooltip treatment.
- (On hold) Rich-text tooltip for the read button's "download this item first" hint
  (lighter color, smaller font) — do this one interactively with visual feedback.
- Icons:  
  1. Create an assets/icons/ directory in your project root
  2. Download Lucide icons: `npm install lucide-static`
  3. Copy needed SVGs: `cp node_modules/lucide-static/icons/*.svg assets/icons/`
  4. Use the IconName enum to reference them type-safely

- Make all text fields' content selectable and copyable: gpui-component TextView
- Add collection editing (add/remove items)
  - Context menu item on catalog: "add to <list of collections>", "remove from <list of collections>"
  - If catalog view is currently a collection, context menu for remove should be "remove from this collection"
- Drag and drop to add item from catalog to collection
- Charts:
  - Publishers
  - Collection counts
  - Document types
- Switch to `gpui-ce` (community edition)
  - Dock/Tiles layout?
- Use gpui-component HoverCard for rich tooltips
- Use "loading" capability on list and other content views
- Use "sections" on list views for publisher grouping
- Make the rich tooltip title bold 
- Add PDF library to display information about PDFs in file list
  - Page count
  - Title page thumbnail
  - Other?
- For multi-file catalog entries, display invidual file size and type
- Add disclosure area in detail view with all the other information
- Add Sentry for crash reporting?
- "Refresh thumbnails" menu item does nothing — traced the full path
  (`RefreshThumbnails` action → `LibraryController::refresh_all_thumbnails` →
  `drain_thumbnail_queue` with `force_network: true` → disk write via
  `save_cached_cover` → `CoverCache::insert` → `LibraryChanged` emit). The handler is
  wired and the force-network bypass is correct; could not reproduce "does nothing"
  from code inspection alone. Needs a live repro (screenshot or steps) if it's still
  broken — otherwise treat as already fixed by earlier work.
