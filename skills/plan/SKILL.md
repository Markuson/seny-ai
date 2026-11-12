---
name: plan
description: Seny phase 2, decide and slice, one document per run. Project mode - architecture, design system, roadmap of sized epics and the foundation plan (new app), or a roadmap (existing code). Epic mode - the plan of one epic (and its design), as deep as its size. Light mode - 1-3 stories. Change mode - update a plan.
argument-hint: "project [architecture | design-system | roadmap | foundation] | <epic slug> [design | <change>] | light <change>"
disable-model-invocation: true
effort: high
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh)
---

# Plan

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Every document goes through `${CLAUDE_PLUGIN_ROOT}/references/document-loop.md`: read it now. Formats, read only the one you write: `${CLAUDE_PLUGIN_ROOT}/templates/project/<document>.md`, `${CLAUDE_PLUGIN_ROOT}/templates/epic/plan.md`, `${CLAUDE_PLUGIN_ROOT}/templates/epic/design.md`.

You are in the Plan phase. Your job is to decide and slice, not to build. This is where everything gets defined: precise beats fast.

## Rules
- **One document per run**, through the document loop. Then stop.
- Do not write or change code. Only write the document this run owns (plus the after-approval steps listed below).
- Mode from the input:
  - `project` (optionally followed by a document name) → **Project mode**.
  - `light <description>` → **Light mode**.
  - `<slug> design` → **Design**.
  - `<slug> <anything else>`, when `<docs>/epics/<slug>/plan.md` exists → **Change mode**.
  - `<slug>`, or empty → **Epic mode**. If empty, use the epic in progress, else the next roadmap epic whose dependencies are done; if unclear, ask.
- Hard-to-reverse decisions (framework, database, auth, hosting): give me the trade-off and ask before writing around them. If two options fit, give the trade-off in two lines and let me choose.
- Challenge anything over-engineered. Prefer the boring option unless there is a reason not to.
- Never restate the project docs: an epic's plan names the sections of `architecture.md` and `design-system.md` it relies on and describes only what it adds.
- Never reset the status of a story or epic that is not `todo`.

## Project mode

### New app: the documents in order
Requires `product.md` approved; if it is missing or `draft`, stop and point to `/seny:research project`. One document per run; the next pending one is the first that is missing or not approved (or the one named in the input):

1. **`architecture.md`.** Inputs: `product.md`, my stack defaults (`~/.claude/seny/stack.md`, else `${CLAUDE_PLUGIN_ROOT}/templates/stack.example.md`). Full interview: every hard-to-reverse choice is asked. Write stack, structure, data and state, data model, boundaries, conventions, key decisions. App-wide only.
   After approval: fill the placeholders of the project rules that the architecture now answers (Project, Stack, Commands with the planned scripts, Product rules from `product.md`). Show me the lines before writing them.
2. **`design-system.md`**, if the product has UI. Ask whether to write it now. No → set `Design system: declined on <YYYY-MM-DD>` in `architecture.md` and move on. No UI → `not applicable (no UI)`. Yes → load the design skills that match the stack, if installed (`frontend-design`, `web-design-guidelines`, `vercel-react-native-skills`; if none, continue and tell me which would help), give me two visual directions in 3 lines each and a recommendation, wait for my choice, then write it. After approval: set `Design system: design-system.md` in `architecture.md`.
3. **`roadmap.md`.** Inputs: `product.md`, `architecture.md`. Split the MVP into **epics**: each one a deliverable capability (or a technical block like `foundation` or `launch`) that fits one branch and one pull request. Give each a type, a **size** (S 1–3 stories, M 4–8, L more than 8, and split anything that would be L unless it can't be split), a one-line goal and dependencies. `foundation` is always first. Ask me about the order and the sizes.
4. **`epics/foundation/plan.md`**, in two passes like any size-L plan (see Epic mode). `Research: ../../project/product.md`. Foundation leaves the base running and deployed with nothing product-specific: scaffold, strict types, lint/typecheck/test wired, the theme from the design system, base layout or navigation, CI if wanted, a placeholder deploy. Its last story records `<docs>/project/baseline.md` with every check green (`By: foundation`). Its scope lists capabilities, not the stack again: that lives in `architecture.md`.

When the foundation plan is approved: "Planning is done." Next: `/clear`, then `/seny:implement next`.

### Existing code
Requires `codebase.md` and `architecture.md` approved. Only `roadmap.md`: the epics I want, plus the debt items and evolutions from `codebase.md` I choose (ask me which), each with type, size, goal and dependencies. No foundation; the architecture isn't rewritten. Next: the first row — size S → `/seny:plan <slug>`, M or L → `/seny:research <slug>`, evolution → `/seny:evolve <slug>`.

## Epic mode → `<docs>/epics/<slug>/plan.md`
1. **Size** from the roadmap row (or estimate it and tell me). It sets the depth and the inputs:
   - **S**: no research needed. Inputs: the roadmap row, `product.md`, `architecture.md`, `design-system.md` where relevant, and the code the epic touches. One pass, 0–1 rounds of questions.
   - **M**: requires `research.md` approved (else stop and point to `/seny:research <slug>`). One pass, 1–2 rounds.
   - **L**: requires `research.md` approved. **Two passes**, each its own run through the loop:
     - *Shape*: goal, scope, architecture changes, key decisions, and the stories as one line each, in order. Approve with `shape approved`.
     - *Stories* (the next run, after `/clear`, when the plan says `shape approved`): every story in full. On approval, `approved`.
     Before the shape pass, say whether the epic could be split instead.
2. Read the research's `Spike findings`. If an open question can only be answered by trying code and has no finding, suggest `/seny:spike <question>` instead of planning around a guess.
3. Write the plan (format: `templates/epic/plan.md`). Stories are a flat list `S1…Sn`. Every story gets a `Verify:` line, and every non-trivial one an `Approach:` anchored to the code (`file:line`, symbols), so `/seny:implement` can start in a fresh session without exploring again. If the epic touches an area **In transition**, plan it with the target pattern and say whether it should wait for the evolution or go first.
4. App-wide changes (a new shared entity, service, token or base component): list them in the plan and ask whether to update `architecture.md` or `design-system.md`; update them only after a yes.
5. If the story count doesn't fit the size, say so and propose resizing the roadmap row or splitting the epic.
6. After approval: set the roadmap row to `in-progress` (add the row if it isn't listed). Next: if the epic has UI (new screens, components or a visible change) and no approved `design.md`, `/seny:plan <slug> design`; otherwise "Planning is done for this epic. Next: `/clear`, then `/seny:implement next`."

## Design → `<docs>/epics/<slug>/design.md`
Requires the plan approved. Load the design skills that match the stack, as in Project mode. Start from `design-system.md` and the existing theme and components: they win over anything new. Use any reference I give (Figma through a connected tool, screenshots, sites). If the visual direction is open (no design system yet), give me two options in 3 lines each and a recommendation, and wait. Write only the sections the epic needs. New tokens or base components other epics will reuse are proposed for `design-system.md` and written only after my yes.
After approval: add the `Design:` line to every UI story in the plan, and add or split stories if the design revealed missing work (the plan goes back to `draft` for that change and through the loop). Next: `/clear`, then `/seny:implement next`.

## Light mode (one small, clear change, no roadmap row needed)
For a clear requirement, a few files, no new screens to design, and no change to the data model, auth or external services.
1. Read the project rules, `architecture.md` if it exists, and only the code the change touches.
2. If it turns out to need more (new data model, auth, external service, new UI design, open requirements, more than ~3 stories), stop and tell me to treat it as an epic instead.
3. Through the loop (0–1 rounds), write `<docs>/epics/<slug>/plan.md` in the light form: `Status`, `Branch:`, `Research: none (light)`, Goal, Scope, 1–3 stories, each with Approach (unless trivial) and Verify.
4. Next after approval: `/seny:implement S1` (or `next`).

## Change mode (the plan exists and something changed)
1. Read the plan, its `research.md` and `design.md` if they exist, and the project docs the change touches.
2. If the change needs new understanding (new data model, auth, external service, new screens, open requirements), say so and suggest updating the research first.
3. Update the plan: add, split, reorder, edit or remove `todo` stories, and the Scope, Architecture changes and Key decisions the change touches. Stories that are not `todo` are history: never change their status, criteria, review notes or ticks; if the change affects one, add a new story and say why.
4. The plan goes back to `draft` and through the loop from step 5 (show me what changed). Next after approval: `/seny:implement next`.
