## Context

`dtrpg-sdk` is a meta-repository nesting one submodule per SDK language (`go`, `js`, `python`, `rust`, `swift`), plus `API` (the shared `dtrpg-api` submodule providing `openapi.yaml`). `go`, `rust`, and `swift` are complete: configuration, `dtrpg-api` submodule integration, auth/session lifecycle, a library client (orders, product lists, download preparation), CI, and a release pipeline. `python` and `js` currently contain only a `README.md` and `LICENSE`(`.md`) — no code, no `dtrpg-api` submodule reference, no CI.

This proposal is scoped to the umbrella repository: declaring Python and Node as SDK family members and recording the coordination plan. Actual SDK code is out of scope here and belongs in child OpenSpec changes inside `dtrpg-sdk/python` and `dtrpg-sdk/js`, per `docs/openspec.md`'s repo-boundary rule (`repo-boundaries` capability).

## Goals / Non-Goals

**Goals:**
- Declare the parity bar a new SDK language member must meet before it's considered part of the family (not just "a repo exists").
- Record dependency order: `dtrpg-api` contract availability before child SDK implementation; no ordering dependency between `python` and `js` themselves since they don't depend on each other.
- Update umbrella docs (`docs/git-repos.md`) and add SDK-authoring guidance for Node (`docs/typescript.md`), matching the existing per-language doc pattern (`docs/go.md`, `docs/rust.md`, `docs/swift.md`, `docs/python.md`).
- Create GitHub Issues for each child repo's initial implementation work.

**Non-Goals:**
- Implementing the actual SDK client (auth/session lifecycle, library client behavior) in `dtrpg-sdk/python` or `dtrpg-sdk/js` — that remains a separate child OpenSpec change per repo. Scope was extended to cover the surrounding scaffolding (CI, release pipeline, branch protection, governance docs) directly in this change, since that scaffolding is a prerequisite for any child change to run tests and merge safely — see the scope addendum below.
- Choosing the Node package manager, build tool, or publishing target (npm vs. JSR, etc.) beyond what's needed to give CI a real target — deferred to the `dtrpg-sdk/js` child change's own design doc for anything beyond a minimal scaffold.
- Changing behavior of the existing Go, Rust, or Swift SDKs.

**Scope addendum:** the umbrella change now also scaffolds each child repo directly — a minimal buildable package (so CI isn't vacuous), CI/release GitHub Actions workflows, `cliff.toml`, governance docs (`CONTRIBUTING.md`, `SECURITY.md`, `RELEASE.md`), and live GitHub rulesets on `develop`/`master` mirroring `dtrpg-sdk.go` and `dtrpg-sdk.swift`. This still excludes the SDK's actual API client code.

## Decisions

**Decision: Treat `python` and `js` symmetrically as new family members, not a "primary + follow-on" pair.**
Both repos are equally empty stubs today; there's no existing partial Python implementation to build on despite `docs/python.md` already existing. Alternative considered: sequence Python first since its style guide already exists in this repo. Rejected — a style doc isn't implementation progress, and the two child efforts have no code dependency on each other, so serializing them adds delay without reducing risk.

**Decision: Both child SDKs depend on `dtrpg-api`, not on each other or on an existing SDK's code.**
`dtrpg-api`'s `openapi.yaml` is the shared contract each SDK's `API` submodule consumes (mirroring the Go SDK's `go:generate` step reading `API/openapi.yaml`). The umbrella change only needs to confirm the current `dtrpg-api` contract is stable enough to start from; it doesn't need to change `dtrpg-api` itself. Alternative considered: require the Rust SDK's auth/session module to be ported as a shared reference implementation first. Rejected — each language's SDK is independently maintained per `docs/git-repos.md`'s versioning-independence note, and forcing a code-level reference adds coupling this repo structure was designed to avoid.

**Decision: Add `docs/typescript.md`, not `docs/node.md` or `docs/javascript.md`.**
The SDK will be authored in TypeScript (consistent with `dtrpg-app`'s existing use of `typescript-development` conventions elsewhere in this environment) and this repo's other language docs are named after the language, not the runtime (`docs/go.md`, not `docs/golang.md`). Alternative considered: `docs/node.md`. Rejected for naming consistency with the language-not-runtime convention already in place.

## Risks / Trade-offs

- [Risk] Declaring family membership before any code exists could create a stale doc if implementation stalls. → Mitigation: this change's tasks include filing the child GitHub Issues so progress is tracked outside this doc; `docs/git-repos.md` states "active SDK targets," not "shipped."
- [Risk] `docs/typescript.md` is written without an existing TypeScript codebase in this repo family to derive conventions from. → Mitigation: base it on the same structural sections as `docs/go.md`/`docs/rust.md` (project context, focus areas, testing, security invariants) rather than inventing new categories, and let the `dtrpg-sdk/js` child change refine specifics once code exists.
- [Risk] No API-stability check is performed here, so a child SDK could start against a `dtrpg-api` contract that changes underneath it. → Mitigation: `cross-repo-compatibility` requirement already covers rollout sequencing; this change adds a scenario extending that coverage to new-language onboarding.

## Migration Plan

Not applicable — this is a planning/coordination change with no runtime deployment. Doc changes land directly; child implementation work is tracked via linked GitHub Issues and separate child OpenSpec changes.

## Open Questions

- Does `dtrpg-sdk/js` target Node-only, or also browser/edge runtimes? Deferred to the child change's design doc since it affects build tooling, not umbrella-level scope.
- Publishing target (npm registry name, scope) — deferred to the child change.
