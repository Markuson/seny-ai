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
- `<docs>/project/` — app-wide: `research.md` (product, or codebase analysis and checks baseline), `architecture.md`, `design-system.md`, `roadmap.md`. Read `architecture.md` before changing structure, state or boundaries, and `design-system.md` before any UI work.
- `<docs>/features/<slug>/` — one feature: `research.md`, `plan.md`, `design.md` when it has UI. Feature docs build on the project docs and never repeat them.

| Phase     | Command                                   | Result                                              |
|-----------|-------------------------------------------|-----------------------------------------------------|
| Setup     | `/seny:init`                              | this file and the docs folders                      |
| Research  | `/seny:research project [refresh] \| <feature>` | project or feature `research.md`              |
| Plan      | `/seny:plan project \| <slug> [design] \| light <change>` | project docs, or feature `plan.md` / `design.md` |
| Implement | `/seny:implement <id> \| next`            | code; story → `review`                              |
| Review    | `/seny:review [id]`                       | story → `done` (I approve) or back to `in-progress` |
| Fix       | `/seny:fix <bug>`                         | failing test → root cause → minimal fix → review    |
| Evolve    | `/seny:evolve <change>`                   | options → incremental migration plan → transition in `architecture.md` |
| Help      | `/seny:help [what I want]`                | where I am, the right track and the next command    |

- The plan is the source of truth for a feature; `architecture.md` and `design-system.md` for the app. If reality contradicts them, stop and propose a change.
- App-wide changes go to the project docs only after I approve them.
- Statuses: `todo`, `in-progress`, `review`, `done`. Only I move a story to `done`.
- Only new check failures block; the baseline lists the ones that were already there.
- Changing untested code starts with characterization tests.
- Areas **In transition** in `architecture.md`: new code uses the target pattern, never the old one.
- One story = one commit, made when the story is `done`.
- Start a new phase with `/clear` when the context is heavy. The docs carry the state, not the chat.
