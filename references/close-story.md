# Closing a story

Run only after I confirm that a story in `review` is done. Shared by `/seny:review` and `/seny:implement`.

1. **A `should` first?** If I want a `should` finding fixed before closing, set the story to `in-progress` and stop. Next: `/seny:implement <story id>`.
2. **Status.** Set the story to `done`.
3. **Epic finished?** If every story in the plan is now `done`:
   - Check that every app-wide change the plan approved is reflected in `architecture.md` / `design-system.md`; update them if I agree.
   - If a roadmap exists, set this row to `done`.
   - Evolution (`Type: evolution`): search the code to confirm the old pattern is really gone, then propose removing its **In transition** row and describing the target as the current architecture. Update `architecture.md` after my yes.
   - **Pull request:** propose a title and a body from the plan, ready to paste: the goal, the stories (id and title), key decisions, checks vs baseline, the manual checks from the `Verify:` lines, and what stayed out of scope. Remind me that pushing and opening the PR are mine.
4. **Commit.** Propose a commit message: the repo convention from the project rules, else `<type>: <description>`, mentioning the story id. It includes the code and the doc updates of steps 2–3. Apply my commit rule: commit if I told you to, don't if I told you not to, otherwise ask. Never push.
5. **Next.** `/seny:implement next` if the plan has `todo` stories. If the epic is finished, the next roadmap row whose dependencies are `done`: size S → `/seny:plan <slug>`; size M or L → `/seny:research <slug>`; an evolution → `/seny:evolve <slug>`. Suggest `/clear` before starting it: the docs carry the state.
