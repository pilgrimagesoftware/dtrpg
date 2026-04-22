## Context

DriveThruRPG auth/session work crosses repository boundaries by design. The API defines token issuance and error behavior, SDKs adapt those semantics into language-specific clients, and applications decide how session expiry and recovery affect user flow. The new OpenSpec structure gives each layer a home, but the top-level repo still needs a concrete example showing when an umbrella change belongs there.

## Goals / Non-Goals

**Goals:**
- Show that the top-level `dtrpg` repo owns the coordinating proposal for a multi-repo auth/session initiative.
- Define a repeatable pattern for sequencing child work in `dtrpg-api`, `dtrpg-sdk`, and `dtrpg-app`.
- Make dependency order explicit so future auth/session changes are not planned independently and merged in the wrong order.

**Non-Goals:**
- Define the HTTP token contract itself
- Define language-specific SDK auth implementation details
- Define macOS or Rust desktop session UX in detail

## Decisions

Use the top-level meta-repository as the umbrella owner for auth/session coordination.
Rationale: the initiative is not complete until multiple child repositories move together, so no single child repo can fully own the planning artifact.

Introduce a dedicated `auth-session-rollout` capability instead of burying all auth coordination rules under a generic compatibility spec.
Rationale: auth/session work is a recurring cross-repo concern and deserves a discoverable home.

Model downstream work as child changes in the owning repos rather than copying implementation details into the top-level proposal.
Rationale: this keeps the umbrella change focused on sequencing, ownership, and scope while preserving local ownership of API, SDK, and app behavior.

## Risks / Trade-offs

- More artifacts to maintain across repos -> Mitigation: keep the umbrella change narrow and delegate implementation specifics downward.
- Auth work may still start in a child repo first -> Mitigation: use the umbrella proposal as the required coordination entry point for cross-repo auth/session initiatives.
- The initial example may need refinement once a real auth project starts -> Mitigation: treat this as a pattern-setting change and evolve the specs when the first concrete child proposals are created.
