---
name: evolve
description: Change how the app is built without breaking it - framework or SDK upgrades, JavaScript to TypeScript, unifying patterns, swapping a library, restructuring. Researches the current state, gives options and a migration strategy, and plans incremental stories with characterization tests and a cleanup, tracking the transition in architecture.md. Only when the user runs /seny:evolve.
argument-hint: "<what to change, e.g. move server state from Redux to TanStack Query> | <evolution slug>"
disable-model-invocation: true
effort: high
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git log *) Bash(git status *)
---

# Evolve

Input: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above. Project rules: the files listed under "Project rules" above (already in your context). Formats: `${CLAUDE_PLUGIN_ROOT}/templates/evolution.md` and the feature plan format in the `plan` skill (`${CLAUDE_PLUGIN_ROOT}/skills/plan/SKILL.md`, "Feature plan format").

## Rules
- Do not write or change code. Only write `<docs>/features/<slug>/research.md`, `<docs>/features/<slug>/plan.md`, and, after my yes, `<docs>/project/architecture.md` and `<docs>/project/roadmap.md`.
- Never a big-bang rewrite. Every story must leave the app working and the checks no worse than the baseline.
- Behaviour doesn't change unless I say so: an evolution changes how, not what.
- If the input is a slug that already exists, read its docs and continue from where it stopped (usually the decision in step 3).
- If the change is really a feature (new behaviour for users), say so and point me to `/seny:research`. If it is one small, safe change (a patch bump, one file), point me to `/seny:plan light`.

## Steps

### 1. Research
1. Read the project rules and `<docs>/project/*`, especially `architecture.md` (and any open "In transition" rows: don't start a second evolution on the same area) and the baseline and tech debt in `research.md`.
2. Measure the current state with Explore subagents: where the current pattern or version is used (footprint), what depends on it, and how well it is tested. For upgrades, read the official migration guide and changelog of the target version (web search) and list the breaking changes that affect this code.
3. Propose a slug and write `<docs>/features/<slug>/research.md` in the evolution format.

### 2. Options
Give me 2–3 options (target and strategy), each with effort, risk and reversibility in one line, and your recommendation. Include "do nothing for now" when it is a real option. Then wait for my choice.

### 3. Plan (after my choice)
1. Write `<docs>/features/<slug>/plan.md` with `Type: evolution`, following the evolution specifics: characterization tests first, measurable slices with a `Progress:` line, a final cleanup epic.
2. Propose the changes to `architecture.md`: the "In transition" row (area, from, to, rule for new code, progress, slug) and the decision record. Show them and write them only after my yes.
3. If a roadmap exists, propose where the evolution goes (before the feature that needs it most, or between features) and update it after my yes.
4. Stop. Give me the strategy in 3 lines, the epics and stories, the rule for new code, and the first story: `/seny:implement <id>`.
