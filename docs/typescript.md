# TypeScript

## Stack

- Node.js 22+ (active LTS), TypeScript 5.x, strict mode on.
- Package manager: npm (matches the npm publishing target for `dtrpg-sdk.js`).
- Runtime HTTP: native `fetch` (Node 22+ has it built in) — no axios/request unless a genuine gap forces it.
- Tests: `vitest`. Lint/format: `eslint` + `prettier`.
- Build: `tsc` for library output (declaration files + ESM/CJS dual build via `tsup` if dual-target publishing is
  needed).

## Focus Areas

- Typed request/response models generated or hand-maintained from `dtrpg-api`'s `openapi.yaml`.
- Async/await throughout — no callback-style APIs, no unhandled promise rejections.
- Auth/session lifecycle (token storage, refresh, expiry) mirroring the Go/Rust/Swift SDKs' behavior.
- Library client operations: orders, product lists, download preparation.

## Core Rules

- `strict: true` in `tsconfig.json` (`noImplicitAny`, `strictNullChecks`, etc.) — no relaxing strict flags project-wide.
- Public API surface uses explicit exported types; no `any` in public signatures. Use `unknown` + narrowing at
  boundaries (HTTP responses, JSON parsing) instead.
- Errors: a typed error hierarchy (e.g. `DtrpgApiError extends Error` with a `code` field), not bare `throw new
  Error(string)`. Callers can `instanceof`-check or switch on `code`.
- No default exports from library entry points — named exports only, for predictable tree-shaking and refactor-safe
  imports.
- Prefer composition over class hierarchies; use classes only where they model genuine stateful resources (e.g. an
  authenticated client instance holding a token).

## Style Rules

- Formatting and lint rules enforced by `eslint` + `prettier`; CI runs both and fails on any violation. No inline
  `eslint-disable` without a comment explaining why.
- Naming: `camelCase` for variables/functions, `PascalCase` for types/interfaces/classes, `SCREAMING_SNAKE_CASE` for
  module-level constants. No Hungarian notation.
- Every exported function/class/type carries a TSDoc (`/** ... */`) comment with a one-sentence summary. Functions
  that can throw document `@throws`.
- Imports grouped: Node builtins, external packages, local — enforced by `eslint-plugin-import`'s `order` rule.

## Testing Rules

- Unit tests colocated as `*.test.ts` next to the source file, or under `tests/` for integration-style tests that
  exercise multiple modules together.
- Mock the HTTP layer at the `fetch` boundary (e.g. `msw`) for unit tests — never mock at the client-class level,
  which hides serialization/deserialization bugs.
- `vitest run --coverage` in CI; coverage thresholds enforced per this project's global 80%-for-new-code rule.
- Async tests use `async`/`await` directly — no `done()` callback style.

## Security Invariants

- Never log tokens, credentials, or full request/response bodies containing auth headers. Redact at the boundary.
- Validate all external input (API responses, environment variables) before use — a malformed API response must
  produce a typed error, not an unhandled exception or silent `undefined` propagation.
- No `eval`, `Function(...)` construction, or dynamic `require`/`import` of user-controlled strings.
- Dependencies audited via `npm audit` in CI; known high/critical advisories block merges until patched or
  explicitly waived with a documented reason.

## Workflow Rules

- `npm run lint` and `npm run typecheck` before every commit; CI runs both plus `npm test`.
- `npm run build` must succeed with zero `tsc` errors before a release tag is cut.
- `npm audit` and dependency updates are a deliberate action with their own PR — never bundled with feature work.
- Publish target: npm, scoped under the org's npm scope (finalized in the `dtrpg-sdk/js` child change).

## Common Commands

```bash
npm ci
npm run lint
npm run typecheck
npm test
npm run build
npm audit
```
