# Design system

Status: approved (2026-10-22)
Platform: mobile (React Native + Expo)
References: Finch (tone), Streaks (speed)

## Direction
Warm, rounded and unhurried, like a kitchen-table notebook. Big touch targets for small hands, soft colours, one cheerful accent. Celebrate gently; never shame. Avoid badges, leaderboards and red numbers.

## Tokens
Semantic names, mapped to the NativeWind theme in `apps/mobile/tailwind.config.ts`.
| Token | Light | Dark | Use |
|---|---|---|---|
| color.bg | #FBF7F2 | #1C1A17 | app background |
| color.surface | #FFFFFF | #27241F | cards, sheets |
| color.text | #2B2620 | #F3EEE7 | body text |
| color.text-muted | #6E655B | #B4AA9E | secondary text |
| color.primary | #2F7D6D | #5FB8A4 | main actions, done state |
| color.accent | #F2A541 | #F5B860 | streaks, celebrations |
| color.danger | #B5473A | #E07A6E | destructive actions only |
| color.border | #E8E0D5 | #3A352E | dividers, inputs |

## Typography
| Role | Family | Size / line height | Weight |
|---|---|---|---|
| display | Nunito | 32 / 38 | 800 |
| title | Nunito | 22 / 28 | 700 |
| body | Nunito | 17 / 24 | 500 |
| caption | Nunito | 14 / 20 | 600 |

## Spacing, radius, elevation
4-pt grid (4, 8, 12, 16, 24, 32). Radius: 12 (inputs), 20 (cards), full (buttons and chips). One soft shadow for cards; none in dark mode.

## Motion
150 ms for presses, 300 ms ease-out for check-in celebrations. Reduced motion: no scale or confetti, colour change only.

## Base components
| Component | Variants | States | Location |
|---|---|---|---|
| Button | primary, secondary, ghost, danger | default, pressed, focus, disabled, loading | `components/ui/Button` |
| HabitCard | personal, shared | todo, done, skipped day | `components/ui/HabitCard` |
| Avatar | member, family | default, selected | `components/ui/Avatar` |
| EmptyState | — | — | `components/ui/EmptyState` |

## Accessibility rules
- AA contrast for every text/background pair; `color.accent` is never used for text on `color.bg`
- Accessibility labels and roles on every pressable; check-ins announce "done" or "not done"
- Touch targets ≥ 48×48 dp (kids)
- Dynamic type up to 200% without breaking cards
- Reduced motion respected
