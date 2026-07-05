## MODIFIED Requirements

### Requirement: Login window presents email and password input
The app SHALL display a login window containing a single-line text field for the user's
DriveThruRPG account email, a masked text field for the user's password, and a "Sign In"
button. The window SHALL be presented before the library window when no stored
credentials are found at startup.

#### Scenario: Login window appears on first launch
- **WHEN** the app starts and no credentials are stored in the keyring
- **THEN** a login window opens instead of the library window

#### Scenario: Login window appears after logout
- **WHEN** the user performs a logout action from the settings panel
- **THEN** the library window closes and the login window opens

#### Scenario: Login window pre-fills email from a legacy or expired entry
- **WHEN** the login window opens and a stored credential entry has an email but the
  application key was rejected
- **THEN** the email field is pre-filled and the password field is empty

### Requirement: Login window validates email and password before submission
The app SHALL disable the "Sign In" button and prevent submission unless the email field
contains a non-whitespace value and the password field is non-empty.

#### Scenario: Empty fields block submission
- **WHEN** the email field or the password field is empty or contains only whitespace
- **THEN** the "Sign In" button is disabled and cannot be activated

#### Scenario: Both fields populated enables submission
- **WHEN** the email field contains at least one non-whitespace character and the
  password field is non-empty
- **THEN** the "Sign In" button is enabled

### Requirement: Login controller initiates authentication on submission
On "Sign In", `LoginController` SHALL call the SDK credential exchange with the entered
email and password to obtain an application key, then call the SDK auth endpoint with
that application key to exchange it for an access token and refresh token. If either SDK
call is not yet available, the controller SHALL fail closed and display an error rather
than falling back to a stand-in credential.

#### Scenario: Successful authentication opens library window
- **WHEN** the credential exchange and the SDK auth call both succeed and tokens are
  stored
- **THEN** the library window opens and the login window closes

#### Scenario: Failed credential exchange displays an error
- **WHEN** the credential exchange returns an error (invalid email/password, network
  failure, etc.)
- **THEN** an error message is shown in the login window and the window remains open

#### Scenario: Failed token exchange displays an error
- **WHEN** the credential exchange succeeds but the subsequent SDK auth call returns an
  error
- **THEN** an error message is shown in the login window and the window remains open

### Requirement: Login window shows an in-progress indicator during authentication
While the credential exchange or the SDK auth call is in-flight, the app SHALL show a
loading indicator and disable the email field, password field, and "Sign In" button to
prevent duplicate submissions.

#### Scenario: In-progress state during auth call
- **WHEN** the user clicks "Sign In" and either the credential exchange or the token
  exchange has not yet completed
- **THEN** a spinner or progress indicator is visible, and the fields and button are
  disabled
