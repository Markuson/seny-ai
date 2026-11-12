# Changelog

All notable changes to Seny. Versions follow [semver](https://semver.org/): while Seny is `0.x`, minor versions may change commands or document formats.

## [0.6.0] — 2026-11-12

Lessons from the first real project: smaller documents, cheaper runs, tighter rails, and tests for Seny itself.

### Added
- **Size guide** for every document (typical sizes, never limits): a clearly longer draft comes with the reason and a choice (keep, move raw material to `<docs>/project/inputs/`, or trim named parts); nothing is cut without your say.
- **Epic notes** in the roadmap: up to three lines per epic, so a size-S plan reads its row and notes instead of the whole product document.
- Interview answers are saved in the draft after each round; an interrupted interview resumes.
- `tests/run.sh` (guard, state snapshot, repo lint) and a CI workflow on Linux and macOS.
- `Type: light` for plans outside the roadmap.

### Changed
- The guard also blocks `git` called by path (`/usr/bin/git push`) and the GitHub CLI commands that push (`gh pr create`, `gh pr merge`, `gh repo sync`).
- Branches: project documents on the default branch; an epic's first document creates the epic's branch. The default-branch warning only shows when there is epic work.
- `/seny:evolve` takes two runs instead of three: approving the research is choosing the option.
- The second review after a fix round is a cheaper **re-review** of the findings and the files the fixes touched.
- The state snapshot prints compact roadmap rows (no goals).
- Questions use the `AskUserQuestion` tool when available.

## [0.5.0] — 2026-11-12

Planning gets the weight it deserves: one document at a time, epics with sizes, and the agile three levels.

### Changed
- **Project → epics → stories.** "Features" are now **epics**: one roadmap row, one folder (`<docs>/epics/<slug>/`), one branch, one pull request. Plans are a flat list of stories `S1…Sn`; there are no epics inside a plan any more. Story ids elsewhere are `<slug> S2`.
- **Sizes.** Every roadmap row has a size (S 1–3 stories, M 4–8, L more) that decides how much planning the epic gets: S is a plan only, M is research then plan, L is research then a plan in two passes (shape, then stories), or a split.
- **One document per run.** Research, plan and evolve write a single document through a shared loop (`references/document-loop.md`): an interview in rounds with recommended answers, a draft, a self-check, your review, changes, approval, a commit proposal and the next command after `/clear`. The depth of the interview follows the weight of the document.
- **Document status.** Every document carries `Status: draft` until approved (`shape approved` between the passes of a large plan). Nothing builds on a draft; `/seny:implement` requires an approved plan; the state snapshot shows every status and size.
- New-app planning runs in order: `product.md` → `architecture.md` → `design-system.md` → `roadmap.md` → the foundation plan (two passes). Existing code: `codebase.md` + `baseline.md` → `architecture.md` → `design-system.md`.
- After the architecture is approved, `/seny:plan project` fills the Stack, Commands and Product rules placeholders of the project rules.
- Plans never restate `architecture.md`: they name the sections they rely on.
- Templates moved to `templates/epic/`; the roadmap gained a `Size` column.
- `/seny:help` routes by document status and epic size.
- Docs, README and the example project updated to the new structure.

### Migrating from 0.4
Rename `<docs>/features/` to `<docs>/epics/`, turn `#### E1-S2 ·` headings into `#### S<n> ·` (one flat list per plan), add `Status:` lines to the documents you already approved, and a `Size` column to the roadmap.

## [0.4.0] — 2026-11-10

Documentation: everything Seny does, explained, with a real example.

### Added
- `guide/concepts.md`: tracks, documents, the anatomy of a story, statuses, the baseline (with a worked example), characterization tests, reviews, spikes, evolutions, design, shared and private mode, the state snapshot, context hygiene and a glossary.
- `guide/commands.md`: every command with what it reads, writes, asks and stops on.
- `guide/configuration.md`: personal rules, stack defaults, project rules, review mode, commits, permissions, the safety hook, private mode, monorepos, companion skills, several machines.
- `guide/faq.md`: frequent questions and troubleshooting.
- `examples/poc-a-poc/`: a small app halfway through its second feature, with every document Seny writes and stories in every status.

### Changed
- README rewritten: clearer title and pronunciation, statuses table, install and update, links to the guide and the example.
- `/seny:implement` resumes an `in-progress` story that has neither notes nor findings by reading the diff.
- `/seny:plan` Change mode can remove `todo` stories.
- Design skill name corrected to `vercel-react-native-skills`.

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
