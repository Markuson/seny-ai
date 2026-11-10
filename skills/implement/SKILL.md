---
name: implement
description: Seny phase 3. Implement one story from a feature plan (or fix its review findings) with TDD where the story asks for it, run the checks against the baseline, and move it to review. Only when the user runs /seny:implement.
argument-hint: "<story id, e.g. E1-S2> | next"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git diff) Bash(git diff HEAD*) Bash(git diff --stat*) Bash(git branch --show-current)
---

# Implement

Target: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context).

## Rules
- Find the plan in `<docs>/features/*/plan.md`. If more than one plan has unfinished stories and the target doesn't make it clear, ask which feature.
- `next` means the first `todo` story whose dependencies are all `done`.
- Work on ONE story. Stay inside its scope. If you need to touch something outside it, or the plan turns out to be wrong, stop and propose a plan change instead of improvising.
- Keep the change small. Follow existing patterns. No new dependency without asking.
- Never push. Don't commit here: the commit happens when the story is `done`, after `/seny:review`.

## Steps
1. Check the story:
   - `todo` → start it.
   - `in-progress` with review notes → a fix round: the open findings come first.
   - `review` or `done` → tell me and stop.
   - A dependency not `done` → warn me and wait.
2. If the current branch is the default branch, propose `feature/<slug>` from the plan and wait for my answer before changing anything.
3. Set the story's status to `in-progress` in the plan.
4. Restate the acceptance criteria (and open review findings, if any) in a few lines. Then read what the story builds on:
   - `<docs>/project/architecture.md`, if it exists: follow its structure, state, boundaries and conventions. If the story needs something that contradicts it, stop and tell me. If the story touches an area listed under **In transition**, follow its rule for new code: use the target pattern, never add more of the old one.
   - If the plan has `Type: evolution`: behaviour must not change unless the story says so. The characterization tests must pass unchanged; if one needs editing, stop and ask me why.
   - For UI stories, `<docs>/project/design-system.md` and the section the `Design:` line points to: tokens (no hard-coded colours or sizes), base components, every listed state. If a design skill is installed (`frontend-design`, `react-native-skills`), load it.
   - The baseline in `<docs>/project/research.md`, if any: the checks that already failed before this story.
5. **Characterization first.** If the story changes existing code that has no tests, first write tests that pin its current behaviour and run them green. Then change it.
6. Implement, following the story's `Tests` mode:
   - `tdd`:
     1. **Red** — turn the acceptance criteria into tests. Run them and show me they fail for the right reason (not a typo or a missing import).
     2. **Green** — write the minimum code to make them pass.
     3. **Refactor** — clean up with the tests green.
     Test behaviour through the public interface, not implementation details. In a fix round, write a failing test that reproduces each bug finding first.
   - `after` — implement, then add tests, following the testing rules in the project rules.
   - `none` — implement; no tests needed.
7. Run the project's checks (lint, typecheck, tests; commands in the project rules). Compare with the baseline: only **new** failures block. Never make the baseline worse; if you fix a pre-existing failure along the way, say so. Fix what fails; if it still fails after two attempts, stop and show me the error. The story stays `in-progress`.
8. Tick the acceptance criteria you met. Mark the review findings you fixed as `[x]`. For an evolution story, update its `Progress:` line and the progress in its **In transition** row of `architecture.md`.
9. Set the status to `review`.
10. Report, briefly:
    - what changed and why (files listed)
    - checks vs baseline
    - how I can check it by hand
    - next: `/seny:review <story id>`
