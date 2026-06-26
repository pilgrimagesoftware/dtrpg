## Why

Some DriveThruRPG catalog entries bundle multiple physical or digital items together — for example, Moria contains both a book and a separate map sheet — but the current library detail view treats each entry as a single homogeneous unit, hiding the per-item distinctions and their individual metadata from the user.

## What Changes

- Introduce a catalog entry detail view that surfaces multi-item entries distinctly from single-item entries.
- When a user opens the detail view for a multi-item catalog entry, present a discoverable item-selection affordance (secondary detail panel or picker UI) so the user can inspect individual items within the entry.
- Expose catalog-entry-level metadata (title, publisher, description, purchase/download state) alongside item-level metadata (item type, filename, format, size, individual download state) without conflating the two.
- Define the behavioral contract for how apps navigate from the library browsing surface (established by `main-window-library-layout`) into a catalog entry detail view that supports both single-item and multi-item layouts.

## Capabilities

### New Capabilities

- `catalog-entry-detail-view`: Defines the layout and interaction model for the catalog entry detail view, covering both single-item and multi-item entries, metadata presentation, and item-selection affordance.

### Modified Capabilities

- `main-window-library-layout`: Extends the library browsing contract to include navigation into catalog entry detail views, so apps understand how the detail surface fits into the overall window layout.

## Impact

- `dtrpg/openspec`: New umbrella capability coordinating layout behavior across app implementations.
- `dtrpg-app`: Needs child implementation proposals for the detail view shell and item-picker integration.
- `dtrpg-app/swift`: Needs a child change for native macOS SwiftUI detail view behavior.
- `dtrpg-app/rust`: Needs a child change if the Rust desktop app targets the same detail surface.
- `dtrpg-api`: Verify that the API response for a catalog entry exposes item-level data; no new contract change is expected, but item metadata fields must be confirmed as available.
- `dtrpg-sdk`: SDK models should map the API's item array to typed per-item structs; confirm whether this is already done or requires a model addition.
