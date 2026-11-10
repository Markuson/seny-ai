---
name: research
description: Seny phase 1, understand before planning. Project level - a new product, an existing codebase (analysis plus checks baseline) or a refresh of the project docs. Feature level - a feature, brief or problem.
argument-hint: "project [refresh] [idea] | <feature, brief file or problem>"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git status *) Bash(git rev-parse *)
---

# Research

Focus: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Formats: `${CLAUDE_PLUGIN_ROOT}/templates/project/<document>.md`; read only the one you are about to write.

You are in the Research phase. Your job is to understand, not to solve.

## Rules
- Do not write or change code. Only write the documents this phase owns (listed per level).
- Separate facts from assumptions. Every fact cites its source (file path, or section of a brief). Never present an assumption as a fact.
- Describe, don't prescribe: no solutions, architecture choices, epics or stories. That is `/seny:plan`'s job. Problems you find go to risks or tech debt.
- If something blocks your understanding, ask ALL your questions in one batch and wait for my answers.
- If a question can only be answered by trying code (a library's real behaviour, a device, an API, performance), don't guess: list it under open questions and suggest `/seny:spike <question>`.
- For broad codebase sweeps, delegate to Explore subagents (in parallel when the areas are independent) and keep only their conclusions.
- If the project rules are missing, suggest `/seny:init` first.

## Choose the level
- Input starts with `project refresh` → **Project refresh**.
- Input starts with `project` → **Greenfield** if the repo has no application code yet, **Brownfield** if it has.
- Anything else → **Feature**.
If it's not obvious, ask me.

## Greenfield (new product)
1. Read my idea, any brief or references, and the project rules. If `<docs>/project/product.md` exists, update it instead of starting over.
2. Write `<docs>/project/product.md` (format: `product.md`).
3. Stop. Give me a 5-line summary and the open questions. Next: `/seny:plan project`.

## Brownfield (existing codebase)
Map what exists so features can build on it. Describe the code as it is, even where it is inconsistent. Never overwrite `product.md` if it exists.
1. Read the project rules, README, and any existing architecture or decision docs.
2. Explore in parallel (one Explore subagent each):
   - **Stack and structure** — frameworks and versions, packages (each one in a monorepo), folders, routing or navigation, build and deploy.
   - **Data and backend** — data sources, APIs, state (server vs client), auth, validation, external services.
   - **UI** (if any) — theme and tokens (Tailwind / NativeWind config or equivalent), base components, how screens are built, accessibility.
   - **Quality** — test tools and where tests live, which areas have tests and which don't, lint and type settings, CI.
3. **Baseline.** Run the project's checks (lint, typecheck, tests; build if cheap) with the commands in the project rules, and write `<docs>/project/baseline.md` (format: `baseline.md`; `Commit:` is `git rev-parse --short HEAD`; `By: codebase analysis`). Later phases compare against it, so only new failures block a story.
4. Write:
   - `<docs>/project/architecture.md` — the current architecture, as it is. `Design system:` line: `design-system.md`, or `not applicable (no UI)`.
   - `<docs>/project/design-system.md` — only if there is UI: the tokens and base components that actually exist. If there is no coherent system, say so; don't invent one.
   - `<docs>/project/codebase.md` — conventions in practice, test coverage map, tech debt and risks with `file:line`, fragile areas.
   - `<docs>/project/roadmap.md` — empty table, or the features I told you I want.
5. Stop. Give me a summary (stack, health, the 3 biggest risks) and the questions the code can't answer ("there are two fetch patterns; which one is the intended one?"). Next: `/seny:research <first feature>`, `/seny:evolve <change>` for an architecture improvement, or `/seny:plan project` to put features and evolutions on a roadmap.

## Project refresh
1. Read `<docs>/project/architecture.md`, `design-system.md`, `codebase.md` and `baseline.md`.
2. Compare them with the code now (Explore subagents as above, only the areas that may have changed), and re-run the checks.
3. For each **In transition** row, measure the real progress (how much of the old pattern is left) and any new code that broke the rule for new code.
4. Give me the differences as a list (document says / code does, with `file:line`), the transition progress, and the new baseline. Update the documents only after my yes.

## Feature
1. Propose a short kebab-case slug (e.g. `user-login`) and the branch `feature/<slug>`, following the repo's branch convention if the project rules state one. If `<docs>/features/<slug>/` exists, read it and update it instead of starting over; keep any `## Spike findings` section as it is.
2. Read the project rules, `architecture.md` and `design-system.md`, and the parts of `product.md` and `codebase.md` that touch this feature. If the repo has code but no `architecture.md`, suggest `/seny:research project` first; if I prefer to go on, map only what this feature needs.
3. Read the inputs and map the relevant part of the codebase.
4. Write `<docs>/features/<slug>/research.md`, one page at most:
   - **Problem** — 3 lines
   - **Users / roles** — what each one needs
   - **Constraints** — stack, platform, product rules, anything I stated
   - **Codebase** — what exists, what to reuse, where new code would fit, with `file:line`; tests around that code (if it has none, say so: implementation will need characterization tests)
   - **Fit with the project** — what in `architecture.md` and `design-system.md` this feature relies on, and anything it would have to change
   - **Challenges** — each one with its impact on the design
   - **Risks**
   - **Assumptions** (marked as such) and **open questions** (mark the ones only a spike can answer)
5. Stop. Give me a 5-line summary, the slug and branch, and the open questions. Next: `/seny:spike <question>` for questions only code can answer, then `/seny:plan <slug>`. Suggest `/clear` first: the research carries the state.
