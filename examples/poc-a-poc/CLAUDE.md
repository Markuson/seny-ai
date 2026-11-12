# CLAUDE.md

Project-specific rules. Personal defaults (language, git, stack, TypeScript, testing) live in `~/.claude/CLAUDE.md`; anything here overrides them.

## Project
Poc a poc: a habit tracker for families. Parents and kids track small daily habits together and cheer each other on. Kindness over competition: nothing in the app shames anyone.

## Stack
- Expo (SDK 54) + React Native + TypeScript, NativeWind
- TanStack Query (server state), Zustand (client state)
- API: Hono on Node 22, PostgreSQL + Drizzle, Better Auth
- Deploy: EAS (app), Fly.io (API)

## Commands
- Package manager: pnpm (workspaces)
- `pnpm dev` — app and API in watch mode
- `pnpm lint` · `pnpm typecheck` · `pnpm test` — compared against the baseline before a story goes to review
- `pnpm build` — API build and app export
- `pnpm e2e` — Maestro flows (run by hand, never in review)

## Product rules
- Never show a ranking between family members.
- Never invent data: a day without a check-in is "not done", never guessed.
- Every date is computed in the family's time zone, never the device's.

## Repo conventions
- Commits: `<type>: <description>` (types: feature, fix, refactor, test, docs, chore)
- Branches: `<type>/<short-description>`
- PRs: one feature per PR

## Seny
- Seny docs: `docs`
- Seny review: auto
- `<docs>/project/` is app-wide: `product.md`, `codebase.md`, `baseline.md`, `architecture.md`, `design-system.md`, `roadmap.md`. Read `architecture.md` before changing structure, state or boundaries, and `design-system.md` before UI work.
- `<docs>/epics/<slug>/` is one epic (a roadmap row: one branch, one PR): `plan.md`, plus `research.md` and `design.md` when its size or UI needs them. The plan is the source of truth; if reality contradicts it, stop and propose a change.
- Documents are `draft` until I approve them; nothing builds on a draft. One document per run, `/clear` between them.
- Story statuses: `todo` → `in-progress` → `review` → `done`. Only I move a story to `done`. One story = one commit = one session.
- Only new check failures block: `baseline.md` lists the old ones. Untested code gets characterization tests before it changes.
- Areas **In transition** in `architecture.md`: new code uses the target pattern, never the old one.
- App-wide doc changes only after my yes. Not sure what's next: `/seny:help`.
