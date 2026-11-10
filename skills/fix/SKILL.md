---
name: fix
description: Quick fix for a bug or a small defect outside any plan. Reproduces it with a failing test, finds the root cause, applies the minimal fix, runs the checks against the baseline and gets an independent review.
argument-hint: "<bug: what happens, what should happen, steps, error or log>"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git diff) Bash(git diff HEAD*) Bash(git diff --stat*) Bash(git branch --show-current) Bash(git log *) Bash(git rev-parse *)
---

# Fix

Bug: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context).

## Rules
- Fix the cause, not the symptom. No workarounds that hide the error (empty catch, optional chaining over a value that should exist, a sleep for a race).
- Minimal change. Don't refactor, rename or "improve" anything the bug doesn't need.
- If the bug is in a story that is not `done` yet, stop and tell me to use `/seny:implement <id>` (fix round) instead.
- If the root cause is bigger than a fix — a design flaw, a data model change or migration, auth or permissions, changes across many modules — stop, explain it, and recommend `/seny:plan light <change>` or `/seny:research <change>`.
- Follow the project rules and `<docs>/project/architecture.md` if it exists.
- Never push. Commit only following my commit rule.

## Steps
1. **Understand.** Restate the bug in 2 lines: actual vs expected behaviour. If you are missing what you need to reproduce it (steps, input, error, platform), ask in one batch.
2. **Clean start.** On the default branch → propose `fix/<short-description>` (or the repo's convention) and wait for my answer. Uncommitted changes that aren't part of this fix → ask me to commit or stash them first.
3. **Baseline.** If the state says it is missing or stale and the project rules define checks, record it first, exactly as `/seny:implement` does (step 3 there; `By: fix`).
4. **Reproduce.** Find the code involved. If it has no tests, first write characterization tests that pin its current correct behaviour. Then write a test that fails because of the bug. Run it and show me it fails for the right reason.
   If it can't be a unit or integration test (purely visual, device-specific, timing), say why, give me the manual steps, and propose an E2E test (Playwright or Maestro, or the project's tool) for me to decide.
5. **Root cause.** Explain it in 2–3 lines with `file:line`: what is wrong and why it produces the symptom.
6. **Fix.** Apply the minimal change. The reproduction test passes.
7. **Check.** Run the project's checks and compare with `<docs>/project/baseline.md`, if any: only new failures block. Fix what fails; if it still fails after two attempts, stop and show me the error.
8. **Look around.** Search for the same mistake elsewhere (same pattern, same misuse). List what you find; don't fix it here. Offer to add it to the tech debt table of `<docs>/project/codebase.md`, and write it only after my yes.
9. **Review.** Follow steps 1–3 of `${CLAUDE_PLUGIN_ROOT}/references/review-loop.md` in fix mode (the bug is the acceptance criterion; results in chat, no plan) with **2 fix rounds**. Still CHANGES REQUESTED after them → stop and show me.
10. **Report**, briefly: cause and fix (files), the test that covers it, checks vs baseline, review verdict and any `should` findings, the same pattern elsewhere if found, how to check it by hand, and a commit message (the repo's convention, else `fix: <description>`). Then apply my commit rule: commit if I told you to, don't if I told you not to, otherwise ask.
