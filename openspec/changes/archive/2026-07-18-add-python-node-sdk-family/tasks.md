## 1. Umbrella Documentation

- [x] 1.1 Update `docs/git-repos.md` to list `js` (Node) under `dtrpg-sdk`, alongside `go`, `python`, `rust`, `swift`
- [x] 1.2 Update `docs/git-repos.md` wording to record `python` and `js` as active SDK targets under development, not shipped implementations
- [x] 1.3 Create `docs/typescript.md` with the same section structure as `docs/go.md`/`docs/rust.md`/`docs/swift.md` (stack, focus areas, style rules, testing rules, workflow rules)
- [x] 1.4 Add a `Swift`/`Python`/`Go`/`Rust`-style reference line for `docs/typescript.md` under the "Writing Code and Generating Files" section of `CLAUDE.md`

## 2. Child Repository Coordination

- [x] 2.1 Confirm `dtrpg-api`'s current `develop` branch contract is stable enough for a new SDK implementation to start against — confirmed active, unprotected `develop` at `4a54add` with recent CRUD-endpoint definitions; usable as a starting contract
- [x] 2.2 Verify `dtrpg-sdk/python` has (or needs) a `dtrpg-api` submodule reference under `API/`, matching the pattern used by `dtrpg-sdk/go` — confirmed missing (no `.gitmodules`); deferred to the `dtrpg-sdk/python` child SDK-implementation change, since adding it now without client code would be dead weight
- [x] 2.3 Verify `dtrpg-sdk/js` has (or needs) a `dtrpg-api` submodule reference under `API/`, matching the pattern used by `dtrpg-sdk/go` — confirmed missing (no `.gitmodules`); same deferral as 2.2

## 3. Issue Tracking

- [x] 3.1 Create a GitHub Issue in `dtrpg-sdk/python` for the initial SDK implementation (config, `dtrpg-api` integration, auth/session lifecycle, library client, CI/release pipeline), linked to this OpenSpec change — [dtrpg-sdk.py#1](https://github.com/pilgrimagesoftware/dtrpg-sdk.py/issues/1)
- [x] 3.2 Create a GitHub Issue in `dtrpg-sdk/js` for the initial SDK implementation (same scope), linked to this OpenSpec change — [dtrpg-sdk.js#1](https://github.com/pilgrimagesoftware/dtrpg-sdk.js/issues/1)
- [x] 3.3 Set labels, type, size, project, and milestone on both issues per `docs/openspec.md`'s issue-tracking convention — labeled `enhancement`, typed `Feature`, added to the DriveThruRPG project; neither repo has milestones or a Size/Effort field defined yet, so those were left unset

## 5. Python SDK Scaffolding (dtrpg-sdk/python)

- [x] 5.1 Scaffold a minimal `pyproject.toml`-based package (via `uv init --package`) so CI has a real target to lint/type-check/test against — no SDK client behavior yet
- [x] 5.2 Add `.github/workflows/ci.yaml`: ruff lint + format check, type check (pyrefly/ty/mypy), `pytest`, on PR and push to `develop`
- [x] 5.3 Add `.github/workflows/prepare-release.yaml`: `git-cliff --bump` version + changelog, opens a release PR from `release/<version>` to `master` (manual trigger)
- [x] 5.4 Add `.github/workflows/release.yaml`: triggered by `v*` tag on `master` — test, build, `uv publish` to PyPI, generate scoped changelog, create GitHub Release
- [x] 5.5 Add `cliff.toml` (git-cliff config, Conventional Commits, matching the umbrella's `docs/git-flow.md` pattern)
- [x] 5.6 Add `CONTRIBUTING.md`, `SECURITY.md`, `RELEASE.md`
- [x] 5.7 Push the scaffolding on a feature branch and open a PR into `develop` — [dtrpg-sdk.py#2](https://github.com/pilgrimagesoftware/dtrpg-sdk.py/pull/2), CI passed, merged into `develop`; also switched the repo's default branch from `master` to `develop` to match `dtrpg-sdk.go`/`.rs`/`.swift`
- [x] 5.8 Apply GitHub rulesets to `develop` and `master` mirroring `dtrpg-sdk.go`/`dtrpg-sdk.swift`: deletion protection, required status checks (this repo's new CI job names), CodeQL code scanning, code quality gate, Copilot code review on `develop`; `master` additionally requires signed commits — rulesets `develop` (19143507) and `master` (19143510) active; CodeQL default-setup is "configured" but language auto-detection was still catching up as of this run, matching `dtrpg-sdk.swift`'s current state

## 6. Node/TypeScript SDK Scaffolding (dtrpg-sdk/js)

- [x] 6.1 Scaffold a minimal TypeScript package (`package.json`, `tsconfig.json`, `src/index.ts`, one trivial test) so CI has a real target — no SDK client behavior yet
- [x] 6.2 Add `.github/workflows/ci.yaml`: lint, type check, test, on PR and push to `develop`
- [x] 6.3 Add `.github/workflows/prepare-release.yaml`: `git-cliff --bump` version + changelog, opens a release PR from `release/<version>` to `master` (manual trigger)
- [x] 6.4 Add `.github/workflows/release.yaml`: triggered by `v*` tag on `master` — build, publish to npm, generate scoped changelog, create GitHub Release
- [x] 6.5 Add `cliff.toml`
- [x] 6.6 Add `CONTRIBUTING.md`, `SECURITY.md`, `RELEASE.md`
- [x] 6.7 Push the scaffolding on a feature branch and open a PR into `develop` — [dtrpg-sdk.js#2](https://github.com/pilgrimagesoftware/dtrpg-sdk.js/pull/2), CI passed, merged into `develop`; also switched the repo's default branch from `master` to `develop`. Along the way, `npm audit` flagged 6 vulnerabilities (2 critical) in `vitest@2.x`'s transitive `esbuild`/`vite` deps; pinned to `vitest@4.x` instead, which resolves clean
- [x] 6.8 Apply GitHub rulesets to `develop` and `master` mirroring `dtrpg-sdk.go`/`dtrpg-sdk.swift`: deletion protection, required status checks (this repo's new CI job names), CodeQL code scanning, code quality gate, Copilot code review on `develop`; `master` additionally requires signed commits — rulesets `develop` (19143607) and `master` (19143608) active

## 4. Verification

- [x] 4.1 Confirm `docs/git-repos.md` and `docs/typescript.md` render correctly and follow the markdown conventions in `CLAUDE.md`
- [x] 4.2 Confirm no existing Go/Rust/Swift SDK documentation or behavior was modified — verified via `git diff origin/master -- docs/rust.md docs/swift.md docs/go.md dtrpg-sdk`; only the `dtrpg-sdk` submodule pointer moved, and that pointer's only change is `dtrpg-sdk/README.md`
- [x] 4.3 Confirm `dtrpg-sdk/python` and `dtrpg-sdk/js` CI workflows pass on their scaffolding PRs before rulesets are applied — both PRs' "Lint, Type Check, and Test" checks passed before merge
- [x] 4.4 Confirm both repos' `develop`/`master` rulesets are active via `gh api repos/<owner>/<repo>/rulesets` — confirmed for both `dtrpg-sdk.py` and `dtrpg-sdk.js`
