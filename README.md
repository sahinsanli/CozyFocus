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

- `lib/core/`: theme, asset mappings, models, persistence, service contracts, shared widgets
- `lib/features/`: focus, room, stats, sounds, profile, and settings screens
- `assets/visuals/`: production room scenes, app artwork, and cropped sprite atlases
- `assets/placeholders/`: fallback guidance for future visual replacements
- `assets/fonts/`: bundled Quicksand and Nunito Sans fonts (SIL Open Font License)

The final illustration pack is bundled and mapped through `AppAssets` and
`AtlasSprite`. Ambient sound playback remains intentionally local and safe via
`MockAudioService`; the sound cards use the supplied atmosphere previews.
