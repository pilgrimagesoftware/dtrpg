## Context

The DriveThruRPG API already documents library endpoints that let authenticated users browse their purchased products and named product collections:

- `GET /order_products` — list user's purchased products (library items)
- `GET /order_products/{id}` — get a single product detail
- `GET /order_products/{id}/prepare` — prepare a file download
- `GET /product_lists` — list user's named product collections
- `GET /product_list_items` — list items in a specific product collection

These endpoints exist in `openapi.yaml` but no child repository has formalized ownership of their contracts, and no SDK has defined typed access to them. The umbrella change ensures the API contract work is complete and validated before SDK implementation work begins, preventing out-of-order merges that could introduce breaking changes downstream.

## Goals / Non-Goals

**Goals:**
- Establish the top-level `dtrpg` repo as the umbrella owner for the library API cross-repo initiative.
- Define explicit sequencing between the API contract change and the Rust SDK implementation change.
- Name the child repositories expected to carry implementation-level proposals so that work can be planned and tracked independently.

**Non-Goals:**
- Define the HTTP contract for library endpoints (owned by `dtrpg-api`)
- Define Rust types, models, or SDK client behavior for the library API (owned by `dtrpg-sdk/rust`)
- Define application UX for library browsing in any desktop app (out of scope for this change)

## Decisions

Use the top-level meta-repository as the umbrella owner for library API coordination.
Rationale: the initiative is not complete until the API contract and at least one SDK move together in validated sequence, so no single child repo can fully own the planning artifact.

Introduce a dedicated `library-api-rollout` capability instead of extending the existing `auth-session-rollout` capability.
Rationale: library access is a functionally distinct concern from authentication, has its own endpoint group, and will have its own recurring cross-repo maintenance surface.

Model downstream work as child changes in the owning repos rather than embedding implementation details in the top-level proposal.
Rationale: this keeps the umbrella change focused on sequencing, ownership, and scope while preserving local ownership of API contract and SDK behavior decisions.

## Rollout Order

1. `dtrpg-api/openspec/changes/define-library-api-contract` formalizes library endpoint and resource contracts, including response schemas, pagination conventions, and error semantics.
2. `dtrpg-sdk/rust/openspec/changes/define-rust-library-behavior` adapts the API-defined contracts into Rust types, deserialization behavior, and HTTP client method signatures.
3. Other language SDK changes (Go, Python, Swift) follow the Rust SDK change as the established pattern.
4. The top-level meta-repository advances child repository submodule pointers only after the dependent child changes are present and validated in their owning repositories.

## Risks / Trade-offs

- More artifacts to maintain across repos → Mitigation: keep the umbrella change narrow and delegate all implementation specifics to child proposals.
- Library API work could start independently in child repos before the umbrella change is in place → Mitigation: use this umbrella proposal as the required coordination entry point for any cross-repo library API initiative and reference it in child proposals.
