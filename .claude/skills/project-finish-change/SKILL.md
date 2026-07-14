---
name: project-finish-change
description: Wrap up work on an OpenSpec change already in progress - commits code and docs, marks remaining tasks complete, opens or updates the linked PR, merges it once checks pass, closes the GitHub Issue, updates the local main worktree, and removes the feature worktree. Use when the user says a change is done, ready to merge, or wants to close out/finish/wrap up a change - not for starting a change (use project-start-change) or archiving OpenSpec artifacts on their own (use openspec-archive-change).
---

Close out an OpenSpec change that was set up with `project-start-change`: land the code, merge
the PR, close the issue, and clean up the worktree.

## Steps

### 1. Identify the change and its worktree

Ask which change to finish, unless clear from context. Find its worktree: `git worktree
list` in the owning repo, or the fixed path convention
`/Users/paulyhedral/Projects/Code/Libri/dtrpg/worktrees/<repo-slug>-<branch-slug>`. All
remaining work happens inside that worktree, not the main working tree.

### 2. Verify the work before declaring anything done

Run the repo's build, lint, and test commands (see the relevant `docs/<language>.md` for the
exact commands) inside the worktree. Do not proceed to committing/merging on the basis of
untested claims - confirm by actually running these.

### 3. Mark tasks complete

Open the change's `tasks.md` and flip any task actually finished from `- [ ]` to `- [x]`.
If tasks remain genuinely incomplete, stop and ask the user whether to finish them first or
proceed anyway (mirroring `openspec-archive-change`'s incomplete-task warning) - don't mark a
task done that wasn't done.

### 4. Commit code and docs

Stage only the files that changed for this work (never a blanket `git add -A`/`.`). Commit
using Conventional Commits (`<type>(<scope>): <description>`, per the root `AGENTS.md`),
splitting code and doc/task-list changes into separate commits only if that matches the
repo's existing commit history style - otherwise one commit is fine.

### 5. Push and ensure the PR is in order

`git push` the branch. If `project-start-change` already opened a PR, confirm it's still
pointed at the right base and not marked draft. If no PR exists yet, create one now:

```
gh pr create --repo <owner/repo> --base develop --title "<issue title, no Conventional Commits prefix>" --body "Closes #<issue-number>"
```

The `Closes #<n>` (or `Fixes #<n>`) line is what links the PR to the issue and auto-closes it
on merge - confirm it's present in the PR body even if the PR already existed.

### 6. Wait for checks

`gh pr checks <n> --watch` (or poll `gh pr view <n> --json statusCheckRollup`). If checks
fail, report the failure and stop - do not merge a red PR. Fix and re-push if the fix is
clear; otherwise hand back to the user.

### 7. Merge

Confirm with the user before merging, unless they've already authorized auto-merge for this
task - merging into `develop` is a shared, visible action. Default to squash merge (per
`docs/git-flow.md`: "squash keeps history cleaner"), or ask if the repo's convention differs:

```
gh pr merge <n> --squash --delete-branch
```

`--delete-branch` removes the remote branch; it does not touch the local worktree.

### 8. Close out the Issue

If the merge's `Closes #<n>` didn't auto-close it (e.g. PR merged into a branch that isn't
the repo's GitHub default branch), close it explicitly:

```
gh issue close <n> --repo <owner/repo>
```

Then, per `docs/openspec.md` ("When completing a change"): set the end date if the project
tracks one, and move the issue's project status to "Done" (`gh project item-edit`).

### 9. Update the local main worktree

In the repo's main working tree (not the feature worktree):

```
git checkout develop
git pull
```

If this repo is itself a submodule of a parent meta-repo (`dtrpg-app`, `dtrpg-sdk`, or the
top-level `dtrpg`), walk up: in the parent's main working tree, `git add <submodule-path>`
and commit the updated submodule reference, then push - repeat at each level up to the
umbrella `dtrpg` repo if the change touched a nested submodule (see `docs/git-submodules.md`).

### 10. Remove the feature worktree

```
git worktree remove /Users/paulyhedral/Projects/Code/Libri/dtrpg/worktrees/<repo-slug>-<branch-slug>
git branch -D <branch-name>
```

If `git worktree remove` refuses because a submodule is checked out inside it, confirm
`git status --short` and `git submodule status` are clean first, then use `--force`.

### 11. Report back

Summarize: change name, PR number/URL and merge method, issue number and closed state,
submodule references updated (if any), and confirmation the worktree was removed.

## Gotchas

- Don't skip step 2 - "tests pass" and "lint is clean" must be observed by actually running
  them this session, not assumed from earlier context.
- A PR merged into `develop` does not auto-close the issue unless `develop` happens to be the
  repo's configured default branch - always verify the issue actually closed (step 8) rather
  than trusting the `Closes #n` line alone.
- Nested submodule repos need the submodule-pointer commit propagated at every level between
  where the code lives and the umbrella `dtrpg` repo, not just one level up.
- Never force-merge past failing checks or skip hooks to make a merge go through - stop and
  report instead.
