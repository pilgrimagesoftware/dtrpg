# GitHub Actions 

## Style

`run` blocks should be formatted as follows:

```bash
run: |
  command
  command
  etc
```

## Versioning

- Always pin versions of an action, to avoid supply-chain attacks.

## Do NOT

- Use `latest` as a version.
