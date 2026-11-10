---
name: help
description: Seny navigator. Reads the project state and docs, then tells me where I am and what to run next, or sizes what I want to do (direct, fix, spike, light, feature, evolve, project) and gives me the exact steps. Read-only.
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
- Read what you need: the state above, `<docs>/project/*`, and the `research.md`, `plan.md` and `design.md` of the features involved. Read code only to size a request.
- Be short. One recommended next step, plus alternatives only if they are real.

## The workflow you are guiding
Docs: `<docs>/project/` (app-wide: `product.md`, `codebase.md`, `baseline.md`, `architecture.md`, `design-system.md`, `roadmap.md`) and `<docs>/features/<slug>/` (`research.md`, `plan.md`, `design.md`). Story statuses: `todo` → `in-progress` → `review` → `done` (only I set `done`).
- `/seny:init` — set up a project.
- `/seny:research project [<idea> | refresh]` — product (new app), codebase analysis + baseline (existing code), or refresh.
- `/seny:research <feature>` — feature research.
- `/seny:spike <question>` — answer one technical question with throwaway code; findings go to the feature research.
- `/seny:plan project` — architecture, design system, roadmap and foundation (new app), or a roadmap (existing code).
- `/seny:plan <slug> [design | <change>]` · `/seny:plan light <change>` — plan, design, change a plan, or a 1–3 story plan.
- `/seny:implement <id> | next [no-review]` — one story; reviews itself when the review mode is `auto`.
- `/seny:review [id] [done | range]` — review again, review in manual mode, or close an approved story.
- `/seny:fix <bug>` — failing test, root cause, minimal fix, review.
- `/seny:evolve <change>` — architecture change as an incremental migration.

## Mode 1 — no request: "where am I, what next?"
Work in flight comes first. Pick the first rule that applies:
1. No project rules in the state → `/seny:init`.
2. A story in `review` → if its last recorded review is `APPROVED`, ask me to check it by hand (its `Verify:` manual part), then `/seny:review <id> done`; otherwise `/seny:review <id>`.
3. A story in `in-progress` → `/seny:implement <id>`. Say whether it has open review findings or `Notes:`.
4. No application code and no `product.md` → new app: ask what I want to build, then `/seny:research project <idea>`.
5. Application code but no `architecture.md` → existing code: `/seny:research project`.
6. `product.md` but no `architecture.md` → review its open questions, then `/seny:plan project`.
7. App with UI whose `architecture.md` has no `Design system:` decision (neither the file, nor declined, nor not applicable) → `/seny:plan project` to settle it.
8. A feature with `research.md` but no `plan.md` → review its open questions; if one can only be answered by trying code, `/seny:spike <question>`; otherwise `/seny:plan <slug>`.
9. A plan with UI stories but no `design.md` → `/seny:plan <slug> design` before implementing them.
10. A plan with `todo` stories whose dependencies are `done` → `/seny:implement next` (name the story it will pick).
11. A plan with `todo` stories all blocked → say which dependency blocks them.
12. Every story of the feature `done` → the next `todo` roadmap row whose dependencies are `done`: `Type: feature` → `/seny:research <slug>`; `Type: evolution` → `/seny:evolve <slug>`. Remind me to check uncommitted changes and open the PR (I push).
13. Nothing in progress, no roadmap → ask me what I want to do next.

If several features are in progress, show one line per feature and ask which one to continue. If the baseline is stale, say that the next `/seny:implement` or `/seny:fix` will re-record it. If the project docs look out of date (the code clearly moved on), suggest `/seny:research project refresh`. If `architecture.md` has open **In transition** rows, mention their progress in one line.

## Mode 2 — a request: "how do I do X?"

### First, size the work
Decide how much process the request deserves. Take a quick look at the code it touches if you need to. Pick the smallest track that is safe:

| Track | When | What to run |
|---|---|---|
| **Direct** | Trivial, low-risk and not a bug: typo, copy, config value, a dependency bump with no API change | No Seny. Ask for it directly |
| **Fix** | A bug or defect outside any plan, with a local cause | `/seny:fix <what happens, what should happen, steps>` |
| **Spike** | A technical question only code can answer: can this library, device, SDK or API do X, how fast is it | `/seny:spike <question>`, then the track the answer calls for |
| **Light** | One coherent change: clear requirement, a few files, 1–3 stories, no new screens to design | `/seny:plan light <change>` → implement |
| **Feature** | Several stories, open questions, new UI to design, or any risk signal below | `/seny:research <feature>` → `/seny:plan <slug>` (+ design) → implement |
| **Evolve** | Change how the app is built, not what it does: SDK or framework upgrade, JS → TS, unifying patterns, swapping a library, restructuring | `/seny:evolve <change>` → implement |
| **Project** | A new app, adopting Seny in an existing codebase, or an app-wide change: new stack piece, database, auth provider, hosting, design-system overhaul | `/seny:init`, `/seny:research project`, `/seny:plan project` |

Risk signals (any one moves the work up at least to **Feature**): new or changed data model or migrations, auth or permissions, payments or personal data, a new external service, a new screen or flow, undecided requirements, changes across many modules, touching untested legacy code, anything hard to reverse.

Give the track in one line with the reason. If you hesitate between two, say so and pick the safer one; I decide.

### Then, the steps
Concrete steps with the exact commands. Typical cases:
- **New app** → `/seny:init`, `/seny:research project <idea>`, `/seny:plan project`, then implement `foundation`.
- **Adopt Seny in an existing project** → `/seny:init`, `/seny:research project` (analysis and baseline), review the docs and answer its questions, optionally `/seny:plan project` for a roadmap, then the first feature.
- **New feature** → `/seny:research <feature>`, `/seny:spike` for questions only code can answer, `/seny:plan <slug>` (with design if it has UI), then `/seny:implement` story by story. If there is a roadmap, check it's listed.
- **Change to a feature already planned** → `/seny:plan <slug> <change>` (keeps stories that are not `todo`).
- **App-wide change** → plan it inside the feature that needs it; `/seny:plan` asks before updating `architecture.md` or `design-system.md`.
- **Bug in a story under way** → `/seny:implement <id>` (fix round).
- **Bug outside any plan** → `/seny:fix <bug>`; if it stops because the cause is bigger, follow its recommendation.
- **Pre-existing failing checks or tech debt** → small and local: `/seny:fix`; structural: `/seny:evolve`; put them on the roadmap with `/seny:plan project` if they should wait.
- **Improve or modernize the architecture** → `/seny:evolve <change>`. If an area is already **In transition**, finish or continue that evolution first.
- **Not sure a library, device or API can do it** → `/seny:spike <question>`.
- **Design or redesign a screen** → `/seny:plan <slug> design`.
- **Resume after a break** → Mode 1.

If the request is too vague to choose, ask one concrete question.

## Output
**Where you are:** 1–3 lines (project or feature, story, status, branch).
**Track:** (Mode 2 only) Direct | Fix | Spike | Light | Feature | Evolve | Project — and why, in one line.
**Next:** the exact command to run.
**Then:** the following 2–3 steps, briefly.
**Watch out:** only if something needs attention (uncommitted changes on the default branch, blocked stories, open questions, stale baseline, stale or contradicting docs, a lockfile that doesn't match the package manager in the project rules).
