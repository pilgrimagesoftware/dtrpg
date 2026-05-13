## Why

User library access is split across repository boundaries by design. The API repository owns the endpoint contracts for browsing purchased products and named product collections; the SDK repositories own the typed models and HTTP client behavior that consumers depend on. No umbrella change exists to coordinate this work, which makes it easy for API contract and SDK implementation changes to proceed independently and merge in the wrong order.

## What Changes

- Introduce a top-level capability that defines how cross-repo library API initiatives are coordinated.
- Define the dependency order between API contract changes and SDK implementation changes for library API work.
- Record the child repositories expected to carry implementation-level proposals for endpoint contract ownership and Rust SDK behavior.
- Clarify that cross-repo library API rollout planning belongs in the top-level meta-repository rather than any single implementation repository.
- Extend `cross-repo-compatibility` to capture library API dependency sequencing requirements.

## Capabilities

### New Capabilities
- `library-api-rollout`: Defines how umbrella library API initiatives are scoped, sequenced, and delegated across the repo family.

### Modified Capabilities
- `cross-repo-compatibility`: Extends compatibility planning to require that library API contract changes are finalized before SDK implementation changes treat them as stable dependencies.

## Impact

- `dtrpg/openspec`: New umbrella capability and rollout guidance
- `dtrpg-api`: Needs a child change (`define-library-api-contract`) to formalize ownership of library endpoint and resource contracts
- `dtrpg-sdk/rust`: Needs a child change (`define-rust-library-behavior`) to implement Rust-facing types and HTTP client behavior for the library API
