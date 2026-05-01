#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source_spec="$repo_root/dtrpg-api/openapi.yaml"
swift_sdk="$repo_root/dtrpg-sdk/swift"
rust_sdk="$repo_root/dtrpg-sdk/rust"

if [[ ! -f "$source_spec" ]]; then
  echo "Missing source OpenAPI spec: $source_spec" >&2
  exit 1
fi

for sdk in "$swift_sdk" "$rust_sdk"; do
  git -C "$sdk" submodule update --init --recursive API
done

source_hash="$(shasum -a 256 "$source_spec" | awk '{print $1}')"
targets=(
  "$swift_sdk/API/openapi.yaml"
  "$rust_sdk/API/openapi.yaml"
)
for target in "${targets[@]}"; do
  if [[ ! -f "$target" ]]; then
    echo "Missing SDK OpenAPI file: $target" >&2
    exit 1
  fi
  target_hash="$(shasum -a 256 "$target" | awk '{print $1}')"
  if [[ "$target_hash" != "$source_hash" ]]; then
    echo "OpenAPI mismatch for $target" >&2
    exit 1
  fi
done

echo "OpenAPI submodules verified against dtrpg-api/openapi.yaml"
