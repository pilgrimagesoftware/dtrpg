## ADDED Requirements

### Requirement: Catalog shows a distinct empty state when the library has no items

The system SHALL render a "library empty" state when the unfiltered catalog contains zero items (`total_count == 0`), displaying a visual icon and the message "Your library is empty."

#### Scenario: Library is empty

- **WHEN** `total_count == 0` and `items` is empty
- **THEN** the catalog area shows a centered icon and the text "Your library is empty."

#### Scenario: Library is not empty but this state is not shown

- **WHEN** `total_count > 0`
- **THEN** the "library empty" state is NOT rendered regardless of whether `items` is empty

### Requirement: Catalog shows a distinct empty state when a filter or search yields no results

The system SHALL render a "no matches" state when `total_count > 0` but the filtered `items` list is empty, displaying a visual icon, the message "No titles match.", and a contextual hint.

#### Scenario: Search query produces no results

- **WHEN** `total_count > 0`, `items` is empty, and `search_query` is non-empty
- **THEN** the catalog shows "No titles match." and the hint "Try clearing your search."

#### Scenario: Sidebar filter produces no results

- **WHEN** `total_count > 0`, `items` is empty, and `search_query` is empty
- **THEN** the catalog shows "No titles match." and the hint "Try selecting a different section."

### Requirement: Items are present — no empty state is shown

The system SHALL NOT render any empty state when `items` is non-empty.

#### Scenario: Items available

- **WHEN** `items` is non-empty
- **THEN** the catalog renders the normal list, thumbs, or grid layout with no empty state overlay
