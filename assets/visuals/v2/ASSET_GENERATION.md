# Cozy Focus Room V2 Asset Notes

Generated with the built-in image generation tool, using the existing Cozy
Focus room and sprite atlases as visual references. Transparent atlases were
generated against a flat magenta chroma-key background, then converted to
alpha PNGs with the ImageGen skill's `remove_chroma_key.py` helper.

## Final prompt set

1. **Empty room base** — A 9:16 portrait, truly empty study room at night in
   the existing warm watercolor-storybook style. Permanent architecture only:
   cream walls, honey-oak floorboards, a wooden window, tied-back curtains and
   a moonlit garden. No furniture, decorations, plants, characters, text or UI.
2. **Main item atlas** — A 4x3 atlas of isolated study desk, wooden chair,
   brass desk lamp, botanical rug, potted/hanging greenery, bookshelf, jar
   candle, botanical wall print, sleeping cream-and-sage cat, moon tea and
   books, matching the existing palette and perspective.
3. **Daily rewards and avatars** — A 4x4 atlas containing eight daily rewards
   (tea, books, vase, Starflower, Night Fern, owl, leaf lantern and clock) and
   six non-human profile avatars (Moonleaf, cat, moon, lamp, forest and tea).
4. **Crafting atlas A** — A 5x4 atlas containing five coherent build stages for
   the desk, chair, lamp and rug, from loose parts to completed item.
5. **Crafting atlas B** — A 5x4 atlas containing five coherent growth/build
   stages for the potted plant, bookshelf, candle and botanical print.
6. **Crafting atlas C** — A 5x2 atlas containing five growth stages for the
   hanging plant and five arrival/rest stages for the sleeping cat.

Shared constraints for all atlases: equal cells, one isolated sprite per cell,
consistent scale and viewpoint, generous padding, no labels, no grid lines, no
watermark, no cast shadow and no chroma color inside the sprites.
