# Cozy Focus

A mobile-first, local-first Flutter MVP based on the **Cozy Focus Room** design
references. The app includes a persistent focus timer, progress-driven room
decorations, live statistics, a multi-track ambient mixer, profile progress, and
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
`AtlasSprite`. Bundled rain, campfire, forest, and piano loops play locally
through independent audio players, so they can run together with separate
volume controls. Local one-shot effects provide tap, item placement, focus
development, cat, and reward feedback without interrupting the ambience mix.
