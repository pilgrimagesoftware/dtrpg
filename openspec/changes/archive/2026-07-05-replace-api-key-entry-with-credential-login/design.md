## Context

The login window currently asks for a raw DriveThruRPG API key
(`openspec/specs/auth-login-view`). There is no page in the DriveThruRPG website UI that
shows a user their API key, so the field can only be filled by a user who already has a
key from some other source (support ticket, prior manual extraction). `dtrpg-api/LOGIN.md`
documents the two website endpoints DriveThruRPG's own login page uses to turn an
email/password pair into an application key:

1. `POST https://www.drivethrurpg.com/validate_login_credentials.php` — validates
   credentials, returns a JSON-encoded array (not an object).
2. `POST https://www.drivethrurpg.com/create_account_app.php` — same request shape,
   returns `{"status": "success", "message": {"key": "<application-key>"}}`.

These endpoints are on `www.drivethrurpg.com`, not `api.drivethrurpg.com`. They are
website form endpoints, not part of the `dtrpg-api` OpenAPI contract, and return
inconsistent body shapes (a bare JSON array vs. an object) rather than a uniform API
envelope.

This affects both desktop app implementations (`dtrpg-app/rust`, `dtrpg-app/swift`) and,
for the Rust app, the shared `dtrpg-sdk/rust` crate that already owns the `auth_key`
exchange in `auth_client.rs`.

## Goals / Non-Goals

**Goals:**
- Let a user sign in with the email and password they already use on the DriveThruRPG
  website.
- Keep the website credential exchange behind an SDK function so app code issues one
  logical "log in" call instead of orchestrating two HTTP requests.
- Store email alongside the application key so the login window can show which account
  is signed in and so a stored key can be tied back to an email for support/debugging.

**Non-Goals:**
- Do not add the website login endpoints to `dtrpg-api`'s `openapi.yaml`. That spec is
  scoped to `api.drivethrurpg.com`; these are a different host with a different contract
  shape.
- Do not attempt SSO, OAuth, or a browser-based login flow. This mirrors the existing
  website form login only.
- Do not change the existing `auth_key` → JWT exchange (`auth_client::authenticate`); it
  continues to consume an application key exactly as it does today.

## Decisions

- **New SDK module, not a change to `auth_client.rs`**: add
  `dtrpg-sdk/rust/src/credential_login.rs` (name TBD at implementation time) with a single
  `login_with_credentials(email, password, base_url) -> Result<String, ClientError>`
  (returns the application key). Kept separate because it targets a different host and a
  non-uniform response shape; mixing it into `auth_client.rs` would blur the
  `api.drivethrurpg.com`-only scope documented there.
  - Alternative considered: fold both website calls and the `auth_key` call into one
    "login" SDK entry point. Rejected — callers (app `LoginController`) need to
    distinguish "bad credentials" from "application key rejected", and a single call
    would collapse two independently-failing steps into one error type.
- **Sequential two-request implementation, first response is a status gate**: call
  `validate_login_credentials.php` first; only call `create_account_app.php` if the first
  call's response indicates valid credentials. Both requests use the same
  multipart/form-data body per `LOGIN.md`.
  - Alternative considered: call `create_account_app.php` directly, since it accepts the
    same body and DriveThruRPG's server presumably validates credentials anyway.
    Rejected — the two-step flow matches the documented website behavior exactly and
    keeps validation and errors that are attributable to bad credentials, distinct from
    key retrieval.
- **Credential store gains an email field, not a new store type**: extend the stored
  credential to carry `email` alongside the existing `secret` (application key), still
  under the single `com.pilgrimagesoftware.dtrpg` / `api-key` keychain entry. Store email
  as a second field on the same entry's payload (e.g. JSON-encoded `{email, key}` as the
  keychain secret, or a second keychain account key) rather than a new top-level
  credential kind.
  - Alternative considered: add a fully separate keychain entry for email. Rejected —
    email is not secret; storing it alongside the key in the same entry avoids doubling
    keychain round-trips and keeps "one login = one keychain write" semantics.
- **Login window fields**: replace the single API-key text field with email and password
  fields per the existing "Login window presents API key input" requirement, keeping the
  same disabled/loading/error states already specified in `auth-login-view`.

## Risks / Trade-offs

- [Website endpoints are not versioned or officially supported like `api.drivethrurpg.com`,
  so DriveThruRPG could change them without notice] → Isolate them behind the new SDK
  module so a breakage is a single-file fix, and keep `LOGIN.md` as the source of truth to
  diff against.
- [`validate_login_credentials.php` returns a bare JSON array (`["password", true,
  "Locked", true]`) instead of a named object, so field meaning is positional and
  fragile] → Document the array's field order in code comments next to the deserializer
  and add a unit test fixture from the exact example in `LOGIN.md`.
- [Existing users have a keychain entry containing only an application key, with no
  email] → Treat a legacy entry (no email field) as still valid for silent
  reauthentication; only require a fresh email/password login when the entry is entirely
  absent or the application key is rejected by `auth_key`.
- [Two sequential website calls plus the existing `auth_key` call means three network
  round-trips to complete one login] → Acceptable for an interactive login action; no
  latency budget currently exists for this path.

## Migration Plan

1. Add the SDK credential exchange function and unit tests (fixture-based, no live network
   calls).
2. Update `dtrpg-app/rust` `LoginController` and login view to collect email/password and
   call the new SDK function before the existing `authenticate` call.
3. Extend `KeyringCredentialStore` (or its call sites) to persist email with the
   application key; keep read compatibility with legacy key-only entries.
4. Repeat steps 2-3 for `dtrpg-app/swift` against the same `LOGIN.md` contract.
5. No data migration script needed — legacy entries keep working until the user's key is
   next rejected, at which point they see the normal re-login flow with the new fields.

## Open Questions

- Should the stored email be shown read-only in the login window when a legacy/expired
  application key is present, to save the user re-typing it? Left to
  `dtrpg-app`-level design during implementation.
- Should `validate_login_credentials.php`'s positional array response be given a typed
  struct now, or left as indexed access until DriveThruRPG documents field names? Leaning
  toward a small typed struct with named accessors for readability, decided at
  implementation time.
