## ADDED Requirements

### Requirement: Standalone crate formats elapsed seconds as a short duration string
The system SHALL provide a standalone, published Rust crate exposing a public function that formats a `u64` seconds count as a short human-readable duration string ("Xs" for under 60 seconds, "Xm Ys" for 60 seconds or more), independent of any DriveThruRPG-specific type or UI framework.

#### Scenario: Formatting sub-minute duration
- **WHEN** the function is called with `secs = 42`
- **THEN** it returns a string representing "42 seconds" in the active locale's short form

#### Scenario: Formatting minute-and-second duration
- **WHEN** the function is called with `secs = 125`
- **THEN** it returns a string representing "2 minutes 5 seconds" in the active locale's short form

### Requirement: Locale-aware output via rust_i18n
The crate SHALL use `rust_i18n` to resolve the active process locale and render unit labels accordingly, shipping built-in translations for at least `en`, `de`, and `fr`.

#### Scenario: English locale active
- **WHEN** `rust_i18n::locale()` is `en` and the function is called with `secs = 42`
- **THEN** the returned string uses English unit labels (e.g. "42s")

#### Scenario: Non-English locale active
- **WHEN** `rust_i18n::locale()` is `de` or `fr` and the function is called with `secs = 125`
- **THEN** the returned string uses the corresponding locale's unit labels instead of English

### Requirement: Customizable unit labels for non-rust_i18n consumers
The crate SHALL expose a lower-level function that accepts caller-supplied unit labels, so consumers who do not use `rust_i18n` or who need custom wording can still use the duration-formatting logic.

#### Scenario: Caller supplies custom labels
- **WHEN** a caller invokes the lower-level function with `secs = 90` and custom labels for "minute" and "second"
- **THEN** the returned string uses the caller-supplied labels instead of the crate's built-in translations

### Requirement: Published as an independent open source crate
The system SHALL publish the crate to crates.io under its own name, with an OSI-approved license, a public repository, and CI covering build, test, `clippy`, and `fmt` checks, independent of the DriveThruRPG repositories' release process.

#### Scenario: Crate is installable from crates.io
- **WHEN** a Rust project adds the crate as a dependency by name and version from crates.io
- **THEN** the project builds successfully using only the published crate, without requiring access to any DriveThruRPG-internal repository
