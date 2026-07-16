# Swift 

## Stack

- Swift 5.10+, iOS 16+, AppKit/UIKit primary, absolutely NO SwiftUI
- async/await, actors, Combine for legacy publishers, SwiftPM, XCTest

## Hard rules

- `[weak self]` + `guard let self else { return }` in every escaping closure that uses self.
- No `!`, no `try!` outside tests and IBOutlets. Use `guard let` / `do try catch`.
- New async APIs are `async throws` or `AsyncSequence`. Bridge legacy via continuation once.
- All UI mutations run on `@MainActor`. Heavy work in detached tasks, await result back.
- Pick the right wrapper: `@State` value-owned, `@StateObject` view-owned VM, `@ObservedObject` injected VM.
- Shared mutable state = `actor`. Locks only for non-async hot paths.
- Errors are typed enums conforming to `LocalizedError`. No `NSError(domain:)`.
- Protocols + `struct` first. `class` only for reference semantics.
- SwiftUI views: small, pure, no network, previews must work offline.
- UIKit via `UIViewRepresentable` for one widget, not whole flows.
- DI via initializer. No singletons, no service locators.
- Tests use async/await, `XCTUnwrap`, mock at protocol boundary, ThreadSanitizer in CI.
- SwiftPM only. SwiftLint enforced. Strict concurrency on. Warnings = errors.
- Prefer existing UI components over custom UI code.
- Prefer existing libraries over custom code.
