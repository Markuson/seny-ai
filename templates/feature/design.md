# Design document template

Write `<docs>/features/<slug>/design.md` with the sections below. Omit what the feature doesn't need. Be concrete: values, names and states, not adjectives.

If `<docs>/project/design-system.md` exists, the feature design builds on it: no Direction section (link to it instead), and Tokens and Components list only what is new. Anything new that other features will reuse is proposed for `design-system.md`, not kept here.

```markdown
# <Feature name> — design

Platform: <web (Astro | Next.js) | mobile (React Native + Expo) | both>
References: <links, screenshots, Figma frames, or "none">

## Direction
<"See design-system.md", or, if there is no design system: 3–5 lines on tone, visual personality, what it must feel like, and what to avoid. For web, the aesthetic direction from the frontend-design skill.>

## Tokens
Only new or changed tokens; reuse the existing theme. Name them semantically and map them to the Tailwind / NativeWind config.
| Token | Light | Dark | Use |
|---|---|---|---|
| color.surface | ... | ... | page and card backgrounds |
- Typography: <families, scale (size / line height / weight) per role: display, title, body, caption>
- Spacing and radius: <scale used, e.g. 4-pt grid>
- Motion: <durations, easing; what animates and what doesn't; respects reduced motion>

## Components
| Component | New / reuse | Variants | States |
|---|---|---|---|
| Button | reuse `components/Button` | primary, ghost | default, hover, pressed, focus, disabled, loading |

## Screens
### screen-<name>
- Purpose: <one line>
- Layout:
  ```
  ┌───────────────────────┐
  │ header                │
  │ [ list of items     ] │
  │ [ primary action    ] │
  └───────────────────────┘
  ```
- Components: <which, in which order>
- States: loading · empty (with copy) · error (with copy and recovery) · success
- Responsive (web): <what changes at each breakpoint>
- Platform (mobile): <safe areas, keyboard, iOS vs Android differences, gestures>

## Flows
<user flows as numbered steps across screens, including the unhappy path>

## Accessibility
- Contrast: every text/background pair at AA (4.5:1 text, 3:1 large text and UI)
- Focus order and visible focus (web); accessibility labels and roles (mobile)
- Touch targets ≥ 44×44 pt (iOS) / 48×48 dp (Android)
- Dynamic type / browser zoom up to 200% without breaking the layout
- Reduced motion respected

## Copy
<labels, button texts, empty and error messages — in the product's language>

## Story mapping
| Section | Stories |
|---|---|
| screen-<name> | E1-S2, E1-S3 |
```
