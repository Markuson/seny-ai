---
name: review
description: Seny phase 4. Have the independent seny reviewer check one story in review, record the findings in the plan, and move the story to done (with my approval) or back to in-progress. Also closes a story that was already approved.
argument-hint: "[<epic slug>] [story id] [done | git range, if already committed]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git diff --stat*) Bash(git diff --name-only*) Bash(git log *)
---

# Review

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above.

When the review mode is `auto`, `/seny:implement` already ran the reviewer. Use this command to review again after manual changes, to review a git range, to review in `manual` mode, or to close an approved story.

## Rules
- You do not review the code yourself and you do not fix anything. The `seny:reviewer` subagent reviews; you orchestrate, record and ask.
- Only I can move a story to `done`.

## Steps
1. **Find the story**: the id in the input, or the only story with status `review`. If none or several, ask.
2. **Just closing?** If the input says `done` and the story's last recorded review is `APPROVED`: follow `${CLAUDE_PLUGIN_ROOT}/references/close-story.md` and stop. If the last review isn't `APPROVED`, tell me and review it instead.
3. **What to review**: by default the uncommitted changes (`git diff HEAD` plus untracked files). If I gave a git range, use that instead.
4. Follow `${CLAUDE_PLUGIN_ROOT}/references/review-loop.md` with **0 fix rounds**.
