# Review loop

Shared by `/seny:implement` (when the review mode is `auto`), `/seny:review` and `/seny:fix`. You orchestrate and record; the `seny:reviewer` subagent judges. You never review the code yourself: the author doesn't grade their own homework.

The caller tells you how many **fix rounds** you may run: `/seny:implement` auto → 1, `/seny:fix` → 2, `/seny:review` → 0.

## 1. Launch the reviewer
Launch the `seny:reviewer` subagent. It has not seen this conversation, so its prompt must stand on its own:
- The docs root, the plan path and the story id. For a fix (no plan): the bug as the acceptance criterion — "<expected behaviour>; the reproduction test fails without the fix and passes with it" — and "scope means nothing changed beyond what the fix needs".
- What to diff, as an exact command: by default `git diff HEAD` plus the untracked files from `git status --porcelain`; or the git range I gave.
- Which project docs exist: `architecture.md`, `design-system.md`, `baseline.md`.
- That it must follow its checklist and its output format exactly.

## 2. Record the result
Under the story in the plan (for a fix, in chat only):
```markdown
- Review <YYYY-MM-DD>: <APPROVED | CHANGES REQUESTED>
  - [ ] [blocker] path/file.ts:42 — <problem> → <fix>
  - [ ] [should] ...
```
Leave nits out of the plan; mention them in chat. Story ids are `S1`, `S2`… within the epic.

## 3. Fix round (only if the caller allows one)
On **CHANGES REQUESTED** with fix rounds left:
1. Fix each blocker. If it is a bug, first write a test that reproduces it and fails. Mark it `[x]`.
2. Never fix a `should` without my yes. Never edit a characterization test to make it pass.
3. Re-run the checks against the baseline, then launch the reviewer again as a **re-review** and record it (step 2). A re-review prompt adds to step 1: the findings of the previous review, word for word; that it must verify each blocker is really fixed, review only the files touched by the fixes, and run the tests plus any check that failed before, without redoing the full checklist; and that it reports new problems only if the fixes introduced them.

Still CHANGES REQUESTED when no rounds are left → stop.

## 4. Hand over to me
- **CHANGES REQUESTED** → set the story to `in-progress`. Show me the blockers and the `should` findings. Next: `/seny:implement <story id>` (a fix round).
- **APPROVED** → the story stays in `review`. Show me the verdict, the `should` findings, and the manual part of the story's `Verify:` line (what I should check by hand). Ask whether to mark it `done`. When I say yes, follow `${CLAUDE_PLUGIN_ROOT}/references/close-story.md`.
- In both cases:
  - If the reviewer proposed E2E tests, show the proposal and ask whether to run or write them. Do nothing with E2E until I decide.
  - If it flagged an undocumented architecture or design-system change, ask whether to record it in the project docs or treat it as a finding.
  - **Learning loop:** if a finding of the same kind already appears in another story's review in this plan, propose one rule for the project rules (`CLAUDE.md`) that would have prevented both. Write it only after my yes.
