# CLAUDE.md

Project-specific rules. Personal defaults (language, git, stack, TypeScript, testing) live in `~/.claude/CLAUDE.md`; anything here overrides them.

## Project
<!-- 2–3 lines: what this is, for whom, and what matters most. -->

## Stack
- <Astro | Next.js (App Router) | React Native + Expo | ...> + TypeScript
- <styling>
- <data layer / backend>
- Deploy: <target>

## Commands
- Package manager: <pnpm | the project's own, if different>
- `<dev>` — dev server
- `<lint>` · `<typecheck>` · `<test>` — compared against the baseline before a story goes to review
- `<build>` — production build
- `<e2e>` — <Playwright | Maestro | none>

## Product rules
<!-- Rules the reviewer treats as blockers. -->
- <e.g. Never invent data: unknown values are shown as unknown.>

## Repo conventions
<!-- Detected by /seny:init. They override the personal defaults. -->
- Commits: <format seen in git log>
- Branches: <naming seen in the repo>
- PRs: <template or rules>

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
