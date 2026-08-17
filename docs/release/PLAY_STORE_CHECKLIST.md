# Cozy Focus — Google Play release checklist

## Ready in the repository

- [x] Stable package ID: `com.sahinsanli.cozyfocus`
- [x] Version: `1.0.0+1` (version code 1)
- [x] `minSdk 24`, `targetSdk 36`
- [x] Release upload keystore and non-debug signing configuration
- [x] Upload SHA-1/SHA-256 registered in Firebase
- [x] Google services configuration refreshed
- [x] Release App Check provider set to Play Integrity
- [x] Firebase App Check Play Integrity registration (1-hour TTL)
- [x] Firestore ownership/schema rules and emulator tests
- [x] Firestore rules deployed to `cozyfocus-1ca80`
- [x] In-app and public account deletion paths
- [x] Privacy, Terms, Delete Account and Support pages online
- [x] 512×512 store icon and 1024×500 feature graphic
- [x] English and Turkish store copy draft
- [x] Data safety answer draft
- [x] Signed release AAB produced and verified

## Requires a Play Console developer account

- [ ] Complete identity/developer verification and public developer contact
      details. An organization account also needs its organization/D-U-N-S
      details.
- [ ] Create the app with package `com.sahinsanli.cozyfocus`. Treat the package
      name as permanent after publishing.
- [ ] Select default language, free/paid status, App category and countries.
- [ ] Enable Play App Signing and upload the release AAB.
- [ ] Add Play's **App signing key** SHA-1 and SHA-256 to Firebase.
- [ ] Link/verify the Play app's Cloud project and Play App Signing certificate
      after the first Play upload.
- [ ] Complete App access (the core app is accessible as guest), Ads (No),
      Content rating, Target audience, Privacy, Data safety and Account deletion
      forms.
- [ ] Add support email `ganyuyku@gmail.com` and the hosted policy URLs.
- [ ] Capture at least two current phone screenshots from the Play-installed
      release build. Do not use old debug/test-mode screenshots.
- [ ] Run Internal Testing and the complete release test matrix.
- [ ] If this is a new personal developer account, complete the currently
      required closed test with at least 12 opted-in testers for 14 continuous
      days before applying for production access.
- [ ] Enable App Check enforcement only after the Play-installed internal build
      shows valid requests for Auth and Firestore.

## Internal test matrix

- Guest first launch and onboarding
- Guest → Google link without progress loss
- Guest → email/password link without progress loss
- Existing Google and email sign-in
- Email verification and password reset
- Second-device/reinstall Firestore restore
- Offline focus completion and later sync without duplicate session
- Sign-out isolation between users
- In-app deletion removes Auth and Firestore data
- External deletion page works without app access
- Focus, breaks, rewards, sounds, room, inventory and Turkish language
- App Check request metrics show accepted Play Integrity tokens

## Current policy reminders (checked 11 August 2026)

- New apps and updates must target Android 16 / API 36 from 31 August 2026.
- New apps are published as Android App Bundles and use Play App Signing.
- Apps that create accounts need in-app and external account deletion paths.
- Data safety declarations cover SDK collection as well as app-owned code.

Official references:

- Target API: https://support.google.com/googleplay/android-developer/answer/11926878
- App signing: https://support.google.com/googleplay/android-developer/answer/9844679
- Account deletion: https://support.google.com/googleplay/android-developer/answer/13327111
- Closed testing for new personal accounts: https://support.google.com/googleplay/android-developer/answer/14151465
