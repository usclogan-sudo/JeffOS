# Changelog

## Unreleased

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
