# Git Repositories

## Repository Structure

This repository contains two main meta-repositories as git submodules:

- **dtrpg-sdk** - SDK implementations across multiple languages (Go, Node/TypeScript, Python, Rust, Swift)
  - `go` - Go SDK implementation
  - `js` - Node/TypeScript SDK implementation
  - `python` - Python SDK implementation
  - `rust` - Rust SDK implementation
  - `swift` - Swift SDK implementation

- **dtrpg-app** - Desktop application implementations
  - `rust` - Rust-based desktop application (macOS, Windows, Linux; gpui UI framework)
  - `swift` - Swift-based desktop application (macOS)

It also contains the `dtrpg-api` repository as a submodule where the API documentation and 
configuration are kept. This repository is a submodule of several of the other repositories,
so that any repo that needs access to the API documentation can simply update the submodule
and get the latest version.

## Branches

All meta-repositories use the `master` branch as the source of truth.

All code repositories use the `develop` branch as the source of truth, with the "Git Flow" process for branch creation
and merging.

The `dtrpg-api` repository is also a submodule of each of the `*-sdk` repositories, so that the `openapi.yaml` spec file
is maintained in the `dtrpg-api` repository and synchronized to the `*-sdk` repositories through submodule updates.

## Commit Messages

Commit messages follow the "Conventional Commits" format: https://www.conventionalcommits.org/en/v1.0.0/
