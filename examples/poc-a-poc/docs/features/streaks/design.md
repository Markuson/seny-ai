# Streaks — design

Platform: mobile (React Native + Expo)
References: none beyond the design system

## Direction
See `../../project/design-system.md`.

## Tokens
No new tokens: the badge uses `color.accent` on `color.surface`.

## Components
| Component | New / reuse | Variants | States |
|---|---|---|---|
| HabitCard | reuse `components/ui/HabitCard`, new optional `badge` slot | personal, shared | todo, done, skipped day |
| StreakBadge | new, in `features/streaks/` | — | hidden (< 2), shown |
| ReminderRow | new, in `features/reminders/` | — | off, on, permission denied |

## Screens
### screen-today
- Purpose: check off today's habits and see their streaks.
- Layout:
  ```
  ┌───────────────────────────┐
  │ Today · Tuesday           │
  │ [🌱 Read 10 min  🔥 5 days]│
  │ [💧 Water plants   ✓ done ]│
  │ [🦷 Brush teeth           ]│
  └───────────────────────────┘
  ```
- Components: HabitCard list, StreakBadge inside the card's badge slot.
- States: loading (3 skeleton cards) · empty ("No habits yet. Add your first one, little by little.") · error ("Couldn't load today. Pull to try again.") · success
- Platform (mobile): the badge never wraps under the title; at 200% dynamic type it moves to a second line.

### screen-habit-settings
- Purpose: set or remove the habit's reminder time.
- Components: ReminderRow (switch + time picker).
- States: off · on (shows the time) · permission denied ("Notifications are off for Poc a poc. Turn them on in Settings to get reminders." + button to Settings)
- Platform (mobile): native time pickers; Android needs the exact-alarm permission explanation if the OS asks.

## Flows
1. Kid opens Today → sees "🔥 5 days" on "Read 10 min" → taps the card → it turns done; the badge stays (the streak counts today).
2. Parent opens a habit's settings → turns the reminder on → picks 19:30 → if permission isn't granted, the OS asks; if denied, the denied state appears.

## Accessibility
- Badge label: "5 day streak", read after the habit title.
- Contrast: `color.accent` on `color.surface` at 3.2:1, used only for the icon; the text uses `color.text`.
- Touch targets ≥ 48×48 dp for the card and the switch.

## Copy
- Badge: "🔥 {n} days"
- Denied hint: "Notifications are off for Poc a poc. Turn them on in Settings to get reminders."

## Story mapping
| Section | Stories |
|---|---|
| screen-today | E1-S3 |
| screen-habit-settings | E2-S1 |
