# Notes

A place to keep track of things to tell the robot when limits are reached

Prompt for the robot

```
identify changes or create them, work through the list; some items might already be complete; some changes have been completed in the interim, archive if so
```

## Known API limitation (not a bug)

- Page count in detail view always shows 0 — the DriveThruRPG order-product API does not
  return a page count field at all (`OrderProductAttributes` has no such field). Not
  fixable without a different endpoint or a PDF-parsing fallback.

## Still open

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
- Presentation, Sort, and Find in Library menu items or submenu items are all disabled
  when they should not be.
- Icons:  
  1. Create an assets/icons/ directory in your project root
  2. Download Lucide icons: `npm install lucide-static`
  3. Copy needed SVGs: `cp node_modules/lucide-static/icons/*.svg assets/icons/`
  4. Use the IconName enum to reference them type-safely

- Make all text fields' content selectable and copyable: gpui-component TextView
- Add sub-progress text to catalog load activity item message:
  - "Getting count of items"
  - "Loading collections"
  - "Loading library"
  - Etc.
- Put a question mark "?" for the collection count until it's known (e.g. after "Loading
  collections").
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
- Use gpui-components Progress for activity button content (sum of all active loaders)
- Detail view should be thumbnail on the left, information on the right
