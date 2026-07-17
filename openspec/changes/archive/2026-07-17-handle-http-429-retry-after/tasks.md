## 1. Umbrella Spec

- [x] 1.1 Add the `cross-repo-compatibility` delta spec adding the
      "Sequencing an SDK-exposed HTTP behavior rollout" scenario in the
      top-level `dtrpg` repo

## 2. Child Proposal Planning

- [x] 2.1 Create a child proposal in `dtrpg-sdk/rust` to capture the
      `Retry-After` header on HTTP 429 responses and expose it via
      `ClientError` (or a new variant)
- [x] 2.2 Create a child proposal in `dtrpg-app/rust` to classify HTTP 429
      distinctly (`LibraryServiceErrorKind::RateLimited` or equivalent) and
      to wait the SDK-exposed `Retry-After` duration in `retry_with_backoff`
      call sites and the direct file-download HTTP call, falling back to
      the existing exponential backoff when the SDK exposes no value

## 3. Rollout Coordination

- [x] 3.1 Record the required implementation order: `dtrpg-sdk/rust` before
      `dtrpg-app/rust`
- [x] 3.2 Confirm the meta-repo submodule pointers advance only after both
      child repos have implemented and validated their respective changes
