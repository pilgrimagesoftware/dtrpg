#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
api_repo="$repo_root/dtrpg-api"
sdk_root="$repo_root/dtrpg-sdk"
swift_sdk="$sdk_root/swift"
rust_sdk="$sdk_root/rust"
remote_mode=false
remote_ref="origin/develop"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --remote)
      remote_mode=true
      if [[ $# -gt 1 && "$2" != --* ]]; then
        remote_ref="$2"
        shift
      fi
      ;;
    --help|-h)
      cat <<'EOF'
Usage:
  ./scripts/update-sdk-api-submodules.sh [--remote [origin/branch]]

Options:
  --remote           Align to the latest commit from a remote ref.
                     Defaults to origin/develop.
  --remote <ref>     Align to a specific remote ref (for example origin/master).
EOF
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
  shift
done

if [[ ! -e "$api_repo/.git" ]]; then
  echo "Missing API repository checkout at $api_repo" >&2
  exit 1
fi

if [[ "$remote_mode" == true ]]; then
  git -C "$api_repo" fetch origin --prune
  remote_branch="${remote_ref#origin/}"

  if git -C "$api_repo" show-ref --verify --quiet "refs/heads/$remote_branch"; then
    git -C "$api_repo" checkout "$remote_branch"
    git -C "$api_repo" merge --ff-only "$remote_ref"
  else
    git -C "$api_repo" checkout -b "$remote_branch" "$remote_ref"
  fi
fi

target_commit="$(git -C "$api_repo" rev-parse HEAD)"
target_short="$(git -C "$api_repo" rev-parse --short HEAD)"

git -C "$sdk_root" submodule update --init --recursive swift rust

for sdk in "$swift_sdk" "$rust_sdk"; do
  git -C "$sdk" submodule update --init --recursive API

  if ! git -C "$sdk/API" cat-file -e "${target_commit}^{commit}" 2>/dev/null; then
    git -C "$sdk/API" fetch --all --prune
  fi

  git -C "$sdk/API" checkout "$target_commit"
  git -C "$sdk" add API
done

echo "Aligned swift/API and rust/API to dtrpg-api commit $target_short"
