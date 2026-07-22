# Roadmap

## Milestone 1: Buildable baseline

- [x] Confirm the macOS build succeeds
- [x] Confirm the deployment target and Swift language mode
- [x] Remove the unused bridging header
- [x] Organize the SwiftUI source tree by responsibility
- [ ] Add unit and UI test targets
- [ ] Add continuous integration for Debug and Release builds

## Milestone 2: Microsoft 365

- MSAL delegated sign-in
- Outlook message synchronization
- Calendar synchronization
- Contact identity resolution
- Secure Keychain token storage

## Recommended next sprint

1. Add a test target and fixtures for `RelationshipMapper` and follow-up ordering.
2. Introduce protocols around Graph, AI, and Asana clients so orchestration can be tested offline.
3. Implement MSAL delegated authentication and Keychain token storage.
4. Add a deterministic identity-resolution layer before persisting interactions.

## Milestone 3: Relationship intelligence

- Follow-up status rules
- Commitment extraction and confirmation
- Relationship health scoring
- Executive attention ranking
- Interaction history

## Milestone 4: Chief of staff

- Morning briefing
- Draft follow-ups
- Meeting preparation
- Opportunity and relationship-risk insights

## Milestone 5: Execution

- Asana project and workspace selection
- Task creation and synchronization
- Waiting-on and waiting-for workflows
- Revenue and opportunity views
