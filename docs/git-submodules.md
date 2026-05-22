# Git Submodules

- **Meta-repository Pattern**: This is a top-level organizational repository. Actual development happens in the
  submodules.
- **Language-Specific SDKs**: Each language SDK (Go, Python, Rust, Swift) is maintained as a separate repository,
  allowing independent versioning and release cycles.
- **Shared API Documentation**: The `dtrpg-sdk/api` submodule contains the source of truth for API specifications
  used across all SDK implementations.
- **Nested Submodules**: Both `dtrpg-sdk` and `dtrpg-app` are meta-repositories themselves containing their own
  submodules. Use `--recursive` flags when appropriate.

## Initial Setup

```bash
# Clone with all nested submodules
git clone --recursive git@github.com:pilgrimagesoftware/dtrpg.git

# Or initialize submodules after cloning
git submodule update --init --recursive
```

## Updating Submodules

```bash
# Update all submodules to latest commits on their tracked branches
git submodule update --remote --merge

# Update specific submodule
git submodule update --remote --merge dtrpg-sdk

# Update nested submodules within dtrpg-sdk
cd dtrpg-sdk && git submodule update --remote --merge
```

## Checking Submodule Status

```bash
# Check status of direct submodules
git submodule status

# Check nested submodules
cd dtrpg-sdk && git submodule status
cd dtrpg-app && git submodule status
```

## Making Changes

When making changes to submodules:
1. Navigate into the submodule directory
2. Make changes and commit within the submodule
3. Push the submodule changes to its remote
4. Return to the parent repository and commit the updated submodule reference
5. Push the parent repository changes

```bash
cd dtrpg-sdk/swift
# Make changes, commit, push
git add . && git commit -m "Update swift SDK"
git push

cd /Users/paulyhedral/Code/DriveThruRPG/dtrpg
git add dtrpg-sdk
git commit -m "Update dtrpg-sdk submodule"
git push
```

## Common Issues

### Detached HEAD State

Submodules often end up in detached HEAD state. Before making changes, ensure you're on a branch:

```bash
cd <submodule-directory>
git checkout master  # or appropriate branch
```

### Submodule Not Initialized

If a submodule directory is empty or shows errors:

```bash
git submodule update --init --recursive
```
