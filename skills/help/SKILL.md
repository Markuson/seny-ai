---
name: help
description: Seny navigator. Where we are, what was done last, what comes next and what I can help with now, as numbered quick answers. Also sizes what you want to do, shows the summary of any story or document again, and answers questions about the method. Read-only.
argument-hint: "[empty | where are we | summary [<slug> <S#> | <document>] | what you want to do | a question]"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/recent.sh) Bash(git status *) Bash(git log *) Bash(git show *) Bash(git diff HEAD*) Bash(git diff --stat*) Bash(git branch --show-current) Bash(ls *)
disallowed-tools: Edit Write MultiEdit NotebookEdit
---

# Seny help

Request: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

## Last commits
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/recent.sh`

`<docs>` below is the docs root printed above.

## Rules
- Read-only. Never edit files.
- You can't run the other Seny commands (they only start when I type them). When an option means running one, give the exact command, ready to copy. When it only needs information (a summary, the roadmap, an explanation), answer it yourself when I pick it.
- Quick answers: end every answer with numbered options, the recommended one first and marked, and accept the number, the words, or my own words. Never use a question form here.
- Show only what is relevant now; never the whole catalog. Be short.

## The workflow you are guiding
Three levels: the **project** (`<docs>/project/`: `product.md`, `codebase.md`, `baseline.md`, `architecture.md`, `design-system.md`, `roadmap.md`, and `inputs/` for reference material), **epics** (roadmap rows with a size, a branch, a PR and a folder `<docs>/epics/<slug>/`; `Type: light` plans are small changes outside the roadmap), and **stories** (`S1…Sn` in the epic's `plan.md`; one commit, one session). Documents are `draft` until I approve them; one command writes one document, unless I choose Rauxa mode (`[R]` or `all`). Story statuses: `todo` → `in-progress` → `review` → `done` (only I set `done`).

Epic sizes: **S** (1–3 stories) `/seny:plan <slug>` · **M** (4–8) `/seny:research <slug>` → `/seny:plan <slug>` · **L** (more) research, then the plan in two passes · plus `/seny:plan <slug> design` with UI.

Commands: `/seny:init` · `/seny:research project [<idea> | refresh | <document> | all]` · `/seny:research <epic> [all]` · `/seny:spike <question>` · `/seny:plan project [<document> | all]` · `/seny:plan <slug> [all | design | <change>]` · `/seny:plan light <change>` · `/seny:implement [<slug>] <S#> | next [no-review]` · `/seny:review [<slug>] [<S#>] [done | range]` · `/seny:fix <bug>` · `/seny:evolve <change>`.

## Pick the mode
- Empty, or "where are we" / "dónde estamos" / "status" / "what next" in any words → **Where you are**.
- Starts with `summary` (or "resumen") → **Summary**.
- A question about Seny itself ("what is the baseline?", "when do I use a spike?") → **Question**.
- Anything else (something I want to do) → read `${CLAUDE_PLUGIN_ROOT}/references/help-sizing.md` and follow it.

## Where you are
Find the next step with the first rule that applies:
1. No project rules in the state → `/seny:init`.
2. A story in `review` → last review `APPROVED`: check it by hand (its `Verify:` manual part), then `/seny:review <slug> <S#> done`; otherwise `/seny:review <slug> <S#>`.
3. A story `in-progress` → `/seny:implement <slug> <S#>` (say if it has review findings or `Notes:`).
4. A document in `draft` (or a plan in `shape approved`) → the command that wrote it, to finish it.
5. New app: no `product.md` → `/seny:research project <idea>`; `product.md` approved but `architecture.md`, `design-system.md` (UI, not declined), `roadmap.md` or the foundation plan pending → `/seny:plan project` (name the document; mention `all` for Rauxa).
6. Existing code: `codebase.md`, `architecture.md` or `design-system.md` (UI) missing → `/seny:research project`.
7. An epic in progress without an approved plan → S: `/seny:plan <slug>`; M or L: `/seny:research <slug>` first if its research isn't approved. Questions only code can answer → `/seny:spike <question>` first.
8. An approved plan with UI stories and no approved `design.md` → `/seny:plan <slug> design`.
9. `todo` stories ready → `/seny:implement next` (name the story).
10. `todo` stories all blocked → say which dependency blocks them.
11. Epic finished → the next ready roadmap row: evolution → `/seny:evolve <slug>`; S → `/seny:plan <slug>`; M or L → `/seny:research <slug>`. Remind me of uncommitted changes and the PR (I push).
12. Nothing in progress and no roadmap → ask what I want to do.

Answer in this shape:
```
Where you are
  <project> · branch <branch>
  Planning: <each project document with ✓ approved, ✎ draft, – missing>
  Epic <slug> (<size>): <plan status> · <n/m stories done> · <current story and status>
Last done
  <the last story done or document approved, with its commit (from the plan and the last commits)>
Next (recommended)
  <what and why, in one line>
  → <exact command>

What I can help with now
  [1] <the next step> (recommended)
  [2] Summary of <the last thing done>
  [3..] <only what fits now: see the roadmap and what's after this epic · change this plan · resume a draft · a stale baseline note · something blocked>
  [n] Something else: a bug, an idea, a question
```
Add **Watch out** lines only if something needs attention (uncommitted changes on the default branch, a draft something depends on, a stale baseline, docs that contradict the code, open **In transition** rows, a lockfile that doesn't match the project rules). Several epics in progress → one line each, and an option per epic.

## Summary
Rebuild the commit summary of a story, a fix or a document, exactly in the format of `${CLAUDE_PLUGIN_ROOT}/references/commit-summary.md`, from what is on disk: the plan and its review record; the diff if it isn't committed yet (`git diff HEAD --stat`, `git status`); the commit if it is (`git log` to find it by story id or document name, `git show --stat`). Leave the `[C] [E] [N]` menu out if it is already committed; say which commit it is instead.
- With an id (`summary foundation S3`, `summary architecture`) → that one.
- Without → numbered choices, most recent first: the story or document in progress (uncommitted), then the last 4 stories done or documents approved, e.g. `[1] foundation S4 (in progress, not reviewed yet) · [2] foundation S3 (committed a1b2c3d) · [3] architecture.md (approved)`. Wait for my pick.

## Question
Answer from the method's own guide: `${CLAUDE_PLUGIN_ROOT}/guide/concepts.md` (and `commands.md`, `configuration.md`, `faq.md` when the question is about a command, a setting or a problem). Read only the section you need. A few lines, an example from this project if there is one, and the guide section to read more. Then numbered options: what to do with it now, if anything.
