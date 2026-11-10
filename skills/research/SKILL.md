---
name: research
description: Seny phase 1. Understand before planning. Project level - a new product (greenfield), the existing codebase (brownfield analysis with a checks baseline) or a refresh of the project docs. Feature level - a feature, brief or problem. Only when the user runs /seny:research.
argument-hint: "project [refresh] [idea] | <feature, brief file or problem>"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git status *)
---

# Research

Focus: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context).

You are in the Research phase. Your job is to understand, not to solve.

## Rules
- Do not write or change code. Only write the documents this phase owns (listed per level).
- Separate facts from assumptions. Every fact cites its source (file path, or section of a brief). Never present an assumption as a fact.
- Describe, don't prescribe: no solutions, architecture choices, epics or stories. That is `/seny:plan`'s job. Problems you find go to risks or tech debt.
- If something blocks your understanding, ask ALL your questions in one batch and wait for my answers.
- For broad codebase sweeps, delegate to Explore subagents (in parallel when the areas are independent) and keep only their conclusions.
- If the project CLAUDE.md is missing, suggest `/seny:init` first.

## Choose the level
- Input starts with `project refresh` → **Project refresh**.
- Input starts with `project` → **Greenfield** if the repo has no application code yet, **Brownfield** if it has.
- Anything else → **Feature**.
If it's not obvious, ask me.

## Greenfield (new product)
1. Read my idea, any brief or references, and the project rules. If `<docs>/project/research.md` exists, update it instead of starting over.
2. Write `<docs>/project/research.md` using the greenfield format in `${CLAUDE_PLUGIN_ROOT}/templates/project-docs.md`.
3. Stop. Give me a 5-line summary and the open questions. Next: `/seny:plan project`.

## Brownfield (existing codebase)
Map what exists so features can build on it. Describe the code as it is, even where it is inconsistent.
1. Read the project rules, README, and any existing architecture or decision docs.
2. Explore in parallel (one Explore subagent each):
   - **Stack and structure** — frameworks and versions, packages (each one in a monorepo), folders, routing or navigation, build and deploy.
   - **Data and backend** — data sources, APIs, state (server vs client), auth, validation, external services.
   - **UI** (if any) — theme and tokens (Tailwind / NativeWind config), base components, how screens are built, accessibility.
   - **Quality** — test tools and where tests live, which areas have tests and which don't, lint and type settings, CI.
3. **Baseline.** Run the project's checks (lint, typecheck, tests; build if cheap) with the commands in the project rules. Record what already fails. This is what later phases compare against, so only new failures block a story.
4. Write, using `${CLAUDE_PLUGIN_ROOT}/templates/project-docs.md`:
   - `<docs>/project/architecture.md` — the current architecture, as it is.
   - `<docs>/project/design-system.md` — only if there is UI: the tokens and base components that actually exist. If there is no coherent system, say so; don't invent one.
   - `<docs>/project/research.md` — brownfield format: conventions in practice, the baseline, test coverage map, tech debt and risks with `file:line`, fragile areas.
   - `<docs>/project/roadmap.md` — empty table, or the features I told you I want.
5. Stop. Give me a summary (stack, health, the 3 biggest risks), and the questions the code can't answer ("there are two fetch patterns; which one is the intended one?"). Next: `/seny:research <first feature>`, `/seny:evolve <change>` for an architecture improvement, or `/seny:plan project` to put features and evolutions on a roadmap.

## Project refresh
1. Read `<docs>/project/architecture.md`, `design-system.md` and the research baseline.
2. Compare them with the code now (Explore subagents as above, only the areas that may have changed), and re-run the checks.
3. For each **In transition** row, measure the real progress (how much of the old pattern is left) and any new code that broke the rule for new code.
4. Give me the differences as a list (document says / code does, with `file:line`), transition progress, and the new baseline. Update the documents only after my yes.

## Feature
1. Propose a short kebab-case slug (e.g. `user-login`) and the branch `feature/<slug>`, following the repo's branch convention if the project rules state one. If `<docs>/features/<slug>/` exists, read it and update it instead of starting over.
2. Read the project rules and everything in `<docs>/project/`. If the repo has code but no `architecture.md`, suggest `/seny:research project` first; if I prefer to go on, map only what this feature needs.
3. Read the inputs and map the relevant part of the codebase.
4. Write `<docs>/features/<slug>/research.md`, one page at most:
   - **Problem** — 3 lines
   - **Users / roles** — what each one needs
   - **Constraints** — stack, platform, product rules, anything I stated
   - **Codebase** — what exists, what to reuse, where new code would fit; tests around that code (if it has none, say so: implementation will need characterization tests)
   - **Fit with the project** — what in `architecture.md` and `design-system.md` this feature relies on, and anything it would have to change
   - **Challenges** — each one with its impact on the design
   - **Risks**
   - **Assumptions** (marked as such) and **open questions**
5. Stop. Give me a 5-line summary, the slug and branch, and the open questions. Next: `/seny:plan <slug>`.
