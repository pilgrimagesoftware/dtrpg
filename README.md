# dtrpg

Master repo for DriveThruRPG projects

---

## OpenSpec Note

Use the top-level repo for umbrella cross-repo changes, `dtrpg-api` for contract changes, and prefer `dtrpg-sdk/rust` as the language-specific SDK example path.

## OpenAPI Sync

`dtrpg-api/openapi.yaml` is the local source of truth for generated SDKs. Run:

```bash
./scripts/sync-openapi.sh
```

This validates that both SDK repositories use `dtrpg-api` as an `API` submodule and verifies `openapi.yaml` checksums.
