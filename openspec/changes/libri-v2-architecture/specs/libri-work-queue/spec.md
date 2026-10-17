## ADDED Requirements

### Requirement: One work queue serves all background concerns

Background work for thumbnail fetches, downloads, and on-disk verification SHALL be scheduled by a single
queue in the library core.

#### Scenario: Concerns share the queue

- **WHEN** thumbnail, download, and verification work are all pending
- **THEN** all of it SHALL be scheduled by the same queue with one set of concurrency accounting

#### Scenario: Queue runs without the UI

- **WHEN** background work is scheduled in a process with no window
- **THEN** it SHALL run to completion

### Requirement: The queue bounds concurrency and respects priority

The queue SHALL limit how many items run at once and SHALL run higher-priority work first.

#### Scenario: Concurrency limit is honored

- **WHEN** more work is queued than the configured concurrency limit
- **THEN** no more than the limit SHALL run at once and the remainder SHALL wait

#### Scenario: User-initiated work goes first

- **WHEN** a user-initiated download is queued while background thumbnail work is pending
- **THEN** the download SHALL be scheduled ahead of the thumbnail work

### Requirement: Queued work is cancellable and reports progress

The queue SHALL allow pending and running work to be cancelled, and SHALL report progress for work that
has a measurable size.

#### Scenario: Cancelling pending work

- **WHEN** the user cancels an operation that has not started
- **THEN** it SHALL be removed from the queue and SHALL NOT start

#### Scenario: Cancelling running work

- **WHEN** the user cancels an operation that is running
- **THEN** it SHALL stop and SHALL release its concurrency slot

#### Scenario: Progress reaches the activity panel

- **WHEN** a download is running
- **THEN** its progress SHALL be reported to the activity panel
