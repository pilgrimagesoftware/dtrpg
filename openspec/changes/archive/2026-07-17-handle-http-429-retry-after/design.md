## Context

The DriveThruRPG API can respond with HTTP 429 and, per standard HTTP semantics, may include a `Retry-After` header telling the client exactly how long to wait. Today that header is not captured anywhere in the stack: `dtrpg-sdk/rust`'s `ClientError::ApiError`/`DecodeFailed` variants carry only a raw `status: u16`, and `dtrpg-app/rust`'s `retry_with_backoff` retries every `Network`-kind failure (429 included, since it currently falls into that generic bucket) on the same fixed exponential-backoff schedule regardless of what the server actually asked for. Honoring `Retry-After` correctly requires the SDK to read the header before the underlying `reqwest` error is converted (headers are not available on `reqwest::Error` after `.error_for_status()`), so the app cannot implement this alone.

## Goals / Non-Goals

**Goals:**
- Show that a two-repo dependent change (SDK behavior a prerequisite for app behavior) is coordinated from the top-level `dtrpg` repo, following the same pattern established by `auth-session-rollout` for auth/session work.
- Define the dependency order: SDK exposes `Retry-After` before the app can consume it.
- Keep this proposal's decisions scoped to sequencing and ownership; implementation details (exact `ClientError` shape, exact retry-loop integration) belong in the child repos' own design docs.

**Non-Goals:**
- Define the exact `ClientError` variant/field shape for carrying `Retry-After` (SDK child change's decision).
- Define exactly how `retry_with_backoff` or its call sites change to wait a server-specified duration (app child change's decision).
- Handle rate limiting for the direct file-download `reqwest::blocking::get` call in `download.rs` differently from SDK-mediated API calls — both are in the app child change's scope, but this document does not dictate whether they share one code path.
- Retrying other 4xx/5xx status codes differently — this initiative is scoped to 429 specifically.

## Decisions

**Sequence the SDK change before the app change.** The app cannot honor a header the SDK doesn't expose, so `dtrpg-sdk/rust` is the upstream dependency. This mirrors the existing `cross-repo-compatibility` capability's general "a repository reference is updated only after the dependent behavior exists upstream" rule — no new capability spec is needed, only child proposals that follow that existing sequencing requirement.

**No new umbrella capability, unlike `auth-session-rollout`.** That capability was introduced because auth/session coordination is a *recurring* concern likely to need this pattern repeatedly. A single SDK-exposes/app-consumes header dependency is a narrower, one-off sequencing fact, adequately captured by this proposal and design doc without a dedicated spec capability.

**Model downstream work as child changes in the owning repos.** `dtrpg-sdk/rust/openspec/changes/expose-retry-after-header` (or equivalent name) owns the SDK-side contract; `dtrpg-app/rust/openspec/changes/handle-http-429-retry-after` (same name, child repo) owns the app-side consumption. Neither child proposal is written by this umbrella change — this document only records that they must exist and in what order.

## Rollout Order

1. `dtrpg-sdk/rust/openspec/changes/expose-retry-after-header` captures the `Retry-After` response header on HTTP 429 and exposes it through `ClientError` (or a new variant) so callers can read a `Duration`/`Option<Duration>`.
2. `dtrpg-app/rust/openspec/changes/handle-http-429-retry-after` adapts the SDK-exposed value into app-visible retry behavior: a distinct `RateLimited` error kind, and `retry_with_backoff` call sites (plus the direct download HTTP call) waiting the server-specified duration when present, falling back to the existing exponential backoff otherwise.
3. The top-level meta-repository advances the `dtrpg-sdk`/`dtrpg-app` submodule pointers only after both child changes are implemented and validated in their owning repositories.

## Risks / Trade-offs

- [SDK change ships without the app ever consuming it] → Mitigation: this design records both child changes as required before the umbrella considers the initiative complete; the app's `retry_with_backoff` already has a safe fallback (its current exponential backoff) if the SDK's new field is ever `None`, so partial rollout degrades gracefully rather than breaking.
- [App change starts before the SDK change lands, blocking on an API that doesn't exist yet] → Mitigation: this rollout order is the enforced sequencing; the app child proposal should not begin implementation until the SDK's `Retry-After` exposure is merged and released.
- [`Retry-After` can be specified as either a delay-in-seconds or an HTTP-date per RFC 9110] → Left to the SDK child change to resolve; noted here so it isn't missed when that design doc is written.
