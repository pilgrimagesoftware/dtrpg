## Why

HTTP 429 (Too Many Requests) responses from the DriveThruRPG API are currently treated as an undifferentiated network failure: the SDK's `ClientError` surfaces only a raw status code, and the Rust desktop app's retry logic (`retry_with_backoff`) retries with the same exponential-backoff schedule it uses for any other transient failure. This risks retrying faster than the server wants, prolonging the rate-limit window instead of resolving it. The fix requires both layers to move together: the SDK must capture and expose the `Retry-After` response header before the app can honor it, so this needs a coordinating umbrella change rather than starting independently in either child repo.

## What Changes

- Establish the required implementation order for honoring `Retry-After` on HTTP 429: the SDK layer must expose it before the app layer can consume it.
- Record the child repositories expected to carry the implementation-level proposals: `dtrpg-sdk/rust` (capture and expose `Retry-After`) and `dtrpg-app/rust` (wait the server-specified duration on 429 instead of blind exponential backoff).
- Clarify that this cross-repo sequencing decision belongs in the top-level meta-repository, consistent with how the existing auth/session rollout pattern (`auth-session-rollout`) established this for coordinated multi-repo work.

## Capabilities

### New Capabilities

_(none)_

### Modified Capabilities

- `cross-repo-compatibility`: adds a scenario for sequencing an SDK-then-app rollout where a shared-behavior change (here, exposing an HTTP response header) must land in the SDK before the app can depend on it — mirroring the existing auth/session rollout scenario already recorded there.

## Impact

- `dtrpg/openspec`: coordinating rollout guidance for this initiative (this proposal + design.md's Rollout Order).
- `dtrpg-sdk/rust`: will need a child change capturing the `Retry-After` header on HTTP 429 responses and exposing it via `ClientError` (or a new variant) so callers can read it.
- `dtrpg-app/rust`: will need a child change to classify 429 distinctly in its SDK error-mapping layer (`LibraryServiceErrorKind`) and to wait the SDK-exposed `Retry-After` duration (falling back to the existing exponential backoff when absent) in `retry_with_backoff` call sites and the direct file-download HTTP call.
