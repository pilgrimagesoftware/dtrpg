## Context

The sidebar currently renders collection and publisher entries with count badges that include descriptive text (e.g., "5 items"). This follows a pattern where the sidebar was self-documenting, but it creates visual clutter and redundancy since the catalog footer already provides full context about what's being viewed.

Current implementation in `sidebar_view.rs`:
- Collection entries render count badges with item text
- Publisher entries render count badges with item text
- The catalog footer shows comprehensive context (e.g., "Viewing 5 items from Collection Name")

## Goals / Non-Goals

**Goals:**
- Display numeric-only badges in sidebar collection and publisher entries
- Maintain existing badge styling and positioning
- Keep catalog footer text unchanged (it provides the necessary context)

**Non-Goals:**
- Changing badge styling, colors, or positioning
- Modifying any other sidebar elements (filters, sections)
- Changing how counts are calculated or retrieved
- Altering catalog footer presentation

## Decisions

### Badge Text Format

**Decision**: Show raw numeric count only (e.g., "5" instead of "5 items")

**Rationale**: The sidebar is a navigation surface where space is limited and context is provided by section headers and the catalog footer. Numeric badges align with common UI patterns (notification badges, tab counts) and reduce visual noise.

**Alternatives Considered**:
- Keep current format: Rejected due to redundancy with footer text
- Remove badges entirely: Rejected as counts provide useful at-a-glance information
- Use abbreviated text (e.g., "5 i"): Rejected as it's harder to read and still clutters

### Implementation Scope

**Decision**: Update only the badge rendering logic in `render_collections_section` and `render_publishers_section` functions

**Rationale**: This is a presentation-only change that requires no data model, controller, or service modifications. The count values are already available; we just need to change how they're formatted.

**Impact**: Two function updates in `sidebar_view.rs`

## Risks / Trade-offs

**Risk**: Users accustomed to descriptive text may initially be confused  
→ **Mitigation**: The catalog footer provides immediate context. The numeric-only format is a common pattern users recognize from other applications.

**Risk**: Accessibility - screen readers may not have enough context from number alone  
→ **Mitigation**: Ensure the parent element or aria-label provides context (e.g., "Collection: My Favorites, 5 items"). This should be verified during implementation.

**Trade-off**: Less self-documenting UI in exchange for cleaner visual hierarchy  
→ **Accepted**: The footer provides the necessary documentation, and the cleaner sidebar improves scannability.
