## 1. Umbrella Spec

- [ ] 1.1 Add the `auth-session-rollout` delta spec in the top-level `dtrpg` repo
- [ ] 1.2 Update `cross-repo-compatibility` to require explicit auth/session dependency sequencing

## 2. Child Proposal Planning

- [ ] 2.1 Create a child proposal in `dtrpg-api` for token/session contract changes
- [ ] 2.2 Create a child proposal in `dtrpg-sdk` or a language SDK repo for auth lifecycle behavior
- [ ] 2.3 Create a child proposal in `dtrpg-app` or an app implementation repo for session expiry and recovery UX

## 3. Rollout Coordination

- [ ] 3.1 Record the required implementation order across API, SDK, and app repos
- [ ] 3.2 Confirm that the meta-repo submodule updates will only advance once the dependent child repos are ready
