# Architecture

## Product model

Jeff OS is relationship-first rather than app-first. Microsoft 365 is the source of interaction history, AI interprets relationships and commitments, and Asana remains the execution system.

## Source layout

- **App**: SwiftUI application entry point and composition root.
- **Models**: domain entities and disconnected sample data.
- **Services**: application workflows that coordinate integrations and domain logic.
- **Views**: SwiftUI screens and reusable presentation components.
- **ViewModels**: observable application state and user actions.
- **Integrations**: Microsoft Graph, Anthropic, and Asana API boundaries plus environment-backed configuration.
- **RelationshipEngine**: deterministic mapping and, eventually, scoring and prioritization rules.
- **Resources**: asset catalogs and future localizable resources; it must not contain Swift source.

The Xcode project uses a file-system-synchronized root group, so files under `JeffOS1/` are discovered according to their directory structure without hand-maintained file references.

## Data and control flow

1. `AppModel` receives a user intent from a SwiftUI view.
2. `RelationshipOrchestrationService` coordinates Microsoft Graph and AI analysis.
3. `RelationshipMapper` normalizes advisory AI output into domain models.
4. Views render the resulting account and contact state.
5. Explicit user actions create Outlook drafts or Asana tasks.

External API output is advisory. Microsoft Graph remains the source of interaction truth, and Asana remains the execution layer.

## Configuration and security

The prototype reads credentials from process environment variables and commits no values. Production work must replace raw token injection with Microsoft delegated OAuth/MSAL and Keychain-backed secret storage. Local secret files are ignored by Git.

## Near-term direction

1. Add a unit-test target for relationship mapping, ranking, and status rules.
2. Replace environment-token prototypes with secure authentication.
3. Persist normalized interactions and commitments locally.
4. Expand deterministic relationship rules before AI enrichment.
5. Add integration abstractions and fixtures for offline testing.
