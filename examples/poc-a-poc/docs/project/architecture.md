# Architecture

Status: approved (2026-11-03)
Last updated: 2026-11-03 by streaks
Design system: `design-system.md`

## Stack
| Layer | Choice | Why |
|---|---|---|
| App | React Native + Expo SDK 54 | iOS and Android from one codebase; no custom native modules needed |
| Styling | NativeWind 4 | Tailwind tokens shared with a future web page |
| State | TanStack Query (server) + Zustand (client) | Check-ins are server state; the selected member is client state |
| Backend | Hono on Node 22 | Several clients later (widgets, web); typed RPC client |
| Database | PostgreSQL + Drizzle | Relational data, migrations in code |
| Auth | Better Auth (+ `@better-auth/expo`) | Email for adults; kid profiles have no credentials |
| CMS | none | |
| Hosting | EAS (app), Fly.io (API and Postgres) | Free tiers cover the MVP |

## Structure
pnpm workspaces:
- `apps/mobile` — Expo Router app: `app/` (routes), `features/<feature>/` (screens, hooks, components), `components/ui/` (base components)
- `apps/api` — Hono app: `src/routes/`, `src/db/` (Drizzle schema and migrations), `src/auth.ts`
- `packages/shared` — Zod schemas, types and pure domain functions used by both sides

## Data and state
- Server state: habits, check-ins and family come from the API through TanStack Query (`apps/mobile/lib/api.ts`, typed `hc<AppType>` client). Query keys per family.
- Client state: `useSession` store (selected member, family id) in Zustand.
- Offline: check-ins are queued with TanStack Query's mutation persistence and replayed on reconnect.

## Data model
- `family` (id, name, timeZone, inviteCode)
- `member` (id, familyId, name, role: `parent` | `adult` | `kid`, userId nullable for kids)
- `habit` (id, familyId, ownerMemberId, title, emoji, schedule: `daily` | `weekdays`, shared: boolean)
- `check_in` (id, habitId, memberId, day: date in the family time zone, createdAt)

## Boundaries
- External services: Expo push service (not used yet; reminders are local, see key decisions).
- Auth: parents and adults sign in; every route checks the member belongs to the family in the path. Kids act through the parent's device session.
- Validation: Zod schemas in `packages/shared/src/schemas/`, validated in Hono with `@hono/zod-validator`.

## Conventions
- Dates cross the API as `YYYY-MM-DD` strings in the family time zone, never as timestamps.
- Domain rules (streaks, schedules) are pure functions in `packages/shared`, tested there and reused by app and API.

## Key decisions
- 2026-10-21 Hono over Supabase — several clients and custom rules (streaks, kid profiles) (rejected: Supabase, logic would end up in the client)
- 2026-10-21 Kids as profiles without accounts — privacy and store rules for under-13s (rejected: kid accounts with parental consent flow)
- 2026-11-03 Reminders as local notifications scheduled on the device — the spike showed `expo-notifications` covers it offline (rejected: push from the API, needs a scheduler and more personal data)
