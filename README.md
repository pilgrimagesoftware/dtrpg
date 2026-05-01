# dtrpg

Master repo for DriveThruRPG projects

---

## OpenSpec Note

Use the top-level repo for umbrella cross-repo changes, `dtrpg-api` for contract changes, and prefer `dtrpg-sdk/rust` as the language-specific SDK example path.

## OpenAPI Sync

`dtrpg-api/openapi.yaml` is the local source of truth for generated SDKs. Run:

```bash
./scripts/update-sdk-api-submodules.sh
./scripts/sync-openapi.sh
```

`update-sdk-api-submodules.sh` aligns both SDK `API` submodules to the current `dtrpg-api` commit.
Use `./scripts/update-sdk-api-submodules.sh --remote` to fast-forward `dtrpg-api` from `origin/develop` first, then align both SDK submodules.
`sync-openapi.sh` verifies `openapi.yaml` checksums after submodule alignment.
