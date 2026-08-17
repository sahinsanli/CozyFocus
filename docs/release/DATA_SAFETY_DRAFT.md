# Google Play Data safety draft

This is a preparation sheet for the Play Console form. Re-check it whenever an
SDK or backend feature is added.

## Top-level answers

- Does the app collect user data? **Yes**. Cloud sync transmits data off-device,
  including for the automatically created guest account.
- Does the app share user data? **No**, based on the current implementation.
  Firebase is used as a service provider, not for advertising or sale.
- Is all collected data encrypted in transit? **Yes**.
- Can users request deletion? **Yes** — in-app account deletion and the public
  deletion page are both available.
- Deletion URL: `https://cozyfocus-1ca80.web.app/delete-account`
- Privacy URL: `https://cozyfocus-1ca80.web.app/privacy`

## Data types to declare

| Play category | Data | Optional? | Purpose |
| --- | --- | --- | --- |
| Personal info | Name/nickname | Yes | App functionality, personalization |
| Personal info | Email address | Yes | Account management, authentication |
| Personal info | User IDs | No | Authentication, cloud sync, security |
| App activity | App interactions / other actions | No | Focus history, rewards, inventory, room and badge progress |
| Device or other IDs | App/device integrity identifiers | No | Fraud prevention, security, App Check |

The app currently does **not** include advertising, Analytics, Crashlytics,
payments, location, contacts, microphone/camera collection, user photo upload or
Firebase Storage. If any of these are added, this draft and the privacy policy
must be updated before the next release.

Official Firebase SDK disclosure guide:
https://firebase.google.com/docs/android/play-data-disclosure

Official Play form guide:
https://support.google.com/googleplay/android-developer/answer/10787469
