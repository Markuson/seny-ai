# Colla mode: epics in parallel

A *colla* is the team that raises a castell: many people at once, each in their place. Colla mode works on several **epics** at the same time, each one on its own branch, in its own git worktree, in its own Claude Code session, following Seny as usual inside it. Planning documents need my answers, so Seny prepares the sessions; it doesn't run them in the background.

## When it's offered
When the state shows `Parallel:` (two or more roadmap epics ready: `todo`, every dependency done) and `Seny parallel:` isn't `off`. It is offered when an epic is closed, in `/seny:help`, and by `/seny:plan colla`.

## Steps
1. **Pick.** Show the ready epics with their size and first command, as numbered choices, and the limit (`max N` from `Seny parallel:`, default 2). Example:
   ```
   Ready now: [1] about (M)  [2] projects (S)  [3] contact (S)   — up to 2 at a time
   Answer with numbers, e.g. "1 2".
   ```
   Warn if two chosen epics are likely to touch the same areas (from the roadmap notes and `architecture.md`): parallel is still possible, but their pull requests may conflict.
2. **Prepare**, after my yes, for each epic:
   - Branch `feature/<slug>` (or the repo's convention) from the latest default branch.
   - Worktree beside the repo: `git worktree add ../<repo>-<slug> -b <branch> <default branch>`.
   - Nothing else: no documents are written here.
3. **Hand over**, per epic, ready to copy:
   ```
   about (M) → cd ../marcuson.dev-about && claude
               then: pnpm install (once), /seny:research about
   ```
   The first command follows the size: S → `/seny:plan <slug>`, M or L → `/seny:research <slug>`, evolution → `/seny:evolve <slug>`. This session can keep working on its own epic, or take one of them.
4. **Remind** in two lines how it ends: each epic ends in its own pull request (I push and merge); after merging, `git worktree remove ../<repo>-<slug>` (Seny can do it after my yes).

## Rules while epics run in parallel
- **Roadmap**: epics never edit `roadmap.md` to change their status; the state derives it from each plan. Changes to the roadmap itself (a new epic, a size) are made on the default branch.
- **Baseline**: on an epic's branch, implement and fix record the baseline in `<docs>/epics/<slug>/baseline.md`, never in the project one. Each branch has its own; nothing to merge.
- **Project documents** (`architecture.md`, `design-system.md`): an epic that needs an app-wide change proposes it as usual; if another epic in parallel is likely to touch the same section, say so, since the pull requests will meet.
- Work done in one worktree isn't visible in the others until it is merged into the default branch.
