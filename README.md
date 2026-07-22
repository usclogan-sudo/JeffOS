# Jeff OS

Jeff OS is a native macOS executive operating system centered on relationship intelligence.

Its central question is: **Who needs Jeff's attention, what was promised, and what should happen next?**

## Sprint 1

The first usable morning workflow includes:

- Executive dashboard with priorities, meetings, people waiting on Jeff, and open commitments
- SwiftData-backed People with full create, read, update, delete, notes, and search
- SwiftData-backed Commitments with people, due dates, status, and completion actions
- Local meeting capture for the daily dashboard
- Global quick capture with `Command-K`
- Dashboard, People, Commitments, and Settings navigation only
- Native system, light, and dark appearance modes
- A focused onboarding state for an empty first launch

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

## Data and privacy

Sprint 1 is offline-first. People, commitments, meetings, and preferences are stored locally on the Mac with SwiftData. It makes no Microsoft Graph, AI, or Asana network requests.

Never commit API keys or access tokens. Future authentication work must use secure OAuth and Keychain storage.
