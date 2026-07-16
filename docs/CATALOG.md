# Catalog Maintenance Behavior

This document describes the behavior of the application in maintaining the user's local catalog, and how it interacts
with the remote API to handle initialization, updates, and downloads.

## Fresh Startup

When the user first starts the application, it is assumed there is no local catalog, i.e., catalog metadata, downloaded 
items, or cached content, such as cover images. It is also assumed that the application does not have sufficient 
credentials to access the remote API.

Once credentials are acquired, the application should proceed with initializing the local catalog.

The initialization process needs to orderly and progressive.

An initial request should be made to the remote API to retrieve information about the user's catalog, such as total
size and number of items. This information is used to communicate to the user the progress of operations.

As data is retrieved from the remote API, the application should update the local catalog accordingly and 
present that data to the user, i.e., the catalog view contents are updated in real-time as data is downloaded.

Requests should be paginated. This will prevent the application from attempting to process large amounts of data at once,
which could lead to performance issues or even crashes.

"Last request time" should be tracked and recorded to avoid redundant requests and to keep the application from repeatedly
requesting the same data over short periods of time.

## Subsequent Startup

The local catalog content and cache should always be loaded first before any network requests are made.

If the next attempt to connect to the remote API is too soon, as determined by the "last request time", the application
should not make a new request but instead use the cached data. The age of the catalog and cache are shown to the user
in the settings view, so that the user is not kept in the dark as to why no data is being updated.

## Updating the Catalog

The application should attempt to make use of cache control headers or queries with parameters to determine if data
on the remote server is newer than the cached data or stored content, and if so, update the cache or content accordingly.

## Logging

All activity related to the catalog and cache should be logged, including any errors or warnings that occur. Information
about the catalog and cache state, as well as any network requests made, should be logged at the appropriate log level.
Log messages that are exposed to the user should be clear, concise, and user-friendly, while log messages that are only 
used internally should be more verbose.

## Error Handling

Errors that occur during catalog updates or cache operations should be handled gracefully, with clear and concise error
messages exposed to the user. Log messages that are only used internally should be more verbose.

Retries should be attempted up to a certain limit, with a backoff strategy in place to avoid overwhelming the server.
The retry number and reason for the retry should be logged with each attempt. It is acceptable to expose the retry number 
to the user.

## Disconnection 

It is possible that the user is disconnected from the remote API, either due to network issues or a change in their
credentials. In this case, the application should handle the disconnection gracefully.

The application should include a lightweight network monitor that network processes can use to detect disconnections.
The network monitor should be able to distinguish between general network inaccessibility and issues with specific 
endpoints and make that information available to the application.

Processes that require access to a specific endpoint should be able to query the network monitor to determine whether
they should continue or stop. This type of query should be performed before making a request to the endpoint.

Processes that require general network access should be able to query the network monitor as to the state of network
connectivity and continue or stop accordingly.

## Work Queues

All activity performed in the background should make use of work queues to ensure:
- Tasks are executed in order 
- Tasks are executed concurrently
- The application UI remains responsive during background activity
- Remote resources are not overloaded by too many concurrent requests

### Concurrency

The application should use threads and executors to perform background tasks concurrently.

The application should use a queue for catalog updates and synchronization with the remote API. This queue should be 
serial to ensure that catalog updates are applied consistently and in the correct order.

The application should use a separate queue for content downloads with its own thread pool and concurrency settings.

If necessary, the application should use a separate queue for other background tasks.

## Caveats

It is possible that the user's local catalog can be empty or relocated, while the application already has credentials 
stored in the user's keychain. The "Fresh Startup" behavior should be used to re-initialize the catalog from the remote API.

It is also possible that user's credentials are inaccessible or expired, while the application still has a valid local catalog.
In this case, the application should continue to use the local catalog and notify the user that they need to re-authenticate
(usually done via a non-intrusive banner or notification message).
