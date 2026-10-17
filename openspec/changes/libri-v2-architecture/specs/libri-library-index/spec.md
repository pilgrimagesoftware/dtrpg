## ADDED Requirements

### Requirement: A single database is the source of truth for library data

The application SHALL store catalog items, files, collections, collection membership, tags, storage roots,
item placement, and content summaries in one local database.

#### Scenario: Library data survives a restart

- **WHEN** the application is closed and reopened
- **THEN** catalog items, collections, tags, and placement SHALL be read from the database with no API call

#### Scenario: Cover images stay on the file system

- **WHEN** a cover or thumbnail image is cached
- **THEN** its bytes SHALL be written as a file on disk rather than stored in the database

### Requirement: Full-text search is served by a text index

The database SHALL maintain a full-text index covering item title, publisher, authors, description, tag
names, file names, and summary text.

#### Scenario: Searching matches indexed text

- **WHEN** the user searches for a term present in any indexed field
- **THEN** matching items SHALL be returned without scanning the full catalog in application code

#### Scenario: Index follows catalog changes

- **WHEN** a catalog item is added, changed, or removed
- **THEN** the text index SHALL reflect that change before the next query returns

### Requirement: Facet and aggregate counts come from the index

Facet counts and library aggregate statistics SHALL be computed by the database over the same filter
conditions as the active view.

#### Scenario: Facet counts agree with the result list

- **WHEN** a view has filters applied and facet counts are displayed
- **THEN** selecting a facet SHALL yield exactly the number of items its count showed

#### Scenario: Aggregates available offline

- **WHEN** the application has no network connection
- **THEN** library statistics SHALL still be computed from the local database

### Requirement: Existing caches migrate on first launch

On first launch after the index is introduced, the application SHALL populate the database from the
existing on-disk caches and SHALL leave those cache files in place.

#### Scenario: Migrating an existing install

- **WHEN** the application starts and finds catalog or collections cache files but no database
- **THEN** it SHALL build the database from those files and SHALL NOT delete them

#### Scenario: Fresh install

- **WHEN** the application starts with neither a database nor cache files
- **THEN** it SHALL create an empty database and populate it from the API
