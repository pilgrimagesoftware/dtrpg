## Why

The sidebar currently displays collection and publisher counts with trailing text (e.g., "5 items"), but this text belongs in the catalog area footer where context makes it clear what the number represents. The sidebar should show only numeric badges for a cleaner, more focused navigation experience.

## What Changes

- Remove trailing text from collection count badges in the sidebar
- Remove trailing text from publisher count badges in the sidebar
- Keep numeric-only badges (e.g., "5" instead of "5 items")
- Catalog footer already shows the full context (e.g., "12 titles" or "Viewing 5 items from Collection Name")

## Capabilities

### New Capabilities

(None - this is a presentation refinement)

### Modified Capabilities

(None - no spec-level behavior changes, only UI presentation)

## Impact

- `dtrpg-ui/src/ui/views/sidebar_view.rs`: Update collection and publisher entry rendering to show count-only badges
- Translation strings may be simplified if count text was using i18n keys
- No API or data model changes
