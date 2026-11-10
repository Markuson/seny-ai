# Command reference

Every Seny command, with the same shape each time: how to call it, when to use it, what it reads and writes, what it asks you, and where it stops. For the ideas behind them, see [concepts](concepts.md).

All commands start by reading the [state snapshot](concepts.md#the-state-snapshot), and none of them ever pushes. `<docs>` means your docs root: `docs/` or `.seny/`.

| Command | One line |
|---|---|
| [`/seny:init`](#seny-init) | Set Seny up in a project |
| [`/seny:research project …`](#seny-research-project) | Understand the product or the codebase, record the baseline |
| [`/seny:research <feature>`](#seny-research-feature) | Understand one feature |
| [`/seny:spike`](#seny-spike) | Answer one technical question with throwaway code |
| [`/seny:plan project`](#seny-plan-project) | Architecture, design system, roadmap, foundation |
| [`/seny:plan <slug> …`](#seny-plan-feature) | Plan, design, change or lightly plan a feature |
| [`/seny:implement`](#seny-implement) | Build one story and get it reviewed |
| [`/seny:review`](#seny-review) | Review again, or close an approved story |
| [`/seny:fix`](#seny-fix) | Fix a bug outside any plan |
| [`/seny:evolve`](#seny-evolve) | Change how the app is built, step by step |
| [`/seny:help`](#seny-help) | Where am I, what next, how much process |

---

<a name="seny-init"></a>

## `/seny:init`

**Usage:** `/seny:init [notes about the project]`

**Use it when** you start using Seny in a project, new or existing. Once per repo.

**Reads:** existing instructions (`CLAUDE.md` at any level, `AGENTS.md`, `.claude/`, `README.md`, `CONTRIBUTING.md`, decision records), every `package.json` and its scripts, the lockfile, `git log` (commit style), branches, PR template and CI workflows.

**Asks you, in one batch:**
- Shared docs (`docs/`, committed) or private docs (`.seny/`, invisible to git).
- Your package manager, only if the lockfile doesn't match the one in your personal rules.
- To confirm the detected stack, commands and conventions (the repo's conventions win over yours).
- In a monorepo with different stacks: a `CLAUDE.md` per package?
- Review mode: `auto` (recommended) or `manual`.

**Writes:**
- Shared: `CLAUDE.md` from the template (or a `## Seny` section appended to yours, shown first), `docs/project/` and `docs/features/` with a `.gitkeep`.
- Private: `.seny/CLAUDE.md`, `.seny/project/`, `.seny/features/`, a one-line `CLAUDE.local.md` that loads it, and both excluded in `.git/info/exclude`.
- Optionally: your check commands in `.claude/settings.local.json` (merged, shown first, kept out of git), and `~/.claude/CLAUDE.md` / `~/.claude/seny/stack.md` from the templates if you don't have them.

**Never:** overwrites existing content, or migrates anything (package manager, tooling, folders). Things worth changing become candidate features.

**Next:** `/seny:research project` (existing code) or `/seny:research project <your idea>` (new app).

---

<a name="seny-research-project"></a>

## `/seny:research project …`

**Usage:**
- `/seny:research project <idea>`: a new app (no application code yet).
- `/seny:research project`: an existing codebase.
- `/seny:research project refresh`: do the project docs still match the code?

You can pass a file instead of (or with) the idea: `/seny:research project docs/inputs/brief.md`.

**New app → writes `product.md`:** vision, users, core needs, MVP, constraints, references, risks, assumptions and open questions. Updates it if it exists.

**Existing code →** four Explore subagents in parallel (stack and structure, data and backend, UI, quality), then:
- runs your checks and writes `baseline.md`;
- writes `architecture.md` (as it is), `design-system.md` (only what really exists; if there's no coherent system, it says so), `codebase.md` (conventions in practice, coverage map, debt with `file:line`, fragile areas) and an empty `roadmap.md` (or the features you mentioned);
- never overwrites an existing `product.md`.

**Refresh →** compares the project docs with the code now, re-runs the checks, measures the real progress of every **In transition** row, and lists the differences ("document says / code does", with `file:line`). Updates the docs only after your yes.

**Asks you:** everything that blocks its understanding, in one batch. For existing code, the questions the code can't answer ("there are two fetch patterns; which one is intended?").

**Never:** writes code, proposes solutions, or presents assumptions as facts. Every fact cites its source.

**Next:** new app → `/seny:plan project`. Existing code → `/seny:research <first feature>`, `/seny:evolve <change>`, or `/seny:plan project` for a roadmap.

---

<a name="seny-research-feature"></a>

## `/seny:research <feature>`

**Usage:** `/seny:research <a feature, a problem, or a brief file>`

**Use it when** the change is a **Feature**: several stories, open questions, new UI, or any risk signal.

**Reads:** the project rules, `architecture.md`, `design-system.md`, the relevant parts of `product.md` and `codebase.md`, your inputs, and the code the feature touches.

**Writes:** `<docs>/features/<slug>/research.md`, one page: problem, users and roles, constraints, codebase (what exists, what to reuse, where new code fits, which tests surround it, all with `file:line`), fit with the project, challenges, risks, assumptions and open questions. Keeps any existing `Spike findings`.

**Proposes:** a kebab-case slug and a branch (`feature/<slug>`, or your repo's convention).

**Stops** with a 5-line summary and the open questions. Questions only code can answer are marked for a spike.

**Next:** `/seny:spike <question>` if needed, then `/seny:plan <slug>`.

---

<a name="seny-spike"></a>

## `/seny:spike`

**Usage:** `/seny:spike <question> [for <feature slug>]`

**Use it when** a decision depends on something only code can show: can this library, SDK, device or API do X, and how well.

**Steps:**
1. Frames the question: what each answer would change, the evidence that will settle it, a time box (default: this session), the slug and branch. **Waits for your yes.**
2. Creates `spike/<slug>` from your current branch (asks you to commit or stash first if there are uncommitted changes).
3. Tries the smallest code that answers. For hardware or devices, gives you exact steps and asks for the output.
4. Asks you: keep the code (committed on the spike branch as `spike: <question>`, never merged) or discard it. Then switches back.
5. Writes `## Spike findings` in the feature's `research.md`: answer (yes / no / partly / unknown), evidence, what was tried, consequences for the plan, where the code lives.

**Never:** merges spike code, installs anything globally, or guesses a result it couldn't run.

**Next:** `/seny:plan <slug>` (or `/seny:research <slug>` if the feature has no research yet).

---

<a name="seny-plan-project"></a>

## `/seny:plan project`

**Usage:** `/seny:plan project [extra guidance]`

**Requires:** `product.md` (new app) or `codebase.md` (existing code).

**Existing code →** writes or updates `roadmap.md` only: the features you want, in order, plus the debt items and evolutions you choose from `codebase.md`, each typed `feature` or `evolution`. No foundation; the architecture isn't rewritten.

**New app →**
1. Chooses the stack from `~/.claude/seny/stack.md` (or the plugin's example), asking about anything hard to reverse.
2. Writes `architecture.md`, `roadmap.md` (MVP features in order, `foundation` first) and `features/foundation/plan.md`: scaffold, strict types, lint/typecheck/test wired, theme, base layout or navigation, CI if wanted, a placeholder deploy, and a last story that records an all-green `baseline.md`.
3. Gives you the architecture in 5 lines, the roadmap, the foundation stories and the 2–3 decisions it's least sure about.
4. If there's UI, asks whether to write the design system now: on yes, loads your design skills, offers **two visual directions** and waits for your choice, then writes `design-system.md`. On no, records the decision so nobody asks again.

**Next:** `/clear`, then `/seny:implement next`.

---

<a name="seny-plan-feature"></a>

## `/seny:plan <slug> …`

**Usage:**
- `/seny:plan <slug>` (or empty, if only one feature has research and no plan): **Feature mode**.
- `/seny:plan <slug> design`: only the design document.
- `/seny:plan <slug> <change>`: **Change mode**, for a plan that already exists.
- `/seny:plan light <change>`: **Light mode**, no research needed.

**Feature mode, step 1 (plan):** reads the research (including spike findings), the project rules and docs, and writes `plan.md`: goal, scope (in and out, with reasons), architecture changes on top of `architecture.md`, key decisions with rejected alternatives, and epics of small vertical stories. Every story gets acceptance criteria, `Tests`, `Verify`, `Depends on`, and an `Approach` anchored to the code unless it's trivial. Sets the feature to `in-progress` in the roadmap. Asks before any app-wide change. If an open question can only be answered by code, suggests a spike instead of planning around a guess.

**Feature mode, step 2 (design, if there's UI and you say yes):** loads your design skills, starts from the design system and existing components, offers two directions if there's no system yet, writes `design.md` (only the sections the feature needs), proposes reusable tokens or components for `design-system.md`, and links UI stories to their design sections.

**Change mode:** updates the plan (add, split, reorder or edit stories; scope, architecture changes and decisions) without touching stories that already started: their status, criteria, review records and ticks are history. If the change affects one of them, it adds a new story and tells you why. Suggests going back to research if the change needs new understanding.

**Light mode:** for a clear change in a few files with no data model, auth, external service or new screens. Reads only the code the change touches and writes a short plan: branch, goal, scope, one epic with 1–3 stories. Stops and sends you to research if it turns out bigger.

**Never:** writes code, or resets the status of a story that isn't `todo`. Challenges anything over-engineered and prefers the boring option.

**Next:** `/clear`, then `/seny:implement next` (or the first story it names).

---

<a name="seny-implement"></a>

## `/seny:implement`

**Usage:** `/seny:implement <story id> | next [no-review]`

`next` is the first `todo` story whose dependencies are all `done`. `no-review` skips the automatic review for this run.

**Steps:**
1. **Checks the story.** `todo` → starts. `in-progress` with review findings → a fix round, findings first. `in-progress` with `Notes:` → resumes from them. `review` or `done` → tells you and stops. A dependency not done → warns and waits.
2. **Clean start.** On the default branch, proposes the plan's branch and waits. Uncommitted changes that aren't this story's → asks you to commit or stash them, so the review sees one story.
3. **Baseline.** If it's missing or stale (and the project has checks), runs them on a clean tree and records a fresh `baseline.md`, telling you what changed.
4. **Reads what the story builds on:** its `Approach`, `Files` and `Verify`, then `architecture.md` (and the rule for new code of any area **In transition**), the design system and design section for UI stories, and the baseline.
5. **Characterization tests** first if it changes untested code.
6. **Builds** per the `Tests` mode: `tdd` (red, shown to fail for the right reason → green → refactor), `after`, or `none`.
7. **Runs the checks** against the baseline. Only new failures block. Two attempts at fixing a failure, then it stops and shows you the error.
8. **Updates the plan:** ticks criteria and fixed findings, removes `Notes`, updates evolution progress. Status → `review`.
9. **Review** (mode `auto`): runs the [review loop](concepts.md#reviews) with one fix round. Mode `manual`: tells you to run `/seny:review`.
10. **Reports** what changed and why, checks vs baseline, the verdict, and what to check by hand. Asks whether the story is done.

When you say yes, it [closes the story](#closing-a-story).

**If the context gets heavy** mid-story, it writes `Notes:` under the story and asks you to `/clear` and run the same command again.

**Never:** works on two stories, goes outside the story's scope (it proposes a plan change instead), adds a dependency without asking, edits a characterization test to make it pass, or marks a story `done`.

---

<a name="seny-review"></a>

## `/seny:review`

**Usage:** `/seny:review [story id] [done | git range]`

**Use it when:**
- the review mode is `manual`;
- you changed code by hand after the automatic review and want a fresh look;
- the work is already committed: pass a git range (`main..HEAD`);
- you only want to close a story that was already approved: `/seny:review E1-S2 done`.

**Steps:** finds the story (the id, or the only one in `review`), works out the diff (uncommitted changes plus untracked files, or your range), launches `seny:reviewer`, records the result under the story (nits stay in chat), and hands over:
- **CHANGES REQUESTED** → story back to `in-progress`; next is `/seny:implement <id>`.
- **APPROVED** → shows the `should` findings and the manual checks, and asks whether it's done.
- Either way: E2E tests proposed by the reviewer are shown and wait for your decision; undocumented architecture changes are offered for the project docs.

**Never:** reviews code itself or fixes anything.

### Closing a story

When you confirm "done" (here or at the end of `/seny:implement`):
1. If you want a `should` fixed first, the story goes back to `in-progress`.
2. The story becomes `done`; finished epics are announced.
3. If the whole feature is done: approved app-wide changes are checked in the project docs, the roadmap row becomes `done`, evolutions get their **In transition** row retired (after checking the old pattern is gone), and you get a **PR title and body** ready to paste.
4. A commit message is proposed (repo convention, else `<type>: <description>`, with the story id) and your commit rule applies: commit if you said so, don't if you said not, ask otherwise.
5. Next: `/seny:implement next`, or the next roadmap row (`/seny:research` for a feature, `/seny:evolve` for an evolution), after a `/clear`.

---

<a name="seny-fix"></a>

## `/seny:fix`

**Usage:** `/seny:fix <what happens, what should happen, steps, error or log>`

**Use it when** there's a bug outside any plan with a local cause. For a bug in a story that isn't done, use `/seny:implement <id>` instead.

**Steps:**
1. Restates the bug (actual vs expected). Asks for anything missing to reproduce it.
2. Proposes a `fix/…` branch if you're on the default branch; asks to commit or stash unrelated changes.
3. Refreshes a missing or stale baseline.
4. **Reproduces** it: characterization tests if the code has none, then a test that fails because of the bug, shown to fail for the right reason. If it can't be a unit or integration test, gives you manual steps and proposes an E2E test.
5. Explains the **root cause** in 2–3 lines with `file:line`.
6. Applies the **minimal fix**.
7. Runs the checks against the baseline.
8. **Looks around** for the same mistake elsewhere; offers to record what it finds as debt in `codebase.md`.
9. **Review** by `seny:reviewer` (up to two fix rounds).
10. Reports cause, fix, test, checks, verdict, manual checks and a commit message (`fix: …`), then applies your commit rule.

**Stops and escalates** if the cause is bigger than a fix (a design flaw, a migration, auth, many modules): it recommends `/seny:plan light` or `/seny:research`.

**Never:** hides the error (empty catch, optional chaining over something that should exist, a sleep for a race) or refactors what the bug doesn't need.

---

<a name="seny-evolve"></a>

## `/seny:evolve`

**Usage:** `/seny:evolve <what to change> | <evolution slug>`

**Use it when** you want to change how the app is built without changing what it does.

**Steps:**
1. **Research:** reads `architecture.md` (no second evolution on an area already in transition), `codebase.md` and the baseline; measures the footprint, what depends on it and how well it's tested; for upgrades, reads the official migration guide and changelog and lists the breaking changes that affect your code. Writes the evolution's `research.md`.
2. **Options:** 2–3 options with effort, risk and reversibility, including "do nothing for now" when it's real, and a recommendation. **Waits for your choice.**
3. **Plan:** writes `plan.md` with `Type: evolution`: characterization tests first, measurable slices with `Progress:` lines, a cleanup epic. Proposes the **In transition** row and the decision record for `architecture.md`, and a place in the roadmap, each written after your yes.

Passing an existing slug continues where it stopped (usually at the choice).

**Redirects you** if it's really a feature (`/seny:research`), a tiny safe change (`/seny:plan light`), or depends on something only code can show (`/seny:spike`).

**Next:** `/clear`, then `/seny:implement <first story>`. Implement keeps the transition's progress up to date.

---

<a name="seny-help"></a>

## `/seny:help`

**Usage:** `/seny:help [what you want to do]`

**Without arguments** it tells you where you are and the one next step, checking in this order: setup missing, a story waiting in `review`, a story `in-progress`, project research or plan missing, the design-system decision missing, a feature without plan or design, the next ready story, blocked stories, the next roadmap row. It also mentions a stale baseline, stale docs and open transitions.

**With a request** it sizes the work (Direct, Fix, Spike, Light, Feature, Evolve or Project), says why in one line, and gives you the exact commands.

**Output:** where you are · track · the next command · the 2–3 steps after it · anything to watch out for.

**Never:** edits files or runs other Seny commands for you. It's read-only by design (the file tools are disabled while it runs).
