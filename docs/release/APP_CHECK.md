# Firebase App Check — Android release

The app is already wired correctly:

- debug builds use the Firebase App Check debug provider;
- profile/release builds use Play Integrity;
- App Check initialization happens before Auth and Firestore access.
- the Firebase Android app is registered with Play Integrity;
- token TTL is 1 hour and the current minimum device recognition level is
  `NO_INTEGRITY` (the safe default before Play testing);
- Firestore and Authentication enforcement are currently disabled.

## Manual Firebase and Play Console steps

These remaining steps cannot be completed before the Play Console app and Play
App Signing certificate exist.

1. Keep enforcement disabled while the first AAB is being prepared.
2. Create the Play Console app, enable Play App Signing, and upload an internal
   test AAB.
3. Copy both SHA-1 and SHA-256 values under Play Console → App integrity →
   App signing key certificate into the Firebase Android app.
4. Download the refreshed `google-services.json` and replace the project copy.
5. Install the app from Google Play Internal Testing. Verify guest, Google and
   email sign-in; Firestore sync; account deletion; and reinstall restore.
6. Confirm App Check requests in Firebase metrics, then enable enforcement for
   **Cloud Firestore** and **Authentication**. Never enable enforcement before
   the Play-delivered build succeeds.

The upload certificate has already been registered in Firebase, but it is not
the Play App Signing certificate. Both are needed for the complete release
configuration.

Official reference:
https://firebase.google.com/docs/app-check/flutter/default-providers
