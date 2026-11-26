# Closing a story

Run only after I confirm that a story in `review` is done. Shared by `/seny:review` and `/seny:implement`.

1. **A `should` first?** If I want a `should` finding fixed before closing, set the story to `in-progress` and stop. Next: `/seny:implement <story id>`.
2. **Status.** Set the story to `done`.
3. **Epic finished?** If every story in the plan is now `done`:
   - Check that every app-wide change the plan approved is reflected in `architecture.md` / `design-system.md`; update them if I agree.
   - The roadmap status needs no edit: the state derives it from the plan.
   - Evolution (`Type: evolution`): search the code to confirm the old pattern is really gone, then propose removing its **In transition** row and describing the target as the current architecture. Update `architecture.md` after my yes.
   - **Pull request:** propose a title and a body from the plan, ready to paste: the goal, the stories (id and title), key decisions, checks vs baseline, the manual checks from the `Verify:` lines, and what stayed out of scope. Remind me that pushing and opening the PR are mine.
4. **Commit.** Give the commit summary, story form (`${CLAUDE_PLUGIN_ROOT}/references/commit-summary.md`), with its `[C] [E] [N]` menu. The message follows `${CLAUDE_PLUGIN_ROOT}/references/commits.md`; the commit includes the code and the doc updates of steps 2–3. Never push.
5. **Next.** `/seny:implement next` if the plan has `todo` stories. If the epic is finished, the next roadmap row whose dependencies are `done`: size S → `/seny:plan <slug>`; size M or L → `/seny:research <slug>`; an evolution → `/seny:evolve <slug>`. Suggest `/clear` before starting it: the docs carry the state. If the state shows `Parallel:` (two or more epics ready), offer `[P] Work on several in parallel (Colla mode)`: follow `${CLAUDE_PLUGIN_ROOT}/references/colla.md`.
