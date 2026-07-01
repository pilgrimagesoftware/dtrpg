## 1. Rust App — Setup and ItemOpener Service

- [x] 1.1 Add `open` crate dependency to `dtrpg-app/rust/Cargo.toml`
- [x] 1.2 Create an `ItemOpener` struct (or module) in `dtrpg-app/rust` that wraps `open::that(path)`
- [x] 1.3 Define an `OpenError` error enum with variants for: `FileNotFound`, `NoDefaultApp`, `OsFailed(String)`, and `MultipleFilesRequireSelection`
- [x] 1.4 Implement `ItemOpener::open(path: &Path) -> Result<(), OpenError>` mapping `open` crate errors to `OpenError`
- [x] 1.5 Write unit tests for `ItemOpener` covering the success path and each error variant (mock the `open` call where necessary)

## 2. Rust App — Catalog View Integration

- [x] 2.1 Identify the catalog list/grid item component in `dtrpg-app/rust` and confirm where download state is accessible
- [x] 2.2 Add an "Open" affordance (button or context menu item) to the catalog item row/card, visible only when `downloadState == downloaded`
- [x] 2.3 Replace or hide the "Open" affordance with a "Download" prompt when the item has not been downloaded
- [x] 2.4 Wire the "Open" affordance to call `ItemOpener::open` with the item's local file path
- [x] 2.5 Display an error dialog/notification when `ItemOpener::open` returns an error, including a "Re-download" option for `FileNotFound`

## 3. Rust App — Detail View Integration

- [x] 3.1 Identify the catalog item detail view component in `dtrpg-app/rust`
- [x] 3.2 Add a primary "Open" button to the detail view when the item is downloaded; show "Download" button otherwise
- [x] 3.3 Wire the "Open" button to `ItemOpener::open` with the item's local file path
- [x] 3.4 Display an error dialog when `ItemOpener::open` returns an error from the detail view

## 4. Rust App — Multi-File Item Handling

- [ ] 4.1 Confirm with `dtrpg-api` / `dtrpg-sdk` whether a "primary file" field exists in the catalog item model
- [ ] 4.2 If a primary file is designated, open it directly; if not, present a file-selection sheet/popover listing available downloaded files
- [ ] 4.3 Implement the file-selection popover in gpui, listing each file's name and format
- [ ] 4.4 Wire popover selection to `ItemOpener::open` with the chosen file's path

## 5. Swift App — KeychainCredentialStore and Open Integration

- [ ] 5.1 Implement `func openItem(at url: URL) throws` in the Swift app using `NSWorkspace.shared.open(_ url: URL)`
- [ ] 5.2 Define an `ItemOpenError` enum for `fileNotFound`, `noDefaultApp`, `osFailed` with `LocalizedError` conformance
- [ ] 5.3 Map the `NSWorkspace.open` `Bool` return to `ItemOpenError.osFailed` when it returns `false`
- [ ] 5.4 Write XCTest tests for the open function covering success, file-not-found, and no-default-app paths

## 6. Swift App — Catalog View Integration

- [ ] 6.1 Add an "Open" button or context menu entry to the catalog item row/card in SwiftUI, conditioned on download state
- [ ] 6.2 Replace with "Download" button when item is not downloaded
- [ ] 6.3 Call `openItem(at:)` on button tap; display an `Alert` on error with appropriate message and "Re-download" option for missing files

## 7. Swift App — Detail View Integration

- [ ] 7.1 Add a primary "Open" button to the catalog item detail view in SwiftUI when item is downloaded
- [ ] 7.2 Show "Download" button instead when item is not downloaded
- [ ] 7.3 Call `openItem(at:)` on button tap; display an `Alert` on error

## 8. Swift App — Multi-File Item Handling

- [ ] 8.1 Apply the same primary-file / picker logic as the Rust app (see task 4.1)
- [ ] 8.2 Implement file-selection as a SwiftUI sheet listing available downloaded files for multi-file items without a primary designation
- [ ] 8.3 Wire sheet selection to `openItem(at:)`

## 9. Verification and Polish

- [ ] 9.1 Manual test on macOS: open a downloaded PDF, EPUB, and ZIP from both catalog view and detail view; verify correct app launches
- [ ] 9.2 Manual test on Windows (Rust app): open a downloaded PDF; verify Windows default PDF reader launches
- [ ] 9.3 Manual test on Linux (Rust app): open a downloaded PDF; verify `xdg-open` delegates to the registered viewer
- [ ] 9.4 Test missing-file error path: delete a downloaded file externally, then trigger "Open"; verify error message and re-download offer
- [ ] 9.5 Test no-default-app path on each platform (unregister/clear handler for a test extension); verify the error message is user-friendly
- [ ] 9.6 Update Linux installation documentation to note the `xdg-utils` runtime requirement
