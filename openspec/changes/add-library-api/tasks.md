## 1. Umbrella Spec

- [x] 1.1 Add the `library-api-rollout` delta spec in the top-level `dtrpg` repo
- [x] 1.2 Update `cross-repo-compatibility` to require explicit library API dependency sequencing

## 2. Child Proposal Planning

- [ ] 2.1 Create a child proposal in `dtrpg-api` for library endpoint and resource contract changes (`define-library-api-contract`)
- [ ] 2.2 Create a child proposal in `dtrpg-sdk/rust` for library API types and HTTP client behavior (`define-rust-library-behavior`)

## 3. Rollout Coordination

- [ ] 3.1 Record the required implementation order across API and SDK repos
- [ ] 3.2 Confirm that the meta-repo submodule updates will only advance once the dependent child repos are ready
