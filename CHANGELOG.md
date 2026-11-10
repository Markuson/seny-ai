# Changelog

All notable changes to Seny. Versions follow [semver](https://semver.org/): while Seny is `0.x`, minor versions may change commands or document formats.

## [0.3.0] — 2026-11-10

The RPI loop gets tighter: plans carry the how, review runs on its own, and rauxa gets a sandbox.

### Added
- `/seny:spike <question>`: answers one technical question with throwaway code on a `spike/<slug>` branch, time-boxed, and writes the findings into the feature research. The only command allowed to write disposable code.
- **Automatic review**: `/seny:implement` runs the independent reviewer itself and does one round of fixes for blockers. Switch it off per project (`- Seny review: manual`) or per run (`no-review`). Only the human still moves a story to `done`.
- Story fields: `Approach:` (how to build it, anchored to `file:line`), `Verify:` (automatic and manual checks) and `Notes:` (hand-over when a story stops half-way and the context gets `/clear`ed).
- `/seny:plan <slug> <change>`: Change mode, updates a plan without touching stories that already started.
- `/seny:review <id> done`: closes an approved story without reviewing again.
- Closing a feature proposes a PR title and body from the plan. Repeated review findings lead to a proposed project rule (learning loop).
- `references/review-loop.md` and `references/close-story.md`: one procedure shared by implement, review and fix.
- `templates/stack.example.md` → `~/.claude/seny/stack.md`: stack choices for new apps, read only by `/seny:plan project`.

### Changed
- Project docs split: `product.md` (new app), `codebase.md` (existing code) and `baseline.md` replace the two-format `project/research.md`. The baseline records its commit.
- `state.sh` tells whether the baseline is current or stale (recorded on another line of history, or other people's work came in since), and prints the review mode. `implement` and `fix` re-record a stale baseline before changing code. The last `foundation` story records an all-green one.
- Templates: one file per document (`templates/project/`, `templates/feature/`); the plan format moved out of the plan skill into `templates/feature/plan.md`.
- `/seny:help`: work in flight comes first, a Spike track, roadmap rows typed `feature` or `evolution` (evolutions point to `/seny:evolve`), and a declined design system is remembered (`Design system:` line in `architecture.md`).
- `implement` and `fix` ask to commit or stash unrelated changes first, so each review sees one story.
- `fix` offers to record the same mistake found elsewhere as tech debt in `codebase.md`.
- Smaller always-loaded files: the project `CLAUDE.md` template went from 3.3 KB to 1.9 KB, the personal one from 7.2 KB to 3.3 KB.
- Skill descriptions shortened for the `/` menu.

## [0.2.0] — 2026-11-10

Robustness: what Seny promises is now enforced, not just requested.

### Added
- `hooks/hooks.json` + `scripts/guard.sh`: a `PreToolUse` hook that blocks `git push` everywhere (opt out with `SENY_ALLOW_PUSH=1`) and keeps the `seny:reviewer` agent read-only (no file tools, no mutating Bash commands). Plain bash, no `jq` needed.
- `/seny:init` proposes the project's check commands for `.claude/settings.local.json` so checks run without permission prompts, and makes sure that file stays out of git.
- Private mode loads `.seny/CLAUDE.md` in every session through a `CLAUDE.local.md` import (both excluded with `.git/info/exclude`).
- Reviewer runs with `effort: high` and a `color` in the transcript.

### Changed
- `scripts/state.sh` rewritten: runs from the git root (works from any subfolder), shows the default branch and warns when you are on it, finds the docs root in `CLAUDE.md`, `CLAUDE.local.md` or `.seny/CLAUDE.md`, prints when the baseline was recorded, and lists only open work: one line per open feature with story counts, finished features collapsed into one line, only stories that are not `done`.
- Skills no longer assume pnpm: check commands come from the project rules, and the plugin only pre-approves read-only git commands.
- Narrower pre-approvals: `git branch *` and `git diff *` replaced with read-only forms.
- `/seny:help` can no longer edit files (`disallowed-tools`).
- Stack-specific test rules (no snapshots, query by role, no `any`) moved out of the reviewer: it applies the rules in your `CLAUDE.md` files, which it already inherits.

## [0.1.0] — 2026-11-04

First version: 8 skills (`init`, `research`, `plan`, `implement`, `review`, `fix`, `evolve`, `help`), the `reviewer` agent, project and feature templates.
