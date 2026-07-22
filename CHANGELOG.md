# Changelog

## Unreleased

- Delivered the Sprint 1 executive dashboard as the default launch experience.
- Added SwiftData-backed People with full CRUD, search, relationship health, notes, and next actions.
- Added SwiftData-backed Commitments with people, due dates, status, completion, and dashboard visibility.
- Added local daily meetings and a focused meeting capture sheet.
- Added global quick capture that stores text exactly as entered.
- Reduced navigation to Dashboard, People, Commitments, and Settings.
- Added keyboard shortcuts, native animations, appearance controls, and dark-mode support.
- Removed inactive Graph, AI, and Asana prototype code from the Sprint 1 application target.
- Confirmed the complete baseline builds for macOS with Xcode 26.6 and Swift 5 language mode.
- Set the project to macOS-only with a macOS 14.0 deployment target.
- Organized sources into App, Models, Services, Views, ViewModels, Integrations, RelationshipEngine, and Resources.
- Extracted relationship mapping from orchestration into the relationship engine.
- Removed the unused Objective-C bridging header.
- Expanded project documentation, security guidance, and build instructions.
- Hardened Git ignores for Xcode results, source-control metadata, and local configuration.
- Reconstructed a complete project root from the uploaded Xcode project and source folder.
- Removed nested Git metadata and user-specific Xcode state.
- Confirmed `AppModel.swift` imports Combine for `ObservableObject` and `@Published`.
- Added repository documentation and a safe `.gitignore`.
