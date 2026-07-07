# Git Flow: `master` + `develop`

## Branch model

- **`master`** — always reflects the latest released state. Every commit on `master` corresponds to a tagged, published version. Nothing is committed here directly.
- **`develop`** — integration branch for ongoing work. Always builds and passes tests, but isn't necessarily released.
- **`feature/*`** — branched from `develop`, merged back into `develop`.
- **`fix/*`** — bug fixes branched from `develop` (or from `master` if it's a hotfix — see below), merged back into `develop`.
- **`release/*`** — cut from `develop` when you're preparing a release. Only version bumps, changelog updates, and last-minute fixes go here. Merges into both `master` and `develop`.
- **`hotfix/*`** — branched from `master` for urgent fixes to a released version. Merges into both `master` and `develop`.

## Feature work

```sh
git checkout develop
git pull
git checkout -b feature/add-retry-logic

# ... work, commit ...

git push -u origin feature/add-retry-logic
# open PR: feature/add-retry-logic -> develop
```

CI runs on the PR (build, test, lint, format check). Once it's green and reviewed, merge into `develop` (squash or merge commit, your call — squash keeps history cleaner for a hobby project). Delete the feature branch after merge.

## Bug fixes

Same pattern as a feature, just named `fix/*` instead of `feature/*`:

```sh
git checkout develop
git pull
git checkout -b fix/off-by-one-in-parser
# ... fix, commit, push, PR into develop ...
```

If the bug is in a version that's already released and you can't wait for the next normal release, that's a **hotfix** instead (see below).

## Changelog and version bumping: git-cliff

[git-cliff](https://git-cliff.org) reads your Conventional Commits history and does two jobs at once:

1. **Generates the changelog**, grouped by commit type.
2. **Calculates the next version** (`--bump`), by looking at commit types since the last tag: `fix:` → patch, `feat:` → minor, anything marked breaking (`!` or a `BREAKING CHANGE:` footer) → major.

That means there's no separate "version bump" tool to maintain — one config drives both.

### `cliff.toml`

This config groups commits by type, and **excludes** the types and scopes you don't want cluttering the changelog (adjust the lists to taste):

```toml
[changelog]
header = ""
body = """
{% for group, commits in commits | group_by(attribute="group") %}
### {{ group | upper_first }}
{% for commit in commits %}
- {{ commit.message | upper_first }}\
  {% if commit.breaking %} **[BREAKING]**{% endif %}
{% endfor %}
{% endfor %}\n
"""
trim = true

[git]
conventional_commits = true
filter_unconventional = true
split_commits = false

# Map commit types to changelog groups, and set which types
# count toward a "breaking"/major bump.
commit_parsers = [
  { message = "^feat", group = "Added" },
  { message = "^fix", group = "Fixed" },
  { message = "^perf", group = "Performance" },
  { message = "^refactor", group = "Changed" },
  { message = "^doc", group = "Documentation" },

  # Excluded from the changelog entirely:
  { message = "^chore", skip = true },
  { message = "^ci", skip = true },
  { message = "^test", skip = true },
  { message = "^style", skip = true },
  { message = "^build", skip = true },
]

# Exclude specific scopes regardless of type, e.g. internal tooling
# that isn't user-facing.
filter_commits = true
```

`filter_commits = true` combined with `skip = true` on a parser drops those commits from the changelog. To exclude a *scope* rather than a type, add a parser with a `scope` match and `skip = true`, e.g.:

```toml
{ scope = "internal", skip = true },
```

Commits marked `skip = true` are excluded from the changelog **but still count for version bumping** unless you also set `bump = "skip"` on that parser — useful if a `chore:` commit shouldn't be able to trigger any bump at all:

```toml
{ message = "^chore", skip = true, bump = "skip" },
```

### Release process (automated)

Instead of manually bumping `Cargo.toml` and writing the changelog by hand on the release branch, a `prepare-release` workflow does it for you:

```sh
git checkout develop
git pull
```

Trigger the **Prepare Release** workflow (`workflow_dispatch` in the Actions tab). It:
1. Runs `git-cliff --bump` against `develop` to determine the next version (e.g. `0.3.0`) from commits since the last tag.
2. Updates `Cargo.toml` to that version.
3. Prepends the generated changelog section to `CHANGELOG.md`.
4. Opens a PR from an auto-created `release/0.3.0` branch into `master`.

You review the PR (catch anything that shouldn't ship, fix as needed), merge into `master`, then merge the same changes back into `develop`. Merging into `master` triggers tagging — either as a manual step or via a follow-up workflow step that tags on merge:

```sh
git checkout master
git pull
git tag -a v0.3.0 -m "Release 0.3.0"
git push origin v0.3.0
```

The tag push triggers the release CI workflow (below), which builds, publishes to crates.io, generates the changelog scoped to that tag, and attaches it to the GitHub Release.

### `prepare-release.yaml`

```yaml
name: Prepare Release

on:
  workflow_dispatch:

jobs:
  prepare:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # full history required for git-cliff

      - name: Install git-cliff
        uses: taiki-e/install-action@git-cliff

      - name: Install cargo-edit
        uses: taiki-e/install-action@cargo-edit

      - name: Determine next version
        id: version
        run: |
          NEXT_VERSION=$(git-cliff --bumped-version)
          echo "version=${NEXT_VERSION#v}" >> "$GITHUB_OUTPUT"

      - name: Bump Cargo.toml
        run: cargo set-version ${{ steps.version.outputs.version }}

      - name: Update changelog
        run: git-cliff --tag v${{ steps.version.outputs.version }} --unreleased --prepend CHANGELOG.md

      - name: Open release PR
        uses: peter-evans/create-pull-request@v6
        with:
          branch: release/${{ steps.version.outputs.version }}
          base: master
          title: "Release ${{ steps.version.outputs.version }}"
          commit-message: "chore(release): ${{ steps.version.outputs.version }}"
          body: "Automated release PR. Review the changelog and Cargo.toml version before merging."
```

## Hotfixes

For an urgent fix to what's currently in production:

```sh
git checkout master
git pull
git checkout -b hotfix/fix-panic-on-empty-input
# ... fix, bump patch version, commit ...
```

PR into `master`, merge, tag (e.g. `v0.3.1`), which triggers the same release workflow. Then PR the same branch into `develop` so the fix isn't lost on the next regular release.

## CI: on every PR and push to `develop`

`.github/workflows/ci.yml` — build, test, lint. Fails fast, keeps `develop` trustworthy.

```yaml
name: CI

on:
  pull_request:
  push:
    branches: [develop]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable
        with:
          components: rustfmt, clippy

      - uses: Swatinem/rust-cache@v2

      - name: Check formatting
        run: cargo fmt --check

      - name: Clippy
        run: cargo clippy --all-targets --all-features -- -D warnings

      - name: Test
        run: cargo test --all-features
```

## CI: release, triggered by a version tag

`.github/workflows/release.yml` — runs only when a `v*` tag is pushed to `master`. Publishes to crates.io and creates the GitHub Release with the changelog for that specific tag attached as the release notes.

```yaml
name: Release

on:
  push:
    tags:
      - 'v*'

jobs:
  publish:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0  # full history required for git-cliff

      - name: Install Rust
        uses: dtolnay/rust-toolchain@stable

      - uses: Swatinem/rust-cache@v2

      - name: Install git-cliff
        uses: taiki-e/install-action@git-cliff

      - name: Test
        run: cargo test --all-features

      - name: Publish to crates.io
        run: cargo publish --token ${{ secrets.CARGO_REGISTRY_TOKEN }}

      - name: Generate changelog for this tag
        run: git-cliff --current --strip header -o RELEASE_NOTES.md

      - name: Create GitHub Release
        uses: softprops/action-gh-release@v2
        with:
          body_path: RELEASE_NOTES.md
```

Notes:
- `CARGO_REGISTRY_TOKEN` is a repo secret pointing at your crates.io API token.
- `git-cliff --current` extracts just the section for the tag that triggered the workflow (rather than the full changelog history), which is what `--body-path` attaches to the release.
- Since `CHANGELOG.md` was already updated by the `prepare-release` workflow before this tag was created, this step just re-derives the same section for the release notes — it doesn't regenerate the changelog file itself.
- Restrict who can push tags to `master` in branch protection, so a tag pushed from the wrong branch can't trigger a release.

## Summary of triggers

| Event | Branch | CI does |
|---|---|---|
| PR opened/updated | any → `develop` | fmt, clippy, test |
| Push | `develop` | fmt, clippy, test |
| Manual trigger | `develop` | git-cliff bumps version, updates changelog, opens release PR to `master` |
| Tag push (`v*`) | `master` | test, `cargo publish`, generate scoped changelog, GitHub Release |

Everything on `develop` is validated continuously; nothing reaches `crates.io` or GitHub Releases without going through `master` and a tag. The version number and changelog are both derived from the same Conventional Commits history, so they can't drift out of sync with each other.
