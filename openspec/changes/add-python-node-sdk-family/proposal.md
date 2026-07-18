## Why

`dtrpg-sdk/python` and `dtrpg-sdk/js` exist as empty stub repositories (README and license only), while `dtrpg-sdk/go`, `dtrpg-sdk/rust`, and `dtrpg-sdk/swift` are full SDK implementations with auth/session lifecycle, a library client, and CI/release pipelines. The project's own documentation (`docs/git-repos.md`, `docs/python.md`) already treats Python as a first-class SDK language, but no implementation or coordinating plan exists yet, and Node/TypeScript is not represented in the SDK family or docs at all. This change formally brings Python and Node into the SDK family and coordinates the two child implementation efforts from the umbrella repository.

## What Changes

- Add `dtrpg-sdk/js` (Node/TypeScript) as a tracked member of the SDK language family alongside Go, Python, Rust, and Swift.
- Define the umbrella-level scope and rollout order for bringing `dtrpg-sdk/python` and `dtrpg-sdk/js` to parity with the existing SDKs: configuration, `dtrpg-api` submodule integration, auth/session lifecycle, and a library client (orders, product lists, download preparation).
- Update `docs/git-repos.md` to list `js` (Node) under `dtrpg-sdk` and record that `python` and `js` are active SDK targets, not placeholders.
- Add a `docs/typescript.md` (or `docs/node.md`) authoring guide analogous to the existing `docs/rust.md`, `docs/swift.md`, `docs/go.md`, and `docs/python.md` files, defining stack, style, and workflow conventions for the Node SDK.
- Record the required implementation order between the two child repos and `dtrpg-api` so neither child change starts implementation ahead of an available API contract.
- Create GitHub Issues to track each child repository's initial SDK implementation, per this repo's OpenSpec issue-tracking convention.

## Capabilities

### New Capabilities
- `sdk-language-family`: Defines which languages constitute the DTRPG SDK family, the parity bar new language members must meet (config, auth/session lifecycle, library client, CI/release pipeline), and where each language's authoring conventions are documented.

### Modified Capabilities
- `cross-repo-compatibility`: Extends coordinated-rollout requirements to cover onboarding a new SDK language member, including sequencing the child implementation repos against `dtrpg-api` and against each other.

## Impact

- **Affected repos**: `dtrpg` (umbrella docs, this OpenSpec change), `dtrpg-sdk/python` (implementation work, out of scope for this proposal's own tasks but tracked via a linked child change/issue), `dtrpg-sdk/js` (same).
- **Affected docs**: `docs/git-repos.md`, new `docs/typescript.md`.
- **No breaking changes**: existing Go, Rust, and Swift SDKs are unaffected.
