# Stream Deck Setup

Jeff OS registers the `jeffos://` URL scheme. Each Stream Deck button can use the **System: Website** action with one of the URLs below. The action launches Jeff OS if it is closed and routes the existing app window when it is already running.

| Button | URL | Behavior |
| --- | --- | --- |
| Dashboard | `jeffos://dashboard` | Opens the Dashboard. |
| People | `jeffos://people` | Opens People. |
| Commitments | `jeffos://commitments` | Opens Commitments. |
| Capture | `jeffos://capture` | Opens Jeff OS and immediately presents Quick Capture. |
| Meetings | `jeffos://meetings` | Opens the Dashboard, where Today's Meetings is shown. |

## Configure a button

1. Open the Stream Deck app and drag a **System: Website** action onto a button.
2. Paste the corresponding `jeffos://` URL into the action's URL field.
3. Give the button the matching title and choose its PNG from `BrandAssets/StreamDeck`.
4. Press the button to verify Jeff OS opens at the expected destination.

Routes are case-insensitive. Any unknown or malformed Jeff OS route safely opens the Dashboard.
