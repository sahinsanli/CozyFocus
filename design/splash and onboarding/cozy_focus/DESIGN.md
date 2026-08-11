---
name: Cozy Focus
colors:
  surface: '#fff8f6'
  surface-dim: '#e5d7d2'
  surface-bright: '#fff8f6'
  surface-container-lowest: '#ffffff'
  surface-container-low: '#fff1eb'
  surface-container: '#faebe5'
  surface-container-high: '#f4e5e0'
  surface-container-highest: '#eee0da'
  on-surface: '#211a17'
  on-surface-variant: '#444840'
  inverse-surface: '#372f2b'
  inverse-on-surface: '#fdeee8'
  outline: '#74786f'
  outline-variant: '#c4c8bd'
  surface-tint: '#516447'
  primary: '#4f6144'
  on-primary: '#ffffff'
  primary-container: '#677a5c'
  on-primary-container: '#f8ffee'
  inverse-primary: '#b8cdaa'
  secondary: '#97463e'
  on-secondary: '#ffffff'
  secondary-container: '#fd978c'
  on-secondary-container: '#772e27'
  tertiary: '#625b4b'
  on-tertiary: '#ffffff'
  tertiary-container: '#7b7463'
  on-tertiary-container: '#fffbff'
  error: '#ba1a1a'
  on-error: '#ffffff'
  error-container: '#ffdad6'
  on-error-container: '#93000a'
  primary-fixed: '#d4e9c4'
  primary-fixed-dim: '#b8cdaa'
  on-primary-fixed: '#0f1f09'
  on-primary-fixed-variant: '#3a4c31'
  secondary-fixed: '#ffdad6'
  secondary-fixed-dim: '#ffb4ab'
  on-secondary-fixed: '#3e0404'
  on-secondary-fixed-variant: '#792f28'
  tertiary-fixed: '#ebe2cd'
  tertiary-fixed-dim: '#cfc6b2'
  on-tertiary-fixed: '#1f1b0f'
  on-tertiary-fixed-variant: '#4c4637'
  background: '#fff8f6'
  on-background: '#211a17'
  surface-variant: '#eee0da'
typography:
  display-lg:
    fontFamily: Quicksand
    fontSize: 48px
    fontWeight: '700'
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Quicksand
    fontSize: 32px
    fontWeight: '600'
    lineHeight: 40px
  headline-md:
    fontFamily: Quicksand
    fontSize: 24px
    fontWeight: '600'
    lineHeight: 32px
  body-lg:
    fontFamily: Nunito Sans
    fontSize: 18px
    fontWeight: '400'
    lineHeight: 28px
  body-md:
    fontFamily: Nunito Sans
    fontSize: 16px
    fontWeight: '400'
    lineHeight: 24px
  label-md:
    fontFamily: Nunito Sans
    fontSize: 14px
    fontWeight: '700'
    lineHeight: 20px
    letterSpacing: 0.05em
  headline-lg-mobile:
    fontFamily: Quicksand
    fontSize: 28px
    fontWeight: '600'
    lineHeight: 36px
rounded:
  sm: 0.5rem
  DEFAULT: 1rem
  md: 1.5rem
  lg: 2rem
  xl: 3rem
  full: 9999px
spacing:
  unit: 8px
  container-padding-mobile: 20px
  container-padding-desktop: 40px
  gutter: 16px
  stack-gap: 12px
  section-gap: 48px
---

## Brand & Style

The design system is centered on the concept of "Digital Hygge." It aims to transform productivity from a high-pressure corporate task into a tranquil, ritualistic experience. The target audience includes students, creative professionals, and neurodivergent users who seek a low-stress environment to maintain focus.

The visual style is a hybrid of **Soft Minimalism** and **Glassmorphism**, heavily influenced by "Lo-Fi" aesthetics and cozy indie gaming interfaces. It prioritizes "breathability" through generous whitespace and avoids sharp angles or aggressive transitions. Every interaction should feel soft, intentional, and grounded. Use hand-drawn line work for iconography to inject human warmth and break the rigidity of standard digital interfaces.

## Colors

The palette is derived from natural, earthy elements to evoke a sense of calm.

- **Primary (Sage Green):** Used for progress indicators, success states, and primary actions. It represents growth and focus.
- **Secondary (Muted Terracotta):** Used for highlights, gamified rewards, and "break time" indicators. It provides a warm contrast without being alarming.
- **Tertiary (Warm Beige):** The foundational surface color. It replaces pure white to reduce eye strain and provide a "paper-like" warmth.
- **Neutral (Cocoa Mud):** Used for typography and iconography. This softened brown is more organic and less harsh than pure black or gray.
- **Background:** Use `#FDFBF7` as the base canvas color.

## Typography

The typography system utilizes rounded terminals to reinforce the friendly and approachable brand personality.

**Quicksand** is reserved for headlines and large display moments. Its geometric but soft nature pairs perfectly with gamified elements. **Nunito Sans** provides high legibility for task lists, notes, and settings.

All text should be rendered with a slight tint of the neutral "Cocoa Mud" color rather than pure black to maintain the "cozy" atmosphere. Avoid all-caps for anything other than small labels or category headers to keep the tone conversational and gentle.

## Layout & Spacing

The layout philosophy follows a **Fluid Content Model** with intentional padding to prevent information density from feeling overwhelming.

- **Grid:** Use a 12-column grid for desktop and a 4-column grid for mobile.
- **Margins:** Desktop views should employ wide safe-area margins (up to 120px) to center the focus and mimic the look of an open journal.
- **Rhythm:** Use an 8px base unit. Components should have generous internal padding (usually 16px or 24px) to ensure they feel "cushioned."
- **Focus Mode:** In "Deep Work" views, hide all non-essential navigation and expand the primary task container to occupy the central 60% of the screen.

## Elevation & Depth

Depth in this design system is achieved through **Tonal Layering** and **Soft Ambient Shadows**.

1.  **Surfaces:** The base layer is the Tertiary Beige. Elevated containers use a pure white background with 60% opacity (Glassmorphism) when placed over decorative background textures or illustrations.
2.  **Shadows:** Use extremely diffused, large-radius shadows (e.g., `box-shadow: 0 10px 30px rgba(98, 88, 84, 0.08)`). Shadows should feel like ambient light hitting a soft object, never harsh or dark.
3.  **Glassmorphism:** Overlays, modals, and navigation bars should use a `backdrop-filter: blur(12px)` with a thin 1px border colored at 20% opacity of the neutral tone to give the appearance of smooth, frosted glass.

## Shapes

The shape language is defined by extreme roundedness (**2XL/Pill-shaped**). This removes any "sharpness" from the UI, making it feel safe and tactile.

- **Standard Buttons & Inputs:** Use the `rounded-xl` (1.5rem) setting.
- **Feature Cards & Large Containers:** Use a custom `32px` corner radius to mimic the look of a rounded tablet or physical journal.
- **Selection Indicators:** Use pill shapes (fully rounded) for chips and active navigation states.

## Components

- **Buttons:** Primary buttons are Sage Green with white text, using a subtle "squishy" scale-down effect (0.95) on press. Secondary buttons are outlined with a 2px stroke in the neutral color.
- **Cards:** White or semi-transparent glass containers with 32px rounded corners. Include a subtle 1px inner highlight on the top edge to simulate physical thickness.
- **Input Fields:** Soft beige backgrounds with no border, becoming Sage Green on focus. Place labels inside the container for a cleaner, less "form-like" look.
- **Chips/Badges:** Use the Terracotta color for "Break" chips and Sage for "Focus" chips. Always pill-shaped.
- **Progress Bars:** Thick (12px), rounded tracks. Use a soft gradient of the primary color for the fill.
- **Custom Component - "Focus Hearth":** A central animated component that serves as a visual anchor. It uses glassmorphism and contains the timer or current task, surrounded by hand-drawn illustrations that evolve as the user stays focused.
- **Checkboxes:** Replaced with "Stamp" style icons. When a task is completed, it is covered by a soft-edged, hand-drawn "check" mark or a decorative sticker.