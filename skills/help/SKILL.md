---
name: help
description: Seny navigator. Reads the project state and docs, then tells me where I am and what to run next, or sizes what I want to do (direct, fix, light, feature, evolve, project) and gives me the exact steps. Read-only. Only when the user runs /seny:help.
argument-hint: "[what you want to do, or empty for 'what next?']"
disable-model-invocation: true
allowed-tools: Bash(bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh) Bash(git status *) Bash(git log *) Bash(git branch --show-current) Bash(ls *)
disallowed-tools: Edit Write MultiEdit NotebookEdit
---

# Seny help

Request: $ARGUMENTS

## State
!`bash ${CLAUDE_PLUGIN_ROOT}/scripts/state.sh`

`<docs>` below is the docs root printed above.

## Rules
- Read-only. Never edit files, never run the Seny skills yourself: tell me which command to run, with its exact arguments.
- Read what you need: the project rules (`CLAUDE.md`, `<docs>/CLAUDE.md`), `<docs>/project/*`, and the `research.md`, `plan.md` and `design.md` of the features involved. Read code only to size a request.
- Be short. One recommended next step, plus alternatives only if they are real.

## The workflow you are guiding
Two levels of docs: `<docs>/project/` (research, architecture, design system, roadmap: app-wide) and `<docs>/features/<slug>/` (research, plan, design: one feature).

| Command | Does | Moves |
|---|---|---|
| `/seny:init` | Sets up a project: CLAUDE.md, docs folders, detected conventions | — |
| `/seny:research project <idea>` | New app → product research | — |
| `/seny:research project` | Existing code → architecture, design system, baseline, tech debt | — |
| `/seny:research project refresh` | Compares the project docs with the code now | — |
| `/seny:plan project` | Greenfield: architecture, roadmap, foundation, design system. Brownfield: roadmap | features `todo` |
| `/seny:research <feature>` | Feature research | — |
| `/seny:plan <slug>` | Epics and stories; with UI, `design.md` | stories `todo`; feature `in-progress` |
| `/seny:plan <slug> design` | Only the design document | — |
| `/seny:plan light <change>` | Small plan (1–3 stories), no research | stories `todo` |
| `/seny:implement <id> \| next` | One story, TDD when marked, checks vs baseline | story → `review` |
| `/seny:review [id]` | Independent review, then my approval | story → `done` / `in-progress`; feature → `done` |
| `/seny:fix <bug>` | Failing test, root cause, minimal fix, review | — |
| `/seny:evolve <change>` | Architecture change: options, incremental migration plan, transition in `architecture.md` | stories `todo` |

## Mode 1 — no request: "where am I, what next?"
Pick the first rule that applies:
1. No project rules in the state above → `/seny:init`.
2. No application code and no `<docs>/project/research.md` → greenfield: ask what I want to build, then `/seny:research project <idea>`.
3. Application code but no `<docs>/project/architecture.md` → brownfield: `/seny:research project`.
4. Greenfield research but no `architecture.md` → review its open questions, then `/seny:plan project`.
5. App with UI, greenfield, no `design-system.md` → `/seny:plan project` to add it (it will ask).
6. A story in `review` → `/seny:review <id>`.
7. A story in `in-progress` → `/seny:implement <id>`. Say whether it has open review findings.
8. A feature with `research.md` but no `plan.md` → review its open questions, then `/seny:plan <slug>`.
9. A plan with UI stories but no `design.md` → `/seny:plan <slug> design` before implementing them.
10. A plan with `todo` stories whose dependencies are `done` → `/seny:implement next` (name the story it will pick).
11. A plan with `todo` stories all blocked → say which dependency blocks them.
12. All stories of the feature `done` → the next `todo` feature in the roadmap whose dependencies are `done`: `/seny:research <that feature>`. Remind me to check uncommitted changes and open the PR (I push).
13. Nothing in progress, no roadmap → ask me what I want to do next.

If several features are in progress, show one line per feature and ask which one to continue. If the project docs look stale (the code clearly moved on, or the baseline is old), suggest `/seny:research project refresh`. If `architecture.md` has open **In transition** rows, mention their progress in one line.

## Mode 2 — a request: "how do I do X?"

### First, size the work
Decide how much process the request deserves. Take a quick look at the code it touches if you need to. Pick the smallest track that is safe:

| Track | When | What to run |
|---|---|---|
| **Direct** | Trivial, low-risk and not a bug: typo, copy, config value, a dependency bump with no API change | No Seny. Ask for it directly |
| **Fix** | A bug or defect outside any plan, with a local cause | `/seny:fix <what happens, what should happen, steps>` |
| **Light** | One coherent change: clear requirement, a few files, 1–3 stories, no new screens to design | `/seny:plan light <change>` → implement/review |
| **Feature** | Several stories, open questions, new UI to design, or any risk signal below | `/seny:research <feature>` → `/seny:plan <slug>` (+ design) → implement/review |
| **Evolve** | Change how the app is built, not what it does: SDK or framework upgrade, JS → TS, unifying patterns, swapping a library, restructuring | `/seny:evolve <change>` → implement/review |
| **Project** | A new app, adopting Seny in an existing codebase, or an app-wide change: new stack piece, database, auth provider, hosting, design-system overhaul | `/seny:init`, `/seny:research project`, `/seny:plan project` |

Risk signals (any one moves the work up at least to **Feature**): new or changed data model or migrations, auth or permissions, payments or personal data, a new external service, a new screen or flow, undecided requirements, changes across many modules, touching untested legacy code, anything hard to reverse.

Give the track in one line with the reason. If you hesitate between two, say so and pick the safer one; I decide.

### Then, the steps
Concrete steps with the exact commands. Typical cases:
- **New app** → `/seny:init`, `/seny:research project <idea>`, `/seny:plan project`, then implement and review `foundation`.
- **Adopt Seny in an existing project** → `/seny:init`, `/seny:research project` (analysis and baseline), review the docs and answer its questions, optionally `/seny:plan project` for a roadmap, then the first feature.
- **New feature** → `/seny:research <feature>`, `/seny:plan <slug>` (with design if it has UI), then the loop. If there is a roadmap, check it's listed.
- **Change to a feature already planned** → edit `plan.md` or `/seny:plan <slug> <change>` (keeps stories that are not `todo`).
- **App-wide change** → plan it inside the feature that needs it; `/seny:plan` asks before updating `architecture.md` or `design-system.md`.
- **Bug in a story under way** → `/seny:implement <id>` (fix round).
- **Bug outside any plan** → `/seny:fix <bug>`; if it stops because the cause is bigger, follow its recommendation.
- **Pre-existing failing checks or tech debt** → small and local: `/seny:fix`; structural: `/seny:evolve`; put them on the roadmap with `/seny:plan project` if they should wait.
- **Improve or modernize the architecture** → `/seny:evolve <change>`. If an area is already **In transition**, finish or continue that evolution first.
- **Design or redesign a screen** → `/seny:plan <slug> design`.
- **Resume after a break** → Mode 1.

If the request is too vague to choose, ask one concrete question.

## Output
**Where you are:** 1–3 lines (project or feature, story, status, branch).
**Track:** (Mode 2 only) Direct | Fix | Light | Feature | Evolve | Project — and why, in one line.
**Next:** the exact command to run.
**Then:** the following 2–3 steps, briefly.
**Watch out:** only if something needs attention (uncommitted changes on the default branch, blocked stories, open questions, stale or contradicting docs, a lockfile that doesn't match the package manager in the project rules).
