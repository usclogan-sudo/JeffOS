# Agent Instructions

## Product intent

Jeff OS is a native macOS executive operating system focused on relationship intelligence and follow-through.

## Development priorities

1. Keep the project buildable.
2. Do not commit secrets, tokens, certificates, or user-specific Xcode state.
3. Preserve Microsoft Graph as the authoritative source for Outlook email and calendar.
4. Treat AI output as advisory and reviewable, not authoritative.
5. Keep Asana as the execution layer unless an explicit product decision changes that.
6. Prefer small, reviewable pull requests with tests.

## First task

Audit the current build, repair compile errors, run available tests, and open a baseline-repair pull request before adding major features.
