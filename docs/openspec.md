# OpenSpec

OpenSpec is initialized in the top-level repo and in selected child repositories.

- Use this repository (`dtrpg`) for umbrella changes that coordinate work across multiple repositories.
- Use `dtrpg-api` for API contract changes that SDKs and applications depend on.
- Prefer `dtrpg-sdk/rust` as the language-specific downstream example when following an existing OpenSpec pattern.
- Keep `dtrpg-sdk/swift` in place as an additional reference, but prefer Rust for new example-driven SDK OpenSpec work.

Current preferred example chain:

- Top-level umbrella: `dtrpg/openspec/changes/improve-auth-session-lifecycle`
- API contract child: `dtrpg-api/openspec/changes/define-auth-session-contract`
- Preferred SDK child: `dtrpg-sdk/rust/openspec/changes/define-rust-auth-session-behavior`
