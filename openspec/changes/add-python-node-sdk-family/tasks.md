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

- [ ] 5.1 Scaffold a minimal `pyproject.toml`-based package (via `uv init --package`) so CI has a real target to lint/type-check/test against — no SDK client behavior yet
- [ ] 5.2 Add `.github/workflows/ci.yaml`: ruff lint + format check, type check (pyrefly/ty/mypy), `pytest`, on PR and push to `develop`
- [ ] 5.3 Add `.github/workflows/prepare-release.yaml`: `git-cliff --bump` version + changelog, opens a release PR from `release/<version>` to `master` (manual trigger)
- [ ] 5.4 Add `.github/workflows/release.yaml`: triggered by `v*` tag on `master` — test, build, `uv publish` to PyPI, generate scoped changelog, create GitHub Release
- [ ] 5.5 Add `cliff.toml` (git-cliff config, Conventional Commits, matching the umbrella's `docs/git-flow.md` pattern)
- [ ] 5.6 Add `CONTRIBUTING.md`, `SECURITY.md`, `RELEASE.md`
- [ ] 5.7 Push the scaffolding on a feature branch and open a PR into `develop`
- [ ] 5.8 Apply GitHub rulesets to `develop` and `master` mirroring `dtrpg-sdk.go`/`dtrpg-sdk.swift`: deletion protection, required status checks (this repo's new CI job names), CodeQL code scanning, code quality gate, Copilot code review on `develop`; `master` additionally requires signed commits

## 6. Node/TypeScript SDK Scaffolding (dtrpg-sdk/js)

- [ ] 6.1 Scaffold a minimal TypeScript package (`package.json`, `tsconfig.json`, `src/index.ts`, one trivial test) so CI has a real target — no SDK client behavior yet
- [ ] 6.2 Add `.github/workflows/ci.yaml`: lint, type check, test, on PR and push to `develop`
- [ ] 6.3 Add `.github/workflows/prepare-release.yaml`: `git-cliff --bump` version + changelog, opens a release PR from `release/<version>` to `master` (manual trigger)
- [ ] 6.4 Add `.github/workflows/release.yaml`: triggered by `v*` tag on `master` — build, publish to npm, generate scoped changelog, create GitHub Release
- [ ] 6.5 Add `cliff.toml`
- [ ] 6.6 Add `CONTRIBUTING.md`, `SECURITY.md`, `RELEASE.md`
- [ ] 6.7 Push the scaffolding on a feature branch and open a PR into `develop`
- [ ] 6.8 Apply GitHub rulesets to `develop` and `master` mirroring `dtrpg-sdk.go`/`dtrpg-sdk.swift`: deletion protection, required status checks (this repo's new CI job names), CodeQL code scanning, code quality gate, Copilot code review on `develop`; `master` additionally requires signed commits

## 4. Verification

- [ ] 4.1 Confirm `docs/git-repos.md` and `docs/typescript.md` render correctly and follow the markdown conventions in `CLAUDE.md`
- [ ] 4.2 Confirm no existing Go/Rust/Swift SDK documentation or behavior was modified
- [ ] 4.3 Confirm `dtrpg-sdk/python` and `dtrpg-sdk/js` CI workflows pass on their scaffolding PRs before rulesets are applied
- [ ] 4.4 Confirm both repos' `develop`/`master` rulesets are active via `gh api repos/<owner>/<repo>/rulesets`
