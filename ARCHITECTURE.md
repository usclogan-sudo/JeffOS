# Architecture

## Product model

Jeff OS is relationship-first rather than app-first. Microsoft 365 is the source of interaction history, AI interprets relationships and commitments, and Asana remains the execution system.

## Current layers

- **Models.swift**: accounts, contacts, commitments, priorities, and briefing data.
- **AppModel.swift**: application state and user actions.
- **Views**: briefing, accounts, follow-up rows, and supporting workspaces.
- **MicrosoftGraphService.swift**: Outlook and calendar API scaffold.
- **ClaudeRelationshipService.swift**: relationship-analysis API scaffold.
- **AsanaService.swift**: task-creation API scaffold.
- **RelationshipOrchestrationService.swift**: coordinates integrations.

## Near-term direction

1. Establish a clean, buildable baseline.
2. Replace environment-token prototypes with secure authentication.
3. Persist normalized interactions and commitments locally.
4. Add a deterministic relationship engine before AI enrichment.
5. Add tests around ranking, status, and commitment logic.
