## ADDED Requirements

### Requirement: Sidebar Collections header has an Add button
The sidebar Collections section header SHALL display an icon button that the user can activate to begin creating a new collection.

#### Scenario: Button is visible in Collections header
- **WHEN** the sidebar is rendered
- **THEN** the Collections section header contains a visually distinct add/plus button alongside the "Collections" label

#### Scenario: Button activates the creation dialog
- **WHEN** the user clicks the add button in the Collections header
- **THEN** a modal name-prompt dialog opens and focus moves to the name input field

### Requirement: Name-prompt dialog for new collection
The system SHALL present a modal dialog with a single text input for the collection name and two actions: Cancel and Create.

#### Scenario: Cancel dismisses the dialog
- **WHEN** the user opens the dialog and clicks Cancel (or presses Escape)
- **THEN** the dialog closes and no API call is made

#### Scenario: Create with a non-empty name submits the request
- **WHEN** the user enters a non-empty name and clicks Create (or presses Enter)
- **THEN** the dialog closes and a background create task is started

#### Scenario: Create is disabled for an empty name
- **WHEN** the name input is empty or contains only whitespace
- **THEN** the Create button is disabled and pressing Enter has no effect

### Requirement: Collection creation runs in the background
The system SHALL create the collection via a background task tracked in the activity panel.

#### Scenario: Activity entry appears while creation is in progress
- **WHEN** the user confirms creation
- **THEN** an activity item labeled "Creating collection '<name>'" appears in the activity panel with an in-progress indicator

#### Scenario: Successful creation adds the collection to the sidebar
- **WHEN** the background task completes without error
- **THEN** the new collection appears in the sidebar Collections list and the activity item is marked complete

#### Scenario: Failed creation shows an error notification
- **WHEN** the background task fails (network error, auth error, API rejection)
- **THEN** an error `Notification` is pushed to the window containing a human-readable message and the activity item is marked as an error

### Requirement: CollectionsService exposes a create_collection method
The `CollectionsService` trait SHALL expose a method `create_collection(name: &str) -> Result<CollectionEntry, CollectionsServiceError>` that creates a new empty product list on DTRPG and returns it.

#### Scenario: Successful call returns the new CollectionEntry
- **WHEN** `create_collection` is called with a valid non-empty name and valid credentials
- **THEN** it returns `Ok(CollectionEntry)` with the server-assigned `id`, the given `name`, and an empty `member_ids`

#### Scenario: Auth failure returns a Session error
- **WHEN** `create_collection` is called with expired or missing credentials
- **THEN** it returns `Err(CollectionsServiceError { kind: Session, .. })`

#### Scenario: Network failure returns a Network error
- **WHEN** `create_collection` is called and the HTTP request fails
- **THEN** it returns `Err(CollectionsServiceError { kind: Network, .. })`
