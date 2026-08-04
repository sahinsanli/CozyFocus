# Cozy Focus

A mobile-first, local-first Flutter MVP based on the **Cozy Focus Room** design
references. The app includes a persistent focus timer, progress-driven room
decorations, live statistics, a safe mock ambient mixer, profile progress, and
locally stored settings.

## Run

```sh
flutter pub get
flutter run
```

## Verify

```sh
flutter analyze
flutter test
flutter build apk --debug
```

## Structure

- `lib/core/`: theme, models, persistence, service contracts, shared widgets
- `lib/features/`: focus, room, stats, sounds, profile, and settings screens
- `assets/placeholders/`: replacement point for future PNG/SVG illustrations
- `assets/fonts/`: bundled Quicksand and Nunito Sans fonts (SIL Open Font License)

Ambient audio and final illustrations are intentionally not bundled. The
current controls use `MockAudioService`, while visual placeholders are drawn as
real Flutter widgets so both can be replaced without changing feature state.
