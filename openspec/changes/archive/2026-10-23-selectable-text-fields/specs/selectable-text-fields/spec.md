## ADDED Requirements

### Requirement: Data fields render as selectable text

Fields that display catalog or account data SHALL render using a selectable text primitive so the user can click-drag to select and copy the value with the OS copy shortcut. This applies to item titles, descriptions, publisher names, order/product IDs, error and alert messages, and read-only settings values.

#### Scenario: Selecting an item title in the detail panel

- **WHEN** the user click-drags across an item title in the detail panel
- **THEN** the title text SHALL be selected and copyable via the OS copy shortcut

#### Scenario: Selecting an error message

- **WHEN** the user click-drags across an error or alert message in the alert history view
- **THEN** the message text SHALL be selected and copyable via the OS copy shortcut

### Requirement: Structural text remains non-selectable

Button labels, section headers, and other structural/decorative text SHALL NOT be converted to selectable
text, to avoid presenting UI chrome as copyable data.

#### Scenario: Button label is not selectable

- **WHEN** the user click-drags across a button label such as "Download" or "Settings"
- **THEN** no text selection SHALL occur
