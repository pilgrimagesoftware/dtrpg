## ADDED Requirements

### Requirement: One work queue serves all background concerns

Background work for thumbnail fetches, downloads, and availability checks SHALL be scheduled by a
single queue in the library core. Verifying a selected item's files against the disk is local, quick,
and something the user is waiting on, so it is not queued.

#### Scenario: Concerns share the queue

- **WHEN** thumbnail, download, and availability-check work are all pending
- **THEN** all of it SHALL be scheduled by the same queue

#### Scenario: Queue runs without the UI

- **WHEN** background work is scheduled in a process with no window
- **THEN** it SHALL run to completion

#### Scenario: Disk verification is not held up

- **WHEN** the user selects an item whose files are verified against the disk while the queue is busy
- **THEN** the verification SHALL run at once and SHALL NOT wait for the queue

### Requirement: The queue bounds concurrency and respects priority

The queue SHALL limit how many items run at once and SHALL run higher-priority work first. Thumbnail
fetches and downloads SHALL count against one shared limit. Availability checks SHALL NOT count
against it; they SHALL run in a lane of their own, one at a time.

#### Scenario: Concurrency limit is honored

- **WHEN** more thumbnail and download work is queued than the configured concurrency limit
- **THEN** no more than the limit SHALL run at once and the remainder SHALL wait

#### Scenario: Thumbnails and downloads share the limit

- **WHEN** some thumbnail fetches and some downloads are running
- **THEN** their total SHALL NOT exceed the limit

#### Scenario: User-initiated work goes first

- **WHEN** a user-initiated download is queued while background thumbnail work is pending
- **THEN** the download SHALL be scheduled ahead of the thumbnail work

#### Scenario: Equal priorities are served in order

- **WHEN** several jobs of the same priority are waiting
- **THEN** they SHALL start in the order they were submitted

#### Scenario: Running work is not interrupted

- **WHEN** user-initiated work is queued while every slot is occupied
- **THEN** the work already running SHALL continue, and the new work SHALL start when a slot frees

#### Scenario: Checks run one at a time

- **WHEN** several availability checks are queued
- **THEN** at most one SHALL run at once

#### Scenario: Checks are not held up by full slots

- **WHEN** every slot of the shared limit is occupied and an availability check is queued
- **THEN** the check SHALL start without waiting for a slot of the shared limit

#### Scenario: The limit can change while work is queued

- **WHEN** the concurrency limit is raised while work is waiting
- **THEN** waiting work SHALL start up to the new limit without interrupting what is running

### Requirement: Queued work is cancellable and reports progress

The queue SHALL allow pending and running work to be cancelled, and SHALL report to whoever submitted
it when each job starts, finishes, retries, and, for work that has a measurable size, how far along it
is.

#### Scenario: Cancelling pending work

- **WHEN** the user cancels an operation that has not started
- **THEN** it SHALL be removed from the queue and SHALL NOT start

#### Scenario: Cancelling running work

- **WHEN** the user cancels an operation that is running
- **THEN** it SHALL stop and SHALL release its concurrency slot

#### Scenario: A failed job frees its slot

- **WHEN** a job returns an error or panics
- **THEN** it SHALL be reported as failed and its slot SHALL be free for the next job

#### Scenario: Progress reaches the activity panel

- **WHEN** a download is running and the server has said how large the file is
- **THEN** its progress SHALL be reported to the activity panel as the fraction received

#### Scenario: Progress with an unknown total

- **WHEN** a download is running and the server has not said how large the file is
- **THEN** the activity panel SHALL show it as in progress without a fraction

#### Scenario: Retries are reported

- **WHEN** a running job fails in a retryable way and will try again
- **THEN** the queue SHALL report the attempt number and the wait before it
