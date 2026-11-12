---
name: research
description: Seny phase 1, understand before planning, one document per run. Project level - a new product (product.md) or an existing codebase (codebase and baseline, architecture, design system), or a refresh. Epic level - the research for one epic.
argument-hint: "project [refresh | <document> | <idea>] | <epic slug, brief file or problem>"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git status *) Bash(git rev-parse *)
---

# Research

Focus: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Every document goes through `${CLAUDE_PLUGIN_ROOT}/references/document-loop.md`: read it now. Formats: `${CLAUDE_PLUGIN_ROOT}/templates/project/<document>.md` and `${CLAUDE_PLUGIN_ROOT}/templates/epic/<document>.md`; read only the one you are about to write.

You are in the Research phase. Your job is to understand, not to solve.

## Rules
- **One document per run**, through the document loop. Then stop.
- Do not write or change code. Only write the document this run owns.
- Separate facts from assumptions. Every fact cites its source (file path, or section of a brief). Never present an assumption as a fact.
- Describe, don't prescribe: no solutions, architecture choices or stories. That is `/seny:plan`'s job. Problems you find go to risks or tech debt.
- If a question can only be answered by trying code (a library's real behaviour, a device, an API, performance), don't guess: mark it as an open question for `/seny:spike <question>`.
- For broad codebase sweeps, delegate to Explore subagents (in parallel when the areas are independent) and keep only their conclusions.
- If the project rules are missing, suggest `/seny:init` first.

## Choose the level
- Input starts with `project refresh` → **Project refresh**.
- Input starts with `project` → **New app** if the repo has no application code yet, **Existing code** if it has. A document name after `project` (`codebase`, `architecture`, `design-system`) picks that document; otherwise take the next pending one.
- Anything else → **Epic**.
If it's not obvious, ask me.

## New app → `product.md`
Inputs: my idea, any brief, notes or references I give (files from other tools included: cite them as the source), and the project rules. Long reference material (an old version's inventory, content to migrate, a pasted brief) goes to `<docs>/project/inputs/`, linked from `product.md`, not inside it. If `product.md` exists, update it instead of starting over.
Depth: the full interview (vision, users and their needs, core needs with priorities, MVP in and out, constraints, references, risks). This document decides what everything else builds; take the time.
Next after approval: `/seny:plan project` (architecture).

## Existing code: the documents in order
Map what exists so epics can build on it. Describe the code as it is, even where it is inconsistent. Never overwrite `product.md` if it exists. One document per run; the next pending one is the first that is missing or still `draft`:

1. **`codebase.md` + `baseline.md`.** Read the project rules, README and any architecture or decision docs. Explore in parallel (one Explore subagent each): stack and structure; data and backend; UI (theme, tokens, base components, how screens are built, accessibility); quality (test tools, where tests live, what has tests, lint and type settings, CI). Run the project's checks (lint, typecheck, tests; build if cheap) and write `baseline.md` (`Commit:` is `git rev-parse --short HEAD`; `By: codebase analysis`); it is a record, not a document to approve. Then write `codebase.md` through the loop: conventions in practice, coverage map, debt and risks with `file:line`, fragile areas. Ask only what the code can't answer ("there are two fetch patterns; which one is intended?").
2. **`architecture.md`**, as it is: stack with real versions, structure, data and state, data model, boundaries, conventions, key decisions found in the code or docs. `Design system:` is `design-system.md` if there is UI, else `not applicable (no UI)`. Explore again only the stack, structure and data areas if you need detail.
3. **`design-system.md`**, only if there is UI: the tokens and base components that actually exist. If there is no coherent system, say so; don't invent one.

When the last one is approved: "The codebase is mapped." Next: `/seny:plan project` for a roadmap, `/seny:research <epic>` for a first epic, or `/seny:evolve <change>` for an architecture improvement.

## Project refresh
1. Read `architecture.md`, `design-system.md`, `codebase.md` and `baseline.md`.
2. Compare them with the code now (Explore subagents, only the areas that may have changed), and re-run the checks.
3. For each **In transition** row, measure the real progress (how much of the old pattern is left) and any new code that broke the rule for new code.
4. Give me the differences as a list (document says / code does, with `file:line`), the transition progress, and the new baseline. Update the documents only after my yes; each updated document goes back to `draft` and through the loop.

## Epic → `<docs>/epics/<slug>/research.md`
1. Find the epic in `roadmap.md`. Not there: propose a kebab-case slug, a size (S 1–3 stories, M 4–8, L more) and a one-line goal, and ask whether to add it to the roadmap.
2. **Size S doesn't need research**: tell me, and point to `/seny:plan <slug>`. Go on only if I insist.
3. The epic's branch is `feature/<slug>` (or the repo's convention); the document loop creates it before writing. If the folder exists, update its research instead of starting over; keep any `## Spike findings` section as it is.
4. Inputs: the project rules, the roadmap row and its epic notes, `architecture.md`, `design-system.md`, the parts of `product.md`, `codebase.md` and `inputs/` that touch this epic, what I give you, and the code it touches. If the repo has code but no `architecture.md`, suggest `/seny:research project` first; if I prefer to go on, map only what this epic needs.
5. Through the loop (depth: size M or L), write one page at most:
   - **Problem** — 3 lines
   - **Users / roles** — what each one needs
   - **Constraints** — stack, platform, product rules, anything I stated
   - **Codebase** — what exists, what to reuse, where new code would fit, with `file:line`; tests around that code (if none, say so: implementation will need characterization tests)
   - **Fit with the project** — what in `architecture.md` and `design-system.md` this epic relies on, and anything it would have to change
   - **Challenges** — each one with its impact on the design
   - **Risks**
   - **Assumptions** (marked as such) and **open questions** (mark the ones only a spike can answer)
6. Next after approval: `/seny:spike <question>` for questions only code can answer, then `/seny:plan <slug>`.
