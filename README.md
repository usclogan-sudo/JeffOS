# Jeff OS

Jeff OS is a native macOS executive operating system centered on relationship intelligence.

Its central question is: **Who needs Jeff's attention, what was promised, and what should happen next?**

## Current prototype

The current SwiftUI prototype includes:

- Morning executive briefing
- Relationship follow-up queue
- Account and contact views
- Microsoft Graph integration scaffold
- Claude relationship-analysis scaffold
- Asana task-creation scaffold
- Sample relationship data for disconnected development

## Open the project

Requirements:

- Xcode 26.6 or newer
- macOS 14.0 deployment target
- Swift 5 language mode (built with the Swift 6.3.3 toolchain during the baseline audit)

Open `JeffOS1.xcodeproj` in Xcode and build the `JeffOS1` macOS scheme, or run:

```sh
xcodebuild \
  -project JeffOS1.xcodeproj \
  -scheme JeffOS1 \
  -configuration Debug \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

The repository currently contains one application target and no test target.

## Credentials

Never commit API keys or access tokens. The current integration settings read local environment values. Production authentication must use secure OAuth and Keychain storage.
