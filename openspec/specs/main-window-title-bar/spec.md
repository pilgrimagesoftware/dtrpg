# main-window-title-bar Specification

## Purpose
Define the desktop application's main window title bar region, including its account button and account menu, as the shared structure child app repositories implement.

## Requirements
### Requirement: Main window MUST have a distinct title bar region
The desktop application main window MUST provide a title bar region above the content area, separated from the content area by a horizontal separator, containing the window title and an account button.

#### Scenario: Rendering the title bar
- **WHEN** the main window is displayed
- **THEN** the title bar shows the window title, padding, and the account button, and a horizontal separator divides the title bar from the content area

### Requirement: Title bar account button MUST open an account menu
The desktop application title bar MUST provide an account button, shown with the user's avatar image, that opens a menu containing user info, a settings action, and a sign-out action.

#### Scenario: Opening the account menu from the title bar
- **WHEN** the user activates the account button in the title bar
- **THEN** the app displays a menu containing the current user's info, an action to open settings, and an action to sign out

#### Scenario: Signing out from the account menu
- **WHEN** the user selects the sign-out action in the account menu
- **THEN** the app ends the current session and returns to the signed-out state
