---
name: plan
description: Seny phase 2. Project mode - architecture, design system, roadmap and the foundation plan (greenfield), or a roadmap on top of the existing architecture (brownfield). Feature mode - an agile plan of epics and stories (plan.md) and, with UI, a design document (design.md). Light mode - a 1-3 story plan for a small, clear change. Only when the user runs /seny:plan.
argument-hint: "project | <feature slug> [design] | light <change>"
disable-model-invocation: true
effort: high
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh)
---

# Plan

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context).

You are in the Plan phase. Your job is to decide and slice, not to build.

## Rules
- Do not write or change code. Only write documents under `<docs>/project/` and `<docs>/features/`.
- Mode from the input:
  - `project` → **Project mode**.
  - `light <description>` → **Light mode**.
  - `<slug> design` → **Feature mode, step 2 only** (the plan exists).
  - `<slug>`, or empty → **Feature mode**. If empty, use the only feature with a `research.md` and no finished plan; if unclear, ask.
- If the research left open questions that change the plan, ask them in one batch before writing.
- Hard-to-reverse decisions (framework, database, auth, hosting): give me the trade-off and ask before writing around them. If two stacks fit, give the trade-off in two lines and let me choose.
- Challenge anything over-engineered. Prefer the boring option unless there is a reason not to.
- If a document already exists, update it: never reset the status of a story or feature that is not `todo`.
- Formats: `${CLAUDE_PLUGIN_ROOT}/templates/project-docs.md` (project docs), `${CLAUDE_PLUGIN_ROOT}/templates/feature-design.md` (feature design), and the feature plan format at the end of this file.

## Project mode
Requires `<docs>/project/research.md`; if missing, stop and tell me to run `/seny:research project`.

**Brownfield** (`architecture.md` already exists from the codebase analysis):
1. Don't rewrite the architecture. Write or update `<docs>/project/roadmap.md`: the features I want, in order, plus the tech-debt items from the research that I choose (ask me which). No foundation feature.
2. Stop. Give me the roadmap and the first feature: `/seny:research <feature>`.

**Greenfield**:
1. Write `<docs>/project/architecture.md`: stack (per my personal rules), structure, data and state, data model, boundaries, key decisions. App-wide only.
2. Write `<docs>/project/roadmap.md`: the MVP split into features, in order, each with a one-line goal, dependencies and status `todo`. The first feature is always `foundation`.
3. Write `<docs>/features/foundation/plan.md` (feature plan format; `Research: ../../project/research.md`). Foundation leaves the base running and deployed with nothing product-specific: scaffold, strict TypeScript, lint/typecheck/test wired, the theme from the design system, base layout or navigation, CI if wanted, a deploy of a placeholder screen.
4. Give me the architecture in 5 lines, the roadmap, the foundation stories, and the 2–3 decisions you are least sure about.
5. If the product has UI, ask whether to write the design system now. On yes:
   1. Load the design skills that match the stack, if installed: `frontend-design` (web direction), `web-design-guidelines` (web a11y/UX), `react-native-skills` (React Native / Expo). If none is installed, continue and tell me which would help.
   2. Give me two visual directions in 3 lines each and a recommendation, and wait for my choice. Use any references from the research.
   3. Write `<docs>/project/design-system.md`.
   4. Make sure foundation has stories to put the tokens in the theme and build the base components.
6. Stop. Next: `/seny:implement next`.

## Light mode (one small, clear change)
For a clear requirement, a few files, no new screens to design, and no change to the data model, auth or external services.
1. Read the project rules, `<docs>/project/architecture.md` if it exists, and only the code the change touches.
2. If it turns out to need more (new data model, auth, external service, new UI design, open requirements, more than ~3 stories), stop and tell me to use `/seny:research <change>` instead.
3. Propose a slug and write `<docs>/features/<slug>/plan.md` in the feature plan format, reduced: `Research: none (light)`, Goal, Scope, one epic with 1–3 stories. Leave out the other sections unless there is something to say.
4. Stop. Give me the stories and the first one: `/seny:implement <id>`.

## Feature mode

### Step 1 — Plan
1. Read `<docs>/features/<slug>/research.md` (if missing, stop and tell me to run `/seny:research`), the project rules, and everything in `<docs>/project/`.
2. Write `<docs>/features/<slug>/plan.md`. The feature builds on `architecture.md`: describe only what it adds or changes. Without `architecture.md`, describe the full architecture the feature relies on. If the feature touches an area **In transition**, plan it with the target pattern (the rule for new code), and say whether it should wait for the evolution or go first.
3. If the feature needs an app-wide change (new shared entity, new service, new token, new base component), list it in the plan and ask whether to update `architecture.md` or `design-system.md`. Update it only after a yes.
4. If `<docs>/project/roadmap.md` exists, set this feature to `in-progress` there (add it if it isn't listed).
5. Give me the architecture changes in a few lines, the epics and stories (id, title, tests mode, depends on), and the 2–3 decisions you are least sure about.
6. If the feature has UI (new screens, new components, or a visible change), say so and ask whether to write the design document now. Without UI, stop here and give me the first story to implement.

### Step 2 — Design (only if I say yes, or the input contains `design`)
1. Load the design skills that match the stack, as in Project mode.
2. Start from `<docs>/project/design-system.md` and the existing theme and components: they win over anything new. Use any reference I gave (Figma through a connected tool, screenshots, sites).
3. If the visual direction is open (no design system yet), give me two options in 3 lines each and a recommendation, and wait.
4. Write `<docs>/features/<slug>/design.md`. Only the sections the feature needs.
5. New tokens or base components other features will reuse belong in `design-system.md`: propose them and update it only after my yes.
6. Update the plan: add the `Design:` line to every UI story, and add or split stories if the design revealed missing work.
7. Stop. Give me the direction in 2 lines, the screens and new components, what changed in the plan, and the first story to implement.

## Feature plan format
```markdown
# <Feature name>

Branch: `feature/<slug>`
Research: <`research.md` | `../../project/research.md` | none (light)>

## Goal
<2–3 lines: what we deliver and for whom>

## Scope
- In: <item> — <why>
- Out: <item> — <why>

## Architecture changes
<What this feature adds on top of architecture.md. Omit lines that don't apply.>
- Structure: <new folders, modules, routes or screens>
- Data and state: <new entities and fields, server vs local state, queries>
- Boundaries: <new external APIs, auth rules, where input is validated>
- App-wide changes: <changes to architecture.md or design-system.md, approved or pending>

## Key decisions
- <decision> — <why> (rejected: <alternative>)

## Epics

### E1 · <epic title>
<one line: the value this epic delivers>

#### E1-S1 · <story title> — `todo`
- Story: As a <role>, I want <action>, so that <benefit>. (Omit for purely technical stories.)
- Acceptance criteria:
  - [ ] <observable, checkable outcome>
- Files: <expected files or areas>
- Tests: `tdd` | `after` | `none` — <what to test>
- Design: <`design.md#screen-...` or `../../project/design-system.md#...` — UI stories only>
- Depends on: <story ids, or —>
```

- Stories: as many as the work needs, each small (one commit, a handful of files, reviewable in one sitting).
- Prefer vertical slices over horizontal layers. The first epic leaves a thin end-to-end slice running.
- Tests: `tdd` for logic (business rules, state, validation, data transformations, hooks, utilities, API handlers); `after` for UI and wiring (component tests, or an E2E proposed in review); `none` for configuration, styling, docs. A story that changes untested existing code starts with characterization tests, whatever its mode.
- Evolutions (`Type: evolution`) are planned by `/seny:evolve`, not here; they use this same format.
- Statuses, exactly: `todo`, `in-progress`, `review`, `done`.
- Acceptance criteria are outcomes I can check, not tasks ("the form shows an error when the email is invalid", not "add validation").
