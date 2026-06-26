# auth-login-view Specification

## Purpose
TBD - created by archiving change add-auth-ui. Update Purpose after archive.
## Requirements
### Requirement: Login window presents API key input
The app SHALL display a login window containing a single-line text field for the user's DriveThruRPG API key and a "Sign In" button. The window SHALL be presented before the library window when no stored credentials are found at startup.

#### Scenario: Login window appears on first launch
- **WHEN** the app starts and no credentials are stored in the keyring
- **THEN** a login window opens instead of the library window

#### Scenario: Login window appears after logout
- **WHEN** the user performs a logout action from the settings panel
- **THEN** the library window closes and the login window opens

### Requirement: Login window validates API key before submission
The app SHALL disable the "Sign In" button and prevent submission when the API key field is empty or contains only whitespace.

#### Scenario: Empty field blocks submission
- **WHEN** the API key field is empty
- **THEN** the "Sign In" button is disabled and cannot be activated

#### Scenario: Non-empty field enables submission
- **WHEN** the API key field contains at least one non-whitespace character
- **THEN** the "Sign In" button is enabled

### Requirement: Login controller initiates authentication on submission
On "Sign In", `LoginController` SHALL call the SDK auth endpoint with the entered API key to exchange it for an access token and refresh token. If the SDK does not yet expose a token exchange function, the controller SHALL store the raw API key as a stand-in and document the stub clearly.

#### Scenario: Successful authentication opens library window
- **WHEN** the SDK auth call succeeds and tokens are stored
- **THEN** the library window opens and the login window closes

#### Scenario: Failed authentication displays an error
- **WHEN** the SDK auth call returns an error (invalid key, network failure, etc.)
- **THEN** an error message is shown in the login window and the window remains open

### Requirement: Login window shows an in-progress indicator during authentication
While the SDK auth call is in-flight, the app SHALL show a loading indicator and disable the input field and "Sign In" button to prevent duplicate submissions.

#### Scenario: In-progress state during auth call
- **WHEN** the user clicks "Sign In" and the auth call has not yet completed
- **THEN** a spinner or progress indicator is visible, and the field and button are disabled

