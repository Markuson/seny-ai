# Foundation

Branch: `feature/foundation`
Research: `../../project/product.md`

## Goal
A running, deployed, boringly solid base for the app and the API, with nothing product-specific: the pinya of the human tower.

## Scope
- In: monorepo, strict TypeScript, checks wired, theme from the design system, base navigation, CI, placeholder deploys — everything later features stand on.
- Out: auth flows and real data — they belong to the features that need them.

## Key decisions
- One monorepo with `packages/shared` — domain rules written once (rejected: two repos with copied types)

## Epics

### E1 · Running everywhere
The app opens on a phone and the API answers in production.

#### E1-S1 · Scaffold the monorepo — `done`
- Acceptance criteria:
  - [x] `pnpm dev` starts the Expo app and the API together
  - [x] Strict TypeScript in every package; `pnpm typecheck` passes
- Approach:
  - pnpm workspaces with `apps/mobile` (create-expo-app, Router template), `apps/api` (Hono), `packages/shared`
- Files: package.json, pnpm-workspace.yaml, apps/*, packages/shared
- Tests: `none` — scaffolding
- Verify: auto — `pnpm typecheck` · manual — the app opens on the iOS simulator and an Android device
- Depends on: —
- Review 2026-10-24: APPROVED

#### E1-S2 · Checks and CI — `done`
- Acceptance criteria:
  - [x] `pnpm lint`, `pnpm typecheck` and `pnpm test` run in every package
  - [x] CI runs them on every pull request
- Approach:
  - Vitest in `api` and `shared`, `jest-expo` in `mobile`, one GitHub Actions workflow
- Files: package.json scripts, .github/workflows/ci.yml, vitest and jest configs
- Tests: `after` — one smoke test per package
- Verify: auto — the three commands pass locally and in CI · manual — a failing test fails the CI run
- Depends on: E1-S1
- Review 2026-10-25: APPROVED

#### E1-S3 · Theme and base components — `done`
- Acceptance criteria:
  - [x] The design-system tokens are in the NativeWind theme, light and dark
  - [x] Button, HabitCard, Avatar and EmptyState exist with every listed state
- Approach:
  - Tokens in `apps/mobile/tailwind.config.ts`; components in `components/ui/` following `design-system.md`
- Files: apps/mobile/tailwind.config.ts, apps/mobile/components/ui/*
- Tests: `after` — states rendered and accessible by role
- Verify: auto — component tests · manual — light and dark on both platforms, dynamic type at 200%
- Design: `../../project/design-system.md#base-components`
- Depends on: E1-S1
- Review 2026-10-28: APPROVED

#### E1-S4 · Deploy and baseline — `done`
- Acceptance criteria:
  - [x] The API is deployed on Fly.io and answers `GET /health`
  - [x] An internal EAS build installs on a phone and shows the placeholder home screen
  - [x] `docs/project/baseline.md` records every check green
- Approach:
  - `fly launch` with Postgres; EAS internal distribution profile; record the baseline last
- Files: apps/api/fly.toml, apps/mobile/eas.json, docs/project/baseline.md
- Tests: `none` — deployment
- Verify: auto — `curl https://poc-a-poc-api.fly.dev/health` · manual — install the EAS build on a phone
- Depends on: E1-S2, E1-S3
- Review 2026-10-30: APPROVED
