## 1. API and SDK Audit

- [ ] 1.1 Audit `dtrpg-api` OpenAPI spec to confirm catalog entry responses include a structured item array with per-item fields (name, type, format, file size, download URL or state)
- [ ] 1.2 If item-level fields are missing from the API spec, file a companion change in `dtrpg-api` to add them
- [ ] 1.3 Audit `dtrpg-sdk/rust` model types to confirm a typed per-item struct exists and maps to the API item array
- [ ] 1.4 If per-item model structs are missing from the Rust SDK, file a companion change in `dtrpg-sdk/rust` to add them
- [ ] 1.5 Verify the same coverage in `dtrpg-sdk/swift` and file a companion change if needed

## 2. Umbrella OpenSpec Archiving

- [ ] 2.1 Archive this umbrella change once API and SDK audits are complete and all companion changes are filed
- [ ] 2.2 Update `dtrpg/openspec/specs/main-window-library-layout/spec.md` with the ADDED requirements from this change's delta spec
- [ ] 2.3 Add `dtrpg/openspec/specs/catalog-entry-detail-view/spec.md` as a new permanent capability spec

## 3. App-Level Child Changes

- [ ] 3.1 Create a child OpenSpec change in `dtrpg-app` for the shared desktop detail view shell and item-picker integration contract
- [ ] 3.2 Create a child OpenSpec change in `dtrpg-app/swift` for the native macOS SwiftUI catalog entry detail view implementation
- [ ] 3.3 Create a child OpenSpec change in `dtrpg-app/rust` for the Rust/GPUI catalog entry detail view implementation

## 4. Swift App Implementation

- [ ] 4.1 Add item-count badge rendering to library list row and grid tile components for multi-item entries
- [ ] 4.2 Implement catalog entry detail view layout with entry-tier metadata area and item-tier metadata area
- [ ] 4.3 Implement the persistent item list panel for multi-item entries (scrollable, shows item name and type per row)
- [ ] 4.4 Wire item list selection to update the item metadata area in place
- [ ] 4.5 Implement single-item entry rendering that collapses item metadata inline into the entry tier
- [ ] 4.6 Implement the empty/prompt state for the item metadata area when no item is selected
- [ ] 4.7 Add navigation from library browsing surface (list, tree, grid) to catalog entry detail view on entry selection
- [ ] 4.8 Implement in-place detail view update when user selects a different entry while the detail view is open

## 5. Rust App Implementation

- [ ] 5.1 Add item-count badge rendering to library list row and grid tile components for multi-item entries
- [ ] 5.2 Implement catalog entry detail view layout with entry-tier metadata area and item-tier metadata area
- [ ] 5.3 Implement the persistent item list panel for multi-item entries (scrollable, shows item name and type per row)
- [ ] 5.4 Wire item list selection to update the item metadata area in place
- [ ] 5.5 Implement single-item entry rendering that collapses item metadata inline into the entry tier
- [ ] 5.6 Implement the empty/prompt state for the item metadata area when no item is selected
- [ ] 5.7 Add navigation from library browsing surface to catalog entry detail view on entry selection
- [ ] 5.8 Implement in-place detail view update when user selects a different entry while the detail view is open

## 6. Verification

- [ ] 6.1 Test single-item entry: detail view shows entry metadata and item metadata inline, no item list visible
- [ ] 6.2 Test multi-item entry (e.g., Moria): detail view shows entry metadata and item list; selecting each item shows its individual metadata
- [ ] 6.3 Test item count badge is visible on multi-item entries in list, tree, and grid views, and absent on single-item entries
- [ ] 6.4 Test switching selection between entries while detail view is open updates the view in place
- [ ] 6.5 Test returning to a multi-item entry after navigating away confirms no item is pre-selected
- [ ] 6.6 Test item list scrollability with a catalog entry that has a large number of items
- [ ] 6.7 Update parent submodule references in `dtrpg` once all child changes are verified
