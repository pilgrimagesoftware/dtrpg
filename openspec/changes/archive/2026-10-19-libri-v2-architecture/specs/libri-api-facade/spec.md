## ADDED Requirements

### Requirement: The library core builds without a UI framework

The crate holding library domain logic, persistence, and service traits SHALL NOT depend on any UI
framework, and SHALL compile and run in a process that creates no window.

#### Scenario: Core compiles on its own

- **WHEN** the library core crate is built on its own
- **THEN** the build SHALL succeed with no UI-framework crate in its dependency graph

#### Scenario: Headless binary reaches library state

- **WHEN** a binary that links only the library core queries the library
- **THEN** it SHALL receive library data without initializing a window, an event loop, or a UI context

### Requirement: A single facade is the only public entry to library state

The library core SHALL expose one command and query surface, and all other library modules SHALL be
unreachable from outside the crate.

#### Scenario: Callers outside the core use the facade

- **WHEN** a crate outside the library core reads or mutates library state
- **THEN** it SHALL do so through the facade surface

#### Scenario: Bypassing the facade fails to compile

- **WHEN** code outside the library core references a library module other than the facade
- **THEN** the build SHALL fail

### Requirement: The desktop UI and the agent server share one implementation

Every library operation offered to an agent SHALL be served by the same facade call the desktop UI uses
for that operation.

#### Scenario: Equivalent results across callers

- **WHEN** the desktop UI and the agent server each request the same query with the same arguments
- **THEN** both SHALL receive the same result, computed by the same code path

### Requirement: The UI crate performs no direct network access

The UI crate SHALL NOT issue network requests directly, and SHALL obtain all remote data through a core
service.

#### Scenario: Thumbnail and avatar fetches go through a service

- **WHEN** the UI needs a cover thumbnail or a profile avatar
- **THEN** the request SHALL be issued by a core service that can be replaced with a test double

### Requirement: One async runtime serves the process

The application SHALL construct at most one async runtime per process and SHALL share it across services.

#### Scenario: Constructing several services

- **WHEN** more than one service is constructed during a single run
- **THEN** no additional async runtime SHALL be created
