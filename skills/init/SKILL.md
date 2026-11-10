---
name: init
description: Set up Seny in a project, new or existing. Detects the stack, commands and repo conventions, asks where the docs live, and creates the project CLAUDE.md and docs folders without overwriting anything.
argument-hint: "[notes about the project]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git branch -a) Bash(git branch --show-current) Bash(git status *) Bash(git ls-files *) Bash(git check-ignore *) Bash(ls *)
---

# Seny init

Notes: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

## Rules
- Never overwrite or rewrite existing content. Existing instructions win: you add to them, and you show me the exact text before writing it.
- Never migrate anything here (package manager, tooling, folders). If something should change, note it as a candidate feature.
- Ask all your questions in one batch.

## Steps
1. **Detect**, read-only:
   - Instructions already there: `CLAUDE.md` (root and nested), `AGENTS.md`, `.claude/`, `README.md`, `CONTRIBUTING.md`, architecture decision records (`docs/adr/`, `docs/decisions/`).
   - Stack and commands: `package.json` (all of them in a monorepo: `pnpm-workspace.yaml`, `turbo.json`, `apps/*`, `packages/*`), scripts for dev, lint, typecheck, test, e2e, build; the lockfile.
   - Repo conventions: commit style from `git log --oneline -30`, branch naming from `git branch -a`, `.github/pull_request_template.md`, `.github/workflows/`.
   - New project or existing one: application code or not.
2. **Ask**, in one batch:
   - Where Seny's docs live:
     - **Shared** — `docs/` in the repo, committed (your own projects, teams that want them).
     - **Private** — `.seny/`, kept out of git with `.git/info/exclude` (client or team repos where you can't add files). Nothing tracked is modified.
   - Package manager, only if the lockfile doesn't match the one preferred in my personal rules (`~/.claude/CLAUDE.md`): keep the project's one for this repo (recommended in someone else's repo), or plan a migration later.
   - Confirm what you detected: stack, commands, commit and branch conventions. The repo's conventions override my personal ones.
   - In a monorepo whose packages have different stacks: whether to add a `CLAUDE.md` per package.
   - Review mode: `auto` (recommended: `/seny:implement` runs the independent reviewer itself and fixes blockers once; you still decide `done`) or `manual` (you run `/seny:review`).
3. **Write**, after my answers:
   - **Shared mode**:
     - No `CLAUDE.md` → create it from `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.project.md`, filled in with what you detected. Leave `<placeholders>` only for what you couldn't detect (Project description, Product rules).
     - Existing `CLAUDE.md` → append the template's `## Seny` section, plus any detected command or convention it doesn't already state. Show me the section before appending.
     - Create `docs/project/` and `docs/features/` with a `.gitkeep` each.
   - **Private mode**:
     - Create `.seny/project/` and `.seny/features/`.
     - Write the filled template to `.seny/CLAUDE.md`.
     - Make Claude Code load it in every session: add the line `@.seny/CLAUDE.md` to `CLAUDE.local.md` at the repo root (create it if missing; if it exists, show me the line before appending).
     - Append `.seny/` and `CLAUDE.local.md` to `.git/info/exclude`. Nothing tracked changes.
   - Either way, the file with the Seny rules gets the lines `- Seny docs: \`<docs root>\`` and `- Seny review: <auto | manual>`.
   - Monorepo, if I said yes: a short `CLAUDE.md` per package with its stack and commands (shared mode only).
4. **Permissions**: propose the detected check commands for `.claude/settings.local.json` → `permissions.allow`, so lint, typecheck, tests and build run without a prompt, e.g. `Bash(pnpm lint)`, `Bash(pnpm typecheck)`, `Bash(pnpm test)`, `Bash(pnpm test *)`, `Bash(pnpm build)`. Only checks: never dev servers, deploy, release, e2e or install scripts. Merge with the existing file, never replace it, and show me the result before writing. Then check it is ignored by git (`git check-ignore .claude/settings.local.json`); if not, append it to `.git/info/exclude`.
5. **Personal defaults**: if `~/.claude/CLAUDE.md` doesn't exist, offer to copy `${CLAUDE_PLUGIN_ROOT}/templates/CLAUDE.personal.example.md` there as a starting point I'll edit. If `~/.claude/seny/stack.md` doesn't exist, offer the same with `${CLAUDE_PLUGIN_ROOT}/templates/stack.example.md` (stack choices for new apps, read only by `/seny:plan project`). Never touch files that exist.
6. **Stop.** Tell me what you created (paths), what you couldn't detect, and the next step:
   - Existing code → `/seny:research project` (analyses the codebase, records the checks baseline).
   - New project → `/seny:research project <the app idea>`.
