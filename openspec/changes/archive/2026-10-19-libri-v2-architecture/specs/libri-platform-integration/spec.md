## ADDED Requirements

### Requirement: Platform-specific behavior sits behind one abstraction

All operating-system-specific file and shell behavior SHALL be reached through a single platform
abstraction in the library core, and SHALL NOT appear as conditional compilation in view code.

#### Scenario: Views contain no platform branches

- **WHEN** a view needs platform-specific behavior
- **THEN** it SHALL call the platform abstraction rather than compile a per-platform branch of its own

#### Scenario: Building for each target

- **WHEN** the application is built for macOS, Windows, or Linux
- **THEN** only that platform's implementation SHALL be compiled, and the build SHALL succeed on all three

### Requirement: The platform reports its capabilities

The platform abstraction SHALL report which operations it supports on the running system.

#### Scenario: Unsupported affordances are hidden

- **WHEN** the running platform does not support an operation
- **THEN** the UI SHALL omit the control for that operation rather than show one that fails

#### Scenario: Supported affordances are offered

- **WHEN** the running platform supports an operation
- **THEN** the UI SHALL offer the control for it

### Requirement: File state distinguishes placeholders from present files

The platform abstraction SHALL report whether a file is fully present, a cloud placeholder not yet
materialized, in the process of downloading, or missing.

#### Scenario: Offloaded file is not reported as missing

- **WHEN** a downloaded file has been offloaded by the operating system, leaving a placeholder
- **THEN** the item SHALL be reported as a placeholder and SHALL NOT be reported as missing or
  not-downloaded

#### Scenario: Materializing before opening

- **WHEN** the user opens an item whose file is a placeholder
- **THEN** the application SHALL request materialization and wait for it before launching the opener

### Requirement: The index is authoritative for tags

Tags SHALL be stored in the library index, and SHALL be projected to operating-system metadata only where
the platform supports it.

#### Scenario: Tagging on a platform without file-system tags

- **WHEN** the user tags an item on a platform with no file-system tag support
- **THEN** the tag SHALL be stored in the index and SHALL remain after a restart

#### Scenario: Reconciling external tag edits

- **WHEN** tags were changed outside the application and the platform supports reading them back
- **THEN** the application SHALL reconcile those changes into the index on next launch
