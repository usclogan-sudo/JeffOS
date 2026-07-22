# Architecture

## Product model

Jeff OS is relationship-first rather than app-first. Sprint 1 deliberately uses a local SwiftData store so the core morning workflow can be validated before external integrations are introduced.

## Source layout

- **App**: SwiftUI application entry point and composition root.
- **Models**: SwiftData entities for people, commitments, and meetings.
- **Services**: deterministic starter-data setup for the first launch.
- **Views**: SwiftUI screens and reusable presentation components.
- **ViewModels**: observable application state and user actions.
- **Integrations**: reserved for later sprints; Sprint 1 has no active integrations.
- **RelationshipEngine**: reserved for deterministic scoring and prioritization rules after the daily workflow is validated.
- **Resources**: asset catalogs and future localizable resources; it must not contain Swift source.

The Xcode project uses a file-system-synchronized root group, so files under `JeffOS1/` are discovered according to their directory structure without hand-maintained file references.

## Data and control flow

1. `AppModel` owns four-screen navigation and quick-capture presentation state.
2. SwiftUI views query SwiftData directly for live, local updates.
3. Editors insert or mutate `Person`, `Commitment`, and `Meeting` models through `ModelContext`.
4. The dashboard derives priorities and daily sections deterministically from persisted records.
5. Quick Capture stores the user's text exactly as entered as an open commitment.

Future external data must remain advisory until reconciled with the local relationship workflow. Microsoft Graph is still planned as the authoritative interaction source, and Asana remains the planned execution layer.

## Configuration and security

Sprint 1 needs no credentials and performs no external API requests. Future work must use Microsoft delegated OAuth/MSAL and Keychain-backed secret storage. Local secret files are ignored by Git.

## Near-term direction

1. Add a unit-test target for dashboard prioritization and persistence behavior.
2. Validate the morning workflow with daily use before expanding scope.
3. Add deterministic relationship rules before AI enrichment.
4. Introduce secure Microsoft delegated authentication in a separate sprint.
5. Add integration abstractions and fixtures before any live network dependency.
