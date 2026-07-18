## 1. Umbrella Documentation

- [ ] 1.1 Update `docs/git-repos.md` to list `js` (Node) under `dtrpg-sdk`, alongside `go`, `python`, `rust`, `swift`
- [ ] 1.2 Update `docs/git-repos.md` wording to record `python` and `js` as active SDK targets under development, not shipped implementations
- [ ] 1.3 Create `docs/typescript.md` with the same section structure as `docs/go.md`/`docs/rust.md`/`docs/swift.md` (stack, focus areas, style rules, testing rules, workflow rules)
- [ ] 1.4 Add a `Swift`/`Python`/`Go`/`Rust`-style reference line for `docs/typescript.md` under the "Writing Code and Generating Files" section of `CLAUDE.md`

## 2. Child Repository Coordination

- [ ] 2.1 Confirm `dtrpg-api`'s current `develop` branch contract is stable enough for a new SDK implementation to start against
- [ ] 2.2 Verify `dtrpg-sdk/python` has (or needs) a `dtrpg-api` submodule reference under `API/`, matching the pattern used by `dtrpg-sdk/go`
- [ ] 2.3 Verify `dtrpg-sdk/js` has (or needs) a `dtrpg-api` submodule reference under `API/`, matching the pattern used by `dtrpg-sdk/go`

## 3. Issue Tracking

- [ ] 3.1 Create a GitHub Issue in `dtrpg-sdk/python` for the initial SDK implementation (config, `dtrpg-api` integration, auth/session lifecycle, library client, CI/release pipeline), linked to this OpenSpec change
- [ ] 3.2 Create a GitHub Issue in `dtrpg-sdk/js` for the initial SDK implementation (same scope), linked to this OpenSpec change
- [ ] 3.3 Set labels, type, size, project, and milestone on both issues per `docs/openspec.md`'s issue-tracking convention

## 4. Verification

- [ ] 4.1 Confirm `docs/git-repos.md` and `docs/typescript.md` render correctly and follow the markdown conventions in `CLAUDE.md`
- [ ] 4.2 Confirm no existing Go/Rust/Swift SDK documentation or behavior was modified
