## ADDED Requirements

### Requirement: Store credentials in platform-native secure storage
The application SHALL persist DriveThruRPG account credentials (API key, access token, refresh token, or username/password as appropriate) exclusively in the platform's native secure credential store: macOS Keychain on macOS, Windows Credential Manager on Windows, and Linux Secret Service (via DBus / libsecret) on Linux. Credentials SHALL NOT be written to plaintext config files, environment variables, or unencrypted local databases.

#### Scenario: Credential written on successful authentication (macOS)
- **WHEN** the user successfully authenticates with DriveThruRPG on macOS
- **THEN** the credential is stored in the macOS Keychain under a well-known service name (`com.pilgrimagesoftware.dtrpg`) and account label

#### Scenario: Credential written on successful authentication (Windows)
- **WHEN** the user successfully authenticates with DriveThruRPG on Windows
- **THEN** the credential is stored in Windows Credential Manager as a Generic Credential with target name `com.pilgrimagesoftware.dtrpg`

#### Scenario: Credential written on successful authentication (Linux)
- **WHEN** the user successfully authenticates with DriveThruRPG on Linux
- **THEN** the credential is stored in the Secret Service keyring (e.g., GNOME Keyring or KWallet) under a collection-agnostic label of `com.pilgrimagesoftware.dtrpg`

#### Scenario: No plaintext fallback
- **WHEN** the platform secure store is unavailable or write fails
- **THEN** the application SHALL surface an error to the user and SHALL NOT fall back to writing credentials to disk in plaintext

### Requirement: Retrieve credentials from platform-native secure storage
The application SHALL read credentials from the platform secure store on startup and before any authenticated API call. A missing or expired credential SHALL prompt re-authentication rather than failing silently.

#### Scenario: Credentials present at startup
- **WHEN** the application starts and a valid credential exists in the platform store
- **THEN** the credential is loaded into memory and the user is not prompted to log in

#### Scenario: Credentials absent at startup
- **WHEN** the application starts and no credential exists in the platform store
- **THEN** the application presents the login/authentication flow to the user

#### Scenario: Credential retrieval failure
- **WHEN** a credential read from the platform store fails (store locked, permission denied, corrupt entry)
- **THEN** the application logs the error, clears any in-memory credential state, and presents the authentication flow

### Requirement: Delete credentials on sign-out
The application SHALL delete all stored credentials from the platform secure store when the user explicitly signs out. No credential material SHALL remain after sign-out.

#### Scenario: Sign-out clears credential store entry
- **WHEN** the user signs out of the application
- **THEN** the credential entry is removed from the platform secure store and in-memory credential state is cleared

#### Scenario: Sign-out handles missing entry gracefully
- **WHEN** the user signs out and no credential entry exists in the platform store (e.g., manually deleted externally)
- **THEN** the application completes sign-out without error

### Requirement: Unified CredentialStore abstraction
The application SHALL expose a single `CredentialStore` interface (trait in Rust, protocol in Swift) that abstracts platform differences. Platform-specific implementations SHALL be selected at compile time via conditional compilation, not runtime feature detection.

#### Scenario: Rust platform dispatch via cfg
- **WHEN** the Rust application is compiled for `aarch64-apple-darwin` or `x86_64-apple-darwin`
- **THEN** the `CredentialStore` implementation links against `Security.framework` via the `security-framework` crate

#### Scenario: Rust platform dispatch — Windows
- **WHEN** the Rust application is compiled for a `*-pc-windows-*` target
- **THEN** the `CredentialStore` implementation uses the `windows` crate (`Windows.Win32.Security.Credentials`)

#### Scenario: Rust platform dispatch — Linux
- **WHEN** the Rust application is compiled for a `*-unknown-linux-*` target
- **THEN** the `CredentialStore` implementation uses the `secret-service` or `keyring` crate to communicate with the Secret Service DBus API

#### Scenario: Swift uses Security framework directly
- **WHEN** the Swift application stores or retrieves a credential
- **THEN** it calls `SecItemAdd`, `SecItemCopyMatching`, and `SecItemDelete` via `Security.framework` with appropriate `kSecClass`, `kSecAttrService`, and `kSecAttrAccount` attributes

### Requirement: Credential scope and labeling
Stored credentials SHALL be labeled with a consistent, application-specific namespace to avoid collisions with other applications and to allow targeted deletion on uninstall.

#### Scenario: Service name is namespaced
- **WHEN** any credential is stored or retrieved
- **THEN** the service/target name SHALL follow the pattern `com.pilgrimagesoftware.dtrpg[.<sub-key>]` where `<sub-key>` distinguishes credential type (e.g., `api-key`, `access-token`, `refresh-token`)

#### Scenario: Uninstall removes all namespaced entries
- **WHEN** the application is uninstalled or the user invokes a "remove all data" action
- **THEN** all entries matching the `com.pilgrimagesoftware.dtrpg` namespace are removed from the platform credential store
