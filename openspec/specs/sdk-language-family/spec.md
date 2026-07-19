## Purpose
Define which languages constitute the DTRPG SDK family, the parity bar new language members must meet, and where each language's authoring conventions are documented.
## Requirements
### Requirement: The SDK language family MUST be explicitly enumerated
The meta-repository MUST maintain an explicit, documented list of languages that constitute the DTRPG SDK family, distinguishing full implementations from repositories that exist but have not reached the parity bar.

#### Scenario: Checking which languages are part of the SDK family
- **WHEN** a maintainer or contributor needs to know which languages the DTRPG SDK supports
- **THEN** `docs/git-repos.md` lists every `dtrpg-sdk` child repository (`go`, `js`, `python`, `rust`, `swift`) and its status

#### Scenario: A new SDK language repository exists but has no implementation
- **WHEN** a `dtrpg-sdk` child repository contains only scaffolding (license, README) and no SDK code
- **THEN** the meta-repository's documentation records it as an active target under active development, not as a shipped SDK

### Requirement: A new SDK language member MUST meet a defined parity bar
The meta-repository MUST define the minimum capability set a new SDK language implementation must reach before it is considered at parity with the existing Go, Rust, and Swift SDKs: configuration, `dtrpg-api` submodule integration for the OpenAPI contract, auth/session lifecycle, a library client (orders, product lists, download preparation), and a CI/release pipeline.

#### Scenario: Evaluating whether a new language SDK has reached parity
- **WHEN** a `dtrpg-sdk/python` or `dtrpg-sdk/js` implementation is proposed as complete
- **THEN** it can be checked against the same capability set already implemented by `dtrpg-sdk/go`, `dtrpg-sdk/rust`, and `dtrpg-sdk/swift`

#### Scenario: Python and Node reach parity
- **WHEN** `dtrpg-sdk/python` and `dtrpg-sdk/js` each ship configuration, `dtrpg-api` submodule integration, auth/session lifecycle, a library client, and a CI/release pipeline
- **THEN** the meta-repository records both as at parity with `dtrpg-sdk/go`, `dtrpg-sdk/rust`, and `dtrpg-sdk/swift` in `docs/git-repos.md`, and the SDK language family consists of five languages at parity: Go, Node/TypeScript, Python, Rust, and Swift

### Requirement: Each SDK language MUST have documented authoring conventions
The meta-repository MUST provide a per-language conventions document (e.g. `docs/go.md`, `docs/rust.md`, `docs/swift.md`, `docs/python.md`) for every language in the SDK family, covering project structure, style, testing, and workflow rules specific to that language.

#### Scenario: Adding Node/TypeScript as a new SDK family member
- **WHEN** `dtrpg-sdk/js` is declared part of the SDK language family
- **THEN** the meta-repository provides a `docs/typescript.md` conventions document following the same section structure as the other per-language docs
