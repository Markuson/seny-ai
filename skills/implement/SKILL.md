---
name: implement
description: Seny phase 3. Implement one story from an approved epic plan (or fix its review findings) with TDD where the story asks for it, run the checks against the baseline, and get it reviewed by the independent reviewer (automatic unless the review mode is manual).
argument-hint: "[<epic slug>] <story id, e.g. S2> | next [no-review]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git diff) Bash(git diff HEAD*) Bash(git diff --stat*) Bash(git branch --show-current) Bash(git rev-parse *)
---

# Implement

Target: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Story format: `${CLAUDE_PLUGIN_ROOT}/templates/epic/plan.md`, only if you need it.

## Rules
- Find the plan in `<docs>/epics/*/plan.md`. A story id alone (`S2`) refers to the epic in progress; if more than one epic has unfinished stories and the target doesn't say which (`<slug> S2`), ask.
- The plan must be `Status: approved`. If it is `draft` or `shape approved`, stop and tell me which `/seny:plan` run finishes it.
- `next` means the first `todo` story whose dependencies are all `done`.
- Work on ONE story. Stay inside its scope. If you need to touch something outside it, or the plan turns out to be wrong, stop and propose a plan change (`/seny:plan <slug> <change>`) instead of improvising.
- Keep the change small. Follow existing patterns. No new dependency without asking.
- Never push. The commit happens when I confirm the story is `done`.
- **Review mode**: printed in the state above (default `auto`). It is `manual` for this run if the target contains `no-review` or I asked you not to review in this session.
- **Heavy context**: if your context gets heavy before the story is finished, write the story's `Notes:` line (done so far, decisions taken, next step), keep it `in-progress`, and tell me to `/clear` and run `/seny:implement <story id>` again.

## Steps
1. **Check the story.**
   - `todo` → start it.
   - `in-progress` with open review findings → a fix round: the open findings come first.
   - `in-progress` with `Notes:` → resume from the notes.
   - `in-progress` with neither (a session that ended abruptly) → read the diff to see what is already done, tell me, and continue.
   - `review` → tell me: `/seny:review <story id>` (or `/seny:review <story id> done` if it was approved and I only need to close it). Stop.
   - `done` → tell me and stop.
   - A dependency not `done` → warn me and wait.
2. **Clean start.**
   - On the default branch → propose the plan's `Branch:` and wait for my answer before changing anything.
   - Uncommitted changes that don't belong to this story (another story, unrelated edits) → ask me to commit or stash them first, so the review sees only this story.
3. **Baseline.** If the state says the baseline is missing or stale and the project rules define checks: with a clean working tree (else ask), run the checks before changing anything and write `<docs>/project/baseline.md` (format: `${CLAUDE_PLUGIN_ROOT}/templates/project/baseline.md`; `Commit:` is `git rev-parse --short HEAD`; `By: implement <story id>`). Tell me what changed against the previous one. No checks defined yet (early foundation stories) → skip.
4. Set the story's status to `in-progress` in the plan.
5. **Read what the story builds on.** Restate the acceptance criteria (plus open findings or notes) in a few lines. Then:
   - The story's `Approach:`, `Files:` and `Verify:` lines: they are your starting map. Read the code they point to, not the whole repo.
   - `<docs>/project/architecture.md`, if it exists: follow its structure, state, boundaries and conventions. If the story needs something that contradicts it, stop and tell me. If it touches an area listed under **In transition**, follow its rule for new code: use the target pattern, never add more of the old one.
   - `Type: evolution`: behaviour must not change unless the story says so. The characterization tests must pass unchanged; if one needs editing, stop and ask me why.
   - UI stories: `<docs>/project/design-system.md` and the section the `Design:` line points to: tokens (no hard-coded colours or sizes), base components, every listed state. If a design skill is installed (`frontend-design`, `vercel-react-native-skills`), load it.
   - `<docs>/project/baseline.md`, if any: the checks that already failed.
6. **Characterization first.** If the story changes existing code that has no tests, first write tests that pin its current behaviour and run them green. Then change it.
7. **Implement**, following the story's `Tests` mode:
   - `tdd`:
     1. **Red** — turn the acceptance criteria into tests. Run them and show me they fail for the right reason (not a typo or a missing import).
     2. **Green** — write the minimum code to make them pass.
     3. **Refactor** — clean up with the tests green.
     Test behaviour through the public interface, not implementation details. In a fix round, write a failing test that reproduces each bug finding first.
   - `after` — implement, then add tests, following the testing rules in the project rules.
   - `none` — implement; no tests needed.
   If the `Approach:` turns out to be wrong but the scope holds, adapt and say why in the report.
8. **Checks.** Run the project's checks (lint, typecheck, tests; commands in the project rules) and compare with the baseline: only **new** failures block. Never make the baseline worse; if you fix a pre-existing failure along the way, say so. Fix what fails; if it still fails after two attempts, stop and show me the error. The story stays `in-progress`.
9. **Update the plan.** Tick the acceptance criteria you met and the review findings you fixed. Remove the `Notes:` line. For an evolution story, update its `Progress:` line and the progress in its **In transition** row of `architecture.md` (this progress update needs no approval).
10. Set the status to `review`.
11. **Review.**
    - `auto` → follow `${CLAUDE_PLUGIN_ROOT}/references/review-loop.md` with **1 fix round**.
    - `manual` → next: `/seny:review <story id>`.
12. **Report**, briefly: what changed and why (files), checks vs baseline, the review verdict (auto), how I check it by hand (the manual part of `Verify:`), and the next step.
