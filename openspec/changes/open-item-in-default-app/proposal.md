## Why

Users download content from DriveThruRPG and expect to read it immediately — currently the application has no way to open a purchased item, making the catalog a dead-end view. Leveraging the OS's default application for each file type (PDF reader for PDFs, image viewer for images, etc.) delivers this with zero additional dependency and matches the behavior users already know from Finder, Explorer, and file managers on Linux.

## What Changes

- A new "Open" action is added to catalog items that invokes the OS default application for the item's file type.
- The action is accessible from two surfaces: the main catalog list/grid view (per-item action) and the item detail view (primary action button).
- The application resolves the local file path of the downloaded item before attempting to open it; if the file is not yet downloaded, the action is disabled or replaced with a "Download" prompt.
- No new file viewers are built in-app — all viewing is delegated to the OS.

## Capabilities

### New Capabilities

- `open-item`: Triggers the OS default application for a catalog item's downloaded file, surfaced from both the catalog view and the detail view.

### Modified Capabilities

<!-- No existing specs have requirement-level changes from this work. -->

## Impact

- **dtrpg-app/rust**: Primary implementation target — the Rust/gpui desktop app needs OS-level "open file" integration. On macOS this is `NSWorkspace.open(_:)` (via `open` crate or direct `open` shell command), on Windows `ShellExecuteW`, on Linux `xdg-open`.
- **dtrpg-app/swift**: The Swift/macOS app uses `NSWorkspace.shared.open(_:)` natively.
- **Catalog UI** (both apps): Catalog item row/card gains an "Open" affordance; detail view gains a primary "Open" button. State of the affordance depends on whether the item has a local file available.
- **dtrpg-api / dtrpg-sdk**: No API or SDK changes required; the local file path is already known from the download state.
