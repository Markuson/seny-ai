---
name: review
description: Seny phase 4. Have the independent seny reviewer check one story in `review`, record the findings in the plan, and move the story to done (with my approval) or back to in-progress. Only when the user runs /seny:review.
argument-hint: "[story id] [git range, if already committed]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git diff --stat*) Bash(git diff --name-only*) Bash(git log *)
---

# Review

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above.

## Rules
- You do not review the code yourself and you do not fix anything. The `seny:reviewer` subagent reviews; you orchestrate, record and ask.
- Only I can move a story to `done`.

## Steps
1. Find the story: the id in the input, or the only story with status `review`. If none or several, ask.
2. Work out what to review: by default the uncommitted changes (`git diff HEAD` plus untracked files from `git status`). If I gave a git range, use that instead.
3. Launch the `seny:reviewer` subagent. Its prompt must stand on its own: the docs root, plan path, story id, what to diff (exact command), which project docs exist (architecture, design system, research with baseline), and that it must follow its checklist and output format.
4. Record its result in the plan, under the story:
   ```markdown
   - Review <YYYY-MM-DD>: <APPROVED | CHANGES REQUESTED>
     - [ ] [blocker] path/file.ts:42 — <problem> → <fix>
     - [ ] [should] ...
   ```
   Leave out nits; mention them in chat only.
5. Then:
   - **CHANGES REQUESTED** → set the status to `in-progress`. Show me the blockers and the `should` findings. Next: `/seny:implement <story id>`.
   - **APPROVED** → keep it in `review`. Show me the verdict, any `should` findings, and the acceptance criteria to check by hand. Ask whether to mark it `done`.
   - In both cases: if the reviewer proposed E2E tests, show the proposal and ask whether to run or write them; do nothing with E2E until I decide. If it flagged an undocumented architecture or design-system change, ask whether to record it in the project docs or treat it as a finding.
6. When I confirm:
   - If I want a `should` fixed first → set `in-progress`. Next: `/seny:implement <story id>`.
   - Otherwise → set the status to `done`. If all stories of the epic are `done`, say so.
   - If all stories of the feature are `done`: check that every approved app-wide change in the plan is reflected in `architecture.md` / `design-system.md` (update them if I agree); if a roadmap exists, set the feature to `done` there and tell me the next one: `/seny:research <next feature>`.
   - If it was an evolution (`Type: evolution`): check the old pattern is really gone (search the code), then propose removing its **In transition** row and describing the target as the current architecture. Update `architecture.md` after my yes.
   - Propose a commit message (the repo's convention from the project rules, else `<type>: <description>`) and apply my commit rule: commit if I told you to, don't if I told you not to, otherwise ask. Never push.
   - Tell me the next story: `/seny:implement next`.
