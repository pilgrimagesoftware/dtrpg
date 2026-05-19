# AGENTS.md

This file provides guidance to Claude Code (claude.ai/code), Codex (openai.com/codex/), GitHub Copilot (copilot.github.com) when working with code in this repository.

## About This Project

This is the master meta-repository for the DriveThruRPG project, which organizes SDK libraries and desktop
applications for interacting with the DriveThruRPG API. The project uses a nested submodule architecture to
manage multiple language implementations.

## OpenSpec Guidance

OpenSpec is initialized in the top-level repo and in selected child repositories.

- Use this repository (`dtrpg`) for umbrella changes that coordinate work across multiple repositories.
- Use `dtrpg-api` for API contract changes that SDKs and applications depend on.
- Prefer `dtrpg-sdk/rust` as the language-specific downstream example when following an existing OpenSpec pattern.
- Keep `dtrpg-sdk/swift` in place as an additional reference, but prefer Rust for new example-driven SDK OpenSpec work.

Current preferred example chain:

- Top-level umbrella: `dtrpg/openspec/changes/improve-auth-session-lifecycle`
- API contract child: `dtrpg-api/openspec/changes/define-auth-session-contract`
- Preferred SDK child: `dtrpg-sdk/rust/openspec/changes/define-rust-auth-session-behavior`

## Repository Structure

This repository contains two main meta-repositories as git submodules:

- **dtrpg-sdk** - SDK implementations across multiple languages (Go, Python, Rust, Swift)
  - `go` - Go SDK implementation
  - `python` - Python SDK implementation
  - `rust` - Rust SDK implementation
  - `swift` - Swift SDK implementation

- **dtrpg-app** - Desktop application implementations
  - `rust` - Rust-based desktop application (macOS, Windows, Linux; gpui UI framework)
  - `swift` - Swift-based desktop application (macOS)

It also contains the `dtrpg-api` repository as a submodule where the API documentation and configuration are
kept.

The `dtrpg-api` repository is also a submodule of each of the `*-sdk` repositories, so that the `openapi.yaml` spec file
is maintained in the `dtrpg-api` repository and synchronized to the `*-sdk` repositories through submodule updates.

## Working with Submodules

### Initial Setup

```bash
# Clone with all nested submodules
git clone --recursive git@github.com:pilgrimagesoftware/dtrpg.git

# Or initialize submodules after cloning
git submodule update --init --recursive
```

### Updating Submodules

```bash
# Update all submodules to latest commits on their tracked branches
git submodule update --remote --merge

# Update specific submodule
git submodule update --remote --merge dtrpg-sdk

# Update nested submodules within dtrpg-sdk
cd dtrpg-sdk && git submodule update --remote --merge
```

### Checking Submodule Status

```bash
# Check status of direct submodules
git submodule status

# Check nested submodules
cd dtrpg-sdk && git submodule status
cd dtrpg-app && git submodule status
```

### Making Changes

When making changes to submodules:
1. Navigate into the submodule directory
2. Make changes and commit within the submodule
3. Push the submodule changes to its remote
4. Return to the parent repository and commit the updated submodule reference
5. Push the parent repository changes

```bash
cd dtrpg-sdk/swift
# Make changes, commit, push
git add . && git commit -m "Update swift SDK"
git push

cd /Users/paulyhedral/Code/DriveThruRPG/dtrpg
git add dtrpg-sdk
git commit -m "Update dtrpg-sdk submodule"
git push
```

## Repository Branches and Workflow

All meta-repositories use the `master` branch as the source of truth.

All code repositories use the `develop` branch as the source of truth, with the "Git Flow" process for
branch creation and merging.

## Writing Code and Generating Files

- YAML files should always use the `.yaml` extension.
- Code should always include doc comments.

## Commit Messages

Commit messages follow the "Conventional Commits" format: https://www.conventionalcommits.org/en/v1.0.0/

## Architecture Notes

- **Meta-repository Pattern**: This is a top-level organizational repository. Actual development happens in the
  submodules.
- **Language-Specific SDKs**: Each language SDK (Go, Python, Rust, Swift) is maintained as a separate repository,
  allowing independent versioning and release cycles.
- **Shared API Documentation**: The `dtrpg-sdk/api` submodule contains the source of truth for API specifications
  used across all SDK implementations.
- **Nested Submodules**: Both `dtrpg-sdk` and `dtrpg-app` are meta-repositories themselves containing their own
  submodules. Use `--recursive` flags when appropriate.

## Common Issues

### Detached HEAD State

Submodules often end up in detached HEAD state. Before making changes, ensure you're on a branch:

```bash
cd <submodule-directory>
git checkout master  # or appropriate branch
```

### Submodule Not Initialized

If a submodule directory is empty or shows errors:

```bash
git submodule update --init --recursive
```

## Languages

### Rust 

#### Project Context

- Package: defined in `Cargo.toml`; `edition = "2021"`, pinned `rust-version` (MSRV).
- Toolchain: pinned via `rust-toolchain.toml` (`channel = "stable"` or a specific version).
- Targets: systems & CLI (`x86_64-unknown-linux-gnu`, `aarch64-apple-darwin`), WASM (`wasm32-unknown-unknown`, `wasm32-wasi`) when applicable.
- Layout: `src/lib.rs` defines the public API; `src/main.rs` (or `src/bin/<name>.rs`) is a thin entry point that calls into the library.
- Async runtime: one per process — `tokio` multi-thread for servers, `current_thread` for CLIs and tests.

#### Core Rules

- Ownership: prefer owned types (`String`, `Vec<T>`, `PathBuf`) in public APIs; borrow inside implementations. Don't expose explicit lifetimes in `pub` signatures unless `Cow<'_, _>` is genuinely the right call.
- Borrowing: never hold a `std::sync::Mutex` guard across `.await`; use `tokio::sync::Mutex` or restructure to drop the guard first. No `&mut` aliasing tricks via raw pointers.
- Errors: libraries derive `thiserror::Error` on a typed `enum` per crate, with `#[from]` for transparent wrapping and `#[source]` for chains. Binaries return `anyhow::Result<T>` and add `.with_context(|| ...)?` at every boundary.
- `unsafe`: `#![deny(unsafe_code)]` (or `forbid`) at the crate root by default. Every `unsafe` block must have a `// SAFETY:` comment immediately above explaining which invariants hold and why. Every `unsafe fn` documents its preconditions in a `# Safety` doc section.
- Concurrency: spawned tasks (`tokio::spawn`) keep their `JoinHandle` and are awaited or aborted on shutdown — fire-and-forget tasks leak. Long-running loops honor cancellation via `tokio::select!` against a shutdown signal.

#### Style Rules

- Lints: crate root sets `#![warn(clippy::pedantic, clippy::nursery, missing_docs, rust_2018_idioms)]` and `#![deny(unsafe_op_in_unsafe_fn)]`. CI runs `cargo clippy --all-targets --all-features -- -D warnings`. No blanket `#[allow]` at the crate root — narrow allows only, with a comment explaining why.
- Naming: `snake_case` for modules, functions, variables, fields; `CamelCase` (UpperCamelCase) for types, traits, enum variants; `SCREAMING_SNAKE_CASE` for `const` and `static`. No Hungarian notation, no abbreviations beyond well-known ones (`url`, `id`, `db`).
- Formatting: `cargo fmt --all -- --check` runs in CI. No hand-formatted blocks. Imports grouped: std, external crates, local — `rustfmt` handles the order.
- Docs: every `pub` item carries `///` doc comments with a one-sentence summary on the first line. `pub fn` returning `Result` documents `# Errors`; functions that can panic document `# Panics`; every `pub fn` has a `# Examples` block that compiles (`cargo test --doc`).
- Logging: use `tracing` (`info!`, `error!`, `#[tracing::instrument(skip(secrets))]`). Never `println!` / `eprintln!` in library code.

#### Testing Rules

- Unit tests live inside the module in a `#[cfg(test)] mod tests { ... }` block — they have access to private items.
- Integration tests live in the top-level `tests/` directory; each `tests/foo.rs` is a separate crate that imports only the public API.
- Property-based testing with `proptest` (or `quickcheck`) for any function with non-trivial input space — parsers, validators, math, serde round-trips.
- Async tests use `#[tokio::test]`; sync tests use `#[test]`. Doc-tests run via `cargo test --doc` and gate API drift.
- CI runs `cargo test --all-features --workspace` AND `cargo test --no-default-features` so feature-gated code compiles both ways.
- Repository tests run against a real database (testcontainers or a dockerized DB) — never mock the DB; mocked tests pass while broken queries ship.

#### Security Invariants

- No `unwrap()` or `expect()` in production paths. CI greps for `\.unwrap\(\)` and `\.expect\(` on `*.rs` outside `tests/`, `examples/`, `benches/` and fails the build. `expect("...")` is allowed only when the message documents an invariant the type system can't express.
- No `todo!()`, `unimplemented!()`, or `panic!()` as flow control in shipped code. CI fails on any of these reachable from `pub` APIs.
- Explicit lifetime annotations are required wherever elision is ambiguous; never relabel `'a`, `'b`, `'c` in public signatures — name them descriptively (`'src`, `'cfg`).
- Integer arithmetic on untrusted input uses `checked_*`, `saturating_*`, or `wrapping_*` explicitly — never rely on debug-only overflow checks for security-relevant math.
- Indexing (`vec[i]`, `map[k]`) panics on out-of-bounds; prefer `.get(i)` returning `Option`. Never index user-controlled offsets directly.
- Never log secrets, tokens, or PII. `#[serde(skip)]` on secret fields; redact at the boundary, not after the fact. Wire DTOs are separate types from domain types that hold credentials.

#### Workflow Rules

- `cargo check --all-targets` before `cargo build` — it's faster and catches the same type errors. Configure your editor to run it on save.
- `cargo clippy --all-targets --all-features -- -D warnings` before every commit. Warnings are errors.
- `cargo fmt --all` before every commit. CI fails on unformatted code.
- `cargo audit` runs in CI weekly and on every `Cargo.lock` change — known advisories block the build until patched.
- `cargo deny check` enforces the license + advisory + source policy declared in `deny.toml`.
- `cargo update` is a deliberate action with its own PR — never bundled with feature work.
- `cargo doc --no-deps -- -D warnings` runs in CI; missing docs and broken intra-doc links fail the build.
- Library crates set `default-features = false` on every dependency and opt into exactly the features they use.
- Workspaces: one `Cargo.lock` at the workspace root, never per-crate. Shared dependency versions live under `[workspace.dependencies]` so all members agree.
- WASM targets: avoid `std::time::Instant`, threads, and blocking I/O — gate them behind `#[cfg(not(target_arch = "wasm32"))]` or use `wasm-bindgen-futures` and `web-time` shims.

#### Common Commands

```bash
cargo check --all-targets
cargo clippy --all-targets --all-features -- -D warnings
cargo fmt --all -- --check
cargo test --all-features --workspace
cargo test --no-default-features
cargo test --doc
cargo doc --no-deps -- -D warnings
cargo audit
cargo deny check
```
