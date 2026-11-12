---
name: help
description: Seny navigator. Reads the project state and docs, then tells me where I am and what to run next, or sizes what I want to do (direct, fix, spike, light, epic, evolve, project) and gives me the exact steps. Read-only.
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
- Read what you need: the state above (it shows every document's status and every epic's size), `<docs>/project/*`, and the docs of the epics involved. Read code only to size a request.
- Be short. One recommended next step, plus alternatives only if they are real.

## The workflow you are guiding
Three levels: the **project** (`<docs>/project/`: `product.md`, `codebase.md`, `baseline.md`, `architecture.md`, `design-system.md`, `roadmap.md`), **epics** (roadmap rows, each with a size, its own branch, PR and folder `<docs>/epics/<slug>/`), and **stories** (`S1…Sn` in the epic's `plan.md`; one commit, one session). Every document is `draft` until I approve it, and one command writes one document. Story statuses: `todo` → `in-progress` → `review` → `done` (only I set `done`).

Epic sizes set the planning: **S** (1–3 stories) `/seny:plan <slug>` only · **M** (4–8) `/seny:research <slug>` → `/seny:plan <slug>` · **L** (more) research, then the plan in two passes (shape, stories) · plus `/seny:plan <slug> design` when there's UI.

Light plans (`Type: light`) are small changes outside the roadmap: they show among the open epics but are not roadmap work. `<docs>/project/inputs/` is reference material, not documents to approve.

Commands: `/seny:init` · `/seny:research project [<idea> | refresh | <document>]` · `/seny:research <epic>` · `/seny:spike <question>` · `/seny:plan project [<document>]` · `/seny:plan <slug> [design | <change>]` · `/seny:plan light <change>` · `/seny:implement [<slug>] <S#> | next [no-review]` · `/seny:review [<slug>] [<S#>] [done | range]` · `/seny:fix <bug>` · `/seny:evolve <change>`.

## Mode 1 — no request: "where am I, what next?"
Work in flight comes first. Pick the first rule that applies:
1. No project rules in the state → `/seny:init`.
2. A story in `review` → if its last recorded review is `APPROVED`, ask me to check it by hand (its `Verify:` manual part), then `/seny:review <slug> <S#> done`; otherwise `/seny:review <slug> <S#>`.
3. A story in `in-progress` → `/seny:implement <slug> <S#>`. Say whether it has open review findings or `Notes:`.
4. A document in `draft` (or a plan in `shape approved`) → finish it: name the document and the command that continues it (the one that wrote it).
5. New app (no application code): no `product.md` → ask what I want to build, then `/seny:research project <idea>`; `product.md` approved but `architecture.md`, `design-system.md` (UI, not declined), `roadmap.md` or the foundation plan still pending → `/seny:plan project`, naming the next document.
6. Existing code: `codebase.md`, `architecture.md` or `design-system.md` (UI) missing → `/seny:research project`, naming the next document.
7. An epic in progress without an approved plan → size S: `/seny:plan <slug>`; M or L: `/seny:research <slug>` if its research isn't approved, then `/seny:plan <slug>`. Research with questions only code can answer → `/seny:spike <question>` first.
8. An approved plan with UI stories but no approved `design.md` → `/seny:plan <slug> design`.
9. `todo` stories whose dependencies are `done` → `/seny:implement next` (name the story it will pick).
10. `todo` stories all blocked → say which dependency blocks them.
11. Every story of the epic `done` → the next `todo` roadmap row whose dependencies are `done`: evolution → `/seny:evolve <slug>`; size S → `/seny:plan <slug>`; M or L → `/seny:research <slug>`. Remind me to check uncommitted changes and open the PR (I push).
12. Nothing in progress, no roadmap → ask me what I want to do next.

If several epics are in progress, show one line per epic and ask which one to continue. If the baseline is stale, say that the next `/seny:implement` or `/seny:fix` will re-record it. If the project docs look out of date (the code clearly moved on), suggest `/seny:research project refresh`. If `architecture.md` has open **In transition** rows, mention their progress in one line.

## Mode 2 — a request: "how do I do X?"

### First, size the work
Decide how much process the request deserves. Take a quick look at the code it touches if you need to. Pick the smallest track that is safe:

| Track | When | What to run |
|---|---|---|
| **Direct** | Trivial, low-risk and not a bug: typo, copy, config value, a dependency bump with no API change | No Seny. Ask for it directly |
| **Fix** | A bug or defect outside any plan, with a local cause | `/seny:fix <what happens, what should happen, steps>` |
| **Spike** | A technical question only code can answer: can this library, device, SDK or API do X, how fast is it | `/seny:spike <question>`, then the track the answer calls for |
| **Light** | One coherent change outside the roadmap: clear requirement, a few files, 1–3 stories, no new screens to design | `/seny:plan light <change>` → implement |
| **Epic** | A deliverable capability: several stories, open questions, new UI, or any risk signal below. Gets a roadmap row and a size | S: `/seny:plan <slug>` · M/L: `/seny:research <slug>` → `/seny:plan <slug>` · then implement |
| **Evolve** | Change how the app is built, not what it does: SDK or framework upgrade, JS → TS, unifying patterns, swapping a library, restructuring | `/seny:evolve <change>` → implement |
| **Project** | A new app, adopting Seny in an existing codebase, or an app-wide change: new stack piece, database, auth provider, hosting, design-system overhaul | `/seny:init`, `/seny:research project`, `/seny:plan project` |

Risk signals (any one moves the work up at least to **Epic**, size M): new or changed data model or migrations, auth or permissions, payments or personal data, a new external service, a new screen or flow, undecided requirements, changes across many modules, touching untested legacy code, anything hard to reverse.

Give the track (and the size, for an epic) in one line with the reason. If you hesitate between two, say so and pick the safer one; I decide.

### Then, the steps
Concrete steps with the exact commands, reminding me that each document is reviewed and approved before the next, with `/clear` in between. Typical cases:
- **New app** → `/seny:init`, `/seny:research project <idea>` (product), `/seny:plan project` four times (architecture, design system, roadmap, foundation plan in two passes), then `/seny:implement next`.
- **Adopt Seny in an existing project** → `/seny:init`, `/seny:research project` three times (codebase and baseline, architecture, design system), optionally `/seny:plan project` for a roadmap, then the first epic.
- **New epic** → add it to the roadmap with a size (`/seny:plan project roadmap`, or let research propose it), then the steps for its size.
- **Change to an epic already planned** → `/seny:plan <slug> <change>` (keeps stories that are not `todo`).
- **App-wide change** → plan it inside the epic that needs it; `/seny:plan` asks before updating `architecture.md` or `design-system.md`.
- **Bug in a story under way** → `/seny:implement <slug> <S#>` (fix round).
- **Bug outside any plan** → `/seny:fix <bug>`; if it stops because the cause is bigger, follow its recommendation.
- **Pre-existing failing checks or tech debt** → small and local: `/seny:fix`; structural: `/seny:evolve`; on the roadmap if they should wait.
- **Improve or modernize the architecture** → `/seny:evolve <change>`. If an area is already **In transition**, finish or continue that evolution first.
- **Not sure a library, device or API can do it** → `/seny:spike <question>`.
- **Design or redesign a screen** → `/seny:plan <slug> design`.
- **Resume after a break** → Mode 1.

If the request is too vague to choose, ask one concrete question.

## Output
**Where you are:** 1–3 lines (project, epic and size, story, document statuses that matter, branch).
**Track:** (Mode 2 only) Direct | Fix | Spike | Light | Epic (S/M/L) | Evolve | Project — and why, in one line.
**Next:** the exact command to run.
**Then:** the following 2–3 steps, briefly.
**Watch out:** only if something needs attention (uncommitted changes on the default branch, a draft that something depends on, blocked stories, open questions, stale baseline, stale or contradicting docs, a lockfile that doesn't match the package manager in the project rules).
