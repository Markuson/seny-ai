---
name: evolve
description: Change how the app is built without breaking it - framework or SDK upgrades, JavaScript to TypeScript, unifying patterns, swapping a library, restructuring. Researches the current state, gives options and a migration strategy, and plans incremental stories with characterization tests and a cleanup, tracking the transition in architecture.md.
argument-hint: "<what to change, e.g. move server state from Redux to TanStack Query> | <evolution slug>"
disable-model-invocation: true
effort: high
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git status *)
---

# Evolve

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Formats: `${CLAUDE_PLUGIN_ROOT}/templates/epic/evolution.md` and `${CLAUDE_PLUGIN_ROOT}/templates/epic/plan.md`. Each document goes through `${CLAUDE_PLUGIN_ROOT}/references/document-loop.md`: one document per run.

## Rules
- Do not write or change code. Only write `<docs>/epics/<slug>/research.md`, `<docs>/epics/<slug>/plan.md`, and, after my yes, `<docs>/project/architecture.md` and `<docs>/project/roadmap.md`. An evolution is an epic with `Type: evolution`.
- Never a big-bang rewrite. Every story must leave the app working and the checks no worse than the baseline.
- Behaviour doesn't change unless I say so: an evolution changes how, not what.
- If the input is a slug that already exists, read its docs and continue from where it stopped: research in `draft` → finish its review and my choice; research approved → step 2.
- If the change is really new behaviour for users, say so: it is an epic for the roadmap, not an evolution. If it is one small, safe change (a patch bump, one file), point me to `/seny:plan light`.
- If the decision hinges on something only code can show (does the new version support X, how fast is the new library here), suggest `/seny:spike <question>` before choosing.
- Once the plan exists, `/seny:implement` keeps the `Progress:` of the **In transition** row up to date on its own.

## Steps

### 1. Research and options (first run)
1. Read the project rules, `architecture.md` (and any open "In transition" rows: don't start a second evolution on the same area), the tech debt in `codebase.md` and `baseline.md`.
2. Measure the current state with Explore subagents: where the current pattern or version is used (footprint), what depends on it, and how well it is tested. For upgrades, read the official migration guide and changelog of the target version (web search) and list the breaking changes that affect this code.
3. Propose a slug and a size, and write `<docs>/epics/<slug>/research.md` in the evolution format, through the document loop. It includes 2–3 options (target and strategy), each with effort, risk and reversibility in one line, "do nothing for now" when it is a real option, and your recommendation.
4. At hand-over, ask me which option I choose. Approving the research is choosing: record it as `Chosen: <option> (YYYY-MM-DD)` under the options table. Next: `/clear`, then `/seny:evolve <slug>`.

### 2. Plan (next run, the research is approved with a chosen option)
1. Write `<docs>/epics/<slug>/plan.md` with `Type: evolution` through the document loop (two passes if the size is L), following the evolution specifics: characterization tests first, measurable slices with a `Progress:` line, cleanup stories last. Every story gets `Verify:` and, unless trivial, an `Approach:` like any plan.
2. After approval, propose the changes to `architecture.md`: the "In transition" row (area, from, to, rule for new code, progress, slug) and the decision record. Show them and write them only after my yes.
3. If a roadmap exists, propose where the evolution goes (before the epic that needs it most, or between epics), as a row with `Type: evolution` and its size, and update it after my yes.
4. Stop. Give me the strategy in 3 lines, the stories, the rule for new code, and the first story: `/clear`, then `/seny:implement <slug> S1`.
