---
name: plan
description: Seny phase 2. Project mode - architecture, design system, roadmap and the foundation plan (new app), or a roadmap on top of the existing architecture. Feature mode - epics and stories (plan.md) and, with UI, a design document. Light mode - a 1-3 story plan for a small, clear change. Change mode - update an existing plan.
argument-hint: "project | <feature slug> [design | <change>] | light <change>"
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
  - `<slug> <anything else>`, when `<docs>/features/<slug>/plan.md` exists → **Change mode**.
  - `<slug>`, or empty → **Feature mode**. If empty, use the only feature with a `research.md` and no plan; if unclear, ask.
- If the research left open questions that change the plan, ask them in one batch before writing. If one can only be answered by trying code and has no spike finding, suggest `/seny:spike <question>` instead of planning around a guess.
- Hard-to-reverse decisions (framework, database, auth, hosting): give me the trade-off and ask before writing around them. If two options fit, give the trade-off in two lines and let me choose.
- Challenge anything over-engineered. Prefer the boring option unless there is a reason not to.
- If a document already exists, update it: never reset the status of a story or feature that is not `todo`.
- Formats, read only the ones you write: `${CLAUDE_PLUGIN_ROOT}/templates/project/<document>.md` (project docs), `${CLAUDE_PLUGIN_ROOT}/templates/feature/plan.md` (plans and stories), `${CLAUDE_PLUGIN_ROOT}/templates/feature/design.md` (feature design).

## Project mode
Requires `<docs>/project/product.md` (new app) or `<docs>/project/codebase.md` (existing code); if neither exists, stop and tell me to run `/seny:research project`.

**Existing code** (`architecture.md` already exists from the codebase analysis):
1. Don't rewrite the architecture. Write or update `<docs>/project/roadmap.md`: the features I want, in order, plus the tech-debt items and evolutions from `codebase.md` that I choose (ask me which), each with its `Type`. No foundation feature.
2. Stop. Give me the roadmap and the first row: a feature → `/seny:research <slug>`, an evolution → `/seny:evolve <slug>`.

**New app**:
1. Choose the stack from my stack defaults: `~/.claude/seny/stack.md` if it exists, else `${CLAUDE_PLUGIN_ROOT}/templates/stack.example.md`. Apply them to what `product.md` needs; ask about anything hard to reverse.
2. Write `<docs>/project/architecture.md`: stack, structure, data and state, data model, boundaries, key decisions. App-wide only.
3. Write `<docs>/project/roadmap.md`: the MVP split into features (`Type: feature`), in order, each with a one-line goal, dependencies and status `todo`. The first one is always `foundation`.
4. Write `<docs>/features/foundation/plan.md` (`Research: ../../project/product.md`). Foundation leaves the base running and deployed with nothing product-specific: scaffold, strict types, lint/typecheck/test wired, the theme from the design system, base layout or navigation, CI if wanted, a deploy of a placeholder screen. Its last story records `<docs>/project/baseline.md` with every check green (`By: foundation`).
5. Give me the architecture in 5 lines, the roadmap, the foundation stories, and the 2–3 decisions you are least sure about.
6. If the product has UI, ask whether to write the design system now. Without UI, set `Design system: not applicable (no UI)` in `architecture.md`. If I say no, set `Design system: declined on <YYYY-MM-DD>`, so nobody asks again. On yes:
   1. Load the design skills that match the stack, if installed: `frontend-design` (web direction), `web-design-guidelines` (web a11y/UX), `react-native-skills` (React Native / Expo). If none is installed, continue and tell me which would help.
   2. Give me two visual directions in 3 lines each and a recommendation, and wait for my choice. Use any references from `product.md`.
   3. Write `<docs>/project/design-system.md` and set `Design system: design-system.md` in `architecture.md`.
   4. Make sure foundation has stories to put the tokens in the theme and build the base components.
7. Stop. Next: `/clear`, then `/seny:implement next`.

## Light mode (one small, clear change)
For a clear requirement, a few files, no new screens to design, and no change to the data model, auth or external services.
1. Read the project rules, `<docs>/project/architecture.md` if it exists, and only the code the change touches.
2. If it turns out to need more (new data model, auth, external service, new UI design, open requirements, more than ~3 stories), stop and tell me to use `/seny:research <change>` instead.
3. Propose a slug and write `<docs>/features/<slug>/plan.md` in the light form of the plan format: `Branch:`, `Research: none (light)`, Goal, Scope, one epic with 1–3 stories, each with Approach (unless trivial) and Verify.
4. Stop. Give me the stories and the first one: `/seny:implement <id>`.

## Change mode (the plan exists and something changed)
1. Read the plan, its `research.md` and `design.md` if they exist, and the project docs the change touches.
2. If the change needs new understanding (new data model, auth, external service, new screens, open requirements), say so and suggest `/seny:research <slug>` to update the research first.
3. Update `plan.md`: add, split, reorder or edit stories, and the Scope, Architecture changes and Key decisions the change touches. Stories that are not `todo` are history: never change their status, criteria, review notes or ticks. If the change affects one of them, add a new story instead and say why.
4. Stop. Give me what changed (stories added, edited, removed or reordered), any new open question, and the next story: `/seny:implement next`.

## Feature mode

### Step 1 — Plan
1. Read `<docs>/features/<slug>/research.md` (if missing, stop and tell me to run `/seny:research`), including its `Spike findings`, the project rules, `architecture.md`, `design-system.md`, and the parts of `product.md` and `codebase.md` the feature touches.
2. Write `<docs>/features/<slug>/plan.md`. The feature builds on `architecture.md`: describe only what it adds or changes. Without `architecture.md`, describe the full architecture the feature relies on. If the feature touches an area **In transition**, plan it with the target pattern (the rule for new code), and say whether it should wait for the evolution or go first.
3. Every story gets a `Verify:` line, and every non-trivial story an `Approach:` anchored to the code the research mapped (`file:line`, symbols), so `/seny:implement` can start in a fresh session without exploring again.
4. If the feature needs an app-wide change (new shared entity, new service, new token, new base component), list it in the plan and ask whether to update `architecture.md` or `design-system.md`. Update it only after a yes.
5. If `<docs>/project/roadmap.md` exists, set this feature to `in-progress` there (add it if it isn't listed).
6. Give me the architecture changes in a few lines, the epics and stories (id, title, tests mode, depends on), and the 2–3 decisions you are least sure about.
7. If the feature has UI (new screens, new components, or a visible change), say so and ask whether to write the design document now. Without UI, stop here and give me the first story to implement (`/clear` first).

### Step 2 — Design (only if I say yes, or the input contains `design`)
1. Load the design skills that match the stack, as in Project mode.
2. Start from `<docs>/project/design-system.md` and the existing theme and components: they win over anything new. Use any reference I gave (Figma through a connected tool, screenshots, sites).
3. If the visual direction is open (no design system yet), give me two options in 3 lines each and a recommendation, and wait.
4. Write `<docs>/features/<slug>/design.md`. Only the sections the feature needs.
5. New tokens or base components other features will reuse belong in `design-system.md`: propose them and update it only after my yes.
6. Update the plan: add the `Design:` line to every UI story, and add or split stories if the design revealed missing work.
7. Stop. Give me the direction in 2 lines, the screens and new components, what changed in the plan, and the first story to implement.
