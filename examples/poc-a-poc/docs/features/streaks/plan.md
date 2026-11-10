# Streaks

Branch: `feature/streaks`
Research: `research.md`

## Goal
Every habit shows how many scheduled days in a row it's been done, and a gentle local reminder arrives before a streak would break. For kids and parents alike, without comparing anyone.

## Scope
- In: streak per habit and member, shown on the habit card — the core of the feature.
- In: one daily local reminder per habit, with the time set by the owner or a parent — keeps streaks alive.
- Out: longest streak and history charts — later, if families ask.
- Out: push notifications from the server — the spike showed local reminders are enough.

## Architecture changes
- Structure: `packages/shared/src/streaks.ts`; `apps/mobile/features/reminders/`
- Data and state: `habit.reminderTime` (nullable `HH:mm`); streak computed on the API from check-ins, returned with the habit
- App-wide changes: `HabitCard` gets a streak badge slot (approved for `design-system.md`, 2026-11-03); new dependency `expo-notifications` (approved)

## Key decisions
- Compute streaks on the API, not on the device — one source of truth across the family's phones (rejected: computing on each device from cached check-ins)
- Days that aren't scheduled don't break a streak — a `weekdays` habit keeps its streak over the weekend (rejected: calendar-day streaks)

## Epics

### E1 · See the streak
Each habit card shows its current streak.

#### E1-S1 · Know which days count — `done`
- Story: As a family member, I want weekends to not break my weekdays habits, so that streaks feel fair.
- Acceptance criteria:
  - [x] A `daily` habit counts every day
  - [x] A `weekdays` habit counts Monday to Friday only
- Approach:
  - Add `isScheduledDay(schedule, day)` to `packages/shared/src/schedule.ts`, reusing `familyDay.ts:5` for weekday maths
- Files: packages/shared/src/schedule.ts
- Tests: `tdd` — both schedules, plus a Sunday and a Monday
- Verify: auto — `schedule.test.ts` · manual — none
- Depends on: —
- Review 2026-11-03: APPROVED

#### E1-S2 · Count the current streak — `review`
- Story: As a family member, I want to see how many days in a row I've done a habit, so that I keep going.
- Acceptance criteria:
  - [x] A habit done today and on the 4 previous days shows a streak of 5
  - [x] Missing yesterday resets the streak to 1 when today is done, 0 when it isn't
  - [x] Days are counted in the family's time zone, not the device's
- Approach:
  - Add `currentStreak(checkIns, today, timeZone)` to `packages/shared/src/streaks.ts`, a pure function
  - Expose it through `GET /habits/:id` in `apps/api/src/routes/habits.ts:41`, next to `lastCheckIn`
- Files: packages/shared/src/streaks.ts, apps/api/src/routes/habits.ts
- Tests: `tdd` — the three criteria, plus a daylight-saving change
- Verify: auto — `streaks.test.ts`, `habits.route.test.ts` · manual — check in a habit on two days on the simulator and see 2
- Depends on: E1-S1
- Review 2026-11-04: CHANGES REQUESTED
  - [x] [blocker] apps/api/src/routes/habits.ts:58 — streak computed in UTC → pass the family time zone
  - [ ] [should] packages/shared/src/streaks.ts:12 — sort check-ins once, not per call → sort in the caller
- Review 2026-11-04: APPROVED

#### E1-S3 · Show the streak on the habit card — `in-progress`
- Story: As a kid, I want to see my streak on each habit, so that I'm proud of it.
- Acceptance criteria:
  - [x] A habit with a streak of 2 or more shows a badge "🔥 5 days"
  - [ ] A streak of 0 or 1 shows no badge (no pressure)
  - [ ] Screen readers announce "5 day streak"
- Approach:
  - Add an optional `badge` slot to `components/ui/HabitCard.tsx`, then render `StreakBadge` from `features/streaks/` in `features/today/TodayScreen.tsx:33`
- Files: apps/mobile/components/ui/HabitCard.tsx, apps/mobile/features/streaks/StreakBadge.tsx, apps/mobile/features/today/TodayScreen.tsx
- Tests: `after` — badge shown and hidden, accessible label
- Verify: auto — `StreakBadge.test.tsx`, `HabitCard.test.tsx` · manual — light and dark mode, dynamic type at 200% on a small Android phone
- Design: `design.md#screen-today`
- Depends on: E1-S2
- Notes: badge slot and StreakBadge done and tested; next: hide the badge under 2 and add the accessibility label, then wire it in TodayScreen. Decided to keep the 🔥 inside the label text, not as an image.

### E2 · Keep the streak
A reminder arrives before a streak would break.

#### E2-S1 · Remind before the streak breaks — `todo`
- Story: As a kid, I want a reminder in the evening when I haven't done a habit yet, so that I don't lose my streak.
- Acceptance criteria:
  - [ ] A habit with a reminder time gets one local notification that day, only if it isn't done yet
  - [ ] Changing or removing the reminder time reschedules or cancels it
  - [ ] With notifications denied, the habit screen shows a hint to enable them
- Approach:
  - `features/reminders/scheduleReminder.ts` with `DailyTriggerInput` (see spike findings); cancel today's reminder from `useCheckIn.ts:8` on success
  - `reminderTime` column via a Drizzle migration in `apps/api/src/db/schema.ts`
- Files: apps/mobile/features/reminders/*, apps/mobile/features/today/useCheckIn.ts, apps/api/src/db/schema.ts, migration
- Tests: `tdd` — scheduling rules with a mocked notifications module; `after` — the denied-permission hint
- Verify: auto — `scheduleReminder.test.ts` · manual — on a real Android and iPhone: set a reminder 2 minutes ahead, see it fire; check in first, see it not fire; deny permission, see the hint
- Design: `design.md#screen-habit-settings`
- Depends on: E1-S2
