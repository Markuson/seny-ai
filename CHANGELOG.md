# Changelog

All notable changes to Seny. Versions follow [semver](https://semver.org/): while Seny is `0.x`, minor versions may change commands or document formats.

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
