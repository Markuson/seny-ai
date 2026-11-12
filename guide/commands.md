# Command reference

Every Seny command, with the same shape each time: how to call it, when to use it, what it reads and writes, what it asks you, and where it stops. For the ideas behind them, see [concepts](concepts.md).

All commands start by reading the [state snapshot](concepts.md#the-state-snapshot), and none of them ever pushes. `<docs>` means your docs root: `docs/` or `.seny/`. Research, plan and evolve write **one document per run**, through the [document loop](concepts.md#one-document-at-a-time): questions, draft, your review, approval, commit proposal, and the next command after a `/clear`.

| Command | One line |
|---|---|
| [`/seny:init`](#seny-init) | Set Seny up in a project |
| [`/seny:research project …`](#seny-research-project) | Understand the product or the codebase, one document per run |
| [`/seny:research <epic>`](#seny-research-feature) | Understand one epic (sizes M and L) |
| [`/seny:spike`](#seny-spike) | Answer one technical question with throwaway code |
| [`/seny:plan project`](#seny-plan-project) | Architecture, design system, roadmap, foundation, one document per run |
| [`/seny:plan <slug> …`](#seny-plan-feature) | Plan an epic (as deep as its size), design it, change it, or plan a light change |
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
- Shared: `CLAUDE.md` from the template (or a `## Seny` section appended to yours, shown first), `docs/project/` and `docs/epics/` with a `.gitkeep`.
- Private: `.seny/CLAUDE.md`, `.seny/project/`, `.seny/epics/`, a one-line `CLAUDE.local.md` that loads it, and both excluded in `.git/info/exclude`.
- Optionally: your check commands in `.claude/settings.local.json` (merged, shown first, kept out of git), and `~/.claude/CLAUDE.md` / `~/.claude/seny/stack.md` from the templates if you don't have them.

**Never:** overwrites existing content, or migrates anything (package manager, tooling, folders). Things worth changing become candidate epics.

**Next:** `/seny:research project` (existing code) or `/seny:research project <your idea>` (new app).

---

<a name="seny-research-project"></a>

## `/seny:research project …`

**Usage:**
- `/seny:research project <idea>`: a new app (no application code yet) → `product.md`.
- `/seny:research project`: an existing codebase → its next pending document.
- `/seny:research project <document>`: that document (`codebase`, `architecture`, `design-system`).
- `/seny:research project refresh`: do the project docs still match the code?

You can pass a file instead of (or with) the idea: `/seny:research project docs/inputs/brief.md`.

**New app → `product.md`**, with the full interview: vision, users, core needs with priorities, MVP in and out, constraints, references, risks, assumptions and open questions. It's the document everything else builds on, so it takes as many rounds of questions as it needs. Next: `/seny:plan project`.

**Existing code →** one document per run, in this order:
1. **`codebase.md` + `baseline.md`**: four Explore subagents in parallel (stack and structure, data and backend, UI, quality); runs your checks and records the baseline; then `codebase.md` (conventions in practice, coverage map, debt with `file:line`, fragile areas). Asks only what the code can't answer.
2. **`architecture.md`**, as it is, with real versions.
3. **`design-system.md`**, if there's UI: only what really exists; if there's no coherent system, it says so.

Never overwrites an existing `product.md`. When the last one is approved: `/seny:plan project` for a roadmap, `/seny:research <epic>`, or `/seny:evolve <change>`.

**Refresh →** compares the project docs with the code now, re-runs the checks, measures the real progress of every **In transition** row, and lists the differences ("document says / code does", with `file:line`). Updated documents go back to `draft` and through your review.

**Never:** writes code, proposes solutions, presents assumptions as facts, or writes two documents in one run.

---

<a name="seny-research-feature"></a>

## `/seny:research <epic>`

**Usage:** `/seny:research <epic slug, a problem, or a brief file>`

**Use it for** epics of size **M** and **L**. For size S it tells you research isn't needed and points to `/seny:plan <slug>` (it goes on only if you insist).

**Finds** the epic in the roadmap. If it isn't there, proposes a slug, a size and a one-line goal, and asks whether to add it.

**Reads:** the project rules, `architecture.md`, `design-system.md`, the relevant parts of `product.md` and `codebase.md`, the roadmap row, your inputs, and the code the epic touches.

**Writes**, through the document loop: `<docs>/epics/<slug>/research.md`, one page: problem, users and roles, constraints, codebase (what exists, what to reuse, where new code fits, which tests surround it, all with `file:line`), fit with the project, challenges, risks, assumptions and open questions. Keeps any existing `Spike findings`.

**Proposes:** the branch (`feature/<slug>`, or your repo's convention).

**Next:** `/seny:spike <question>` for questions only code can answer, then `/seny:plan <slug>`.

---

<a name="seny-spike"></a>

## `/seny:spike`

**Usage:** `/seny:spike <question> [for <epic slug>]`

**Use it when** a decision depends on something only code can show: can this library, SDK, device or API do X, and how well.

**Steps:**
1. Frames the question: what each answer would change, the evidence that will settle it, a time box (default: this session), the slug and branch. **Waits for your yes.**
2. Creates `spike/<slug>` from your current branch (asks you to commit or stash first if there are uncommitted changes).
3. Tries the smallest code that answers. For hardware or devices, gives you exact steps and asks for the output.
4. Asks you: keep the code (committed on the spike branch as `spike: <question>`, never merged) or discard it. Then switches back.
5. Writes `## Spike findings` in the epic's `research.md`: answer (yes / no / partly / unknown), evidence, what was tried, consequences for the plan, where the code lives.

**Never:** merges spike code, installs anything globally, or guesses a result it couldn't run.

**Next:** `/seny:plan <slug>` (or `/seny:research <slug>` if the epic has no research yet and its size is M or L).

---

<a name="seny-plan-project"></a>

## `/seny:plan project`

**Usage:** `/seny:plan project [architecture | design-system | roadmap | foundation]`

Without a document name it writes the next pending one. One document per run.

**New app** (requires `product.md` approved):
1. **`architecture.md`**: chooses the stack from `~/.claude/seny/stack.md` (or the plugin's example) with a full interview on everything hard to reverse. After approval, fills the Project, Stack, Commands and Product rules placeholders of your project `CLAUDE.md` (shown to you first).
2. **`design-system.md`**, if there's UI: asks whether to do it now; on yes, loads your design skills, offers **two visual directions**, waits for your choice. On no, records `Design system: declined` so nobody asks again.
3. **`roadmap.md`**: the MVP split into **epics** (one branch and one PR each), every one with a type, a **size** (S, M or L), a goal and dependencies; `foundation` first. It asks you about the order and the sizes.
4. **`epics/foundation/plan.md`**, in **two passes**: the shape (goal, scope, decisions, one line per story), then the stories in full. Its last story records an all-green `baseline.md`. Its scope lists capabilities, never the stack again.

When the foundation plan is approved: "Planning is done." Next: `/clear`, then `/seny:implement next`.

**Existing code** (requires `codebase.md` and `architecture.md` approved): only `roadmap.md`, with the epics you want plus the debt items and evolutions you choose, each sized. No foundation.

---

<a name="seny-plan-feature"></a>

## `/seny:plan <slug> …`

**Usage:**
- `/seny:plan <slug>` (or empty: the epic in progress, else the next ready roadmap epic): **Epic mode**.
- `/seny:plan <slug> design`: the design document.
- `/seny:plan <slug> <change>`: **Change mode**, for a plan that already exists.
- `/seny:plan light <change>`: **Light mode**, outside the roadmap.

**Epic mode** writes `<docs>/epics/<slug>/plan.md`, as deep as the epic's size:

| Size | Needs | Passes | Questions |
|---|---|---|---|
| S | the project docs and the roadmap row (no research) | 1 | 0–1 rounds |
| M | `research.md` approved | 1 | 1–2 rounds |
| L | `research.md` approved | 2: shape (`shape approved`), then stories (`approved`), each its own run | 1–2 per pass |

The plan has a goal, scope (in and out, with reasons), architecture changes on top of `architecture.md` (never restating it), key decisions with rejected alternatives, and a **flat list of stories** `S1…Sn`: acceptance criteria, `Tests`, `Verify`, `Depends on`, and an `Approach` anchored to the code unless trivial. If the story count doesn't fit the size, it proposes resizing or splitting. It asks before any app-wide change, and suggests a spike instead of planning around a guess. After approval the roadmap row becomes `in-progress`; next is the design (if there's UI) or `/seny:implement next`.

**Design** (requires the plan approved): loads your design skills, starts from the design system and existing components, offers two directions if there's no system yet, writes `design.md` (only the sections the epic needs), proposes reusable tokens or components for `design-system.md`, and links UI stories to their design sections.

**Change mode:** updates the plan (add, split, reorder, edit or remove `todo` stories; scope, architecture changes, decisions) without touching stories that already started: their status, criteria, review records and ticks are history. The plan goes back to `draft` until you approve the change.

**Light mode:** for a clear change in a few files with no data model, auth, external service or new screens. Reads only the code the change touches and writes a short plan (1–3 stories) with a quick review. Stops and suggests an epic if it turns out bigger.

**Never:** writes code, writes two documents in one run, or resets the status of a story that isn't `todo`. Challenges anything over-engineered and prefers the boring option.

---

<a name="seny-implement"></a>

## `/seny:implement`

**Usage:** `/seny:implement [<epic slug>] <story id> | next [no-review]`

Story ids are `S1`, `S2`… within an epic; add the slug when several epics are in progress (`/seny:implement i18n S2`). `next` is the first `todo` story whose dependencies are all `done`. `no-review` skips the automatic review for this run. The plan must be approved: a draft or a plan with only its shape approved is finished with `/seny:plan` first.

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

**Usage:** `/seny:review [<epic slug>] [story id] [done | git range]`

**Use it when:**
- the review mode is `manual`;
- you changed code by hand after the automatic review and want a fresh look;
- the work is already committed: pass a git range (`main..HEAD`);
- you only want to close a story that was already approved: `/seny:review streaks S2 done` (or just `S2 done`).

**Steps:** finds the story (the id, or the only one in `review`), works out the diff (uncommitted changes plus untracked files, or your range), launches `seny:reviewer`, records the result under the story (nits stay in chat), and hands over:
- **CHANGES REQUESTED** → story back to `in-progress`; next is `/seny:implement <id>`.
- **APPROVED** → shows the `should` findings and the manual checks, and asks whether it's done.
- Either way: E2E tests proposed by the reviewer are shown and wait for your decision; undocumented architecture changes are offered for the project docs.

**Never:** reviews code itself or fixes anything.

### Closing a story

When you confirm "done" (here or at the end of `/seny:implement`):
1. If you want a `should` fixed first, the story goes back to `in-progress`.
2. The story becomes `done`; finished epics are announced.
3. If the whole epic is done: approved app-wide changes are checked in the project docs, the roadmap row becomes `done`, evolutions get their **In transition** row retired (after checking the old pattern is gone), and you get a **PR title and body** ready to paste.
4. A commit message is proposed (repo convention, else `<type>: <description>`, with the story id) and your commit rule applies: commit if you said so, don't if you said not, ask otherwise.
5. Next: `/seny:implement next`, or the next roadmap row after a `/clear`: `/seny:plan <slug>` for size S, `/seny:research <slug>` for M and L, `/seny:evolve <slug>` for an evolution.

---

<a name="seny-fix"></a>

## `/seny:fix`

**Usage:** `/seny:fix <what happens, what should happen, steps, error or log>`

**Use it when** there's a bug outside any plan with a local cause. For a bug in a story that isn't done, use `/seny:implement <slug> <id>` instead.

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

**Stops and escalates** if the cause is bigger than a fix (a design flaw, a migration, auth, many modules): it recommends `/seny:plan light` or a new epic.

**Never:** hides the error (empty catch, optional chaining over something that should exist, a sleep for a race) or refactors what the bug doesn't need.

---

<a name="seny-evolve"></a>

## `/seny:evolve`

**Usage:** `/seny:evolve <what to change> | <evolution slug>`

**Use it when** you want to change how the app is built without changing what it does.

**Steps:**
1. **Research:** reads `architecture.md` (no second evolution on an area already in transition), `codebase.md` and the baseline; measures the footprint, what depends on it and how well it's tested; for upgrades, reads the official migration guide and changelog and lists the breaking changes that affect your code. Writes the evolution's `research.md` (an evolution is an epic with `Type: evolution`) and stops for your review.
2. **Options** (next run): 2–3 options with effort, risk and reversibility, including "do nothing for now" when it's real, and a recommendation. **Waits for your choice.**
3. **Plan:** writes `plan.md` with `Type: evolution` through the document loop: characterization tests first, measurable slices with `Progress:` lines, cleanup stories last. Proposes the **In transition** row and the decision record for `architecture.md`, and a place in the roadmap, each written after your yes.

Passing an existing slug continues where it stopped (usually at the choice).

**Redirects you** if it's really new behaviour (an epic for the roadmap), a tiny safe change (`/seny:plan light`), or depends on something only code can show (`/seny:spike`).

**Next:** `/clear`, then `/seny:implement <first story>`. Implement keeps the transition's progress up to date.

---

<a name="seny-help"></a>

## `/seny:help`

**Usage:** `/seny:help [what you want to do]`

**Without arguments** it tells you where you are and the one next step, checking in this order: setup missing, a story waiting in `review`, a story `in-progress`, a document still in `draft`, the next pending project document, an epic without an approved plan (research first for sizes M and L), a missing design, the next ready story, blocked stories, the next roadmap epic. It also mentions a stale baseline, stale docs and open transitions.

**With a request** it sizes the work (Direct, Fix, Spike, Light, Epic S/M/L, Evolve or Project), says why in one line, and gives you the exact commands.

**Output:** where you are · track · the next command · the 2–3 steps after it · anything to watch out for.

**Never:** edits files or runs other Seny commands for you. It's read-only by design (the file tools are disabled while it runs).
