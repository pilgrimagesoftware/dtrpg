# OpenSpec

OpenSpec is initialized in the top-level repo and in selected child repositories.

- Use this repository (`dtrpg`) for umbrella changes that coordinate work across multiple repositories.
- Use `dtrpg-app` for general app changes that affect the app's UI and behavior that are not specific to a programming language or UI framework.
- Use `dtrpg-api` for API contract changes that SDKs and applications depend on.
- Prefer `dtrpg-sdk/rust` as the language-specific downstream example when following an existing OpenSpec pattern.
- Keep `dtrpg-sdk/swift` in place as an additional reference, but prefer Rust for new example-driven SDK OpenSpec work.

Current preferred example chain:

- Top-level umbrella: `dtrpg/openspec/changes/improve-auth-session-lifecycle`
- API contract child: `dtrpg-api/openspec/changes/define-auth-session-contract`
- Preferred SDK child: `dtrpg-sdk/rust/openspec/changes/define-rust-auth-session-behavior`

## GitHub Issues

Create one or more GitHub Issues to track the work required to implement the OpenSpec changes.

Issues should be created in the appropriate repository, and should:
- set the appropriate labels, type (e.g. bug, feature, documentation), size, and level of effort
- set the project and milestone
- link to the relevant OpenSpec change file

When starting on a change:
- set the assignee
- set the start date
- move the issue's project status to "In Progress".
- use the issue number and a descriptive branch name (e.g. `fix-auth-session-lifecycle`), per GitHub's 
  documentation for linking branches and PRs to issues
- push the branch to the remote and create a pull request, attach the branch/PR to the issue
- set the PR title to the issue title without the Conventional Commits prefix
- set the PR metadata according to the issue: assignee, labels, project and milestone
- link the PR to the issue

When completing a change (clean up):
- set the end date
- move the issue's project status to "Done"
- merge the PR
- remove worktrees
