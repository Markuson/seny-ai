# Streaks — research

## Problem
Families check off habits, but nothing shows progress over time, so motivation fades after a week. Streaks make progress visible, and a gentle reminder before a streak breaks keeps it going without nagging.

## Users / roles
- Kid: sees their streak grow on each habit card; a reminder helps them not forget.
- Parent: sees each member's streaks, never compared side by side (product rule).

## Constraints
- Dates in the family time zone (product rule; `architecture.md` conventions).
- No ranking between members (product rule).
- Check-ins work offline (`product.md` constraints).

## Codebase
- Check-ins exist: `apps/api/src/routes/checkins.ts:12` (create, list by habit) and `apps/mobile/features/today/useCheckIn.ts:8` (optimistic mutation). Tested: `checkins.route.test.ts`, 6 tests.
- No streak logic anywhere. `packages/shared/src/` has date helpers (`familyDay.ts:5`, tested) to reuse.
- `HabitCard` (`apps/mobile/components/ui/HabitCard.tsx`) has no slot for extra info; tested for its three states.
- Notifications: `expo-notifications` is not installed yet.

## Fit with the project
- Relies on the data model (`check_in.day` as a family-zone date) and the shared-domain convention: streak logic belongs in `packages/shared`.
- Would change: `HabitCard` gets a streak badge (a design-system change, to propose), and a new dependency (`expo-notifications`).

## Challenges
- Daylight-saving days: a day can be 23 or 25 hours; using `day` strings avoids it, timestamps don't.
- Habits on `weekdays` schedules: a skipped Saturday must not break a streak.
- Reminders must survive app restarts and work offline.

## Risks
- Notification permission refused: reminders silently do nothing.
- Kids sharing a parent's phone get the parent's reminders.

## Assumptions
- (assumption) One reminder per habit per day is enough.

## Open questions
- ~~Can reminders be scheduled locally, offline, and survive a restart? (spike)~~ Yes, see below.
- Should a parent be able to turn reminders off for a kid profile? → decided in plan: yes, per habit.

## Spike findings

### Can `expo-notifications` schedule daily local reminders that survive restarts and work offline? — 2026-11-02
- Answer: yes — daily triggers persist across restarts on iOS 18 and Android 15 with no network.
- Evidence: a scheduled daily trigger at 19:30 fired on both test phones after force-quitting the app and in airplane mode (3 days); `getAllScheduledNotificationsAsync()` still listed it after a reboot on Android.
- Tried: `TimeIntervalTrigger` (drifts and is cleared on Android reboot, dropped); `DailyTriggerInput` (works).
- Consequences for the plan: reminders are local, no push or scheduler needed (key decision in `architecture.md`). The plan must handle denied permission with a visible hint, and reschedule when a habit's reminder time changes.
- Code: branch `spike/local-reminders` (not merged)
